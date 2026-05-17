"""Consequence service — Vitality/HP depletion, death triggers.

Интегрируется в CampaignRuntimeService.apply_turn_result через DI.
"""

from __future__ import annotations

import random
from typing import Any

from app.core.logging import get_logger

logger = get_logger("symmetry.consequence")

# Баланс-константы (тюнятся позже)
VITALITY_START = 6
HP_START = 12
VITALITY_PER_MOVE = 1
HP_COMBAT_MIN = 1
HP_COMBAT_MAX = 3

DEATH_REASON_VITALITY = "vitality_depleted"
DEATH_REASON_HP = "hp_depleted"


class ConsequenceService:
    """Игровые последствия: истощение vitality/HP, проверка смерти, завершение кампании."""

    def depletion_at_move(self, state: dict[str, Any]) -> dict[str, Any]:
        """Каждый ход (перемещение) — Vitality -1. Возвращает патч character."""
        character = state.get("character", {}) if isinstance(state, dict) else {}
        if not isinstance(character, dict):
            return {}
        vitality = int(character.get("energy", VITALITY_START))
        new_vitality = max(0, vitality - VITALITY_PER_MOVE)
        return {"energy": new_vitality}

    def depletion_at_combat(
        self,
        state: dict[str, Any],
        d20_result: int | None = None,
    ) -> dict[str, Any]:
        """Боевой ход — HP -1d3. Возвращает патч character."""
        character = state.get("character", {}) if isinstance(state, dict) else {}
        if not isinstance(character, dict):
            return {}
        hp = int(character.get("hp", HP_START))
        dmg = random.randint(HP_COMBAT_MIN, HP_COMBAT_MAX)
        new_hp = max(0, hp - dmg)
        return {"hp": new_hp}

    def check_death(self, state: dict[str, Any]) -> tuple[bool, str | None]:
        """True если HP ≤ 0 ИЛИ Vitality ≤ 0. Возвращает (is_dead, reason)."""
        character = state.get("character", {}) if isinstance(state, dict) else {}
        if not isinstance(character, dict):
            return False, None
        hp = int(character.get("hp", HP_START))
        vitality = int(character.get("energy", VITALITY_START))
        if hp <= 0:
            return True, DEATH_REASON_HP
        if vitality <= 0:
            return True, DEATH_REASON_VITALITY
        return False, None

    async def apply_end_state(
        self,
        *,
        campaign_id: str,
        reason: str,
        session: Any,
    ) -> None:
        """Меняет campaign.status на 'ended'. Требует активную сессию БД."""
        from sqlalchemy import select

        from app.db.models import Campaign

        result = await session.execute(
            select(Campaign).where(Campaign.id == campaign_id)
        )
        campaign = result.scalar_one_or_none()
        if campaign is None:
            logger.warning(
                "consequence_end_state_campaign_not_found campaign_id=%s",
                campaign_id,
            )
            return
        campaign.status = "ended"
        campaign.ended_reason = reason
        session.add(campaign)
        logger.info(
            "consequence_campaign_ended campaign_id=%s reason=%s",
            campaign_id,
            reason,
        )
