import pytest
from fastapi import Request
from starlette.datastructures import Headers

from app.services.auth import AuthService


class _FakeSession:
    def __init__(self) -> None:
        self.items = []
        self.committed = False

    def add(self, item) -> None:
        self.items.append(item)

    def add_all(self, items) -> None:
        self.items.extend(items)

    async def commit(self) -> None:
        self.committed = True


def _request() -> Request:
    return Request(
        {
            "type": "http",
            "headers": Headers({"user-agent": "pytest"}).raw,
            "client": ("127.0.0.1", 12345),
        }
    )


@pytest.mark.asyncio
async def test_guest_login_creates_session_and_guest_user():
    service = AuthService()
    session = _FakeSession()

    response = await service.login_guest(session, _request())

    assert response.user.display_name == "Guest"
    assert response.user.email.endswith("@symmetry.dev")
    assert response.tokens.access_token
    assert response.tokens.refresh_token
    assert session.committed is True
    assert len(session.items) == 4
