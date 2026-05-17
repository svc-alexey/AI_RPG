from __future__ import annotations

import logging
import uuid
from datetime import UTC, datetime

from yandex_ai_studio_sdk import AsyncAIStudio

from app.core.config import get_settings
from app.db.models import Campaign, CampaignPortrait
from app.db.session import SessionLocal
from app.services.portrait_optimizer import optimize_portrait
from app.services.portrait_prompt_builder import build_portrait_messages

logger = logging.getLogger("symmetry.portrait")


async def generate_portrait(
    messages: list[dict],
    target_width: int | None = None,
    target_height: int | None = None,
) -> bytes:
    settings = get_settings()
    ai = AsyncAIStudio(
        folder_id=settings.yandex_art_folder_id,
        auth=settings.yandex_art_api_key,
    )
    model = ai.models.image_generation("yandex-art")

    if target_width and target_height and target_width > 0 and target_height > 0:
        model = model.configure(width_ratio=target_width, height_ratio=target_height)
    else:
        model = model.configure(width_ratio=3, height_ratio=4)

    operation = await model.run_deferred(messages, timeout=settings.yandex_art_timeout_seconds)
    result = await operation.wait(
        timeout=60,
        poll_timeout=120,
        poll_interval=settings.yandex_art_poll_interval_seconds,
    )
    return result.image_bytes


async def generate_and_store(
    campaign_id: str,
    character: dict,
    setting: str,
    story_prompt: str,
    target_width: int | None = None,
    target_height: int | None = None,
) -> None:
    async with SessionLocal() as session:
        try:
            campaign = await session.get(Campaign, campaign_id)
            if campaign is None:
                logger.warning("portrait_campaign_not_found campaign_id=%s", campaign_id)
                return

            campaign.portrait_status = "pending"
            portrait = CampaignPortrait(
                id=uuid.uuid4().hex[:36],
                campaign_id=campaign_id,
                status="pending",
            )
            session.add(portrait)
            await session.commit()

            messages = build_portrait_messages(
                character, setting, story_prompt,
                target_width=target_width, target_height=target_height,
            )
            raw_bytes = await generate_portrait(
                messages,
                target_width=target_width,
                target_height=target_height,
            )

            webp_bytes, width, height = optimize_portrait(raw_bytes)

            portrait.image_webp = webp_bytes
            portrait.prompt_used = messages[0]["text"] if messages else ""
            portrait.model_used = "yandex-art"
            portrait.status = "ready"
            portrait.completed_at = datetime.now(UTC)
            campaign.portrait_status = "ready"
            await session.commit()

            logger.info(
                "portrait_ready campaign_id=%s size=%d dimensions=%dx%d target=%dx%d",
                campaign_id, len(webp_bytes), width, height,
                target_width or 0, target_height or 0,
            )

        except Exception:
            logger.exception("portrait_failed campaign_id=%s", campaign_id)
            await session.rollback()
            try:
                campaign = await session.get(Campaign, campaign_id)
                if campaign is not None:
                    campaign.portrait_status = "failed"
                    await session.commit()
            except Exception:
                logger.exception("portrait_status_update_failed campaign_id=%s", campaign_id)
                await session.rollback()
