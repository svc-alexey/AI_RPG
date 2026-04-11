from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import require_dev_admin_token
from app.db.session import get_db_session
from app.schemas.dev import UsageReportResponse
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
