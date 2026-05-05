from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import BillingPlan, CreditLedger, User
from app.db.session import get_db_session
from app.schemas.billing import (
    BillingPlanResponse,
    BillingWalletResponse,
    CheckoutRequest,
    CheckoutResponse,
)

router = APIRouter(prefix="/billing", tags=["billing"])

# Seed plans — applied on first catalog access if no plans exist
SEED_PLANS = [
    {"code": "free_welcome_1m", "kind": "welcome", "title": "Welcome 1M",
     "metadata_json": {"description": "Приветственный грант", "token_grant": 1_000_000,
      "base_price_minor": 0, "currency": "RUB", "sort_order": 1}},
    {"code": "pack_1m", "kind": "token_pack", "title": "1M токенов",
     "metadata_json": {"description": "Стандартное пополнение", "token_grant": 1_000_000,
      "base_price_minor": 7900, "currency": "RUB", "sort_order": 2}},
    {"code": "pack_10m", "kind": "token_pack", "title": "10M токенов",
     "metadata_json": {"description": "Для активных игроков", "token_grant": 10_000_000,
      "base_price_minor": 39000, "sale_price_minor": 39000, "sale_badge_text": "Best Value",
      "sale_percent": 51, "currency": "RUB", "sort_order": 3, "featured": True}},
]


async def _seed_plans(session: AsyncSession) -> None:
    """Ensure seed plans exist in DB. Idempotent — skips existing codes."""
    from app.db.models import BillingPlan
    from app.schemas.billing import new_id

    existing = (await session.execute(select(BillingPlan.code))).scalars().all()
    existing_codes = set(existing)

    for plan in SEED_PLANS:
        if plan["code"] in existing_codes:
            continue
        session.add(BillingPlan(
            id=new_id(),
            code=plan["code"],
            title=plan["title"],
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


@router.get("/catalog", response_model=list[BillingPlanResponse])
async def list_catalog(
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingPlanResponse]:
    await _seed_plans(session)
    result = await session.execute(
        select(BillingPlan).order_by(BillingPlan.metadata_json["sort_order"].as_integer())
    )
    plans = result.scalars().all()
    return [_plan_to_response(p) for p in plans]


@router.get("/me", response_model=BillingWalletResponse)
async def get_my_wallet(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingWalletResponse:
    """Return user's token wallet. Phase 1: stub — all zeros unless welcome grant was claimed."""
    # Check if welcome grant was claimed by this user
    result = await session.execute(
        select(CreditLedger).where(
            CreditLedger.user_id == user.id,
            CreditLedger.reason == "welcome_grant",
        )
    )
    welcome_claimed = result.scalars().first() is not None

    return BillingWalletResponse(
        welcome_tokens_remaining=1_000_000 if welcome_claimed else 0,
        paid_tokens_remaining=0,
        subscription_tokens_remaining=0,
        total_tokens_remaining=1_000_000 if welcome_claimed else 0,
    )


@router.post("/checkout", response_model=CheckoutResponse)
async def create_checkout(
    body: CheckoutRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> CheckoutResponse:
    """Placeholder checkout endpoint. Phase 2: real YooKassa integration."""
    # Find the plan
    result = await session.execute(
        select(BillingPlan).where(BillingPlan.code == body.plan_code)
    )
    plan = result.scalars().first()
    if not plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="plan_not_found",
        )

    meta = plan.metadata_json or {}
    price = meta.get("sale_price_minor") or meta.get("base_price_minor", 0)
    if price == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="free_plan_not_checkout",
        )

    # Phase 2: create billing_order + redirect to YooKassa
    # For now, return a placeholder
    from app.schemas.billing import new_id

    order_id = new_id()
    return CheckoutResponse(
        order_id=order_id,
        confirmation_url=f"https://beyondtheverge.online/subscribe.html?order={order_id}&status=pending",
        amount_minor=price,
        currency="RUB",
    )
