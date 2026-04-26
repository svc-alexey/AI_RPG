from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Any
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from fastapi import HTTPException, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.models import (
    BillingCustomer,
    BillingOrder,
    BillingPlan,
    BillingSubscription,
    BillingWallet,
    CreditLedger,
    PaymentEvent,
    User,
)
from app.schemas.billing import (
    BillingCatalogItemResponse,
    BillingCheckoutResponse,
    BillingHistoryItemResponse,
    BillingOrderStatusResponse,
    BillingSummaryResponse,
)
from app.services.ids import new_id
from app.services.yookassa import YooKassaClient

WELCOME_PLAN_CODE = "free_welcome_1m"
WELCOME_GRANT_REASON = "welcome_grant"
SUBSCRIPTION_GRANT_REASON = "subscription_quota_grant"
TOKEN_PACK_GRANT_REASON = "token_pack_purchase"
TOKEN_USAGE_REASON = "ai_usage"
REFUND_REVERSAL_REASON = "refund_reversal"
RENEWAL_RETRY_WINDOWS = (
    timedelta(hours=3),
    timedelta(hours=24),
    timedelta(hours=72),
)


class BillingService:
    def __init__(self) -> None:
        self._settings = get_settings()
        self._yookassa = YooKassaClient()

    async def ensure_catalog_seeded(self, session: AsyncSession) -> None:
        existing = await session.execute(select(BillingPlan.code))
        existing_codes = {code for (code,) in existing.all()}
        now = datetime.now(UTC)
        for seed in self._default_plan_seeds():
            if seed["code"] in existing_codes:
                continue
            session.add(
                BillingPlan(
                    id=new_id(),
                    code=str(seed["code"]),
                    kind=str(seed["kind"]),
                    title=str(seed["title"]),
                    description=str(seed["description"]),
                    currency=str(seed["currency"]),
                    base_price_minor=int(seed["base_price_minor"]),
                    sale_price_minor=(
                        int(seed["sale_price_minor"])
                        if seed["sale_price_minor"] is not None
                        else None
                    ),
                    sale_badge_text=str(seed["sale_badge_text"]),
                    sale_percent=int(seed["sale_percent"]),
                    sale_starts_at=seed["sale_starts_at"],
                    sale_ends_at=seed["sale_ends_at"],
                    is_active=bool(seed["is_active"]),
                    token_grant=int(seed["token_grant"]),
                    monthly_quota=int(seed["monthly_quota"]),
                    fair_use_limit=int(seed["fair_use_limit"]),
                    sort_order=int(seed["sort_order"]),
                    created_at=now,
                    updated_at=now,
                    metadata_json=dict(seed["metadata"]),
                )
            )
        await session.flush()

    async def ensure_customer(self, session: AsyncSession, *, user_id: str) -> BillingCustomer:
        customer = await session.scalar(select(BillingCustomer).where(BillingCustomer.user_id == user_id))
        if customer is not None:
            return customer
        customer = BillingCustomer(id=new_id(), user_id=user_id, metadata_json={})
        session.add(customer)
        await session.flush()
        return customer

    async def ensure_wallet(self, session: AsyncSession, *, user_id: str) -> BillingWallet:
        wallet = await session.scalar(select(BillingWallet).where(BillingWallet.user_id == user_id))
        if wallet is not None:
            return wallet
        wallet = BillingWallet(id=new_id(), user_id=user_id)
        session.add(wallet)
        await session.flush()
        return wallet

    async def get_catalog(self, session: AsyncSession) -> list[BillingCatalogItemResponse]:
        await self.ensure_catalog_seeded(session)
        result = await session.execute(
            select(BillingPlan)
            .where(BillingPlan.is_active.is_(True))
            .order_by(BillingPlan.sort_order.asc(), BillingPlan.title.asc())
        )
        return [self._catalog_item_response(item) for item in result.scalars().all()]

    async def build_summary(
        self,
        session: AsyncSession,
        *,
        user: User | None,
    ) -> BillingSummaryResponse:
        await self.ensure_catalog_seeded(session)
        if user is None:
            return BillingSummaryResponse(
                is_authenticated=False,
                is_guest=False,
                entitlement_status="anonymous",
                paywall_reason="billing_account_required",
            )
        if self._is_guest_user(user):
            return BillingSummaryResponse(
                user_id=user.id,
                is_authenticated=True,
                is_guest=True,
                entitlement_status="guest",
                paywall_reason="billing_account_required",
            )

        await self._expire_welcome_tokens_if_needed(session, user_id=user.id)
        customer = await self.ensure_customer(session, user_id=user.id)
        wallet = await self.ensure_wallet(session, user_id=user.id)
        subscription, plan = await self._load_user_subscription(session, customer.id)
        await self._normalize_subscription_end_state(
            session,
            subscription=subscription,
            wallet=wallet,
        )
        total_remaining = max(0, wallet.subscription_tokens_remaining) + max(
            0, wallet.welcome_tokens_remaining
        ) + max(0, wallet.paid_tokens_remaining)
        subscription_status = subscription.status if subscription is not None else None
        paywall_reason: str | None = None
        entitlement_status = "active"
        if subscription_status in {"past_due", "suspended"} and total_remaining <= 0:
            entitlement_status = "past_due"
            paywall_reason = "subscription_past_due"
        elif total_remaining <= 0:
            entitlement_status = "empty"
            paywall_reason = "free_quota_exhausted"

        return BillingSummaryResponse(
            user_id=user.id,
            is_authenticated=True,
            is_guest=False,
            entitlement_status=entitlement_status,
            paywall_reason=paywall_reason,
            active_plan_code=plan.code if plan is not None else None,
            active_plan_title=plan.title if plan is not None else None,
            subscription_status=subscription_status,
            cancel_at_period_end=bool(subscription.cancel_at_period_end) if subscription else False,
            current_period_end_at=subscription.current_period_end_at if subscription else None,
            next_charge_at=subscription.next_charge_at if subscription else None,
            welcome_tokens_remaining=max(0, wallet.welcome_tokens_remaining),
            paid_tokens_remaining=max(0, wallet.paid_tokens_remaining),
            subscription_tokens_remaining=max(0, wallet.subscription_tokens_remaining),
            total_tokens_remaining=max(0, total_remaining),
            welcome_expires_at=wallet.welcome_expires_at,
            subscription_quota_resets_at=wallet.subscription_quota_resets_at,
            masked_payment_method_label=(
                str((subscription.metadata_json or {}).get("masked_payment_method_label", ""))
                if subscription is not None
                else ""
            ),
        )

    async def get_history(
        self,
        session: AsyncSession,
        *,
        user_id: str,
    ) -> list[BillingHistoryItemResponse]:
        await self.ensure_catalog_seeded(session)
        plan_rows = await session.execute(select(BillingPlan.code, BillingPlan.title))
        titles = {code: title for code, title in plan_rows.all()}
        result = await session.execute(
            select(BillingOrder)
            .where(BillingOrder.user_id == user_id)
            .order_by(desc(BillingOrder.created_at))
            .limit(50)
        )
        return [
            BillingHistoryItemResponse(
                order_id=row.id,
                plan_code=row.plan_code,
                title=titles.get(row.plan_code, row.plan_code),
                kind=row.kind,
                provider=row.provider,
                provider_payment_id=row.provider_payment_id,
                status=row.status,
                amount_minor=row.amount_minor,
                currency=row.currency,
                created_at=row.created_at,
                updated_at=row.updated_at,
            )
            for row in result.scalars().all()
        ]

    async def create_checkout(
        self,
        session: AsyncSession,
        *,
        user: User,
        plan_code: str,
    ) -> BillingCheckoutResponse:
        await self.ensure_catalog_seeded(session)
        if self._is_guest_user(user):
            raise HTTPException(status_code=402, detail="billing_account_required")
        plan = await session.scalar(
            select(BillingPlan).where(BillingPlan.code == plan_code, BillingPlan.is_active.is_(True))
        )
        if plan is None:
            raise HTTPException(status_code=404, detail="billing_plan_not_found")
        customer = await self.ensure_customer(session, user_id=user.id)
        await self.ensure_wallet(session, user_id=user.id)
        order_id = new_id()
        order = BillingOrder(
            id=order_id,
            user_id=user.id,
            plan_code=plan.code,
            kind=plan.kind,
            provider="yookassa",
            provider_payment_id="",
            status="pending",
            amount_minor=self._effective_price_minor(plan),
            currency=plan.currency,
            idempotence_key=new_id(),
            return_url=self._build_return_url(order_id),
            confirmation_url="",
            metadata_json={
                "billing_customer_id": customer.id,
                "plan_code": plan.code,
                "plan_title": plan.title,
            },
        )
        session.add(order)
        await session.flush()
        payment = await self._yookassa.create_payment(
            idempotence_key=order.idempotence_key,
            amount_minor=order.amount_minor,
            currency=order.currency,
            description=plan.title,
            return_url=order.return_url,
            receipt_email=user.email,
            metadata={
                "order_id": order.id,
                "user_id": user.id,
                "plan_code": plan.code,
                "billing_customer_id": customer.id,
                "kind": plan.kind,
            },
            save_payment_method=plan.kind == "subscription",
        )
        order.provider_payment_id = payment.payment_id
        order.status = payment.status or "pending"
        order.confirmation_url = payment.confirmation_url
        order.updated_at = datetime.now(UTC)
        order.metadata_json = {
            **(order.metadata_json or {}),
            "provider_raw": payment.raw,
        }
        return BillingCheckoutResponse(
            order_id=order.id,
            provider_payment_id=order.provider_payment_id,
            confirmation_url=order.confirmation_url,
            expires_at=payment.expires_at,
            status=order.status,
        )

    async def get_order_status(
        self,
        session: AsyncSession,
        *,
        user_id: str,
        order_id: str,
    ) -> BillingOrderStatusResponse:
        order = await session.scalar(
            select(BillingOrder).where(BillingOrder.id == order_id, BillingOrder.user_id == user_id)
        )
        if order is None:
            raise HTTPException(status_code=404, detail="billing_order_not_found")
        return BillingOrderStatusResponse(
            order_id=order.id,
            plan_code=order.plan_code,
            status=order.status,
            confirmation_url=order.confirmation_url,
            provider_payment_id=order.provider_payment_id,
            amount_minor=order.amount_minor,
            currency=order.currency,
            updated_at=order.updated_at,
        )

    async def cancel_subscription(
        self,
        session: AsyncSession,
        *,
        user_id: str,
    ) -> BillingSummaryResponse:
        customer = await session.scalar(
            select(BillingCustomer).where(BillingCustomer.user_id == user_id)
        )
        if customer is None:
            raise HTTPException(status_code=404, detail="billing_subscription_not_found")
        subscription, _ = await self._load_user_subscription(session, customer.id)
        if subscription is None:
            raise HTTPException(status_code=404, detail="billing_subscription_not_found")
        subscription.cancel_at_period_end = True
        if subscription.status == "active":
            subscription.status = "canceling"
        subscription.updated_at = datetime.now(UTC)
        await session.flush()
        user = await session.get(User, user_id)
        return await self.build_summary(session, user=user)

    async def grant_welcome_tokens(self, session: AsyncSession, *, user_id: str) -> None:
        await self.ensure_catalog_seeded(session)
        existing = await session.scalar(
            select(CreditLedger).where(
                CreditLedger.user_id == user_id,
                CreditLedger.reason == WELCOME_GRANT_REASON,
            )
        )
        if existing is not None:
            return
        plan = await session.scalar(select(BillingPlan).where(BillingPlan.code == WELCOME_PLAN_CODE))
        if plan is None or plan.token_grant <= 0:
            return
        wallet = await self.ensure_wallet(session, user_id=user_id)
        wallet.welcome_tokens_remaining += plan.token_grant
        wallet.welcome_expires_at = datetime.now(UTC) + timedelta(days=30)
        wallet.updated_at = datetime.now(UTC)
        session.add(
            CreditLedger(
                id=new_id(),
                user_id=user_id,
                amount=plan.token_grant,
                reason=WELCOME_GRANT_REASON,
                metadata_json={"plan_code": plan.code},
            )
        )
        await session.flush()

    async def ensure_ai_access(self, session: AsyncSession, *, user: User) -> None:
        if self._is_guest_user(user):
            raise HTTPException(status_code=402, detail="billing_account_required")
        summary = await self.build_summary(session, user=user)
        if summary.subscription_status in {"past_due", "suspended"} and summary.total_tokens_remaining <= 0:
            raise HTTPException(status_code=402, detail="subscription_past_due")
        if summary.total_tokens_remaining <= 0:
            if summary.active_plan_code:
                raise HTTPException(status_code=402, detail="subscription_required")
            raise HTTPException(status_code=402, detail="free_quota_exhausted")

    async def consume_tokens(
        self,
        session: AsyncSession,
        *,
        user_id: str,
        total_tokens: int,
        reason: str,
        metadata: dict[str, Any] | None = None,
    ) -> None:
        tokens_to_consume = max(0, int(total_tokens))
        if tokens_to_consume <= 0:
            return
        await self._expire_welcome_tokens_if_needed(session, user_id=user_id)
        wallet = await self.ensure_wallet(session, user_id=user_id)
        remaining = tokens_to_consume
        sub_spent = min(remaining, max(0, wallet.subscription_tokens_remaining))
        wallet.subscription_tokens_remaining -= sub_spent
        remaining -= sub_spent
        welcome_spent = min(remaining, max(0, wallet.welcome_tokens_remaining))
        wallet.welcome_tokens_remaining -= welcome_spent
        remaining -= welcome_spent
        paid_spent = min(remaining, max(0, wallet.paid_tokens_remaining))
        wallet.paid_tokens_remaining -= paid_spent
        remaining -= paid_spent
        actual_spent = tokens_to_consume - max(0, remaining)
        wallet.updated_at = datetime.now(UTC)
        session.add(
            CreditLedger(
                id=new_id(),
                user_id=user_id,
                amount=-actual_spent,
                reason=TOKEN_USAGE_REASON,
                metadata_json={
                    "source": reason,
                    "requested_total_tokens": tokens_to_consume,
                    "consumed_total_tokens": actual_spent,
                    "subscription_tokens": sub_spent,
                    "welcome_tokens": welcome_spent,
                    "paid_tokens": paid_spent,
                    **(metadata or {}),
                },
            )
        )
        await session.flush()

    async def handle_webhook(self, session: AsyncSession, *, payload: dict[str, Any]) -> None:
        await self.ensure_catalog_seeded(session)
        event_type = str(payload.get("event", "")).strip()
        obj = payload.get("object") or {}
        if not event_type or not isinstance(obj, dict):
            raise HTTPException(status_code=400, detail="invalid_billing_webhook")
        provider_event_id = f"{event_type}:{obj.get('id') or obj.get('payment_id') or ''}"
        existing = await session.scalar(
            select(PaymentEvent).where(
                PaymentEvent.provider == "yookassa",
                PaymentEvent.provider_event_id == provider_event_id,
                PaymentEvent.event_type == event_type,
            )
        )
        if existing is not None:
            return
        customer_id = str(((obj.get("metadata") or {}).get("billing_customer_id")) or "").strip()
        session.add(
            PaymentEvent(
                id=new_id(),
                billing_customer_id=customer_id or None,
                provider="yookassa",
                provider_event_id=provider_event_id,
                event_type=event_type,
                payload_json=payload,
            )
        )
        await session.flush()
        if event_type == "payment.succeeded":
            await self._handle_payment_succeeded(session, payment=obj)
        elif event_type == "payment.canceled":
            await self._handle_payment_canceled(session, payment=obj)
        elif event_type == "refund.succeeded":
            await self._handle_refund_succeeded(session, refund=obj)

    async def run_due_renewals(self, session: AsyncSession) -> int:
        await self.ensure_catalog_seeded(session)
        now = datetime.now(UTC)
        result = await session.execute(
            select(BillingSubscription).where(
                BillingSubscription.status.in_(("active", "canceling", "past_due", "suspended"))
            )
        )
        processed = 0
        for subscription in result.scalars().all():
            customer = await session.get(BillingCustomer, subscription.billing_customer_id)
            if customer is None:
                continue
            wallet = await session.scalar(
                select(BillingWallet).where(BillingWallet.user_id == customer.user_id)
            )
            if subscription.current_period_end_at and subscription.current_period_end_at <= now:
                if subscription.cancel_at_period_end:
                    subscription.status = "canceled"
                    subscription.updated_at = now
                    if wallet is not None:
                        wallet.subscription_tokens_remaining = 0
                        wallet.updated_at = now
                    processed += 1
                    continue
            if subscription.cancel_at_period_end:
                continue
            if subscription.next_charge_at is None or subscription.next_charge_at > now:
                continue
            plan = await session.get(BillingPlan, subscription.billing_plan_id)
            user = await session.get(User, customer.user_id)
            if plan is None or user is None:
                continue
            if not subscription.payment_method_id:
                await self._schedule_retry(session, subscription=subscription, user_id=user.id)
                processed += 1
                continue
            order = BillingOrder(
                id=new_id(),
                user_id=user.id,
                plan_code=plan.code,
                kind=plan.kind,
                provider="yookassa",
                provider_payment_id="",
                status="pending",
                amount_minor=self._effective_price_minor(plan),
                currency=plan.currency,
                idempotence_key=new_id(),
                return_url=self._build_return_url(new_id()),
                confirmation_url="",
                metadata_json={
                    "billing_customer_id": customer.id,
                    "plan_code": plan.code,
                    "renewal": True,
                },
            )
            session.add(order)
            await session.flush()
            try:
                payment = await self._yookassa.create_payment(
                    idempotence_key=order.idempotence_key,
                    amount_minor=order.amount_minor,
                    currency=order.currency,
                    description=f"{plan.title} renewal",
                    return_url=order.return_url,
                    receipt_email=user.email,
                    metadata={
                        "order_id": order.id,
                        "user_id": user.id,
                        "plan_code": plan.code,
                        "billing_customer_id": customer.id,
                        "kind": plan.kind,
                    },
                    save_payment_method=True,
                    payment_method_id=subscription.payment_method_id,
                )
            except HTTPException:
                await self._schedule_retry(session, subscription=subscription, user_id=user.id)
                processed += 1
                continue
            order.provider_payment_id = payment.payment_id
            order.confirmation_url = payment.confirmation_url
            order.status = payment.status
            order.updated_at = now
            if payment.status == "succeeded":
                await self._apply_paid_order(session, order=order, payment=payment.raw)
                subscription.retry_count = 0
                subscription.updated_at = now
            else:
                await self._schedule_retry(session, subscription=subscription, user_id=user.id)
            processed += 1
        return processed

    async def _handle_payment_succeeded(
        self,
        session: AsyncSession,
        *,
        payment: dict[str, Any],
    ) -> None:
        metadata = payment.get("metadata") or {}
        order = await self._find_order(
            session,
            order_id=str(metadata.get("order_id", "")).strip(),
            provider_payment_id=str(payment.get("id", "")).strip(),
        )
        if order is None:
            return
        await self._apply_paid_order(session, order=order, payment=payment)

    async def _handle_payment_canceled(
        self,
        session: AsyncSession,
        *,
        payment: dict[str, Any],
    ) -> None:
        metadata = payment.get("metadata") or {}
        order = await self._find_order(
            session,
            order_id=str(metadata.get("order_id", "")).strip(),
            provider_payment_id=str(payment.get("id", "")).strip(),
        )
        if order is None:
            return
        order.status = "canceled"
        order.updated_at = datetime.now(UTC)
        await session.flush()

    async def _handle_refund_succeeded(
        self,
        session: AsyncSession,
        *,
        refund: dict[str, Any],
    ) -> None:
        provider_payment_id = str(refund.get("payment_id", "")).strip()
        if not provider_payment_id:
            return
        order = await session.scalar(
            select(BillingOrder).where(BillingOrder.provider_payment_id == provider_payment_id)
        )
        if order is None:
            return
        if (order.metadata_json or {}).get("refunded_at"):
            return
        plan = await session.scalar(select(BillingPlan).where(BillingPlan.code == order.plan_code))
        if plan is None:
            return
        wallet = await self.ensure_wallet(session, user_id=order.user_id)
        reversed_amount = 0
        if order.kind == "subscription":
            reversed_amount = min(wallet.subscription_tokens_remaining, max(0, plan.monthly_quota))
            wallet.subscription_tokens_remaining -= reversed_amount
            subscription = await self._load_latest_subscription_for_user(session, user_id=order.user_id)
            if subscription is not None:
                subscription.status = "canceled"
                subscription.cancel_at_period_end = True
                subscription.updated_at = datetime.now(UTC)
        else:
            reversed_amount = min(wallet.paid_tokens_remaining, max(0, plan.token_grant))
            wallet.paid_tokens_remaining -= reversed_amount
        wallet.updated_at = datetime.now(UTC)
        if reversed_amount > 0:
            session.add(
                CreditLedger(
                    id=new_id(),
                    user_id=order.user_id,
                    amount=-reversed_amount,
                    reason=REFUND_REVERSAL_REASON,
                    metadata_json={"order_id": order.id, "plan_code": plan.code},
                )
            )
        order.status = "refunded"
        order.updated_at = datetime.now(UTC)
        order.metadata_json = {
            **(order.metadata_json or {}),
            "refunded_at": datetime.now(UTC).isoformat(),
            "refund_raw": refund,
        }
        await session.flush()

    async def _apply_paid_order(
        self,
        session: AsyncSession,
        *,
        order: BillingOrder,
        payment: dict[str, Any],
    ) -> None:
        if (order.metadata_json or {}).get("credited_at"):
            order.status = "paid"
            order.updated_at = datetime.now(UTC)
            return
        plan = await session.scalar(select(BillingPlan).where(BillingPlan.code == order.plan_code))
        if plan is None:
            return
        order.provider_payment_id = str(payment.get("id", "")).strip() or order.provider_payment_id
        order.status = "paid"
        order.updated_at = datetime.now(UTC)
        if order.kind == "subscription":
            await self._activate_subscription(session, order=order, plan=plan, payment=payment)
        else:
            await self._credit_paid_pack(session, order=order, plan=plan)
        order.metadata_json = {
            **(order.metadata_json or {}),
            "credited_at": datetime.now(UTC).isoformat(),
            "payment_raw": payment,
        }
        await session.flush()

    async def _credit_paid_pack(
        self,
        session: AsyncSession,
        *,
        order: BillingOrder,
        plan: BillingPlan,
    ) -> None:
        wallet = await self.ensure_wallet(session, user_id=order.user_id)
        grant = max(0, plan.token_grant)
        wallet.paid_tokens_remaining += grant
        wallet.updated_at = datetime.now(UTC)
        session.add(
            CreditLedger(
                id=new_id(),
                user_id=order.user_id,
                amount=grant,
                reason=TOKEN_PACK_GRANT_REASON,
                metadata_json={"order_id": order.id, "plan_code": plan.code},
            )
        )

    async def _activate_subscription(
        self,
        session: AsyncSession,
        *,
        order: BillingOrder,
        plan: BillingPlan,
        payment: dict[str, Any],
    ) -> None:
        customer = await self.ensure_customer(session, user_id=order.user_id)
        wallet = await self.ensure_wallet(session, user_id=order.user_id)
        subscription, _ = await self._load_user_subscription(session, customer.id, plan_code=plan.code)
        now = datetime.now(UTC)
        if subscription is None:
            subscription = BillingSubscription(
                id=new_id(),
                billing_customer_id=customer.id,
                billing_plan_id=plan.id,
                provider="yookassa",
                status="active",
                metadata_json={},
            )
            session.add(subscription)
            await session.flush()
        start_at = now
        if subscription.current_period_end_at and subscription.current_period_end_at > now:
            start_at = subscription.current_period_end_at
        end_at = start_at + timedelta(days=30)
        subscription.provider = "yookassa"
        subscription.payment_method_id = str(
            ((payment.get("payment_method") or {}).get("id")) or subscription.payment_method_id
        ).strip()
        subscription.status = "active"
        subscription.current_period_start_at = start_at
        subscription.current_period_end_at = end_at
        subscription.next_charge_at = end_at
        subscription.cancel_at_period_end = False
        subscription.retry_count = 0
        subscription.last_payment_id = str(payment.get("id", "")).strip()
        subscription.last_failure_code = ""
        subscription.updated_at = now
        subscription.metadata_json = {
            **(subscription.metadata_json or {}),
            "masked_payment_method_label": self._masked_payment_method_label(payment),
            "payment_method_type": str(((payment.get("payment_method") or {}).get("type")) or ""),
        }
        wallet.subscription_tokens_remaining = max(0, plan.monthly_quota)
        wallet.subscription_quota_resets_at = end_at
        wallet.updated_at = now
        session.add(
            CreditLedger(
                id=new_id(),
                user_id=order.user_id,
                amount=max(0, plan.monthly_quota),
                reason=SUBSCRIPTION_GRANT_REASON,
                metadata_json={"order_id": order.id, "plan_code": plan.code},
            )
        )

    async def _load_user_subscription(
        self,
        session: AsyncSession,
        billing_customer_id: str,
        *,
        plan_code: str | None = None,
    ) -> tuple[BillingSubscription | None, BillingPlan | None]:
        result = await session.execute(
            select(BillingSubscription, BillingPlan)
            .join(BillingPlan, BillingPlan.id == BillingSubscription.billing_plan_id)
            .where(BillingSubscription.billing_customer_id == billing_customer_id)
            .order_by(desc(BillingSubscription.updated_at), desc(BillingSubscription.created_at))
        )
        for subscription, plan in result.all():
            if plan_code is not None and plan.code != plan_code:
                continue
            return subscription, plan
        return None, None

    async def _load_latest_subscription_for_user(
        self,
        session: AsyncSession,
        *,
        user_id: str,
    ) -> BillingSubscription | None:
        customer = await session.scalar(select(BillingCustomer).where(BillingCustomer.user_id == user_id))
        if customer is None:
            return None
        subscription, _ = await self._load_user_subscription(session, customer.id)
        return subscription

    async def _find_order(
        self,
        session: AsyncSession,
        *,
        order_id: str,
        provider_payment_id: str,
    ) -> BillingOrder | None:
        if order_id:
            order = await session.get(BillingOrder, order_id)
            if order is not None:
                return order
        if provider_payment_id:
            return await session.scalar(
                select(BillingOrder).where(BillingOrder.provider_payment_id == provider_payment_id)
            )
        return None

    async def _expire_welcome_tokens_if_needed(self, session: AsyncSession, *, user_id: str) -> None:
        wallet = await session.scalar(select(BillingWallet).where(BillingWallet.user_id == user_id))
        if wallet is None or wallet.welcome_expires_at is None:
            return
        if wallet.welcome_expires_at > datetime.now(UTC):
            return
        if wallet.welcome_tokens_remaining <= 0:
            return
        wallet.welcome_tokens_remaining = 0
        wallet.updated_at = datetime.now(UTC)
        await session.flush()

    async def _normalize_subscription_end_state(
        self,
        session: AsyncSession,
        *,
        subscription: BillingSubscription | None,
        wallet: BillingWallet,
    ) -> None:
        if subscription is None or subscription.current_period_end_at is None:
            return
        now = datetime.now(UTC)
        if subscription.current_period_end_at > now:
            return
        if subscription.cancel_at_period_end and subscription.status != "canceled":
            subscription.status = "canceled"
            subscription.updated_at = now
            wallet.subscription_tokens_remaining = 0
            wallet.updated_at = now
            await session.flush()

    async def _schedule_retry(
        self,
        session: AsyncSession,
        *,
        subscription: BillingSubscription,
        user_id: str,
    ) -> None:
        now = datetime.now(UTC)
        if subscription.retry_count >= len(RENEWAL_RETRY_WINDOWS):
            subscription.status = "suspended"
            subscription.next_charge_at = None
            subscription.updated_at = now
            wallet = await self.ensure_wallet(session, user_id=user_id)
            wallet.subscription_tokens_remaining = 0
            wallet.updated_at = now
            await session.flush()
            return
        subscription.status = "past_due"
        subscription.next_charge_at = now + RENEWAL_RETRY_WINDOWS[subscription.retry_count]
        subscription.retry_count += 1
        subscription.updated_at = now
        await session.flush()

    def _catalog_item_response(self, plan: BillingPlan) -> BillingCatalogItemResponse:
        return BillingCatalogItemResponse(
            code=plan.code,
            kind=plan.kind,
            title=plan.title,
            description=plan.description,
            currency=plan.currency,
            base_price_minor=plan.base_price_minor,
            final_price_minor=self._effective_price_minor(plan),
            sale_price_minor=plan.sale_price_minor,
            is_sale_active=self._is_sale_active(plan),
            sale_badge_text=plan.sale_badge_text,
            sale_percent=plan.sale_percent,
            sale_starts_at=plan.sale_starts_at,
            sale_ends_at=plan.sale_ends_at,
            token_grant=plan.token_grant,
            monthly_quota=plan.monthly_quota,
            fair_use_limit=plan.fair_use_limit,
            is_active=plan.is_active,
            sort_order=plan.sort_order,
            metadata=plan.metadata_json or {},
        )

    def _effective_price_minor(self, plan: BillingPlan) -> int:
        if self._is_sale_active(plan) and plan.sale_price_minor is not None and plan.sale_price_minor >= 0:
            return int(plan.sale_price_minor)
        return int(plan.base_price_minor)

    def _is_sale_active(self, plan: BillingPlan) -> bool:
        if plan.sale_price_minor is None or plan.sale_price_minor >= plan.base_price_minor:
            return False
        now = datetime.now(UTC)
        if plan.sale_starts_at and plan.sale_starts_at > now:
            return False
        if plan.sale_ends_at and plan.sale_ends_at < now:
            return False
        return True

    def _build_return_url(self, order_id: str) -> str:
        raw = (self._settings.yookassa_return_url or "").strip()
        if not raw:
            raw = (self._settings.web_public_origin or "").strip().rstrip("/") or "http://127.0.0.1:3010"
        parts = urlsplit(raw)
        query = dict(parse_qsl(parts.query, keep_blank_values=True))
        query["openBilling"] = "1"
        query["checkout_order_id"] = order_id
        return urlunsplit((parts.scheme, parts.netloc, parts.path or "/", urlencode(query), parts.fragment))

    def _masked_payment_method_label(self, payment: dict[str, Any]) -> str:
        payment_method = payment.get("payment_method") or {}
        card = payment_method.get("card") or {}
        last4 = str(card.get("last4", "")).strip()
        card_type = str(card.get("card_type", "")).strip().upper()
        if last4:
            return f"{card_type or 'CARD'} •••• {last4}"
        payment_type = str(payment_method.get("type", "")).strip()
        return payment_type.upper() if payment_type else ""

    def _default_plan_seeds(self) -> list[dict[str, Any]]:
        return [
            {
                "code": "free_welcome_1m",
                "kind": "welcome",
                "title": "Welcome 1M",
                "description": "One-time starter grant after registration.",
                "currency": "RUB",
                "base_price_minor": 0,
                "sale_price_minor": None,
                "sale_badge_text": "",
                "sale_percent": 0,
                "sale_starts_at": None,
                "sale_ends_at": None,
                "is_active": True,
                "token_grant": 1_000_000,
                "monthly_quota": 0,
                "fair_use_limit": 0,
                "sort_order": 0,
                "metadata": {"expires_in_days": 30},
            },
            {
                "code": "pack_1m",
                "kind": "token_pack",
                "title": "1M tokens",
                "description": "One-time permanent token pack for extra generations.",
                "currency": "RUB",
                "base_price_minor": 10_000,
                "sale_price_minor": 7_900,
                "sale_badge_text": "-21%",
                "sale_percent": 21,
                "sale_starts_at": None,
                "sale_ends_at": None,
                "is_active": True,
                "token_grant": 1_000_000,
                "monthly_quota": 0,
                "fair_use_limit": 0,
                "sort_order": 10,
                "metadata": {"display_hint": "starter_pack"},
            },
            {
                "code": "pack_10m",
                "kind": "token_pack",
                "title": "10M tokens",
                "description": "Permanent token balance for heavy sessions.",
                "currency": "RUB",
                "base_price_minor": 50_000,
                "sale_price_minor": 39_000,
                "sale_badge_text": "Best value",
                "sale_percent": 22,
                "sale_starts_at": None,
                "sale_ends_at": None,
                "is_active": True,
                "token_grant": 10_000_000,
                "monthly_quota": 0,
                "fair_use_limit": 0,
                "sort_order": 20,
                "metadata": {"display_hint": "power_pack"},
            },
            {
                "code": "pro_monthly",
                "kind": "subscription",
                "title": "Pro monthly",
                "description": "Monthly high-cap access with fair-use auto-renew.",
                "currency": "RUB",
                "base_price_minor": 99_000,
                "sale_price_minor": 69_000,
                "sale_badge_text": "Launch offer",
                "sale_percent": 30,
                "sale_starts_at": None,
                "sale_ends_at": None,
                "is_active": True,
                "token_grant": 0,
                "monthly_quota": 20_000_000,
                "fair_use_limit": 50_000_000,
                "sort_order": 30,
                "metadata": {"billing_period": "P1M", "marketing_label": "fair_use"},
            },
        ]

    def _is_guest_user(self, user: User) -> bool:
        email = str(user.email or "").strip().lower()
        return email.startswith("guest-") and email.endswith("@symmetry.dev")
