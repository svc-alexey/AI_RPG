from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal, ROUND_HALF_UP
from typing import Any
from urllib.parse import urlencode

import httpx
from fastapi import HTTPException, status

from app.core.config import get_settings


def _money_minor_to_value(amount_minor: int) -> str:
    value = (Decimal(int(amount_minor)) / Decimal("100")).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP,
    )
    return format(value, "f")


@dataclass(frozen=True)
class YooKassaPayment:
    payment_id: str
    status: str
    confirmation_url: str
    expires_at: datetime | None
    payment_method_id: str
    payment_method_saved: bool
    raw: dict[str, Any]


class YooKassaClient:
    def __init__(self) -> None:
        self._settings = get_settings()

    @property
    def is_configured(self) -> bool:
        return bool(
            self._settings.yookassa_shop_id.strip()
            and self._settings.yookassa_secret_key.strip()
        )

    @property
    def fake_provider_enabled(self) -> bool:
        return bool(self._settings.billing_fake_provider_enabled)

    async def create_payment(
        self,
        *,
        idempotence_key: str,
        amount_minor: int,
        currency: str,
        description: str,
        return_url: str,
        receipt_email: str,
        metadata: dict[str, str],
        save_payment_method: bool,
        payment_method_id: str | None = None,
    ) -> YooKassaPayment:
        if self.fake_provider_enabled and not self.is_configured:
            return self._create_fake_payment(
                amount_minor=amount_minor,
                currency=currency,
                description=description,
                return_url=return_url,
                metadata=metadata,
                save_payment_method=save_payment_method,
                payment_method_id=payment_method_id,
            )
        if not self.is_configured:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="billing_provider_not_configured",
            )

        payload: dict[str, Any] = {
            "amount": {
                "value": _money_minor_to_value(amount_minor),
                "currency": currency,
            },
            "capture": True,
            "description": description[:128],
            "confirmation": {
                "type": "redirect",
                "return_url": return_url,
            },
            "metadata": metadata,
            "save_payment_method": save_payment_method,
            "receipt": {
                "customer": {"email": receipt_email},
                "items": [
                    {
                        "description": description[:128],
                        "quantity": "1.00",
                        "amount": {
                            "value": _money_minor_to_value(amount_minor),
                            "currency": currency,
                        },
                        "vat_code": 1,
                        "payment_mode": "full_prepayment",
                        "payment_subject": "service",
                    }
                ],
            },
        }
        if payment_method_id:
            payload["payment_method_id"] = payment_method_id

        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                "https://api.yookassa.ru/v3/payments",
                auth=(
                    self._settings.yookassa_shop_id,
                    self._settings.yookassa_secret_key,
                ),
                headers={"Idempotence-Key": idempotence_key},
                json=payload,
            )
        if response.status_code < 200 or response.status_code >= 300:
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="billing_provider_request_failed",
            )
        return self._parse_payment(response.json())

    def build_fake_completed_payment(
        self,
        *,
        order_id: str,
        amount_minor: int,
        currency: str,
        description: str,
        metadata: dict[str, Any],
        saved_payment_method: bool,
    ) -> dict[str, Any]:
        now = datetime.now(UTC)
        return {
            "id": f"fake_{order_id}",
            "status": "succeeded",
            "paid": True,
            "captured_at": now.isoformat().replace("+00:00", "Z"),
            "amount": {
                "value": _money_minor_to_value(amount_minor),
                "currency": currency,
            },
            "description": description[:128],
            "metadata": metadata,
            "payment_method": {
                "type": "bank_card",
                "id": f"fake_pm_{order_id}",
                "saved": saved_payment_method,
                "card": {
                    "last4": "4242",
                    "card_type": "MIR",
                },
            },
        }

    def _create_fake_payment(
        self,
        *,
        amount_minor: int,
        currency: str,
        description: str,
        return_url: str,
        metadata: dict[str, str],
        save_payment_method: bool,
        payment_method_id: str | None,
    ) -> YooKassaPayment:
        now = datetime.now(UTC)
        order_id = str(metadata.get("order_id", "")).strip()
        payment_id = f"fake_{order_id or int(now.timestamp())}"
        payment_method = {
            "type": "bank_card",
            "id": payment_method_id or f"fake_pm_{order_id or 'new'}",
            "saved": bool(payment_method_id or save_payment_method),
            "card": {
                "last4": "4242",
                "card_type": "MIR",
            },
        }
        status_value = "succeeded" if payment_method_id else "pending"
        confirmation_url = self._build_fake_confirmation_url(
            order_id=order_id,
            return_url=return_url,
        )
        raw: dict[str, Any] = {
            "id": payment_id,
            "status": status_value,
            "amount": {
                "value": _money_minor_to_value(amount_minor),
                "currency": currency,
            },
            "description": description[:128],
            "metadata": metadata,
            "paid": status_value == "succeeded",
            "captured_at": now.isoformat().replace("+00:00", "Z"),
            "expires_at": now.isoformat().replace("+00:00", "Z"),
            "payment_method": payment_method,
            "confirmation": {
                "type": "redirect",
                "confirmation_url": confirmation_url,
            },
        }
        return YooKassaPayment(
            payment_id=payment_id,
            status=status_value,
            confirmation_url=confirmation_url,
            expires_at=now,
            payment_method_id=str(payment_method["id"]),
            payment_method_saved=bool(payment_method["saved"]),
            raw=raw,
        )

    def _build_fake_confirmation_url(self, *, order_id: str, return_url: str) -> str:
        base = (self._settings.web_public_origin or "").strip().rstrip("/")
        if not base:
            base = "http://127.0.0.1:3010"
        query = urlencode({"return_url": return_url})
        return f"{base}/v1/billing/fake/checkout/{order_id}?{query}"

    def _parse_payment(self, payload: dict[str, Any]) -> YooKassaPayment:
        confirmation = payload.get("confirmation") or {}
        payment_method = payload.get("payment_method") or {}
        expires_at = _parse_dt(payload.get("expires_at"))
        return YooKassaPayment(
            payment_id=str(payload.get("id", "")).strip(),
            status=str(payload.get("status", "")).strip() or "pending",
            confirmation_url=str(confirmation.get("confirmation_url", "")).strip(),
            expires_at=expires_at,
            payment_method_id=str(payment_method.get("id", "")).strip(),
            payment_method_saved=bool(payment_method.get("saved", False)),
            raw=payload,
        )


def _parse_dt(value: object) -> datetime | None:
    raw = str(value or "").strip()
    if not raw:
        return None
    try:
        return datetime.fromisoformat(raw.replace("Z", "+00:00")).astimezone(UTC)
    except ValueError:
        return None
