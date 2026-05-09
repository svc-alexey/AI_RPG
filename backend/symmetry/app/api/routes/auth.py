from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import RedirectResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_current_verified_user
from app.db.models import (
    Campaign,
    CampaignSnapshot,
    CampaignTurn,
    PendingConsequence,
    SimulationTick,
    User,
    UserProfile,
    WorldChronicle,
    WorldLocation,
    WorldState,
)
from app.db.session import get_db_session
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    MigrateGuestRequest,
    RefreshRequest,
    RegisterRequest,
    UserResponse,
    YandexCompleteRequest,
)
from app.core.config import get_settings
from app.schemas.common import MessageResponse
from app.services.auth import AuthService
from app.services.entitlement import grant_welcome_tokens

router = APIRouter(prefix="/auth", tags=["auth"])
auth_service = AuthService()


@router.post("/register", response_model=AuthResponse)
async def register(
    payload: RegisterRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> AuthResponse:
    result = await auth_service.register(session, payload, request)
    settings = get_settings()

    try:
        await grant_welcome_tokens(session, result.user.id, settings.welcome_grant_tokens)
    except Exception:
        pass

    return result


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


@router.get("/verify-email")
async def verify_email(
    token: str = Query(min_length=12),
    session: AsyncSession = Depends(get_db_session),
) -> RedirectResponse:
    try:
        await auth_service.verify_email(session, token)
    except HTTPException as exc:
        detail = exc.detail if isinstance(exc.detail, str) else "verification_failed"
        web_origin = auth_service._require_web_public_origin()
        return RedirectResponse(
            f"{web_origin}/?verify_error={detail}",
            status_code=302,
        )
    web_origin = auth_service._require_web_public_origin()
    return RedirectResponse(
        f"{web_origin}/?email_verified=1",
        status_code=302,
    )


@router.post("/resend-verification", response_model=MessageResponse)
async def resend_verification(
    request: Request,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await auth_service.resend_verification(
        session, user,
        accept_language=request.headers.get("Accept-Language", ""),
    )
    return MessageResponse(message="verification_email_sent")


@router.post("/migrate-guest", response_model=MessageResponse)
async def migrate_guest(
    body: MigrateGuestRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """Reattach campaigns from a guest account to the current (newly registered) user."""
    guest_user = await session.scalar(
        select(User).where(User.id == body.guest_user_id, User.is_active.is_(True))
    )
    if guest_user is None or not guest_user.email.startswith("guest-"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="invalid_guest_user",
        )

    tables = [
        Campaign, CampaignTurn, CampaignSnapshot, WorldState,
        WorldLocation, WorldChronicle, SimulationTick, PendingConsequence,
    ]
    migrated = 0

    for table in tables:
        result = await session.execute(
            select(table).where(table.user_id == body.guest_user_id)
        )
        for row in result.scalars().all():
            row.user_id = user.id
            migrated += 1

    await session.commit()
    return MessageResponse(message=f"guest_migrated_records={migrated}")


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
        email_verified=bool(user.email_verified),
    )
