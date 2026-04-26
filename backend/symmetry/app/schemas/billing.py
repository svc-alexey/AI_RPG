from datetime import datetime

from pydantic import BaseModel, Field


class BillingCatalogItemResponse(BaseModel):
    code: str
    kind: str
    title: str
    description: str = ""
    currency: str = "RUB"
    base_price_minor: int = 0
    final_price_minor: int = 0
    sale_price_minor: int | None = None
    is_sale_active: bool = False
    sale_badge_text: str = ""
    sale_percent: int = 0
    sale_starts_at: datetime | None = None
    sale_ends_at: datetime | None = None
    token_grant: int = 0
    monthly_quota: int = 0
    fair_use_limit: int = 0
    is_active: bool = True
    sort_order: int = 0
    metadata: dict = Field(default_factory=dict)


class BillingHistoryItemResponse(BaseModel):
    order_id: str
    plan_code: str
    title: str
    kind: str
    provider: str
    provider_payment_id: str = ""
    status: str
    amount_minor: int
    currency: str = "RUB"
    created_at: datetime
    updated_at: datetime


class BillingSummaryResponse(BaseModel):
    user_id: str | None = None
    is_authenticated: bool = False
    is_guest: bool = False
    entitlement_status: str = "guest"
    paywall_reason: str | None = None
    active_plan_code: str | None = None
    active_plan_title: str | None = None
    subscription_status: str | None = None
    cancel_at_period_end: bool = False
    current_period_end_at: datetime | None = None
    next_charge_at: datetime | None = None
    welcome_tokens_remaining: int = 0
    paid_tokens_remaining: int = 0
    subscription_tokens_remaining: int = 0
    total_tokens_remaining: int = 0
    welcome_expires_at: datetime | None = None
    subscription_quota_resets_at: datetime | None = None
    masked_payment_method_label: str = ""


class BillingCheckoutRequest(BaseModel):
    plan_code: str = Field(min_length=2, max_length=80)


class BillingCheckoutResponse(BaseModel):
    order_id: str
    provider_payment_id: str = ""
    confirmation_url: str
    expires_at: datetime | None = None
    status: str = "pending"


class BillingOrderStatusResponse(BaseModel):
    order_id: str
    plan_code: str
    status: str
    confirmation_url: str = ""
    provider_payment_id: str = ""
    amount_minor: int
    currency: str = "RUB"
    updated_at: datetime

