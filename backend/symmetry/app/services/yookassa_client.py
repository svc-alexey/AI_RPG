import hashlib
import hmac
import logging
from dataclasses import dataclass

from yookassa import Configuration, Payment
from yookassa.domain.exceptions import ApiError

from app.core.config import get_settings

logger = logging.getLogger("symmetry.billing")


@dataclass
class YooKassaPaymentResult:
    payment_id: str
    confirmation_url: str | None
    status: str
    payment_method_id: str | None


class YooKassaClientError(Exception):
    pass


class YooKassaClient:
    def __init__(self) -> None:
        settings = get_settings()
        self._shop_id = settings.yookassa_shop_id
        self._configured = bool(self._shop_id and settings.yookassa_secret_key)
        if self._configured:
            Configuration.configure(self._shop_id, settings.yookassa_secret_key)

    def _ensure_configured(self) -> None:
        if not self._configured:
            raise YooKassaClientError("yookassa_not_configured")

    def create_payment(
        self,
        amount_minor: int,
        currency: str,
        order_id: str,
        return_url: str,
        *,
        save_payment_method: bool = False,
    ) -> YooKassaPaymentResult:
        self._ensure_configured()
        try:
            payment = Payment.create({
                "amount": {
                    "value": f"{amount_minor / 100:.2f}",
                    "currency": currency,
                },
                "confirmation": {
                    "type": "redirect",
                    "return_url": return_url,
                },
                "capture": True,
                "save_payment_method": save_payment_method,
                "metadata": {
                    "order_id": order_id,
                },
            }, idempotency_key=order_id)
        except ApiError as exc:
            logger.error("yookassa_create_payment_failed order_id=%s error=%s", order_id, exc)
            raise YooKassaClientError(str(exc)) from exc

        return YooKassaPaymentResult(
            payment_id=payment.id,
            confirmation_url=payment.confirmation.confirmation_url if payment.confirmation else None,
            status=payment.status,
            payment_method_id=None,
        )

    def create_recurring_payment(
        self,
        amount_minor: int,
        currency: str,
        order_id: str,
        payment_method_id: str,
    ) -> YooKassaPaymentResult:
        self._ensure_configured()
        try:
            payment = Payment.create({
                "amount": {
                    "value": f"{amount_minor / 100:.2f}",
                    "currency": currency,
                },
                "payment_method_id": payment_method_id,
                "capture": True,
                "metadata": {
                    "order_id": order_id,
                },
            }, idempotency_key=order_id)
        except ApiError as exc:
            logger.error("yookassa_recurring_payment_failed order_id=%s error=%s", order_id, exc)
            raise YooKassaClientError(str(exc)) from exc

        return YooKassaPaymentResult(
            payment_id=payment.id,
            confirmation_url=None,
            status=payment.status,
            payment_method_id=payment.payment_method.id if payment.payment_method else None,
        )

    def get_payment(self, payment_id: str) -> YooKassaPaymentResult:
        self._ensure_configured()
        try:
            payment = Payment.find_one(payment_id)
        except ApiError as exc:
            logger.error("yookassa_get_payment_failed payment_id=%s error=%s", payment_id, exc)
            raise YooKassaClientError(str(exc)) from exc

        pm = payment.payment_method
        return YooKassaPaymentResult(
            payment_id=payment.id,
            confirmation_url=payment.confirmation.confirmation_url if payment.confirmation else None,
            status=payment.status,
            payment_method_id=pm.id if pm else None,
        )

    def create_refund(self, payment_id: str, amount_minor: int, currency: str = "RUB") -> str:
        from yookassa import Refund
        self._ensure_configured()
        try:
            refund = Refund.create({
                "amount": {
                    "value": f"{amount_minor / 100:.2f}",
                    "currency": currency,
                },
                "payment_id": payment_id,
            })
        except ApiError as exc:
            logger.error("yookassa_refund_failed payment_id=%s error=%s", payment_id, exc)
            raise YooKassaClientError(str(exc)) from exc
        return refund.id

    @staticmethod
    def verify_webhook_signature(body: bytes, signature: str | None) -> bool:
        settings = get_settings()
        if not settings.yookassa_webhook_secret:
            return True  # Verification not configured
        if not signature:
            return False
        expected = hmac.new(
            settings.yookassa_webhook_secret.encode(),
            body,
            hashlib.sha256,
        ).hexdigest()
        return hmac.compare_digest(expected, signature)
