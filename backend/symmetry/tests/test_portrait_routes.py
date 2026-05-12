"""Tests for portrait generation API routes."""

import uuid
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.api.deps import get_current_verified_user
from app.api.routes.portraits import router
from app.db.models import CampaignPortrait, User
from app.db.session import get_db_session
from app.services.portrait_service import (
    PolzaApiError,
    PolzaTimeoutError,
    PortraitResponse,
)


def _make_verified_user() -> User:
    return User(
        id="test-user-id",
        email="test@example.com",
        password_hash="fake-hash",
        is_active=True,
        is_admin=False,
        email_verified=True,
    )


def _make_fake_db():
    db = MagicMock()
    db.execute = AsyncMock(return_value=MagicMock(scalar_one_or_none=lambda: None))
    db.add = MagicMock()
    db.commit = AsyncMock()
    return db


@pytest.fixture
def app():
    app = FastAPI()
    app.include_router(router, prefix="/v1")
    return app


@pytest.fixture
def client(app, monkeypatch):
    async def fake_require(campaign_id, user, db):
        return user, db

    monkeypatch.setattr(
        "app.api.routes.portraits._require_campaign_member",
        fake_require,
    )

    async def override_user():
        return _make_verified_user()

    async def override_db():
        yield _make_fake_db()

    app.dependency_overrides[get_current_verified_user] = override_user
    app.dependency_overrides[get_db_session] = override_db

    return TestClient(app)


def _mock_portrait_service(monkeypatch, generate_side_effect):
    mock_service = MagicMock()
    mock_service.generate_portrait = AsyncMock(side_effect=generate_side_effect)
    mock_service.close = AsyncMock()
    monkeypatch.setattr(
        "app.api.routes.portraits.PortraitService.from_settings",
        lambda db: mock_service,
    )
    return mock_service


def test_post_returns_portrait_on_success(client, monkeypatch):
    campaign_id = str(uuid.uuid4())

    async def fake_generate(*args, **kwargs):
        return PortraitResponse(
            portrait_id="port-123",
            url=f"http://testserver/v1/campaigns/{campaign_id}/portrait/image",
        )

    _mock_portrait_service(monkeypatch, fake_generate)

    response = client.post(
        f"/v1/campaigns/{campaign_id}/portrait",
        json={
            "character_name": "Hero",
            "race": "human",
            "class": "warrior",
            "gender": "male",
            "personality": "brave",
            "prompt_fragment": "",
            "story_context": "",
            "setting": "romantasy",
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["portrait_id"] == "port-123"
    assert "portrait/image" in data["portrait_url"]


def test_post_returns_502_on_timeout(client, monkeypatch):
    campaign_id = str(uuid.uuid4())

    async def fake_generate(*args, **kwargs):
        raise PolzaTimeoutError("timeout")

    _mock_portrait_service(monkeypatch, fake_generate)

    response = client.post(
        f"/v1/campaigns/{campaign_id}/portrait",
        json={
            "character_name": "Hero",
            "race": "human",
            "class": "warrior",
            "gender": "male",
            "personality": "",
            "prompt_fragment": "",
            "story_context": "",
            "setting": "romantasy",
        },
    )

    assert response.status_code == 502


def test_post_returns_502_on_api_error(client, monkeypatch):
    campaign_id = str(uuid.uuid4())

    async def fake_generate(*args, **kwargs):
        raise PolzaApiError("api error")

    _mock_portrait_service(monkeypatch, fake_generate)

    response = client.post(
        f"/v1/campaigns/{campaign_id}/portrait",
        json={
            "character_name": "Hero",
            "race": "human",
            "class": "warrior",
            "gender": "male",
            "personality": "",
            "prompt_fragment": "",
            "story_context": "",
            "setting": "romantasy",
        },
    )

    assert response.status_code == 502


def test_guest_gets_403(app, monkeypatch):
    async def guest_raise():
        from fastapi import HTTPException
        raise HTTPException(status_code=403)

    async def fake_require(campaign_id, user, db):
        return user, db

    monkeypatch.setattr(
        "app.api.routes.portraits._require_campaign_member",
        fake_require,
    )

    async def override_db():
        yield _make_fake_db()

    app.dependency_overrides[get_current_verified_user] = guest_raise
    app.dependency_overrides[get_db_session] = override_db

    client = TestClient(app)
    campaign_id = str(uuid.uuid4())

    response = client.post(
        f"/v1/campaigns/{campaign_id}/portrait",
        json={
            "character_name": "Hero",
            "race": "human",
            "class": "warrior",
            "gender": "male",
            "personality": "",
            "prompt_fragment": "",
            "story_context": "",
            "setting": "romantasy",
        },
    )

    assert response.status_code == 403
    app.dependency_overrides.clear()


def test_get_returns_webp(app):
    campaign_id = str(uuid.uuid4())

    portrait = CampaignPortrait(
        id="port-1",
        campaign_id=campaign_id,
        image_webp=b"fake-webp-bytes",
        prompt_used="test",
        model_used="test-model",
    )

    fake_db = _make_fake_db()

    class _Result:
        def scalar_one_or_none(self):
            return portrait

    fake_db.execute = AsyncMock(return_value=_Result())

    async def override_db():
        yield fake_db

    app.dependency_overrides[get_db_session] = override_db

    client = TestClient(app)

    response = client.get(f"/v1/campaigns/{campaign_id}/portrait/image")

    assert response.status_code == 200
    assert response.content == b"fake-webp-bytes"
    assert response.headers["content-type"] == "image/webp"
    assert "max-age=86400" in response.headers["cache-control"]
    app.dependency_overrides.clear()


def test_get_returns_404_when_no_portrait(app):
    fake_db = _make_fake_db()

    class _EmptyResult:
        def scalar_one_or_none(self):
            return None

    fake_db.execute = AsyncMock(return_value=_EmptyResult())

    async def override_db():
        yield fake_db

    app.dependency_overrides[get_db_session] = override_db

    client = TestClient(app)
    campaign_id = str(uuid.uuid4())

    response = client.get(f"/v1/campaigns/{campaign_id}/portrait/image")

    assert response.status_code == 404
    app.dependency_overrides.clear()
