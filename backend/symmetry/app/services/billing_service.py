import logging
from datetime import UTC, datetime, timedelta

from dateutil.relativedelta import relativedelta
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.billing_errors import (
    CheckoutFailedError,
    PlanNotFoundError,
    SubscriptionRenewalError,
)
from app.core.config import get_settings
from app.db.models import (
    BillingCustomer,
    BillingOrder,
    BillingPlan,
    BillingSubscription,
    CreditLedger,
)
from app.schemas.billing import BillingPlanResponse, BillingWalletResponse, CheckoutResponse
from app.services.billing_encryption import decrypt_payment_method_id, encrypt_payment_method_id
from app.services.entitlement import (
    has_welcome_grant as _has_welcome_grant,
)
from app.services.entitlement import (
    wallet_breakdown,
)
from app.services.yookassa_client import YooKassaClient, YooKassaClientError

logger = logging.getLogger("symmetry.billing")


def _new_id() -> str:
    import uuid
    return uuid.uuid4().hex


def _utcnow() -> datetime:
    return datetime.now(UTC)


async def get_or_create_customer(session: AsyncSession, user_id: str) -> BillingCustomer:
    result = await session.execute(
        select(BillingCustomer).where(BillingCustomer.user_id == user_id)
    )
    customer = result.scalars().first()
    if customer:
        return customer
    customer = BillingCustomer(id=_new_id(), user_id=user_id, metadata_json={})
    session.add(customer)
    await session.flush()
    return customer


async def create_checkout(
    session: AsyncSession,
    user_id: str,
    plan_code: str,
    return_url: str,
    yookassa: YooKassaClient,
) -> CheckoutResponse:
    result = await session.execute(
        select(BillingPlan).where(BillingPlan.code == plan_code)
    )
    plan = result.scalars().first()
    if not plan:
        raise PlanNotFoundError(plan_code)

    meta = plan.metadata_json or {}
    price = meta.get("sale_price_minor") or meta.get("base_price_minor", 0)
    kind = meta.get("kind", "token_pack")

    if price == 0 and kind == "welcome":
        raise CheckoutFailedError(plan_code, "free_plan_not_checkout")

    order_id = _new_id()
    order = BillingOrder(
        id=order_id,
        user_id=user_id,
        plan_code=plan_code,
        provider="yookassa",
        idempotency_key=order_id,
        amount_minor=price,
        currency="RUB",
        status="pending",
        return_url=return_url,
    )
    session.add(order)
    await session.flush()

    try:
        payment = yookassa.create_payment(
            amount_minor=price,
            currency="RUB",
            order_id=order_id,
            return_url=return_url,
            save_payment_method=(kind == "subscription"),
        )
    except YooKassaClientError as exc:
        logger.error("checkout_yookassa_failed order_id=%s error=%s", order_id, exc)
        raise CheckoutFailedError(plan_code, str(exc)) from exc

    order.provider_payment_id = payment.payment_id
    order.confirmation_url = payment.confirmation_url
    order.status = "pending"
    await session.flush()

    return CheckoutResponse(
        order_id=order_id,
        confirmation_url=payment.confirmation_url or "",
        amount_minor=price,
        currency="RUB",
    )


async def process_payment_succeeded(
    session: AsyncSession,
    provider_payment_id: str,
    payment_method_id: str | None = None,
) -> None:
    result = await session.execute(
        select(BillingOrder).where(
            BillingOrder.provider_payment_id == provider_payment_id,
        ).with_for_update()
    )
    order = result.scalars().first()
    if not order:
        logger.warning("payment_succeeded_unknown_order provider_payment_id=%s", provider_payment_id)
        return

    if order.status == "succeeded":
        logger.info("payment_already_succeeded provider_payment_id=%s", provider_payment_id)
        return

    now = _utcnow()
    order.status = "succeeded"
    order.updated_at = now
    await session.flush()

    plan_result = await session.execute(
        select(BillingPlan).where(BillingPlan.code == order.plan_code)
    )
    plan = plan_result.scalars().first()
    if not plan:
        logger.error("payment_succeeded_plan_missing plan_code=%s", order.plan_code)
        return

    meta = plan.metadata_json or {}
    token_grant = meta.get("token_grant", 0)
    kind = meta.get("kind", "token_pack")
    plan_id = plan.id

    if token_grant > 0:
        source = "welcome" if kind == "welcome" else "paid"
        ledger = CreditLedger(
            id=_new_id(),
            user_id=order.user_id,
            amount=token_grant,
            reason="purchase",
            provider_payment_id=provider_payment_id,
            metadata_json={"source": source, "plan_code": order.plan_code, "order_id": order.id},
        )
        session.add(ledger)

    if kind == "subscription":
        customer = await get_or_create_customer(session, order.user_id)
        encrypted_pm = None
        if payment_method_id:
            encrypted_pm = encrypt_payment_method_id(payment_method_id)

        now_dt = _utcnow()
        period_end = now_dt + relativedelta(months=1)

        sub = BillingSubscription(
            id=_new_id(),
            billing_customer_id=customer.id,
            billing_plan_id=plan_id,
            status="active",
            current_period_start_at=now_dt,
            current_period_end_at=period_end,
            payment_method_id=encrypted_pm,
            monthly_quota_tokens=meta.get("monthly_quota_tokens"),
            next_retry_at=period_end,
        )
        session.add(sub)

    await session.flush()
    logger.info(
        "payment_succeeded_processed provider_payment_id=%s user_id=%s tokens=%s",
        provider_payment_id, order.user_id, token_grant,
    )


