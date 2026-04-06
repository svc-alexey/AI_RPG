from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.core.logging import get_logger
from app.db.models import User
from app.db.session import get_db_session
from app.schemas.common import MessageResponse
from app.schemas.providers import ProviderConnectionCheckRequest
from app.services.ai_gateway import AiGatewayService
from app.services.credentials import CredentialResolutionService

router = APIRouter(prefix="/providers", tags=["providers"])
credential_service = CredentialResolutionService()
ai_gateway = AiGatewayService()
logger = get_logger("symmetry.routes.providers")


@router.post("/check", response_model=MessageResponse)
async def check_provider_connection(
    payload: ProviderConnectionCheckRequest,
    _: User = Depends(get_current_user),
    __: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    try:
        credentials = credential_service.resolve(
            payload.provider_credentials,
            allow_server_fallback=payload.allow_server_fallback,
        )
    except ValueError as exc:
        logger.warning("provider_check_rejected reason=%s", str(exc))
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    logger.info(
        "provider_check_credentials_resolved user_id=%s credentials=%s",
        _.id,
        credentials.safe_summary,
    )
    try:
        await ai_gateway.check_connection(credentials=credentials)
    except Exception as exc:
        logger.exception(
            "provider_check_upstream_failed user_id=%s credentials=%s",
            _.id,
            credentials.safe_summary,
        )
        raise HTTPException(status_code=502, detail="provider_connection_failed") from exc
    return MessageResponse(message="provider_credentials_resolved")
