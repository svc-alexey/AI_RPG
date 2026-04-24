import json
import re
from dataclasses import asdict, dataclass
from typing import Any

import httpx

from app.core.logging import get_logger
from app.services.credentials import ResolvedCredentials
from app.services.prompt_budget import build_turn_budget
from app.services.text_normalization import normalize_prompt_text

logger = get_logger("symmetry.ai_gateway")


TURN_SCHEMA_PROMPT = """
Return valid JSON only with keys:
- narration
- choices
- state_changes {location, objective, quest_note, module_updates, global_vars_patch, character_patch}
- memory_entry
- importance
- world_event_summary
- needs_background_followup
- impact_seeds
Rules:
- choices: up to 3 concise options, usually 1-4 words, never full sentences.
- location: human-readable place name in the target language, 2-4 words, no snake_case or kebab-case.
- objective and quest_note: short goal summaries in the target language, not narration, <=56 characters.
- omit empty arrays or objects in state_changes completely.
- avoid stock default names for places, factions, companies, markets, and quests; derive names from the story prompt, hero, and current events.
- module_updates is optional; activate modules only when the story truly needs persistent UI/state support.
- do not activate `vitality` by default for every campaign.
- if `vitality` is activated for the first time, provide a full character_patch with hp, max_hp, energy, max_energy, might, wit, spirit.
- if `vitality` is not active or not needed for the scene, keep combat stats untouched.
- do not start titles, objectives, quest notes, or choices with filler words like "and" or "и".
- memory_entry must be a very short anchor phrase, 1-2 sentences max.
- world_event_summary must be a very compact summary.
- impact seeds are optional compact follow-up traces for the background simulation, up to 2 for shortStory and up to 2 for longCampaign.
- impact seeds summarize possible consequences only; do not resolve them in the current narration.
- needs_background_followup is true only if at least one impact seed is meaningful enough to expand later.
- if memory or relevant chronicles show that the hero already knows a character, do not re-introduce, re-meet, or offer "get acquainted" choices with that character.
- if dynamic_context.memory.known_characters lists a character, continue from that existing relationship naturally.
- if the player references something that was established in the immediately previous scene or recent_turns, treat it as an already known fact and answer coherently instead of forgetting it.
"""


PLACEHOLDER_LOCATIONS = {
    "starting point",
    "starting point.",
    "начальная точка",
    "начальная точка.",
}


@dataclass(slots=True)
class LlmUsage:
    prompt_cache_hit_tokens: int = 0
    prompt_cache_miss_tokens: int = 0
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0

    def to_dict(self) -> dict[str, int]:
        return asdict(self)


