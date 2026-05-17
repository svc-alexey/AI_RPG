from __future__ import annotations

import asyncio

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user
from app.core.config import get_settings
from app.db.models import Campaign, CampaignPortrait, CampaignSnapshot, User
from app.db.session import get_db_session
from app.schemas.portraits import PortraitGenerateRequest, PortraitStatusResponse
from app.services.entitlement import check_access, count_guest_turns
from app.services.ids import new_id
from app.services.portrait_service import generate_and_store

router = APIRouter(prefix="/campaigns", tags=["portraits"])


@router.get("/{campaign_id}/portrait/image")
async def get_portrait_image(
    campaign_id: str,
    session: AsyncSession = Depends(get_db_session),
) -> Response:
    result = await session.execute(
        select(CampaignPortrait)
        .where(
            CampaignPortrait.campaign_id == campaign_id,
            CampaignPortrait.status == "ready",
        )
        .order_by(CampaignPortrait.created_at.desc())
        .limit(1)
    )
    portrait = result.scalar_one_or_none()
    if portrait is None or portrait.image_webp is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="portrait_not_found")

    return Response(
        content=portrait.image_webp,
        media_type="image/webp",
        headers={"Cache-Control": "public, max-age=86400, immutable"},
    )


@router.post("/{campaign_id}/portrait", response_model=PortraitStatusResponse)
async def request_portrait(
    campaign_id: str,
    body: PortraitGenerateRequest = PortraitGenerateRequest(),
    user: User = Depends(get_current_verified_user),
    session: AsyncSession = Depends(get_db_session),
) -> PortraitStatusResponse:
    campaign = await session.scalar(
        select(Campaign).where(Campaign.id == campaign_id, Campaign.owner_user_id == user.id)
    )
    if campaign is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="campaign_not_found")

    if campaign.portrait_status in ("pending", "ready"):
        return PortraitStatusResponse(portrait_status=campaign.portrait_status)

    settings = get_settings()
    is_guest = user.email.startswith("guest-")
    can_generate = (
        is_guest and await count_guest_turns(session, user.id) < settings.free_guest_turns
    ) or (not is_guest and await check_access(session, user))

    if not can_generate:
        return PortraitStatusResponse(portrait_status=None)

    snapshot = await session.get(CampaignSnapshot, campaign.current_snapshot_id)
    state = snapshot.state_json if snapshot else {}

    campaign.portrait_status = "pending"
    session.add(CampaignPortrait(id=new_id(), campaign_id=campaign_id, status="pending"))
    await session.commit()

    character = state.get("character", {})
    story_prompt = str(state.get("story_prompt", ""))

    asyncio.create_task(
        generate_and_store(
            campaign_id=campaign.id,
            character=character,
            setting=campaign.setting,
            story_prompt=story_prompt,
            target_width=body.target_width,
            target_height=body.target_height,
        )
    )

    return PortraitStatusResponse(portrait_status="pending")
