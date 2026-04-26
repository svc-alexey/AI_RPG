from html import escape
from urllib.parse import quote

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_optional_current_user
from app.db.models import User
from app.db.session import get_db_session
from app.schemas.billing import (
    BillingCatalogItemResponse,
    BillingCheckoutRequest,
    BillingCheckoutResponse,
    BillingHistoryItemResponse,
    BillingOrderStatusResponse,
    BillingSummaryResponse,
)
from app.schemas.common import MessageResponse
from app.services.billing import BillingService

router = APIRouter(prefix="/billing", tags=["billing"])
billing_service = BillingService()


@router.get("/catalog", response_model=list[BillingCatalogItemResponse])
async def get_catalog(
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingCatalogItemResponse]:
    return await billing_service.get_catalog(session)


@router.get("/me", response_model=BillingSummaryResponse)
async def get_me(
    user: User | None = Depends(get_optional_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingSummaryResponse:
    return await billing_service.build_summary(session, user=user)


@router.get("/history", response_model=list[BillingHistoryItemResponse])
async def get_history(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[BillingHistoryItemResponse]:
    return await billing_service.get_history(session, user_id=user.id)


@router.post("/checkout", response_model=BillingCheckoutResponse)
async def create_checkout(
    payload: BillingCheckoutRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingCheckoutResponse:
    response = await billing_service.create_checkout(
        session,
        user=user,
        plan_code=payload.plan_code.strip(),
    )
    await session.commit()
    return response


@router.get("/checkout/{order_id}", response_model=BillingOrderStatusResponse)
async def get_checkout_status(
    order_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingOrderStatusResponse:
    return await billing_service.get_order_status(
        session,
        user_id=user.id,
        order_id=order_id,
    )


@router.post("/subscription/cancel", response_model=BillingSummaryResponse)
async def cancel_subscription(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> BillingSummaryResponse:
    response = await billing_service.cancel_subscription(session, user_id=user.id)
    await session.commit()
    return response


@router.post("/webhooks/yookassa", response_model=MessageResponse)
async def yookassa_webhook(
    request: Request,
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    payload = await request.json()
    await billing_service.handle_webhook(session, payload=payload)
    await session.commit()
    return MessageResponse(message="ok")


@router.get("/fake/checkout/{order_id}", response_class=HTMLResponse)
async def fake_checkout_page(
    order_id: str,
    return_url: str = Query(default=""),
    session: AsyncSession = Depends(get_db_session),
) -> HTMLResponse:
    if not billing_service.fake_provider_enabled:
        raise HTTPException(status_code=404, detail="billing_fake_provider_disabled")
    order = await billing_service.get_order_by_id(session, order_id=order_id)
    encoded_return = quote(return_url or order.return_url, safe="")
    success_url = (
        f"/v1/billing/fake/checkout/{escape(order_id)}/complete"
        f"?outcome=succeeded&return_url={encoded_return}"
    )
    cancel_url = (
        f"/v1/billing/fake/checkout/{escape(order_id)}/complete"
        f"?outcome=canceled&return_url={encoded_return}"
    )
    html = f"""<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Mock YooKassa Checkout</title>
  <style>
    body {{ font-family: Arial, sans-serif; background: #f5f2e9; color: #1d1a16; margin: 0; }}
    main {{ max-width: 560px; margin: 48px auto; background: #fffdf9; border: 1px solid #e5dccd; border-radius: 20px; padding: 32px; box-shadow: 0 18px 50px rgba(39, 27, 12, 0.08); }}
    h1 {{ margin-top: 0; font-size: 28px; }}
    p {{ line-height: 1.5; }}
    .meta {{ background: #f4efe5; border-radius: 14px; padding: 16px; margin: 20px 0; }}
    .actions {{ display: flex; gap: 12px; flex-wrap: wrap; margin-top: 24px; }}
    .btn {{ display: inline-block; text-decoration: none; padding: 14px 18px; border-radius: 12px; font-weight: 700; }}
    .btn-primary {{ background: #125f45; color: white; }}
    .btn-secondary {{ background: #ece4d6; color: #3d3226; }}
  </style>
</head>
<body>
  <main>
    <h1>Локальная тестовая оплата</h1>
    <p>Это dev-only mock checkout вместо реальной YooKassa. Здесь можно симулировать успешную оплату или отмену и вернуться в приложение.</p>
    <div class="meta">
      <p><strong>Заказ:</strong> {escape(order.id)}</p>
      <p><strong>План:</strong> {escape(order.plan_code)}</p>
      <p><strong>Сумма:</strong> {order.amount_minor / 100:.2f} {escape(order.currency)}</p>
    </div>
    <div class="actions">
      <a class="btn btn-primary" href="{success_url}">Оплатить тестом</a>
      <a class="btn btn-secondary" href="{cancel_url}">Отменить</a>
    </div>
  </main>
</body>
</html>"""
    return HTMLResponse(content=html)


@router.get("/fake/checkout/{order_id}/complete")
async def fake_checkout_complete(
    order_id: str,
    outcome: str = Query(default="succeeded"),
    return_url: str = Query(default=""),
    session: AsyncSession = Depends(get_db_session),
) -> RedirectResponse:
    redirect_url = await billing_service.complete_fake_checkout(
        session,
        order_id=order_id,
        outcome=outcome,
    )
    await session.commit()
    if return_url.strip():
        status_value = "paid" if outcome.strip().lower() == "succeeded" else "canceled"
        redirect_url = billing_service._append_checkout_status(return_url, status_value)
    return RedirectResponse(redirect_url, status_code=302)
