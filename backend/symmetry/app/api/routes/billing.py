import logging

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_optional_user
from app.core.billing_errors import (
    CheckoutFailedError,
    PlanNotFoundError,
    WebhookSignatureError,
)
from app.core.config import get_settings
from app.db.models import BillingPlan, BillingOrder, User
from app.db.session import get_db_session
from app.schemas.billing import (
    BillingPlanResponse,
    BillingWalletResponse,
    CheckoutRequest,
    CheckoutResponse,
    new_id,
)
from app.services.billing_service import create_checkout, get_wallet, process_payment_succeeded
from app.services.yookassa_client import YooKassaClient

logger = logging.getLogger("symmetry.billing")

router = APIRouter(prefix="/billing", tags=["billing"])

SEED_PLANS = [
    {
        "code": "free_welcome_1m", "kind": "welcome", "title": "Welcome 1M",
        "metadata_json": {
            "description": "Приветственный грант", "token_grant": 1_000_000,
            "base_price_minor": 0, "currency": "RUB", "sort_order": 1,
        },
    },
    {
        "code": "pack_1m", "kind": "token_pack", "title": "1M токенов",
        "metadata_json": {
            "description": "Стандартное пополнение", "token_grant": 1_000_000,
            "base_price_minor": 7900, "currency": "RUB", "sort_order": 2,
        },
    },
    {
        "code": "pack_10m", "kind": "token_pack", "title": "10M токенов",
        "metadata_json": {
            "description": "Для активных игроков", "token_grant": 10_000_000,
            "base_price_minor": 39000, "sale_price_minor": 39000,
            "sale_badge_text": "Best Value", "sale_percent": 51,
            "currency": "RUB", "sort_order": 3, "featured": True,
        },
    },
]


async def _seed_plans(session: AsyncSession) -> None:
    existing = (await session.execute(select(BillingPlan.code))).scalars().all()
    existing_codes = set(existing)
    for plan in SEED_PLANS:
        if plan["code"] in existing_codes:
            continue
        session.add(BillingPlan(
            id=new_id(), code=plan["code"], title=plan["title"],
            metadata_json=plan["metadata_json"],
        ))
    await session.commit()


def _plan_to_response(plan: BillingPlan) -> BillingPlanResponse:
    meta = plan.metadata_json or {}
    return BillingPlanResponse(
        code=plan.code,
        kind=meta.get("kind", "token_pack"),
        title=plan.title,
        description=meta.get("description", ""),
        currency=meta.get("currency", "RUB"),
        base_price_minor=meta.get("base_price_minor", 0),
        sale_price_minor=meta.get("sale_price_minor"),
        sale_badge_text=meta.get("sale_badge_text"),
        sale_percent=meta.get("sale_percent"),
        token_grant=meta.get("token_grant", 0),
        featured=meta.get("featured", False),
        is_active=True,
        sort_order=meta.get("sort_order", 0),
    )


def _get_yookassa() -> YooKassaClient:
    return YooKassaClient()


@router.get("/catalog", response_model=list[BillingPlanResponse])
async def list_catalog(
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingPlanResponse]:
    await _seed_plans(session)
    result = await session.execute(
        select(BillingPlan).order_by(BillingPlan.metadata_json["sort_order"].as_integer())
    )
    return [_plan_to_response(p) for p in result.scalars().all()]


@router.get("/me", response_model=BillingWalletResponse)
async def get_my_wallet(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingWalletResponse:
    return await get_wallet(session, user.id)


@router.post("/checkout", response_model=CheckoutResponse)
async def create_checkout_route(
    body: CheckoutRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    yookassa: YooKassaClient = Depends(_get_yookassa),
) -> CheckoutResponse:
    try:
        return await create_checkout(session, user.id, body.plan_code, body.return_url, yookassa)
    except PlanNotFoundError:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="plan_not_found")
    except CheckoutFailedError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))


@router.post("/webhook/yookassa")
async def yookassa_webhook(
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> dict:
    body = await request.body()
    signature = request.headers.get("X-Signature")

    if not YooKassaClient.verify_webhook_signature(body, signature):
        logger.warning("webhook_invalid_signature")
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="invalid_signature")

    import json
    try:
        event = json.loads(body)
    except json.JSONDecodeError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="invalid_json")

    event_type = event.get("event")
    payment_data = event.get("object", {})
    payment_id = payment_data.get("id")
    payment_status = payment_data.get("status")

    if not payment_id:
        return {"received": True}

    if event_type == "payment.succeeded" and payment_status == "succeeded":
        pm = payment_data.get("payment_method", {}) or {}
        payment_method_id = pm.get("id") if isinstance(pm, dict) else getattr(pm, "id", None)
        await process_payment_succeeded(session, payment_id, payment_method_id)

    else:
        order_result = await session.execute(
            select(BillingOrder).where(BillingOrder.provider_payment_id == payment_id)
        )
        order = order_result.scalars().first()
        if order and order.status != payment_status:
            order.status = payment_status
            await session.flush()

    return {"received": True}
