from fastapi import APIRouter, Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_optional_current_user
from app.db.models import User
from app.db.session import get_db_session
from app.schemas.billing import (
    BillingCatalogItemResponse,
    BillingCheckoutRequest,
    BillingCheckoutResponse,
    BillingHistoryItemResponse,
    BillingOrderStatusResponse,
    BillingSummaryResponse,
)
from app.schemas.common import MessageResponse
from app.services.billing import BillingService

router = APIRouter(prefix="/billing", tags=["billing"])
billing_service = BillingService()


@router.get("/catalog", response_model=list[BillingCatalogItemResponse])
async def get_catalog(
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingCatalogItemResponse]:
    return await billing_service.get_catalog(session)


@router.get("/me", response_model=BillingSummaryResponse)
async def get_me(
    user: User | None = Depends(get_optional_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingSummaryResponse:
    return await billing_service.build_summary(session, user=user)


@router.get("/history", response_model=list[BillingHistoryItemResponse])
async def get_history(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingHistoryItemResponse]:
    return await billing_service.get_history(session, user_id=user.id)


@router.post("/checkout", response_model=BillingCheckoutResponse)
async def create_checkout(
    payload: BillingCheckoutRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingCheckoutResponse:
    response = await billing_service.create_checkout(
        session,
        user=user,
        plan_code=payload.plan_code.strip(),
    )
    await session.commit()
    return response


@router.get("/checkout/{order_id}", response_model=BillingOrderStatusResponse)
async def get_checkout_status(
    order_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingOrderStatusResponse:
    return await billing_service.get_order_status(
        session,
        user_id=user.id,
        order_id=order_id,
    )


@router.post("/subscription/cancel", response_model=BillingSummaryResponse)
async def cancel_subscription(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingSummaryResponse:
    response = await billing_service.cancel_subscription(session, user_id=user.id)
    await session.commit()
    return response


@router.post("/webhooks/yookassa", response_model=MessageResponse)
async def yookassa_webhook(
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    payload = await request.json()
    await billing_service.handle_webhook(session, payload=payload)
    await session.commit()
    return MessageResponse(message="ok")
