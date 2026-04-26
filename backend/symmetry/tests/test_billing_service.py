from types import SimpleNamespace
from urllib.parse import parse_qs, urlparse

from app.services.billing import BillingService
from app.services.yookassa import YooKassaClient


def test_billing_default_plan_seeds_cover_expected_skus():
    service = BillingService()

    seeds = service._default_plan_seeds()
    codes = [item["code"] for item in seeds]

    assert codes == [
        "free_welcome_1m",
        "pack_1m",
        "pack_10m",
        "pro_monthly",
    ]
    pro = next(item for item in seeds if item["code"] == "pro_monthly")
    assert pro["kind"] == "subscription"
    assert pro["sale_price_minor"] < pro["base_price_minor"]


def test_build_return_url_appends_billing_query_params():
    service = BillingService()
    service._settings = SimpleNamespace(
        yookassa_return_url="https://example.com/billing?lang=ru",
        web_public_origin="https://example.com",
    )

    url = service._build_return_url("ord-123")
    parsed = urlparse(url)
    query = parse_qs(parsed.query)

    assert parsed.scheme == "https"
    assert parsed.netloc == "example.com"
    assert query["lang"] == ["ru"]
    assert query["openBilling"] == ["1"]
    assert query["checkout_order_id"] == ["ord-123"]


def test_append_checkout_status_preserves_existing_query():
    service = BillingService()

    url = service._append_checkout_status(
        "https://example.com/billing?openBilling=1&checkout_order_id=ord-123",
        "paid",
    )
    parsed = urlparse(url)
    query = parse_qs(parsed.query)

    assert query["openBilling"] == ["1"]
    assert query["checkout_order_id"] == ["ord-123"]
    assert query["checkout_status"] == ["paid"]


def test_fake_confirmation_url_uses_web_origin():
    client = YooKassaClient()
    client._settings = SimpleNamespace(
        billing_fake_provider_enabled=True,
        yookassa_shop_id="",
        yookassa_secret_key="",
        web_public_origin="https://example.com",
    )

    url = client._build_fake_confirmation_url(
        order_id="ord-123",
        return_url="https://example.com/app?openBilling=1",
    )
    parsed = urlparse(url)
    query = parse_qs(parsed.query)

    assert parsed.scheme == "https"
    assert parsed.netloc == "example.com"
    assert parsed.path == "/v1/billing/fake/checkout/ord-123"
    assert query["return_url"] == ["https://example.com/app?openBilling=1"]
