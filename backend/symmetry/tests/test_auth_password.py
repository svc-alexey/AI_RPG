"""Tests for forgot-password, reset-password, and change-password flows."""

import hashlib
from datetime import UTC, datetime, timedelta

import pytest
from fastapi import HTTPException

from app.db.models import PasswordResetToken, User
from app.services.auth import AuthService
from app.core.security import hash_password, verify_password


class _PasswordFakeSession:
    def __init__(self) -> None:
        self.items = []
        self.committed = False
        self.scalar_results = []
        self.records = {}
        self.user = None

    def add(self, item) -> None:
        self.items.append(item)

    async def commit(self) -> None:
        self.committed = True

    async def scalar(self, _query):
        if not self.scalar_results:
            return None
        return self.scalar_results.pop(0)

    async def get(self, model, key):
        if model == User:
            return self.user
        return None

    def seed_scalar(self, *results):
        self.scalar_results = list(results)


@pytest.mark.asyncio
async def test_forgot_password_existing_email_creates_token():
    service = AuthService()
    session = _PasswordFakeSession()

    user = User(
        id="u1",
        email="test@example.com",
        password_hash=hash_password("oldpass"),
        is_active=True,
        is_admin=False,
        email_verified=True,
    )
    session.user = user
    session.scalar_results = [user]

    await service.forgot_password(
        session, email="test@example.com", accept_language=""
    )

    assert session.committed is True
    token_items = [i for i in session.items if isinstance(i, PasswordResetToken)]
    assert len(token_items) == 1
    assert token_items[0].user_id == "u1"


@pytest.mark.asyncio
async def test_forgot_password_nonexistent_email_returns_silently():
    service = AuthService()
    session = _PasswordFakeSession()
    session.scalar_results = [None]

    await service.forgot_password(
        session, email="noone@example.com", accept_language=""
    )

    # No exception, no commit
    assert session.committed is False
    token_items = [i for i in session.items if isinstance(i, PasswordResetToken)]
    assert len(token_items) == 0


@pytest.mark.asyncio
async def test_reset_password_valid_token_changes_password():
    service = AuthService()
    session = _PasswordFakeSession()

    raw_token = "a" * 32
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    db_token = PasswordResetToken(
        id="rt1",
        user_id="u1",
        token_hash=token_hash,
        expires_at=datetime.now(UTC) + timedelta(minutes=15),
    )
    user = User(
        id="u1",
        email="test@example.com",
        password_hash=hash_password("oldpass"),
        is_active=True,
        is_admin=False,
        email_verified=True,
    )
    session.user = user
    session.scalar_results = [db_token]

    result = await service.reset_password(
        session, token=raw_token, new_password="newpass123"
    )

    assert result.id == "u1"
    assert verify_password("newpass123", user.password_hash) is True
    assert db_token.consumed_at is not None
    assert session.committed is True


@pytest.mark.asyncio
async def test_reset_password_invalid_token():
    service = AuthService()
    session = _PasswordFakeSession()
    session.scalar_results = [None]

    with pytest.raises(HTTPException) as exc:
        await service.reset_password(
            session, token="invalid", new_password="newpass123"
        )
    assert exc.value.detail == "invalid_reset_token"


@pytest.mark.asyncio
async def test_reset_password_expired_token():
    service = AuthService()
    session = _PasswordFakeSession()

    raw_token = "b" * 32
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    db_token = PasswordResetToken(
        id="rt2",
        user_id="u1",
        token_hash=token_hash,
        expires_at=datetime.now(UTC) - timedelta(minutes=1),
    )
    session.scalar_results = [db_token]

    with pytest.raises(HTTPException) as exc:
        await service.reset_password(
            session, token=raw_token, new_password="newpass123"
        )
    assert exc.value.detail == "expired_reset_token"


@pytest.mark.asyncio
async def test_reset_password_already_used_token():
    service = AuthService()
    session = _PasswordFakeSession()

    raw_token = "c" * 32
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    db_token = PasswordResetToken(
        id="rt3",
        user_id="u1",
        token_hash=token_hash,
        expires_at=datetime.now(UTC) + timedelta(minutes=15),
        consumed_at=datetime.now(UTC),
    )
    session.scalar_results = [db_token]

    with pytest.raises(HTTPException) as exc:
        await service.reset_password(
            session, token=raw_token, new_password="newpass123"
        )
    assert exc.value.detail == "reset_token_already_used"


@pytest.mark.asyncio
async def test_change_password_correct_current():
    service = AuthService()
    session = _PasswordFakeSession()

    user = User(
        id="u1",
        email="test@example.com",
        password_hash=hash_password("currentpass"),
        is_active=True,
        is_admin=False,
        email_verified=True,
    )

    await service.change_password(
        session,
        user=user,
        current_password="currentpass",
        new_password="newpass123",
    )

    assert verify_password("newpass123", user.password_hash) is True
    assert session.committed is True


@pytest.mark.asyncio
async def test_change_password_wrong_current():
    service = AuthService()
    session = _PasswordFakeSession()

    user = User(
        id="u1",
        email="test@example.com",
        password_hash=hash_password("rightpass"),
        is_active=True,
        is_admin=False,
        email_verified=True,
    )

    with pytest.raises(HTTPException) as exc:
        await service.change_password(
            session,
            user=user,
            current_password="wrongpass",
            new_password="newpass123",
        )
    assert exc.value.detail == "wrong_current_password"


@pytest.mark.asyncio
async def test_get_reset_token_info_valid():
    service = AuthService()
    session = _PasswordFakeSession()

    raw_token = "d" * 32
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    db_token = PasswordResetToken(
        id="rt4",
        user_id="u1",
        token_hash=token_hash,
        expires_at=datetime.now(UTC) + timedelta(minutes=15),
    )
    session.scalar_results = [db_token]

    info = await service.get_reset_token_info(session, token=raw_token)
    assert info["user_id"] == "u1"


@pytest.mark.asyncio
async def test_get_reset_token_info_expired():
    service = AuthService()
    session = _PasswordFakeSession()

    raw_token = "e" * 32
    token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
    db_token = PasswordResetToken(
        id="rt5",
        user_id="u1",
        token_hash=token_hash,
        expires_at=datetime.now(UTC) - timedelta(minutes=1),
    )
    session.scalar_results = [db_token]

    with pytest.raises(HTTPException) as exc:
        await service.get_reset_token_info(session, token=raw_token)
    assert exc.value.detail == "expired_reset_token"
