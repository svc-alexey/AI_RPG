import asyncio
import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from urllib.parse import urlencode

import httpx
from jose import ExpiredSignatureError, JWTError, jwt
from fastapi import HTTPException, Request, status
from fastapi.responses import RedirectResponse
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
from app.db.models import (
    AuthHandoff,
    AuthIdentity,
    AuthSession,
    EmailVerificationToken,
    User,
    UserProfile,
)
from app.schemas.auth import AuthResponse, LoginRequest, RegisterRequest, TokenPair, UserResponse
from app.services.email_service import send_verification_email
from app.services.ids import new_id
from app.core.logging import get_logger


def user_response_from_models(*, user: User, display_name: str) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        display_name=display_name,
        is_admin=bool(user.is_admin),
        email_verified=bool(user.email_verified),
    )


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
            is_active=True,
            is_admin=False,
            email_verified=False,
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
        raw_token, _ = await self._create_verification_token(session, user.id)
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()

        asyncio.create_task(
            self._send_verification_email_async(
                user_email=user.email,
                token=raw_token,
                accept_language=request.headers.get("Accept-Language", ""),
            )
        )

        return AuthResponse(
            user=user_response_from_models(
                user=user,
                display_name=profile.display_name,
            ),
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
            user=user_response_from_models(
                user=user,
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
            is_active=True,
            is_admin=False,
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
            user=user_response_from_models(
                user=user,
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
            user=user_response_from_models(
                user=user,
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

    def build_yandex_authorize_url(self) -> str:
        backend_redirect_uri = self._require_yandex_backend_redirect_uri()
        web_origin = self._require_web_public_origin()
        if not self._settings.yandex_client_id or not self._settings.yandex_client_secret:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        state = self._create_yandex_oauth_state(web_origin=web_origin)
        query = urlencode(
            {
                "response_type": "code",
                "client_id": self._settings.yandex_client_id,
                "redirect_uri": backend_redirect_uri,
                "state": state,
            }
        )
        return f"{self._settings.yandex_authorize_url}?{query}"

    async def handle_yandex_callback(
        self,
        session: AsyncSession,
        *,
        code: str,
        state: str,
    ) -> RedirectResponse:
        state_payload = self._decode_yandex_oauth_state(state)
        web_origin = str(state_payload["web_origin"])
        if not code:
            return self._build_yandex_completion_redirect(
                web_origin=web_origin,
                error_code="missing_code",
            )

        try:
            yandex_profile = await self._exchange_yandex_code_for_profile(code=code)
            user = await self._resolve_or_create_yandex_user(session, yandex_profile)
            handoff_id = self._create_auth_handoff(session, user_id=user.id)
            await session.commit()
        except HTTPException as exc:
            detail = exc.detail if isinstance(exc.detail, str) else "provider_auth_failed"
            return self._build_yandex_completion_redirect(
                web_origin=web_origin,
                error_code=detail,
            )
        except httpx.HTTPError:
            return self._build_yandex_completion_redirect(
                web_origin=web_origin,
                error_code="provider_auth_failed",
            )

        return self._build_yandex_completion_redirect(
            web_origin=web_origin,
            handoff_id=handoff_id,
        )

    async def complete_yandex_handoff(
        self,
        session: AsyncSession,
        *,
        handoff_id: str,
        request: Request,
    ) -> AuthResponse:
        handoff = await session.get(AuthHandoff, handoff_id)
        if handoff is None or handoff.provider != "yandex_oauth":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="invalid_yandex_handoff",
            )
        now = datetime.now(UTC)
        if handoff.consumed_at is not None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="invalid_yandex_handoff",
            )
        if handoff.expires_at <= now:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="expired_yandex_handoff",
            )
        user = await session.get(User, handoff.user_id)
        if user is None or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="user_not_found",
            )
        handoff.consumed_at = now
        tokens = self._issue_tokens(request, user.id)
        session.add(tokens["session"])
        await session.commit()
        profile = await session.get(UserProfile, user.id)
        return AuthResponse(
            user=user_response_from_models(
                user=user,
                display_name=profile.display_name if profile is not None else "",
            ),
            tokens=tokens["response"],
        )

    async def _exchange_yandex_code_for_profile(self, *, code: str) -> dict:
        if not self._settings.yandex_client_id or not self._settings.yandex_client_secret:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        resolved_redirect_uri = self._require_yandex_backend_redirect_uri()
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
        return profile_response.json()

    async def _resolve_or_create_yandex_user(
        self,
        session: AsyncSession,
        yandex_profile: dict,
    ) -> User:
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
            if user is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="user_not_found",
                )
        else:
            user = await session.scalar(select(User).where(User.email == email))
            if user is None:
                user = User(
                    id=new_id(),
                    email=email,
                    password_hash=hash_password(new_id()),
                    is_active=True,
                    is_admin=False,
                    email_verified=True,
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
        return user

    async def _create_verification_token(
        self, session: AsyncSession, user_id: str
    ) -> tuple[str, datetime]:
        raw_token = secrets.token_urlsafe(48)
        token_hash = hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
        expires_at = datetime.now(UTC) + timedelta(
            hours=self._settings.auth_email_verification_token_ttl_hours
        )
        session.add(
            EmailVerificationToken(
                id=new_id(),
                user_id=user_id,
                token_hash=token_hash,
                expires_at=expires_at,
            )
        )
        return raw_token, expires_at

    async def _send_verification_email_async(
        self, *, user_email: str, token: str, accept_language: str = "",
    ) -> None:
        base_url = (
            self._settings.auth_email_verification_base_url.strip()
            or self._settings.web_public_origin.strip()
        )
        verification_url = f"{base_url.rstrip('/')}/v1/auth/verify-email?token={token}"
        try:
            await asyncio.to_thread(
                send_verification_email,
                self._settings,
                to_email=user_email,
                verification_url=verification_url,
                accept_language=accept_language,
            )
        except Exception:
            logger = get_logger("symmetry.auth")
            logger.exception(
                "failed_to_send_verification_email user_email=%s", user_email
            )

    async def verify_email(
        self, session: AsyncSession, token: str
    ) -> User:
        token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
        db_token = await session.scalar(
            select(EmailVerificationToken).where(
                EmailVerificationToken.token_hash == token_hash
            )
        )
        if db_token is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="invalid_verification_token",
            )
        if db_token.consumed_at is not None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="verification_token_already_used",
            )
        if db_token.expires_at <= datetime.now(UTC):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="expired_verification_token",
            )

        user = await session.get(User, db_token.user_id)
        if user is None or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="user_not_found",
            )

        user.email_verified = True
        db_token.consumed_at = datetime.now(UTC)
        await session.commit()
        return user

    async def resend_verification(
        self, session: AsyncSession, user: User, *, accept_language: str = "",
    ) -> None:
        if user.email_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="already_verified",
            )

        last_token = await session.scalar(
            select(EmailVerificationToken)
            .where(
                EmailVerificationToken.user_id == user.id,
                EmailVerificationToken.consumed_at.is_(None),
            )
            .order_by(EmailVerificationToken.created_at.desc())
            .limit(1)
        )
        if last_token is not None:
            elapsed = (datetime.now(UTC) - last_token.created_at).total_seconds()
            if elapsed < 60:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="resend_too_soon",
                )

        now = datetime.now(UTC)
        existing_tokens = await session.execute(
            select(EmailVerificationToken).where(
                EmailVerificationToken.user_id == user.id,
                EmailVerificationToken.consumed_at.is_(None),
            )
        )
        for t in existing_tokens.scalars().all():
            t.consumed_at = now

        raw_token, _ = await self._create_verification_token(session, user.id)
        await session.commit()

        asyncio.create_task(
            self._send_verification_email_async(
                user_email=user.email,
                token=raw_token,
                accept_language=accept_language,
            )
        )

    def _require_yandex_backend_redirect_uri(self) -> str:
        configured = (self._settings.yandex_redirect_uri or "").strip()
        if not configured:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="yandex_oauth_not_configured",
            )
        return configured

    def _require_web_public_origin(self) -> str:
        configured = (self._settings.web_public_origin or "").strip().rstrip("/")
        if not configured:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="web_public_origin_not_configured",
            )
        return configured

    def _create_yandex_oauth_state(self, *, web_origin: str) -> str:
        expires_at = datetime.now(UTC) + timedelta(
            seconds=self._settings.yandex_oauth_state_ttl_seconds
        )
        return jwt.encode(
            {
                "purpose": "yandex_oauth_state",
                "web_origin": web_origin,
                "exp": expires_at,
            },
            self._settings.jwt_secret,
            algorithm=self._settings.jwt_algorithm,
        )

    def _decode_yandex_oauth_state(self, state: str) -> dict:
        try:
            payload = jwt.decode(
                state,
                self._settings.jwt_secret,
                algorithms=[self._settings.jwt_algorithm],
            )
        except ExpiredSignatureError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="expired_yandex_state",
            ) from exc
        except JWTError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="invalid_yandex_state",
            ) from exc

        if payload.get("purpose") != "yandex_oauth_state":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="invalid_yandex_state",
            )
        web_origin = str(payload.get("web_origin", "")).strip().rstrip("/")
        if not web_origin:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="invalid_yandex_state",
            )
        return {"web_origin": web_origin}

    def _create_auth_handoff(self, session: AsyncSession, *, user_id: str) -> str:
        handoff_id = new_id()
        session.add(
            AuthHandoff(
                id=handoff_id,
                user_id=user_id,
                provider="yandex_oauth",
                expires_at=datetime.now(UTC)
                + timedelta(seconds=self._settings.yandex_oauth_handoff_ttl_seconds),
            )
        )
        return handoff_id

    def _build_yandex_completion_redirect(
        self,
        *,
        web_origin: str,
        handoff_id: str | None = None,
        error_code: str | None = None,
    ) -> RedirectResponse:
        base = f"{web_origin}/"
        query = urlencode(
            {
                key: value
                for key, value in {
                    "handoff": handoff_id,
                    "oauth_error": error_code,
                    "autostart": "1",
                }.items()
                if value
            }
        )
        target = f"{base}?{query}" if query else base
        return RedirectResponse(target, status_code=302)

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
