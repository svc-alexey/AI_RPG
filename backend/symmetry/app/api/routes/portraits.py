"""Character portrait generation via Polza.ai."""

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import Response
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user
from app.db.models import CampaignMember, CampaignPortrait, User
from app.db.session import get_db_session
from app.schemas.portraits import GeneratePortraitRequest, PortraitResponseBody
from app.services.portrait_service import (
    PolzaApiError,
    PolzaTimeoutError,
    PortraitService,
)

router = APIRouter(prefix="/campaigns", tags=["portraits"])


async def _require_campaign_member(
    campaign_id: str,
    user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
) -> tuple[User, AsyncSession]:
    member_q = select(CampaignMember).where(
        CampaignMember.campaign_id == campaign_id,
        CampaignMember.user_id == user.id,
    )
    result = await db.execute(member_q)
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Campaign not found")
    return user, db


@router.post(
    "/{campaign_id}/portrait",
    response_model=PortraitResponseBody,
    status_code=200,
)
async def generate_portrait(
    campaign_id: str,
    body: GeneratePortraitRequest,
    request: Request,
    user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    await _require_campaign_member(campaign_id, user, db)

    service = PortraitService.from_settings(db)
    try:
        result = await service.generate_portrait(
            campaign_id=campaign_id,
            character_name=body.character_name,
            character_race=body.race,
            character_class=body.character_class,
            character_gender=body.gender,
            character_personality=body.personality,
            character_prompt_fragment=body.prompt_fragment,
            story_context=body.story_context,
            setting=body.setting,
        )
    except PolzaTimeoutError:
        raise HTTPException(
            status_code=502,
            detail=_localize(request, "gen_timeout"),
        )
    except PolzaApiError:
        raise HTTPException(
            status_code=502,
            detail=_localize(request, "gen_failed"),
        )
    finally:
        await service.close()

    return PortraitResponseBody(
        portrait_id=result.portrait_id,
        portrait_url=result.url,
    )


@router.get("/{campaign_id}/portrait/image")
async def get_portrait_image(
    campaign_id: str,
    db: AsyncSession = Depends(get_db_session),
):
    result = await db.execute(
        select(CampaignPortrait).where(
            CampaignPortrait.campaign_id == campaign_id
        )
    )
    portrait = result.scalar_one_or_none()
    if portrait is None:
        raise HTTPException(status_code=404, detail="No portrait for this campaign")

    return Response(
        content=portrait.image_webp,
        media_type="image/webp",
        headers={
            "Cache-Control": "public, max-age=86400, immutable",
            "Access-Control-Allow-Origin": "*",
        },
    )


def _localize(request: Request, key: str) -> str:
    accept_language = request.headers.get("accept-language", "")
    is_russian = "ru" in accept_language.lower().split(",")[0] if accept_language else True

    messages = {
        "gen_timeout": {
            True: "Генерация портрета заняла слишком много времени. Попробуйте позже.",
            False: "Portrait generation took too long. Please try again later.",
        },
        "gen_failed": {
            True: "Не удалось сгенерировать портрет. Попробуйте позже.",
            False: "Failed to generate portrait. Please try again later.",
        },
    }
    return messages[key][is_russian]
