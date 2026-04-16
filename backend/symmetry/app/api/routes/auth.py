from fastapi import APIRouter, Depends, HTTPException, Query, Request
from fastapi.responses import RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import User, UserProfile
from app.db.session import get_db_session
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    UserResponse,
    YandexCompleteRequest,
)
from app.schemas.common import MessageResponse
from app.services.auth import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()


@router.post("/register", response_model=AuthResponse)
async def register(
    payload: RegisterRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    return await auth_service.register(session, payload, request)


@router.post("/login", response_model=AuthResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    return await auth_service.login(session, payload, request)


@router.post("/guest", response_model=AuthResponse)
async def guest_login(
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    return await auth_service.login_guest(session, request)


@router.post("/refresh", response_model=AuthResponse)
async def refresh(
    payload: RefreshRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    return await auth_service.refresh(
        session, refresh_token=payload.refresh_token, request=request
    )


@router.post("/logout", response_model=MessageResponse)
async def logout(
    payload: RefreshRequest,
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await auth_service.logout(session, refresh_token=payload.refresh_token)
    return MessageResponse(message="logged_out")


@router.get("/yandex/start")
async def yandex_start() -> RedirectResponse:
    return RedirectResponse(auth_service.build_yandex_authorize_url(), status_code=302)


@router.get("/yandex/callback")
async def yandex_callback(
    code: str = Query(default=""),
    state: str = Query(default=""),
    session: AsyncSession = Depends(get_db_session),
) -> RedirectResponse:
    if not state:
        raise HTTPException(status_code=400, detail="missing_yandex_state")
    return await auth_service.handle_yandex_callback(
        session,
        code=code,
        state=state,
    )


@router.post("/yandex/complete", response_model=AuthResponse)
async def yandex_complete(
    payload: YandexCompleteRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    return await auth_service.complete_yandex_handoff(
        session,
        handoff_id=payload.handoff_id,
        request=request,
    )


@router.get("/me", response_model=UserResponse)
async def me(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> UserResponse:
    profile = await session.get(UserProfile, user.id)
    return UserResponse(
        id=user.id,
        email=user.email,
        display_name=profile.display_name if profile is not None else "",
        is_admin=user.is_admin,
    )
