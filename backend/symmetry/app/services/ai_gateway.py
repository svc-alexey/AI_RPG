import json
import re
from typing import Any

import httpx

from app.core.logging import get_logger
from app.services.credentials import ResolvedCredentials

logger = get_logger("symmetry.ai_gateway")


TURN_SCHEMA_PROMPT = """
Return valid JSON only.
Schema:
{
  "narration": "string",
  "choices": ["string"],
  "state_changes": {
    "location": "string",
    "objective": "string",
    "quest_note": "string",
    "global_vars_patch": {},
    "character_patch": {}
  },
  "memory_entry": "string",
  "importance": 0,
  "world_event_summary": "string",
  "needs_background_followup": false,
  "impact_seeds": [
    {
      "entity_kind": "company|faction|location|market|world",
      "entity_slug": "string",
      "impact_type": "scarcity|influence|trust|alertness|rumor|instability|opportunity",
      "strength": 1,
      "delay_min_turns": 1,
      "delay_max_turns": 2,
      "visibility": "public|hidden",
      "summary": "string"
    }
  ]
}
Rules:
- choices: up to 3 options, each concise, usually 1-4 words, never full sentences.
- state_changes.location: a human-readable place name in the target language, 2-4 words, no snake_case, no kebab-case, no special symbols.
- state_changes.objective and state_changes.quest_note: short current goal summaries in the target language, not fragments of narration, no more than 56 characters.
- do not start titles, objectives, quest notes, or choices with filler words like "and" or "и".
- impact_seeds: optional compact follow-up traces for the background simulation, up to 2 for shortStory and up to 4 for longCampaign.
- impact_seeds summarize possible consequences only; do not resolve them in the current narration.
- needs_background_followup should be true only if at least one impact seed is meaningful enough to expand later.
""" 


class AiGatewayService:
    async def check_connection(self, *, credentials: ResolvedCredentials) -> None:
        logger.info(
            "provider_check_started credentials=%s",
            credentials.safe_summary,
        )
        async with httpx.AsyncClient(timeout=credentials.timeout_seconds) as client:
            response = await client.get(
                f"{credentials.base_url.rstrip('/')}/models",
                headers={
                    "Authorization": f"Bearer {credentials.api_key}",
                },
            )
            try:
                response.raise_for_status()
            except httpx.HTTPStatusError:
                logger.warning(
                    "provider_check_failed status=%s body=%s credentials=%s",
                    response.status_code,
                    response.text[:500],
                    credentials.safe_summary,
                )
                raise
        logger.info(
            "provider_check_completed status=%s credentials=%s",
            response.status_code,
            credentials.safe_summary,
        )

    async def generate_turn(
        self,
        *,
        credentials: ResolvedCredentials,
        context: dict[str, Any],
        player_action: str,
        language: str,
        trigger_source: str,
    ) -> dict[str, Any]:
        campaign = context.get("campaign", {}) if isinstance(context, dict) else {}
        mode = str(campaign.get("mode", "shortStory")).strip() or "shortStory"
        turn_number = int(campaign.get("turn_number", 0) or 0)
        return await self.generate_json(
            credentials=credentials,
            system_prompt=build_turn_system_prompt(
                language=language,
                mode=mode,
                turn_number=turn_number,
                trigger_source=trigger_source,
            ),
            user_payload={
                "context": context,
                "player_action": player_action,
                "trigger_source": trigger_source,
            },
        )

    async def generate_json(
        self,
        *,
        credentials: ResolvedCredentials,
        system_prompt: str,
        user_payload: dict[str, Any],
    ) -> dict[str, Any]:
        messages = [
            {
                "role": "system",
                "content": system_prompt,
            },
            {
                "role": "user",
                "content": json.dumps(user_payload, ensure_ascii=False),
            },
        ]

        payload = {
            "model": credentials.model,
            "messages": messages,
            "temperature": 0.8,
            "response_format": {"type": "json_object"},
        }
        logger.info(
            "llm_request_started credentials=%s payload_keys=%s",
            credentials.safe_summary,
            list(payload.keys()),
        )
        async with httpx.AsyncClient(timeout=credentials.timeout_seconds) as client:
            response = await client.post(
                f"{credentials.base_url.rstrip('/')}/chat/completions",
                headers={
                    "Authorization": f"Bearer {credentials.api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )
            try:
                response.raise_for_status()
            except httpx.HTTPStatusError:
                logger.warning(
                    "llm_request_failed status=%s body=%s credentials=%s",
                    response.status_code,
                    response.text[:500],
                    credentials.safe_summary,
                )
                raise
        data = response.json()
        logger.info(
            "llm_request_completed status=%s credentials=%s",
            response.status_code,
            credentials.safe_summary,
        )
        content = (
            data.get("choices", [{}])[0]
            .get("message", {})
            .get("content", "")
        )
        return self._parse_json(content)

    def _parse_json(self, content: Any) -> dict[str, Any]:
        if isinstance(content, dict):
            return content
        if not isinstance(content, str):
            raise ValueError("invalid_llm_payload")
        content = content.strip()
        try:
            return json.loads(content)
        except json.JSONDecodeError:
            match = re.search(r"\{.*\}", content, flags=re.DOTALL)
            if not match:
                raise ValueError("invalid_llm_payload")
            return json.loads(match.group(0))


def classify_provider_error(exc: Exception) -> tuple[int, str]:
    if isinstance(exc, httpx.HTTPStatusError):
        status_code = exc.response.status_code
        if status_code in {401, 403}:
            return 502, "provider_auth_failed"
        if status_code == 429:
            return 429, "provider_rate_limited"
        return 502, "provider_connection_failed"
    if isinstance(exc, httpx.HTTPError):
        return 502, "provider_connection_failed"
    if isinstance(exc, ValueError) and str(exc) == "invalid_llm_payload":
        return 502, "provider_invalid_response"
    return 502, "provider_connection_failed"


def build_turn_system_prompt(
    *,
    language: str,
    mode: str,
    turn_number: int,
    trigger_source: str,
) -> str:
    is_long_campaign = mode == "longCampaign"
    is_long_intro = is_long_campaign and turn_number == 0 and trigger_source == "intro"
    style_rules = (
        "For shortStory mode: keep narration compact and direct, usually 1-2 paragraphs, and move the player into action quickly. "
        if not is_long_campaign
        else "For longCampaign mode: maintain stronger continuity, richer atmosphere, and more developed consequences. "
    )
    if is_long_intro:
        style_rules += (
            "This is the first automatic intro turn for a long campaign. "
            "The narration must contain two clear paragraphs: first a visible prologue with hero or world backstory, "
            "then the opening scene and immediate point of entry. "
            "Do not skip the prologue and do not throw the player straight into action without setup. "
        )
    elif is_long_campaign:
        style_rules += (
            "Narration should usually span 2-3 paragraphs and feel more expansive than shortStory mode. "
        )
    butterfly_rules = (
        "For shortStory mode, if the action creates a follow-up ripple, keep it local and fast, usually visible within the next 1-2 turns. "
        if not is_long_campaign
        else "For longCampaign mode, use impact seeds to mark broader ripple effects for companies, factions, markets, or locations that may unfold over several turns. "
    )
    return (
        "You are the narrative engine for a living-world RPG. "
        "Respect the provided state. "
        f"Write narration and choices in language `{language}`. "
        f"{style_rules}"
        f"{butterfly_rules}"
        + TURN_SCHEMA_PROMPT
    )
