import uuid
from datetime import datetime

from pydantic import BaseModel, Field


def new_id() -> str:
    return uuid.uuid4().hex


class BillingPlanResponse(BaseModel):
    code: str
    kind: str  # welcome | token_pack | subscription
    title: str
    description: str = ""
    currency: str = "RUB"
    base_price_minor: int  # копейки
    sale_price_minor: int | None = None
    sale_badge_text: str | None = None
    sale_percent: int | None = None
    token_grant: int = 0
    featured: bool = False
    is_active: bool = True
    sort_order: int = 0


class BillingWalletResponse(BaseModel):
    welcome_tokens_remaining: int = 0
    paid_tokens_remaining: int = 0
    subscription_tokens_remaining: int = 0
    total_tokens_remaining: int = 0
    subscription_quota_resets_at: datetime | None = None
    welcome_expires_at: datetime | None = None


class TransactionResponse(BaseModel):
    id: str
    amount: int
    reason: str
    source: str = ""
    plan_code: str | None = None
    campaign_id: str | None = None
    created_at: datetime


class CheckoutRequest(BaseModel):
    plan_code: str
    return_url: str = "/"


class CheckoutResponse(BaseModel):
    order_id: str
    confirmation_url: str
    amount_minor: int
    currency: str = "RUB"