async def get_wallet(
    session: AsyncSession,
    user_id: str,
) -> BillingWalletResponse:
    breakdown = await wallet_breakdown(session, user_id)

    sub_reset_at = None
    result = await session.execute(
        select(BillingSubscription).join(BillingCustomer).where(
            BillingCustomer.user_id == user_id,
            BillingSubscription.status == "active",
        ).order_by(BillingSubscription.current_period_end_at.desc()).limit(1)
    )
    sub = result.scalars().first()
    if sub and sub.current_period_end_at:
        sub_reset_at = sub.current_period_end_at

    return BillingWalletResponse(
        welcome_tokens_remaining=breakdown["welcome_tokens_remaining"],
        paid_tokens_remaining=breakdown["paid_tokens_remaining"],
        subscription_tokens_remaining=breakdown["subscription_tokens_remaining"],
        total_tokens_remaining=breakdown["total_tokens_remaining"],
        subscription_quota_resets_at=sub_reset_at,
        welcome_expires_at=None,
    )


async def cancel_subscription(session: AsyncSession, user_id: str) -> bool:
    result = await session.execute(
        select(BillingSubscription).join(BillingCustomer).where(
            BillingCustomer.user_id == user_id,
            BillingSubscription.status.in_(["active", "past_due"]),
        ).with_for_update()
    )
    sub = result.scalars().first()
    if not sub:
        return False

    sub.cancel_at_period_end = True
    sub.metadata_json = {**sub.metadata_json, "canceled_at": _utcnow().isoformat()}
    await session.flush()
    logger.info("subscription_cancelled sub_id=%s user_id=%s", sub.id, user_id)
    return True


async def run_renewal_cycle(session: AsyncSession, yookassa: YooKassaClient) -> dict:
    settings = get_settings()
    now = _utcnow()

    # Phase 1: claim subscriptions due for renewal
    claimed_result = await session.execute(
        update(BillingSubscription)
        .where(
            BillingSubscription.status == "active",
            BillingSubscription.next_retry_at <= now,
        )
        .values(status="renewing")
        .returning(BillingSubscription.id)
    )
    claimed_ids = [row[0] for row in claimed_result]

    # Recovery: stale renewing > 30 min
    recovery_result = await session.execute(
        select(BillingSubscription).where(
            BillingSubscription.status == "renewing",
            BillingSubscription.last_retry_at < now - timedelta(minutes=30),
        )
    )
    for sub in recovery_result.scalars().all():
        claimed_ids.append(sub.id)

    renewed = 0
    failed = 0

    for sub_id in claimed_ids:
        result = await session.execute(
            select(BillingSubscription).where(
                BillingSubscription.id == sub_id
            ).with_for_update()
        )
        sub = result.scalars().first()
        if not sub:
            continue

        try:
            plan_result = await session.execute(
                select(BillingPlan).where(BillingPlan.id == sub.billing_plan_id)
            )
            plan = plan_result.scalars().first()
            meta = plan.metadata_json if plan else {}
            price = meta.get("base_price_minor", 0)

            if sub.payment_method_id:
                pm_decrypted = decrypt_payment_method_id(sub.payment_method_id)
                order_id = _new_id()
                payment = yookassa.create_recurring_payment(
                    amount_minor=price,
                    currency="RUB",
                    order_id=order_id,
                    payment_method_id=pm_decrypted,
                )

                if payment.status == "succeeded":
                    new_end = max(sub.current_period_end_at or now, now) + relativedelta(months=1)
                    sub.status = "active"
                    sub.current_period_start_at = now
                    sub.current_period_end_at = new_end
                    sub.next_retry_at = new_end
                    sub.retry_count = 0
                    sub.last_retry_at = now

                    if meta.get("monthly_quota_tokens"):
                        ledger = CreditLedger(
                            id=_new_id(),
                            user_id=_get_user_id_for_sub(session, sub),
                            amount=meta["monthly_quota_tokens"],
                            reason="subscription_renewal",
                            metadata_json={"source": "subscription", "subscription_id": sub_id},
                        )
                        session.add(ledger)
                else:
                    await _handle_renewal_failure(session, sub, now, settings)

        except Exception as exc:
            logger.error("renewal_error sub_id=%s error=%s", sub_id, exc)
            await _handle_renewal_failure(session, sub, now, settings)
            failed += 1
        else:
            renewed += 1

    # Stale order cleanup
    stale_threshold = now - timedelta(hours=settings.stale_order_timeout_hours)
    await session.execute(
        update(BillingOrder)
        .where(BillingOrder.status == "pending", BillingOrder.created_at < stale_threshold)
        .values(status="canceled", updated_at=now)
    )

    await session.commit()
    return {"renewed": renewed, "failed": failed, "claimed": len(claimed_ids), "stale_cleaned": True}


async def _handle_renewal_failure(
    session: AsyncSession,
    sub: BillingSubscription,
    now: datetime,
    settings,
) -> None:
    if not settings.subscription_retry_enabled:
        sub.status = "suspended"
        sub.next_retry_at = None
        logger.warning("subscription_suspended_no_retry sub_id=%s", sub.id)
        return

    sub.retry_count += 1
    sub.last_retry_at = now

    if sub.retry_count >= 3:
        sub.status = "suspended"
        sub.next_retry_at = None
    elif sub.retry_count == 1:
        sub.status = "past_due"
        sub.next_retry_at = now + timedelta(hours=24)
    else:
        sub.status = "past_due"
        sub.next_retry_at = now + timedelta(hours=72)

    logger.warning(
        "renewal_failed sub_id=%s retry_count=%s next_retry=%s",
        sub.id, sub.retry_count, sub.next_retry_at,
    )


async def _get_user_id_for_sub(session: AsyncSession, sub: BillingSubscription) -> str:
    result = await session.execute(
        select(BillingCustomer.user_id).where(
            BillingCustomer.id == sub.billing_customer_id
        )
    )
    return result.scalars().one()