@dataclass(slots=True)
class LlmJsonResult:
    payload: dict[str, Any]
    usage: LlmUsage
    meta: dict[str, Any]


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
    ) -> LlmJsonResult:
        campaign = context.get("campaign_bootstrap", {}) if isinstance(context, dict) else {}
        mode = str(campaign.get("mode", "shortStory")).strip() or "shortStory"
        turn_number = int((context.get("dynamic_context", {}) or {}).get("turn_number", 0) or 0)
        budget = build_turn_budget(
            mode=mode,
            turn_number=turn_number,
            trigger_source=trigger_source,
        )
        return await self.generate_json(
            credentials=credentials,
            prefix_messages=build_turn_prefix_messages(
                system_prompt=build_turn_system_prompt(
                    language=language,
                    mode=mode,
                    turn_number=turn_number,
                    trigger_source=trigger_source,
                ),
                context=context,
            ),
            dynamic_payload=build_turn_dynamic_payload(
                context=context,
                player_action=player_action,
                trigger_source=trigger_source,
            ),
            max_output_tokens=budget.max_output_tokens,
            scenario=budget.scenario,
        )

    async def generate_json(
        self,
        *,
        credentials: ResolvedCredentials,
        system_prompt: str | None = None,
        user_payload: dict[str, Any] | None = None,
        prefix_messages: list[dict[str, str]] | None = None,
        dynamic_payload: dict[str, Any] | None = None,
        max_output_tokens: int | None = None,
        scenario: str = "generic_json",
    ) -> LlmJsonResult:
        messages = build_messages(
            system_prompt=system_prompt,
            user_payload=user_payload,
            prefix_messages=prefix_messages,
            dynamic_payload=dynamic_payload,
        )
        request_meta = _build_request_meta(
            messages=messages,
            prefix_messages=prefix_messages,
            dynamic_payload=dynamic_payload,
            user_payload=user_payload,
            max_output_tokens=max_output_tokens,
            scenario=scenario,
        )

        payload = {
            "model": credentials.model,
            "messages": messages,
            "temperature": 0.8,
            "response_format": {"type": "json_object"},
        }
        current_max_tokens = max_output_tokens
        current_payload = dict(payload)
        attempt = 0
        parsed_payload: dict[str, Any] | None = None
        usage = LlmUsage()
        finish_reason = ""

        while True:
            if current_max_tokens is not None:
                current_payload["max_tokens"] = current_max_tokens
            elif "max_tokens" in current_payload:
                del current_payload["max_tokens"]

            current_meta = {
                **request_meta,
                "max_output_tokens": current_max_tokens or 0,
                "retry_attempt": attempt,
            }
            if attempt > 0 and max_output_tokens is not None:
                current_meta["retry_of_max_output_tokens"] = max_output_tokens

            data, usage, finish_reason = await self._post_json_completion(
                credentials=credentials,
                payload=current_payload,
                scenario=scenario if attempt == 0 else f"{scenario}_retry_{attempt}",
                request_meta=current_meta,
            )
            response_was_truncated = _is_response_truncated(
                finish_reason=finish_reason,
                usage=usage,
                max_output_tokens=current_max_tokens,
            )
            content = (
                data.get("choices", [{}])[0]
                .get("message", {})
                .get("content", "")
            )
            try:
                parsed_payload = self._parse_json(content)
                if response_was_truncated and current_max_tokens is not None and attempt < 2:
                    next_max_tokens = _next_retry_max_tokens(current_max_tokens)
                    logger.warning(
                        "llm_response_truncated_retrying credentials=%s scenario=%s finish_reason=%s completion_tokens=%s previous_max_tokens=%s retry_max_tokens=%s attempt=%s",
                        credentials.safe_summary,
                        scenario,
                        finish_reason or "-",
                        usage.completion_tokens,
                        current_max_tokens,
                        next_max_tokens,
                        attempt + 1,
                    )
                    current_max_tokens = next_max_tokens
                    attempt += 1
                    continue
                narration_chars = len(str(parsed_payload.get("narration") or ""))
                memory_chars = len(str(parsed_payload.get("memory_entry") or ""))
                world_summary_chars = len(str(parsed_payload.get("world_event_summary") or ""))
                impact_seeds = parsed_payload.get("impact_seeds")
                impact_seeds_count = len(impact_seeds) if isinstance(impact_seeds, list) else 0

                request_meta = {
                    **current_meta,
                    "finish_reason": finish_reason or "",
                    "completion_truncated": response_was_truncated,
                    "narration_chars": narration_chars,
                    "memory_chars": memory_chars,
                    "world_summary_chars": world_summary_chars,
                    "impact_seeds_count": impact_seeds_count,
                    "retry_count": attempt,
                }
                logger.info(
                    "llm_turn_stats scenario=%s retry_count=%s narration_chars=%s memory_chars=%s world_summary_chars=%s impact_seeds_count=%s",
                    scenario,
                    attempt,
                    narration_chars,
                    memory_chars,
                    world_summary_chars,
                    impact_seeds_count,
                )
                break
            except ValueError:
                if current_max_tokens is None or not response_was_truncated or attempt >= 2:
                    raise
                next_max_tokens = _next_retry_max_tokens(current_max_tokens)
                logger.warning(
                    "llm_payload_invalid_retrying credentials=%s scenario=%s finish_reason=%s completion_tokens=%s previous_max_tokens=%s retry_max_tokens=%s attempt=%s",
                    credentials.safe_summary,
                    scenario,
                    finish_reason or "-",
                    usage.completion_tokens,
                    current_max_tokens,
                    next_max_tokens,
                    attempt + 1,
                )
                current_max_tokens = next_max_tokens
                attempt += 1

        return LlmJsonResult(
            payload=parsed_payload or {},
            usage=usage,
            meta=request_meta,
        )

    async def _post_json_completion(
        self,
        *,
        credentials: ResolvedCredentials,
        payload: dict[str, Any],
        scenario: str,
        request_meta: dict[str, Any],
    ) -> tuple[dict[str, Any], LlmUsage, str]:
        logger.info(
            "llm_request_started credentials=%s scenario=%s payload_keys=%s message_count=%s prompt_chars=%s max_tokens=%s",
            credentials.safe_summary,
            scenario,
            list(payload.keys()),
            len(payload.get("messages", [])),
            request_meta["prompt_characters"],
            payload.get("max_tokens", "-"),
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
        usage = _parse_usage(data.get("usage"))
        finish_reason = _extract_finish_reason(data)
        logger.info(
            "llm_request_completed status=%s credentials=%s scenario=%s finish_reason=%s usage=%s meta=%s",
            response.status_code,
            credentials.safe_summary,
            scenario,
            finish_reason or "-",
            usage.to_dict(),
            request_meta,
        )
        return data, usage, finish_reason

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
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError as exc:
                raise ValueError("invalid_llm_payload") from exc


def build_messages(
    *,
    system_prompt: str | None = None,
    user_payload: dict[str, Any] | None = None,
    prefix_messages: list[dict[str, str]] | None = None,
    dynamic_payload: dict[str, Any] | None = None,
) -> list[dict[str, str]]:
    if prefix_messages is not None:
        messages = list(prefix_messages)
        if dynamic_payload is None:
            raise ValueError("dynamic_payload_required")
        messages.append(
            {
                "role": "user",
                "content": json.dumps(dynamic_payload, ensure_ascii=False),
            }
        )
        return messages

    if system_prompt is None or user_payload is None:
        raise ValueError("system_prompt_and_user_payload_required")

    return [
        {
            "role": "system",
            "content": normalize_prompt_text(system_prompt),
        },
        {
            "role": "user",
            "content": json.dumps(user_payload, ensure_ascii=False),
        },
    ]


def build_turn_prefix_messages(
    *,
    system_prompt: str,
    context: dict[str, Any],
) -> list[dict[str, str]]:
    immutable_payload = {
        "campaign_bootstrap": context.get("campaign_bootstrap", {}),
        "world_bootstrap": context.get("world_bootstrap", {}),
        "character_brief": context.get("character_brief", {}),
    }
    return [
        {
            "role": "system",
            "content": system_prompt,
        },
        {
            "role": "user",
            "content": json.dumps(immutable_payload, ensure_ascii=False),
        },
    ]


def build_turn_dynamic_payload(
    *,
    context: dict[str, Any],
    player_action: str,
    trigger_source: str,
) -> dict[str, Any]:
    dynamic_context = context.get("dynamic_context", {})
    state = dynamic_context.get("state", {}) if isinstance(dynamic_context, dict) else {}
    location = str(state.get("location", "")).strip()
    language = str(
        (context.get("campaign_bootstrap", {}) or {}).get("language", "ru")
    ).strip() or "ru"
    return {
        "dynamic_context": dynamic_context,
        "player_action": normalize_prompt_text(player_action, limit=240),
        "trigger_source": normalize_prompt_text(trigger_source, limit=32),
        "location_is_placeholder": is_placeholder_location(
            location,
            language=language,
        ),
    }


def is_placeholder_location(location: str, *, language: str) -> bool:
    normalized = location.strip().lower()
    if not normalized:
        return True
    if normalized in PLACEHOLDER_LOCATIONS:
        return True
    return normalized == ("начальная точка" if language.startswith("ru") else "starting point")


def _parse_usage(raw_usage: Any) -> LlmUsage:
    usage = raw_usage if isinstance(raw_usage, dict) else {}
    return LlmUsage(
        prompt_cache_hit_tokens=int(usage.get("prompt_cache_hit_tokens", 0) or 0),
        prompt_cache_miss_tokens=int(usage.get("prompt_cache_miss_tokens", 0) or 0),
        prompt_tokens=int(usage.get("prompt_tokens", 0) or 0),
        completion_tokens=int(usage.get("completion_tokens", 0) or 0),
        total_tokens=int(usage.get("total_tokens", 0) or 0),
    )


def _extract_finish_reason(data: Any) -> str:
    if not isinstance(data, dict):
        return ""
    choices = data.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    first_choice = choices[0] if isinstance(choices[0], dict) else {}
    finish_reason = str(first_choice.get("finish_reason", "") or "").strip()
    return finish_reason


def _is_response_truncated(
    *,
    finish_reason: str,
    usage: LlmUsage,
    max_output_tokens: int | None,
) -> bool:
    if max_output_tokens is None:
        return False
    if finish_reason.lower() == "length":
        return True
    return usage.completion_tokens >= max_output_tokens


def _next_retry_max_tokens(current_max_tokens: int) -> int:
    return current_max_tokens + max(160, current_max_tokens // 2)


def _build_request_meta(
    *,
    messages: list[dict[str, str]],
    prefix_messages: list[dict[str, str]] | None,
    dynamic_payload: dict[str, Any] | None,
    user_payload: dict[str, Any] | None,
    max_output_tokens: int | None,
    scenario: str,
) -> dict[str, Any]:
    prompt_characters = sum(len(item.get("content", "")) for item in messages)
    prefix_characters = sum(len(item.get("content", "")) for item in prefix_messages or [])
    if dynamic_payload is not None:
        dynamic_characters = len(json.dumps(dynamic_payload, ensure_ascii=False))
    elif user_payload is not None:
        dynamic_characters = len(json.dumps(user_payload, ensure_ascii=False))
    else:
        dynamic_characters = 0
    return {
        "scenario": scenario,
        "message_count": len(messages),
        "prompt_characters": prompt_characters,
        "prefix_characters": prefix_characters,
        "dynamic_characters": dynamic_characters,
        "max_output_tokens": max_output_tokens or 0,
    }


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
        "If the current location is a placeholder such as `Starting Point` or `Начальная точка`, "
        "your first task is to replace it with a unique, concrete starting location that fits the story prompt, "
        "and you must include that place in `state_changes.location`. "
        "Only enable gameplay modules when they are justified by the genre, setting, current story pressure, and hero concept. "
        "Do not assume health bars or RPG stats are always required. "
        f"{style_rules}"
        f"{butterfly_rules}"
        + TURN_SCHEMA_PROMPT
    )
