import pytest
from unittest.mock import AsyncMock, MagicMock

from app.services.billing_service import create_checkout, process_payment_succeeded
from app.services.yookassa_client import YooKassaClient, YooKassaPaymentResult
from app.core.billing_errors import CheckoutFailedError, PlanNotFoundError
from app.db.models import BillingOrder, BillingPlan, CreditLedger


class _FakeResult:
    def __init__(self, scalar) -> None:
        self._scalar = scalar

    def scalars(self):
        return _FakeScalars(self._scalar)

    def first(self):
        if isinstance(self._scalar, list):
            return self._scalar[0] if self._scalar else None
        return self._scalar


class _FakeScalars:
    def __init__(self, data) -> None:
        self._data = data

    def first(self):
        if isinstance(self._data, list):
            return self._data[0] if self._data else None
        return self._data

    def all(self):
        if isinstance(self._data, list):
            return self._data
        return [self._data] if self._data else []


def _plan(code="pack_10m", kind="token_pack", price=9900, token_grant=10_000_000):
    return BillingPlan(
        id="plan_id_" + code,
        code=code,
        title="Test Plan",
        metadata_json={
            "kind": kind,
            "base_price_minor": price,
            "sale_price_minor": price,
            "token_grant": token_grant,
            "currency": "RUB",
        },
    )


def _order(
    order_id="order_1",
    user_id="user_1",
    plan_code="pack_10m",
    status="pending",
    provider_payment_id=None,
):
    return BillingOrder(
        id=order_id,
        user_id=user_id,
        plan_code=plan_code,
        provider="yookassa",
        provider_payment_id=provider_payment_id,
        idempotency_key=order_id,
        amount_minor=9900,
        currency="RUB",
        status=status,
        return_url="https://test/",
    )


class TestCheckout:
    @pytest.mark.asyncio
    async def test_checkout_success(self):
        mock_execute = AsyncMock(return_value=_FakeResult(_plan()))
        session = MagicMock()
        session.execute = mock_execute
        session.add = MagicMock()
        session.flush = AsyncMock()

        mock_yookassa = MagicMock(spec=YooKassaClient)
        mock_yookassa.create_payment.return_value = YooKassaPaymentResult(
            payment_id="payment_123",
            confirmation_url="https://yookassa.ru/test",
            status="pending",
            payment_method_id=None,
        )

        result = await create_checkout(session, "user_1", "pack_10m", "https://test/", mock_yookassa)

        assert result.order_id
        assert result.confirmation_url == "https://yookassa.ru/test"
        assert result.amount_minor == 9900
        assert result.currency == "RUB"

    @pytest.mark.asyncio
    async def test_checkout_plan_not_found(self):
        mock_execute = AsyncMock(return_value=_FakeResult(None))
        session = MagicMock()
        session.execute = mock_execute

        mock_yookassa = MagicMock(spec=YooKassaClient)

        with pytest.raises(PlanNotFoundError):
            await create_checkout(session, "user_1", "nonexistent", "https://test/", mock_yookassa)

    @pytest.mark.asyncio
    async def test_checkout_welcome_free_plan(self):
        mock_execute = AsyncMock(
            return_value=_FakeResult(_plan("free_welcome_1m", kind="welcome", price=0))
        )
        session = MagicMock()
        session.execute = mock_execute

        mock_yookassa = MagicMock(spec=YooKassaClient)

        with pytest.raises(CheckoutFailedError):
            await create_checkout(session, "user_1", "free_welcome_1m", "https://test/", mock_yookassa)


class TestProcessPaymentSucceeded:
    @pytest.mark.asyncio
    async def test_webhook_payment_succeeded(self):
        order = _order(status="pending", provider_payment_id="payment_123")
        plan = _plan()

        session = MagicMock()
        session.add = MagicMock()
        session.flush = AsyncMock()

        call_count = 0

        async def fake_execute(stmt):
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return _FakeResult(order)
            else:
                return _FakeResult(plan)

        session.execute = fake_execute

        await process_payment_succeeded(session, "payment_123")

        assert order.status == "succeeded"
        assert session.add.call_count == 1
        ledger = session.add.call_args[0][0]
        assert isinstance(ledger, CreditLedger)
        assert ledger.amount == 10_000_000

    @pytest.mark.asyncio
    async def test_webhook_duplicate_idempotent(self):
        order = _order(status="succeeded", provider_payment_id="payment_123")

        session = MagicMock()
        session.add = MagicMock()
        session.flush = AsyncMock()
        session.execute = AsyncMock(return_value=_FakeResult(order))

        await process_payment_succeeded(session, "payment_123")

        session.add.assert_not_called()

    @pytest.mark.asyncio
    async def test_webhook_missing_payment_id(self):
        session = MagicMock()
        session.add = MagicMock()
        session.flush = AsyncMock()
        session.execute = AsyncMock(return_value=_FakeResult(None))

        await process_payment_succeeded(session, "unknown_payment")

        session.add.assert_not_called()


class TestWebhookHandler:
    @pytest.mark.asyncio
    async def test_webhook_invalid_json(self):
        from httpx import AsyncClient, ASGITransport
        from app.main import app

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/v1/billing/webhook/yookassa",
                content=b"not json",
                headers={"Content-Type": "application/json"},
            )

        assert response.status_code == 400

    @pytest.mark.asyncio
    async def test_webhook_notification_type_check(self):
        from httpx import AsyncClient, ASGITransport
        from app.main import app

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/v1/billing/webhook/yookassa",
                json={
                    "type": "not-a-notification",
                    "event": "payment.succeeded",
                    "object": {"id": "test"},
                },
            )

        assert response.status_code == 200
        assert response.json() == {"received": True}

    @pytest.mark.asyncio
    async def test_webhook_missing_payment_id(self):
        from httpx import AsyncClient, ASGITransport
        from app.main import app

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/v1/billing/webhook/yookassa",
                json={
                    "type": "notification",
                    "event": "payment.succeeded",
                    "object": {"status": "succeeded"},
                },
            )

        assert response.status_code == 200
        assert response.json() == {"received": True}
