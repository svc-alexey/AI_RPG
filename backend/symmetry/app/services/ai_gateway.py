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
  "world_event_summary": "string"
}
Rules:
- choices: up to 3 options, each concise, usually 1-4 words, never full sentences.
- state_changes.location: a human-readable place name in the target language, 2-4 words, no snake_case, no kebab-case, no special symbols.
- state_changes.objective and state_changes.quest_note: short current goal summaries in the target language, not fragments of narration, no more than 56 characters.
- do not start titles, objectives, quest notes, or choices with filler words like "and" or "и".
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
    ) -> dict[str, Any]:
        return await self.generate_json(
            credentials=credentials,
            system_prompt=(
                "You are the narrative engine for a living-world RPG. "
                "Respect the provided state. "
                f"Write narration and choices in language `{language}`. "
                + TURN_SCHEMA_PROMPT
            ),
            user_payload={
                "context": context,
                "player_action": player_action,
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
