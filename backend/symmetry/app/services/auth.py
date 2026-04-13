from datetime import UTC, datetime, timedelta
from urllib.parse import urlencode

import httpx
from fastapi import HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_password,
    hash_refresh_token,
    verify_password,
)
from app.db.models import AuthIdentity, AuthSession, User, UserProfile
from app.schemas.auth import AuthResponse, LoginRequest, RegisterRequest, TokenPair, UserResponse
from app.services.ids import new_id


class AuthService:
    def __init__(self) -> None:
        self._settings = get_settings()

    async def register(
        self, session: AsyncSession, payload: RegisterRequest, request: Request
    ) -> AuthResponse:
        existing = await session.scalar(select(User).where(User.email == payload.email.lower()))
        if existing is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="email_taken")

        user = User(
            id=new_id(),
            email=payload.email.lower(),
            password_hash=hash_password(payload.password),
        )
        profile = UserProfile(
            user_id=user.id,
            display_name=payload.display_name.strip(),
        )
        identity = AuthIdentity(
            id=new_id(),
            user_id=user.id,
            provider="email_password",
            provider_user_id=user.email,
            provider_email=user.email,
        )
        session.add_all([user, profile, identity])
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        return AuthResponse(
            user=UserResponse(id=user.id, email=user.email, display_name=profile.display_name),
            tokens=tokens["response"],
        )

    async def login(
        self, session: AsyncSession, payload: LoginRequest, request: Request
    ) -> AuthResponse:
        user = await session.scalar(select(User).where(User.email == payload.email.lower()))
        if user is None or not verify_password(payload.password, user.password_hash):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="invalid_login")
        profile = await session.get(UserProfile, user.id)
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        return AuthResponse(
            user=UserResponse(
                id=user.id,
                email=user.email,
                display_name=profile.display_name if profile is not None else "",
            ),
            tokens=tokens["response"],
        )

    async def login_guest(
        self, session: AsyncSession, request: Request
    ) -> AuthResponse:
        guest_id = new_id()
        guest_email = f"guest-{guest_id}@symmetry.dev"
        user = User(
            id=guest_id,
            email=guest_email,
            password_hash=hash_password(new_id()),
        )
        profile = UserProfile(
            user_id=user.id,
            display_name="Guest",
        )
        identity = AuthIdentity(
            id=new_id(),
            user_id=user.id,
            provider="guest",
            provider_user_id=user.id,
            provider_email=user.email,
        )
        session.add_all([user, profile, identity])
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        return AuthResponse(
            user=UserResponse(
                id=user.id,
                email=user.email,
                display_name=profile.display_name,
            ),
            tokens=tokens["response"],
        )

    async def refresh(
        self, session: AsyncSession, *, refresh_token: str, request: Request
    ) -> AuthResponse:
        token_hash = hash_refresh_token(refresh_token)
        auth_session = await session.scalar(
            select(AuthSession).where(AuthSession.refresh_token_hash == token_hash)
        )
        if (
            auth_session is None
            or auth_session.revoked_at is not None
            or auth_session.expires_at <= datetime.now(UTC)
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="invalid_refresh_token",
            )
        user = await session.get(User, auth_session.user_id)
        if user is None or not user.is_active:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="user_not_found")

        auth_session.revoked_at = datetime.now(UTC)
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        profile = await session.get(UserProfile, user.id)
        return AuthResponse(
            user=UserResponse(
                id=user.id,
                email=user.email,
                display_name=profile.display_name if profile is not None else "",
            ),
            tokens=tokens["response"],
        )

    async def logout(self, session: AsyncSession, *, refresh_token: str) -> None:
        token_hash = hash_refresh_token(refresh_token)
        auth_session = await session.scalar(
            select(AuthSession).where(AuthSession.refresh_token_hash == token_hash)
        )
        if auth_session is not None and auth_session.revoked_at is None:
            auth_session.revoked_at = datetime.now(UTC)
            await session.commit()

    def build_yandex_authorize_url(self, *, redirect_uri: str | None = None) -> str:
        if not self._settings.yandex_client_id:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        resolved_redirect_uri = (redirect_uri or "").strip() or self._settings.yandex_redirect_uri
        query = urlencode(
            {
                "response_type": "code",
                "client_id": self._settings.yandex_client_id,
                "redirect_uri": resolved_redirect_uri,
            }
        )
        return f"{self._settings.yandex_authorize_url}?{query}"

    def _resolve_yandex_oauth_redirect_uri(self, redirect_uri: str | None) -> str:
        configured = (self._settings.yandex_redirect_uri or "").strip()
        if not configured:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        raw = (redirect_uri or "").strip()
        if not raw:
            return configured
        if raw != configured:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="invalid_yandex_redirect_uri",
            )
        return raw

    async def login_with_yandex(
        self,
        session: AsyncSession,
        *,
        code: str,
        request: Request,
        redirect_uri: str | None = None,
    ) -> AuthResponse:
        if not self._settings.yandex_client_id or not self._settings.yandex_client_secret:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        resolved_redirect_uri = self._resolve_yandex_oauth_redirect_uri(redirect_uri)
        async with httpx.AsyncClient(timeout=30) as client:
            token_response = await client.post(
                self._settings.yandex_token_url,
                data={
                    "grant_type": "authorization_code",
                    "code": code,
                    "client_id": self._settings.yandex_client_id,
                    "client_secret": self._settings.yandex_client_secret,
                    "redirect_uri": resolved_redirect_uri,
                },
            )
            token_response.raise_for_status()
            access_token = token_response.json()["access_token"]
            profile_response = await client.get(
                self._settings.yandex_userinfo_url,
                headers={"Authorization": f"OAuth {access_token}"},
                params={"format": "json"},
            )
            profile_response.raise_for_status()
        yandex_profile = profile_response.json()
        provider_user_id = str(yandex_profile.get("id", "")).strip()
        email = str(yandex_profile.get("default_email", "")).strip().lower()
        if not provider_user_id or not email:
            raise HTTPException(status_code=400, detail="invalid_yandex_profile")

        identity = await session.scalar(
            select(AuthIdentity).where(
                AuthIdentity.provider == "yandex_oauth",
                AuthIdentity.provider_user_id == provider_user_id,
            )
        )
        if identity is not None:
            user = await session.get(User, identity.user_id)
        else:
            user = await session.scalar(select(User).where(User.email == email))
            if user is None:
                user = User(
                    id=new_id(),
                    email=email,
                    password_hash=hash_password(new_id()),
                )
                session.add(user)
                session.add(
                    UserProfile(
                        user_id=user.id,
                        display_name=str(yandex_profile.get("display_name", "")).strip(),
                    )
                )
            session.add(
                AuthIdentity(
                    id=new_id(),
                    user_id=user.id,
                    provider="yandex_oauth",
                    provider_user_id=provider_user_id,
                    provider_email=email,
                )
            )
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        profile = await session.get(UserProfile, user.id)
        return AuthResponse(
            user=UserResponse(
                id=user.id,
                email=user.email,
                display_name=profile.display_name if profile is not None else "",
            ),
            tokens=tokens["response"],
        )

    def _issue_tokens(self, request: Request, user_id: str) -> dict:
        access_token, access_expires_at = create_access_token(user_id)
        refresh_token, refresh_hash = create_refresh_token()
        refresh_expires_at = datetime.now(UTC) + timedelta(
            days=self._settings.refresh_token_ttl_days
        )
        session_row = AuthSession(
            id=new_id(),
            user_id=user_id,
            refresh_token_hash=refresh_hash,
            user_agent=request.headers.get("user-agent", "")[:500],
            ip_address=request.client.host if request.client is not None else "",
            expires_at=refresh_expires_at,
        )
        return {
            "session": session_row,
            "response": TokenPair(
                access_token=access_token,
                access_token_expires_at=access_expires_at,
                refresh_token=refresh_token,
                refresh_token_expires_at=refresh_expires_at,
            ),
        }
