from fastapi import APIRouter, Depends, Form, HTTPException, Query, Request, status
from fastapi.responses import HTMLResponse, RedirectResponse
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
    ChangePasswordRequest,
    ForgotPasswordRequest,
    LoginRequest,
    MigrateGuestRequest,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
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


def _is_russian(request: Request) -> bool:
    al = request.headers.get("Accept-Language", "")
    if not al:
        return True
    return al.split(",")[0].strip().lower().startswith("ru")


def _verification_result_html(*, success: bool, message: str, lang: str) -> str:
    is_ru = lang == "ru"
    title = "Email подтверждён!" if is_ru else "Email verified!"
    heading = "Email подтверждён!" if is_ru else "Email verified!"
    body = (
        "Сейчас вы будете перенаправлены в приложение..."
        if is_ru
        else "Redirecting to the app..."
    )
    action = "Открыть приложение" if is_ru else "Open app"
    brand = "Стирая Грань" if is_ru else "Beyond The Verge"
    redirect_url = f"/?lang={lang}&autostart=1&email_verified=1"

    if success:
        icon_svg = '<svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#34D399" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 12l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>'
        status_color = "#34D399"
        border_color = "rgba(52,211,153,0.3)"
        heading_text = heading
        body_text = body
    else:
        icon_svg = '<svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#F87171" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M15 9l-6 6M9 9l6 6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
        status_color = "#F87171"
        border_color = "rgba(248,113,113,0.3)"
        heading_text = message
        body_text = (
            "Сейчас вы будете перенаправлены в приложение..."
            if is_ru
            else "Redirecting to the app..."
        )

    return f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<meta http-equiv="refresh" content="1;url={redirect_url}"/>
<script>setTimeout(function(){{window.location.href='{redirect_url}';}},1200);</script>
<title>{title}</title>
<style>
  *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
    background-color: #0A0908;
    color: #E8E4E0;
    display: flex; align-items: center; justify-content: center;
    min-height: 100vh;
    padding: 16px;
  }}
  .card {{
    max-width: 420px; width: 100%;
    background-color: #0F0D0B;
    border-radius: 20px;
    border: 1px solid {border_color};
    padding: 48px 32px;
    text-align: center;
  }}
  .brand {{
    font-family: 'Playfair Display', Georgia, 'Times New Roman', serif;
    font-size: 20px; font-weight: 700;
    color: #BFA76F;
    margin-top: 20px; margin-bottom: 4px;
  }}
  .heading {{
    font-size: 18px; font-weight: 700;
    color: {status_color};
    margin-bottom: 12px;
  }}
  .body-text {{
    font-size: 14px; color: #7A7570;
    line-height: 1.5;
    margin-bottom: 24px;
  }}
  .button {{
    display: inline-block;
    padding: 14px 32px;
    background-color: {status_color};
    color: #0A0908;
    text-decoration: none;
    border-radius: 12px;
    font-size: 15px; font-weight: 600;
    transition: opacity 0.2s;
  }}
  .button:hover {{ opacity: 0.85; }}
</style>
</head>
<body>
<div class="card">
  {icon_svg}
  <div class="brand">{brand}</div>
  <div class="heading">{heading_text}</div>
  <div class="body-text">{body_text}</div>
  <a href="{redirect_url}" class="button">{action}</a>
