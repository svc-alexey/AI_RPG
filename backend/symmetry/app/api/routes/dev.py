from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import require_dev_admin_token
from app.db.models import CampaignTurn
from app.db.session import get_db_session
from app.schemas.dev import TurnDebugResponse, UsageReportResponse
from app.services.usage_report import UsageReportService

router = APIRouter(prefix="/dev", tags=["dev"])
usage_report_service = UsageReportService()


@router.get(
    "/usage",
    response_model=UsageReportResponse,
    dependencies=[Depends(require_dev_admin_token)],
)
async def get_usage_report(
    days: int = Query(default=7, ge=1, le=90),
    limit: int = Query(default=500, ge=1, le=5000),
    campaign_id: str | None = Query(default=None),
    session: AsyncSession = Depends(get_db_session),
) -> UsageReportResponse:
    report = await usage_report_service.build_report(
        session,
        days=days,
        campaign_id=campaign_id,
        limit=limit,
    )
    return UsageReportResponse.model_validate(report)


@router.get(
    "/campaigns/{campaign_id}/turn-debug",
    response_model=TurnDebugResponse,
    dependencies=[Depends(require_dev_admin_token)],
)
async def get_turn_debug(
    campaign_id: str,
    turn_number: int | None = Query(default=None, ge=1),
    session: AsyncSession = Depends(get_db_session),
) -> TurnDebugResponse:
    stmt = select(CampaignTurn).where(CampaignTurn.campaign_id == campaign_id)
    if turn_number is not None:
        stmt = stmt.where(CampaignTurn.turn_number == turn_number)
    else:
        stmt = stmt.order_by(desc(CampaignTurn.turn_number)).limit(1)
    turn = await session.scalar(stmt)
    if turn is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="turn_debug_not_found",
        )

    usage = turn.llm_usage_json if isinstance(turn.llm_usage_json, dict) else {}
    turn_debug = usage.get("turn_debug") if isinstance(usage.get("turn_debug"), dict) else {}
    llm_response = turn.llm_response_json if isinstance(turn.llm_response_json, dict) else {}
    return TurnDebugResponse(
        campaign_id=turn.campaign_id,
        turn_number=int(turn.turn_number or 0),
        created_at=turn.created_at,
        request_id=str(usage.get("request_id", "") or ""),
        client_turn_id=str(usage.get("client_turn_id", "") or ""),
        budget_scenario=str(usage.get("budget_scenario", "") or ""),
        prompt_characters=int(usage.get("prompt_characters", 0) or 0),
        prompt_tokens=int(usage.get("prompt_tokens", 0) or 0),
        completion_tokens=int(usage.get("completion_tokens", 0) or 0),
        scene_state=dict(turn_debug.get("scene_state", {}) or {}),
        context=dict(turn_debug.get("context", {}) or {}),
        rag=dict(turn_debug.get("rag", {}) or {}),
        llm_response_excerpt={
            "narration": str(llm_response.get("narration", "") or "")[:600],
            "memory_entry": str(llm_response.get("memory_entry", "") or "")[:240],
            "scene_state_patch": dict(llm_response.get("scene_state_patch", {}) or {}),
        },
    )
