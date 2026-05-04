"""Campaign spatial map endpoints."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import CampaignMember, User
from app.db.session import get_db_session
from app.services.map_state_service import MapStateService

router = APIRouter(prefix="/campaigns", tags=["campaign-map"])
map_service = MapStateService()


async def _require_campaign_member(
    campaign_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
) -> tuple[User, AsyncSession]:
    """Verify user is a campaign member, raise 404 if not."""
    member_q = select(CampaignMember).where(
        CampaignMember.campaign_id == campaign_id,
        CampaignMember.user_id == user.id,
    )
    result = await db.execute(member_q)
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Campaign not found")
    return user, db


@router.get("/{campaign_id}/map")
async def get_campaign_map(
    campaign_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Return full spatial map graph for a campaign."""
    await _require_campaign_member(campaign_id, user, db)
    return await map_service.get_map(db, campaign_id)


@router.get("/{campaign_id}/return-summary")
async def get_return_summary(
    campaign_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Return World Pulse digest for a returning player."""
    await _require_campaign_member(campaign_id, user, db)
    return await map_service.get_return_summary(db, campaign_id, user.id)


@router.post("/{campaign_id}/map/seed")
async def seed_campaign_map(
    campaign_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Initialize map with a fallback starting node."""
    await _require_campaign_member(campaign_id, user, db)
    node_id = await map_service.seed_map(db, campaign_id)
    await db.commit()
    return {"status": "ok", "node_id": node_id}


@router.post("/{campaign_id}/map/proposals")
async def submit_map_proposals(
    campaign_id: str,
    payload: dict,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Submit spatial change proposals (from LLM)."""
    await _require_campaign_member(campaign_id, user, db)
    proposals = payload.get("proposals", [])
    if len(proposals) > 10:
        raise HTTPException(
            status_code=422,
            detail="Maximum 10 proposals per request",
        )
    results = await map_service.process_proposals(db, campaign_id, proposals)
    await db.commit()
    return {"proposals": results}


@router.post("/{campaign_id}/map/mark-seen")
async def mark_map_seen(
    campaign_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Mark all current chronicles as seen by the player."""
    await _require_campaign_member(campaign_id, user, db)
    await map_service.mark_seen(db, user.id, campaign_id)
    await db.commit()
    return {"status": "ok"}