</div>
</body>
</html>"""


def _reset_password_result_html(*, success: bool, message: str, lang: str, token: str) -> str:
    is_ru = lang == "ru"
    title = "Пароль изменён!" if is_ru else "Password changed!"
    brand = "Стирая Грань" if is_ru else "Beyond The Verge"
    redirect_url = f"/?lang={lang}&autostart=1&password_reset=1"

    if success:
        icon_svg = '<svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#34D399" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 12l3 3 5-5" stroke-linecap="round" stroke-linejoin="round"/></svg>'
        status_color = "#34D399"
        border_color = "rgba(52,211,153,0.3)"
        heading_text = title
        body_text = (
            "Сейчас вы будете перенаправлены в приложение..."
            if is_ru
            else "Redirecting to the app..."
        )
    else:
        icon_svg = '<svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="#F87171" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M15 9l-6 6M9 9l6 6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
        status_color = "#F87171"
        border_color = "rgba(248,113,113,0.3)"
        heading_text = message
        forgot_url = f"/?lang={lang}&autostart=1"
        body_text = f'<a href="{forgot_url}" style="color:#BFA76F;text-decoration:none;">{"Запросить новый сброс" if is_ru else "Request a new reset"}</a>'

    return f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
{"<meta http-equiv=\"refresh\" content=\"1;url=\"+redirect_url+\"\"/>" if success else ""}
{"<script>setTimeout(function(){{window.location.href='"+redirect_url+"';}},1200);</script>" if success else ""}
<title>{title}</title>
<style>
  *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
    background-color: #0A0908;
    color: #E8E4E0;
    display: flex; align-items: center; justify-content: center;
    min-height: 100vh;
    padding: 16px;
  }}
  .card {{
    max-width: 420px; width: 100%;
    background-color: #0F0D0B;
    border-radius: 20px;
    border: 1px solid {border_color};
    padding: 48px 32px;
    text-align: center;
  }}
  .brand {{
    font-family: 'Playfair Display', Georgia, 'Times New Roman', serif;
    font-size: 20px; font-weight: 700;
    color: #BFA76F;
    margin-top: 20px; margin-bottom: 4px;
  }}
  .heading {{
    font-size: 18px; font-weight: 700;
    color: {status_color};
    margin-bottom: 12px;
  }}
  .body-text {{
    font-size: 14px; color: #7A7570;
    line-height: 1.5;
    margin-bottom: 24px;
  }}
  .button {{
    display: inline-block;
    padding: 14px 32px;
    background-color: {status_color};
    color: #0A0908;
    text-decoration: none;
    border-radius: 12px;
    font-size: 15px; font-weight: 600;
    transition: opacity 0.2s;
  }}
  .button:hover {{ opacity: 0.85; }}
</style>
</head>
<body>
<div class="card">
  {icon_svg}
  <div class="brand">{brand}</div>
  <div class="heading">{heading_text}</div>
  <div class="body-text">{body_text}</div>
  {(f'<a href="{redirect_url}" class="button">{"Открыть приложение" if is_ru else "Open app"}</a>') if success else ""}
</div>
</body>
</html>"""


def _reset_password_form_html(*, lang: str, token: str) -> str:
    is_ru = lang == "ru"
    title = "Сброс пароля" if is_ru else "Reset Password"
    brand = "Стирая Грань" if is_ru else "Beyond The Verge"
    heading = "Введите новый пароль" if is_ru else "Enter your new password"
    password_label = "Новый пароль" if is_ru else "New password"
    password_hint = "Минимум 8 символов" if is_ru else "Minimum 8 characters"
    submit_label = "Сохранить" if is_ru else "Save"
    action_url = f"/v1/auth/reset-password"

    return f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>{title}</title>
