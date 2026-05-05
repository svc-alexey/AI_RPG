import logging
from datetime import datetime

from sqlalchemy import func, select, text, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.billing_errors import InsufficientTokensError, WelcomeAlreadyClaimedError
from app.db.models import CreditLedger, User

logger = logging.getLogger("symmetry.billing")

SPEND_ORDER = ["welcome", "subscription", "paid"]


async def has_welcome_grant(session: AsyncSession, user_id: str) -> bool:
    result = await session.execute(
        select(CreditLedger.id).where(
            CreditLedger.user_id == user_id,
            CreditLedger.reason == "welcome_grant",
        ).limit(1)
    )
    return result.scalars().first() is not None


async def grant_welcome_tokens(session: AsyncSession, user_id: str, amount: int) -> None:
    if await has_welcome_grant(session, user_id):
        raise WelcomeAlreadyClaimedError(user_id)

    ledger = CreditLedger(
        id=_new_id(),
        user_id=user_id,
        amount=amount,
        reason="welcome_grant",
        metadata_json={"source": "welcome", "grant_type": "registration"},
    )
    session.add(ledger)
    await session.flush()
    logger.info("welcome_grant user_id=%s amount=%s", user_id, amount)


async def check_access(session: AsyncSession, user: User) -> bool:
    if user.is_admin:
        return True
    remaining = await _total_tokens_remaining(session, user.id)
    return remaining > 0


async def total_tokens_remaining(session: AsyncSession, user_id: str) -> int:
    return await _total_tokens_remaining(session, user_id)


async def deduct_tokens(
    session: AsyncSession,
    user_id: str,
    amount: int,
    *,
    campaign_id: str | None = None,
) -> dict[str, int]:
    if amount <= 0:
        return {}

    remaining = await _total_tokens_remaining(session, user_id)
    if remaining < amount:
        raise InsufficientTokensError(user_id, amount, remaining)

    deducted: dict[str, int] = {}
    to_deduct = amount

    for source in SPEND_ORDER:
        if to_deduct <= 0:
            break
        source_balance = await _source_balance(session, user_id, source)
        if source_balance <= 0:
            continue
        take = min(to_deduct, source_balance)
        ledger = CreditLedger(
            id=_new_id(),
            user_id=user_id,
            amount=-take,
            reason="turn",
            metadata_json={
                "source": source,
                "campaign_id": campaign_id,
            },
        )
        session.add(ledger)
        deducted[source] = take
        to_deduct -= take

    await session.flush()
    new_balance = await _total_tokens_remaining(session, user_id)
    if new_balance < 0:
        raise InsufficientTokensError(user_id, amount, remaining)

    return deducted


async def _source_balance(session: AsyncSession, user_id: str, source: str) -> int:
    result = await session.execute(
        select(func.coalesce(func.sum(CreditLedger.amount), 0))
        .where(
            CreditLedger.user_id == user_id,
            CreditLedger.metadata_json["source"].as_string() == source,
        )
    )
    return result.scalars().one() or 0


async def _total_tokens_remaining(session: AsyncSession, user_id: str) -> int:
    result = await session.execute(
        select(func.coalesce(func.sum(CreditLedger.amount), 0)).where(
            CreditLedger.user_id == user_id
        )
    )
    return result.scalars().one() or 0


async def wallet_breakdown(session: AsyncSession, user_id: str) -> dict:
    welcome = await _source_balance(session, user_id, "welcome")
    subscription = await _source_balance(session, user_id, "subscription")
    paid = await _source_balance(session, user_id, "paid")
    total = welcome + subscription + paid
    return {
        "welcome_tokens_remaining": max(welcome, 0),
        "paid_tokens_remaining": max(paid, 0),
        "subscription_tokens_remaining": max(subscription, 0),
        "total_tokens_remaining": max(total, 0),
    }


async def count_guest_turns(session: AsyncSession, user_id: str) -> int:
    result = await session.execute(
        select(func.count(CreditLedger.id)).where(
            CreditLedger.user_id == user_id,
            CreditLedger.reason == "turn",
        )
    )
    return result.scalars().one() or 0


def _new_id() -> str:
    import uuid
    return uuid.uuid4().hex
