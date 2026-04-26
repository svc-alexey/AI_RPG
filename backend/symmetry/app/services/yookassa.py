from dataclasses import dataclass
from datetime import UTC, datetime
from decimal import Decimal, ROUND_HALF_UP
from typing import Any

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