<style>
  *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
    background-color: #0A0908;
    color: #E8E4E0;
    display: flex; align-items: center; justify-content: center;
    min-height: 100vh;
    padding: 16px;
  }}
  .card {{
    max-width: 420px; width: 100%;
    background-color: #0F0D0B;
    border-radius: 20px;
    border: 1px solid rgba(61,51,40,0.3);
    padding: 48px 32px;
    text-align: center;
  }}
  .brand {{
    font-family: 'Playfair Display', Georgia, 'Times New Roman', serif;
    font-size: 24px; font-weight: 700;
    color: #BFA76F;
    margin-bottom: 8px;
  }}
  .heading {{
    font-size: 16px; font-weight: 400;
    color: #E8E4E0;
    margin-bottom: 32px;
  }}
  .field {{
    width: 100%; padding: 14px 16px;
    background-color: #1A1614;
    border: 1px solid rgba(61,51,40,0.5);
    border-radius: 12px;
    color: #E8E4E0;
    font-size: 15px;
    font-family: 'Inter', Arial, sans-serif;
    outline: none;
    margin-bottom: 20px;
  }}
  .field:focus {{ border-color: #BFA76F; }}
  .field::placeholder {{ color: #7A7570; }}
  .hint {{
    font-size: 12px; color: #7A7570;
    margin-top: -16px; margin-bottom: 20px; text-align: left;
  }}
  .button {{
    display: block; width: 100%;
    padding: 14px 24px;
    background-color: #C87941;
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    font-size: 16px; font-weight: 600;
    font-family: 'Inter', Arial, sans-serif;
    cursor: pointer;
    transition: background-color 0.2s;
  }}
  .button:hover {{ background-color: #D48951; }}
</style>
</head>
<body>
<div class="card">
  <div class="brand">{brand}</div>
  <div class="heading">{heading}</div>
  <form method="POST" action="{action_url}">
    <input type="hidden" name="token" value="{token}"/>
    <input type="password" name="new_password" class="field" placeholder="{password_label}" minlength="8" maxlength="128" required autofocus/>
    <div class="hint">{password_hint}</div>
    <button type="submit" class="button">{submit_label}</button>
  </form>
</div>
</body>
</html>"""


@router.get("/verify-email")
async def verify_email(
    request: Request,
    token: str = Query(min_length=12),
    session: AsyncSession = Depends(get_db_session),
):
    is_ru = _is_russian(request)
    lang = "ru" if is_ru else "en"
    try:
        await auth_service.verify_email(session, token)
    except HTTPException as exc:
        detail = exc.detail if isinstance(exc.detail, str) else "verification_failed"
        friendly = {
            "invalid_verification_token": (
                "Недействительная или уже использованная ссылка."
                if is_ru
                else "Invalid or already used verification link."
            ),
            "verification_token_already_used": (
                "Ссылка уже была использована."
                if is_ru
                else "This link has already been used."
            ),
            "expired_verification_token": (
                "Срок действия ссылки истёк."
                if is_ru
                else "This link has expired."
            ),
            "user_not_found": (
                "Пользователь не найден."
                if is_ru
                else "User not found."
            ),
        }.get(detail, detail)
        return HTMLResponse(
            content=_verification_result_html(success=False, message=friendly, lang=lang),
            status_code=400,
        )
    return HTMLResponse(
        content=_verification_result_html(success=True, message="", lang=lang),
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


@router.post("/forgot-password", response_model=MessageResponse)
async def forgot_password(
    payload: ForgotPasswordRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    try:
        await auth_service.forgot_password(
            session,
            email=payload.email,
            accept_language=request.headers.get("Accept-Language", ""),
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="smtp_unavailable",
        )
    return MessageResponse(message="password_reset_email_sent")


@router.get("/reset-password")
async def reset_password_form(
    request: Request,
    token: str = Query(min_length=12),
    session: AsyncSession = Depends(get_db_session),
):
    is_ru = _is_russian(request)
    lang = "ru" if is_ru else "en"
    try:
        await auth_service.get_reset_token_info(session, token)
    except HTTPException as exc:
        detail = exc.detail if isinstance(exc.detail, str) else "reset_failed"
        friendly = {
            "invalid_reset_token": (
                "Недействительная ссылка для сброса пароля."
                if is_ru
                else "Invalid password reset link."
            ),
            "reset_token_already_used": (
                "Эта ссылка уже была использована."
                if is_ru
                else "This link has already been used."
            ),
            "expired_reset_token": (
                "Срок действия ссылки истёк."
                if is_ru
                else "This link has expired."
            ),
        }.get(detail, detail)
        return HTMLResponse(
            content=_reset_password_result_html(success=False, message=friendly, lang=lang, token=""),
            status_code=400,
        )
    return HTMLResponse(
        content=_reset_password_form_html(lang=lang, token=token),
    )


@router.post("/reset-password")
async def reset_password_submit(
    request: Request,
    token: str = Form(min_length=12),
    new_password: str = Form(min_length=8, max_length=128),
    session: AsyncSession = Depends(get_db_session),
):
    is_ru = _is_russian(request)
    lang = "ru" if is_ru else "en"
    try:
        await auth_service.reset_password(session, token=token, new_password=new_password)
    except HTTPException as exc:
        detail = exc.detail if isinstance(exc.detail, str) else "reset_failed"
        friendly = {
            "invalid_reset_token": (
                "Недействительная ссылка для сброса пароля."
                if is_ru
                else "Invalid password reset link."
            ),
            "reset_token_already_used": (
                "Эта ссылка уже была использована."
                if is_ru
                else "This link has already been used."
            ),
            "expired_reset_token": (
                "Срок действия ссылки истёк."
                if is_ru
                else "This link has expired."
            ),
            "user_not_found": (
                "Пользователь не найден."
                if is_ru
                else "User not found."
            ),
        }.get(detail, detail)
        return HTMLResponse(
            content=_reset_password_result_html(success=False, message=friendly, lang=lang, token=""),
            status_code=400,
        )
    redirect_url = f"/?lang={lang}&autostart=1&password_reset=1"
    return RedirectResponse(redirect_url, status_code=302)


@router.post("/change-password", response_model=MessageResponse)
async def change_password(
    payload: ChangePasswordRequest,
    user: User = Depends(get_current_verified_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await auth_service.change_password(
        session, user,
        current_password=payload.current_password,
        new_password=payload.new_password,
    )
    return MessageResponse(message="password_changed")


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

    result = await session.execute(
        select(Campaign).where(Campaign.owner_user_id == body.guest_user_id)
    )
    campaigns = result.scalars().all()
    for campaign in campaigns:
        campaign.owner_user_id = user.id
    migrated = len(campaigns)

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
