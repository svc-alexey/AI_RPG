from datetime import UTC, datetime, timedelta
from urllib.parse import parse_qs, urlparse

import pytest
from fastapi import HTTPException, Request
from jose import jwt
from starlette.datastructures import Headers

from app.core.config import get_settings
from app.db.models import AuthHandoff, AuthIdentity, User, UserProfile
from app.services.auth import AuthService


class _FakeSession:
    def __init__(self) -> None:
        self.items = []
        self.committed = False
        self.scalar_results = []
        self.records = {}

    def add(self, item) -> None:
        self.items.append(item)

    def add_all(self, items) -> None:
        self.items.extend(items)

    async def commit(self) -> None:
        self.committed = True

    async def get(self, model, key):
        return self.records.get((model, key))

    async def scalar(self, _query):
        if not self.scalar_results:
            return None
        return self.scalar_results.pop(0)

    def seed(self, model, key, value) -> None:
        self.records[(model, key)] = value


def _request() -> Request:
    return Request(
        {
            "type": "http",
            "headers": Headers({"user-agent": "pytest"}).raw,
            "client": ("127.0.0.1", 12345),
        }
    )


@pytest.fixture
def configured_auth(monkeypatch):
    monkeypatch.setenv("SYMMETRY_JWT_SECRET", "test-secret")
    monkeypatch.setenv("SYMMETRY_JWT_ALGORITHM", "HS256")
    monkeypatch.setenv("SYMMETRY_YANDEX_CLIENT_ID", "client-id")
    monkeypatch.setenv("SYMMETRY_YANDEX_CLIENT_SECRET", "client-secret")
    monkeypatch.setenv(
        "SYMMETRY_YANDEX_REDIRECT_URI",
        "http://127.0.0.1:8080/v1/auth/yandex/callback",
    )
    monkeypatch.setenv("SYMMETRY_WEB_PUBLIC_ORIGIN", "http://127.0.0.1:3010")
    monkeypatch.setenv("SYMMETRY_YANDEX_OAUTH_STATE_TTL_SECONDS", "300")
    monkeypatch.setenv("SYMMETRY_YANDEX_OAUTH_HANDOFF_TTL_SECONDS", "300")
    get_settings.cache_clear()
    yield AuthService()
    get_settings.cache_clear()


def test_build_yandex_authorize_url_uses_backend_callback_and_signed_state(
    configured_auth: AuthService,
):
    authorize_url = configured_auth.build_yandex_authorize_url()

    parsed = urlparse(authorize_url)
    query = parse_qs(parsed.query)

    assert parsed.scheme == "https"
    assert parsed.netloc == "oauth.yandex.ru"
    assert query["response_type"] == ["code"]
    assert query["client_id"] == ["client-id"]
    assert query["redirect_uri"] == ["http://127.0.0.1:8080/v1/auth/yandex/callback"]

    state_payload = configured_auth._decode_yandex_oauth_state(query["state"][0])
    assert state_payload["web_origin"] == "http://127.0.0.1:3010"


def test_invalid_yandex_state_is_rejected(configured_auth: AuthService):
    with pytest.raises(HTTPException) as exc_info:
        configured_auth._decode_yandex_oauth_state("broken-state")

    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "invalid_yandex_state"


def test_expired_yandex_state_is_rejected(configured_auth: AuthService):
    settings = get_settings()
    expired_state = jwt.encode(
        {
            "purpose": "yandex_oauth_state",
            "web_origin": "http://127.0.0.1:3010",
            "exp": datetime.now(UTC) - timedelta(seconds=5),
        },
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )

    with pytest.raises(HTTPException) as exc_info:
        configured_auth._decode_yandex_oauth_state(expired_state)

    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "expired_yandex_state"


@pytest.mark.asyncio
async def test_yandex_callback_redirects_back_with_handoff(
    configured_auth: AuthService,
    monkeypatch,
):
    session = _FakeSession()
    state = configured_auth._create_yandex_oauth_state(
        web_origin="http://127.0.0.1:3010"
    )

    async def _exchange(*, code: str) -> dict:
        assert code == "oauth-code"
        return {
            "id": "ya-user",
            "default_email": "user@example.com",
            "display_name": "Example",
        }

    async def _resolve(_session, _profile) -> User:
        return User(
            id="user-1",
            email="user@example.com",
            password_hash="hash",
            is_active=True,
        )

    monkeypatch.setattr(configured_auth, "_exchange_yandex_code_for_profile", _exchange)
    monkeypatch.setattr(configured_auth, "_resolve_or_create_yandex_user", _resolve)
    monkeypatch.setattr(
        configured_auth,
        "_create_auth_handoff",
        lambda _session, user_id: "handoff-123",
    )

    response = await configured_auth.handle_yandex_callback(
        session,
        code="oauth-code",
        state=state,
    )

    assert session.committed is True
    assert response.status_code == 302
    assert response.headers["location"] == (
        "http://127.0.0.1:3010/?handoff=handoff-123&autostart=1"
    )


@pytest.mark.asyncio
async def test_complete_yandex_handoff_is_single_use(configured_auth: AuthService):
    session = _FakeSession()
    handoff = AuthHandoff(
        id="handoff-1",
        user_id="user-1",
        provider="yandex_oauth",
        expires_at=datetime.now(UTC) + timedelta(minutes=5),
    )
    user = User(
        id="user-1",
        email="user@example.com",
        password_hash="hash",
        is_active=True,
    )
    profile = UserProfile(user_id="user-1", display_name="Example")
    session.seed(AuthHandoff, "handoff-1", handoff)
    session.seed(User, "user-1", user)
    session.seed(UserProfile, "user-1", profile)

    response = await configured_auth.complete_yandex_handoff(
        session,
        handoff_id="handoff-1",
        request=_request(),
    )

    assert response.user.email == "user@example.com"
    assert response.tokens.access_token
    assert handoff.consumed_at is not None
    assert session.committed is True

    with pytest.raises(HTTPException) as exc_info:
        await configured_auth.complete_yandex_handoff(
            session,
            handoff_id="handoff-1",
            request=_request(),
        )

    assert exc_info.value.status_code == 401
    assert exc_info.value.detail == "invalid_yandex_handoff"


@pytest.mark.asyncio
async def test_expired_yandex_handoff_is_rejected(configured_auth: AuthService):
    session = _FakeSession()
    session.seed(
        AuthHandoff,
        "handoff-expired",
        AuthHandoff(
            id="handoff-expired",
            user_id="user-1",
            provider="yandex_oauth",
            expires_at=datetime.now(UTC) - timedelta(seconds=5),
        ),
    )

    with pytest.raises(HTTPException) as exc_info:
        await configured_auth.complete_yandex_handoff(
            session,
            handoff_id="handoff-expired",
            request=_request(),
        )

    assert exc_info.value.status_code == 401
    assert exc_info.value.detail == "expired_yandex_handoff"


@pytest.mark.asyncio
async def test_yandex_identity_links_existing_email_account(
    configured_auth: AuthService,
):
    existing_user = User(
        id="user-existing",
        email="user@example.com",
        password_hash="hash",
        is_active=True,
    )
    session = _FakeSession()
    session.scalar_results = [None, existing_user]

    resolved = await configured_auth._resolve_or_create_yandex_user(
        session,
        {
            "id": "ya-user",
            "default_email": "user@example.com",
            "display_name": "Example",
        },
    )

    assert resolved is existing_user
    assert any(
        isinstance(item, AuthIdentity)
        and item.user_id == "user-existing"
        and item.provider == "yandex_oauth"
        for item in session.items
    )
