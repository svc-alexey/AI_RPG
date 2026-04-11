from copy import deepcopy
from typing import Any

from app.db.models import WorldChronicle, WorldState
from app.services.ai_gateway import is_placeholder_location
from app.services.prompt_budget import PromptBudgetProfile, build_turn_budget
from app.services.presentation_text import (
    normalize_campaign_title,
    normalize_choices,
    normalize_location_label,
    normalize_objective_text,
)
from app.services.text_normalization import normalize_compact_list, normalize_prompt_text


LOCATION_BOOTSTRAPS = {
    "ru": {
        "romantasy": "Лунная гавань",
        "cozyFantasy": "Садовый трактир",
        "darkAcademia": "Сумрачный атриум",
        "postApocalypse": "Пепельный коридор",
        "litRpgProgression": "Зал первых рангов",
        "grimdarkFantasy": "Черные ворота",
        "nearFutureSciFi": "Сервисный отсек",
        "horrorWeird": "Глухой вестибюль",
        "cozyCrime": "Туманный причал",
        "altHistorySecret": "Тайный кабинет",
    },
    "en": {
        "romantasy": "Moon Harbor",
        "cozyFantasy": "Garden Inn",
        "darkAcademia": "Shadow Atrium",
        "postApocalypse": "Ash Corridor",
        "litRpgProgression": "Novice Hall",
        "grimdarkFantasy": "Black Gate",
        "nearFutureSciFi": "Service Deck",
        "horrorWeird": "Hush Vestibule",
        "cozyCrime": "Mist Harbor",
        "altHistorySecret": "Hidden Cabinet",
    },
}

ALLOWED_MODULES = {
    "vitality",
    "inventory",
    "notes",
    "companions",
    "resources",
    "progression",
    "checks",
}

CHARACTER_NUMERIC_KEYS = {
    "hp",
    "max_hp",
    "energy",
    "max_energy",
    "might",
    "wit",
    "spirit",
}


def build_initial_state(payload) -> dict[str, Any]:
    language = payload.language.strip() or "ru"
    location = normalize_location_label("", language=language)
    story_prompt = normalize_prompt_text(payload.story_prompt, limit=520)
    objective = normalize_objective_text(
        payload.objective_hint.strip() or story_prompt,
        language=language,
    )
    return {
        "id": "",
        "title": normalize_campaign_title(payload.title, language=language),
        "setting": payload.setting,
        "mode": payload.mode,
        "difficulty": payload.difficulty,
        "language": language,
        "turn_number": 0,
        "custom_story_prompt": story_prompt,
        "location": location,
        "objective": objective,
        "bootstrap": {
            "starting_location": location,
            "starting_objective": objective,
            "story_prompt": story_prompt,
        },
        "character": {
            "name": normalize_prompt_text(payload.character.name, limit=48),
            "gender": normalize_prompt_text(payload.character.gender, limit=24),
            "race": normalize_prompt_text(payload.character.race, limit=48),
            "character_class": normalize_prompt_text(
                payload.character.character_class,
                limit=48,
            ),
            "personality": normalize_prompt_text(payload.character.personality, limit=120),
            "prompt_fragment": normalize_prompt_text(
                payload.character.prompt_fragment,
                limit=240,
            ),
            "skills": normalize_compact_list(payload.character.skills, item_limit=4, text_limit=48),
            "perks": normalize_compact_list(payload.character.perks, item_limit=4, text_limit=48),
        },
        "memory": {
            "rolling_summary": story_prompt,
            "active_goal": objective,
            "active_situation": objective,
            "recent_turns": [],
        },
        "messages": [],
        "choices": [],
        "modules": [],
    }


class CampaignRuntimeService:
    def ensure_bootstrap_state(self, *, state: dict[str, Any]) -> dict[str, Any]:
        next_state = deepcopy(state)
        language = str(next_state.get("language", "ru")).strip() or "ru"
        bootstrap = next_state.setdefault("bootstrap", {})
        bootstrap.setdefault(
            "starting_location",
            normalize_location_label(
                str(next_state.get("location", "")).strip(),
                language=language,
            ),
        )
        bootstrap.setdefault(
            "starting_objective",
            normalize_objective_text(
                str(next_state.get("objective", "")).strip(),
                language=language,
            ),
        )
        bootstrap.setdefault(
            "story_prompt",
            str(next_state.get("custom_story_prompt", "")).strip(),
        )
        next_state.setdefault("modules", [])
        return next_state

    def build_turn_context(
        self,
        *,
        state: dict[str, Any],
        world_state: WorldState,
        chronicles: list[WorldChronicle],
        trigger_source: str,
    ) -> dict[str, Any]:
        current_state = self.ensure_bootstrap_state(state=state)
        character = current_state.get("character", {}) or {}
        bootstrap = current_state.get("bootstrap", {}) or {}
        budget = build_turn_budget(
            mode=str(current_state.get("mode", "shortStory")).strip() or "shortStory",
            turn_number=int(current_state.get("turn_number", 0) or 0),
            trigger_source=trigger_source,
        )
        compact_character = _compact_character_state(character)
        compact_memory = _compact_memory(
            current_state.get("memory", {}) or {},
            budget=budget,
        )
        compact_chronicles = _compact_chronicles(chronicles, budget=budget)
        return {
            "campaign_bootstrap": {
                "title": normalize_prompt_text(str(current_state.get("title", "")), limit=64),
                "setting": current_state.get("setting", ""),
                "mode": current_state.get("mode", ""),
                "difficulty": current_state.get("difficulty", ""),
                "language": current_state.get("language", "ru"),
                "story_prompt": normalize_prompt_text(
                    str(
                        bootstrap.get(
                            "story_prompt",
                            current_state.get("custom_story_prompt", ""),
                        )
                    ),
                    limit=budget.max_story_prompt_chars,
                ),
            },
            "world_bootstrap": {
                "starting_location": normalize_prompt_text(
                    str(bootstrap.get("starting_location", "")),
                    limit=48,
                ),
                "starting_objective": normalize_prompt_text(
                    str(bootstrap.get("starting_objective", "")),
                    limit=64,
                ),
            },
            "character_brief": {
                "character": _compact_character_brief(character),
                "character_prompt": normalize_prompt_text(
                    str(character.get("prompt_fragment", "")),
                    limit=budget.max_character_prompt_chars,
                ),
            },
            "dynamic_context": {
                "turn_number": current_state.get("turn_number", 0),
                "memory": compact_memory,
                "world_state": {
                    "current_day": world_state.current_day,
                    "minute_of_day": world_state.minute_of_day,
                    "butterfly": (world_state.global_vars or {}).get("butterfly", {}),
                    "weather": (world_state.global_vars or {}).get("weather", ""),
                },
                "state": {
                    "location": normalize_prompt_text(
                        str(current_state.get("location", "")),
                        limit=48,
                    ),
                    "objective": normalize_prompt_text(
                        str(current_state.get("objective", "")),
                        limit=64,
                    ),
                    "choices": normalize_compact_list(
                        current_state.get("choices", []) or [],
                        item_limit=3,
                        text_limit=24,
                    ),
                    "active_modules": [
                        str(item.get("module", "")).strip()
                        for item in current_state.get("modules", []) or []
                        if isinstance(item, dict) and item.get("is_active", True)
                    ],
                    "character": compact_character,
                },
                "request": {
                    "trigger_source": normalize_prompt_text(trigger_source, limit=32),
                },
                "relevant_chronicles": compact_chronicles,
            },
        }

    def apply_turn_result(
        self,
        *,
        state: dict[str, Any],
        result: dict[str, Any],
        player_action: str,
    ) -> tuple[dict[str, Any], dict[str, Any], int, str]:
        next_state = self.ensure_bootstrap_state(state=state)
        language = str(next_state.get("language", "ru")).strip() or "ru"
        state_changes = result.get("state_changes", {}) or {}
        next_state["turn_number"] = int(next_state.get("turn_number", 0)) + 1
        next_state["choices"] = normalize_choices(
            [str(item).strip() for item in result.get("choices", []) or []],
            language=language,
        )
        location = str(state_changes.get("location", "")).strip()
        if location:
            next_state["location"] = normalize_location_label(
                location,
                language=language,
            )
        objective = str(state_changes.get("objective", "")).strip()
        if objective:
            next_state["objective"] = normalize_objective_text(
                objective,
                language=language,
            )
        normalized_character_patch = normalize_character_patch(
            state_changes.get("character_patch", {}) or {}
        )
        character_patch = normalized_character_patch
        if character_patch:
            next_state.setdefault("character", {}).update(character_patch)
        module_updates = normalize_module_updates(
            state_changes.get("module_updates", {}) or {}
        )
        if (
            "vitality" in module_updates["activate"]
            and not has_meaningful_vitality_stats(
                current_character=next_state.get("character", {}),
                incoming_patch=normalized_character_patch,
            )
        ):
            module_updates["activate"] = [
                item for item in module_updates["activate"] if item != "vitality"
            ]
        if module_updates["activate"] or module_updates["deactivate"]:
            next_state["modules"] = apply_module_updates(
                current_modules=next_state.get("modules", []),
                activate=module_updates["activate"],
                deactivate=module_updates["deactivate"],
            )
            state_changes["module_updates"] = module_updates

        narration = normalize_prompt_text(str(result.get("narration", "")), limit=1200)
        memory_entry = normalize_prompt_text(
            str(result.get("memory_entry", narration)),
            limit=240,
        ) or narration
        messages = next_state.setdefault("messages", [])
        trimmed_player_action = normalize_prompt_text(player_action, limit=240)
        if trimmed_player_action:
            messages.append({"role": "player", "text": trimmed_player_action})
        messages.append({"role": "narrator", "text": narration})

        memory = next_state.setdefault("memory", {})
        recent_turns = list(memory.get("recent_turns", []))
        recent_turn_entry = {
            "outcome": narration,
            "state_hint": memory_entry,
        }
        if trimmed_player_action:
            recent_turn_entry["player_action"] = trimmed_player_action
        recent_turns.append(recent_turn_entry)
        memory["recent_turns"] = recent_turns[-5:]
        memory["rolling_summary"] = memory_entry
        quest_note = str(state_changes.get("quest_note", "")).strip()
        if quest_note:
            memory["active_goal"] = normalize_objective_text(
                quest_note,
                language=language,
            )
        memory["active_situation"] = narration
        importance = int(result.get("importance", 0) or 0)
        world_event_summary = normalize_prompt_text(
            str(result.get("world_event_summary", "")),
            limit=240,
        )
        return next_state, state_changes, importance, world_event_summary

    def ensure_playable_location(
        self,
        *,
        state: dict[str, Any],
        state_changes: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        next_state = self.ensure_bootstrap_state(state=state)
        language = str(next_state.get("language", "ru")).strip() or "ru"
        location = str(next_state.get("location", "")).strip()
        if not is_placeholder_location(location, language=language):
            return next_state

        generated_location = generate_new_location(
            setting=str(next_state.get("setting", "")).strip(),
            language=language,
            story_prompt=str(next_state.get("custom_story_prompt", "")).strip(),
        )
        next_state["location"] = generated_location
        if state_changes is not None and not str(state_changes.get("location", "")).strip():
            state_changes["location"] = generated_location

        bootstrap = next_state.setdefault("bootstrap", {})
        if is_placeholder_location(
            str(bootstrap.get("starting_location", "")).strip(),
            language=language,
        ):
            bootstrap["starting_location"] = generated_location
        return next_state


def generate_new_location(*, setting: str, language: str, story_prompt: str) -> str:
    locale = "ru" if language.startswith("ru") else "en"
    mapped = LOCATION_BOOTSTRAPS.get(locale, {}).get(setting, "")
    if mapped:
        return normalize_location_label(mapped, language=language)
    if story_prompt.strip():
        return normalize_location_label(
            story_prompt.split(",")[0].split(".")[0].strip(),
            language=language,
        )
    fallback = "Первая сцена" if locale == "ru" else "Opening Scene"
    return normalize_location_label(fallback, language=language)


def normalize_character_patch(raw_patch: dict[str, Any]) -> dict[str, Any]:
    normalized: dict[str, Any] = {}
    for key, value in raw_patch.items():
        normalized_key = str(key).strip()
        if normalized_key == "maxHp":
            normalized_key = "max_hp"
        elif normalized_key == "maxEnergy":
            normalized_key = "max_energy"
        if normalized_key not in CHARACTER_NUMERIC_KEYS:
            continue
        try:
            normalized[normalized_key] = int(value)
        except (TypeError, ValueError):
            continue
    return normalized


def normalize_module_updates(raw_updates: dict[str, Any]) -> dict[str, list[str]]:
    def _as_list(value: Any) -> list[Any]:
        if isinstance(value, list):
            return value
        if value is None:
            return []
        return [value]

    activate = [
        item
        for item in (
            str(value).strip()
            for value in _as_list(raw_updates.get("activate"))
        )
        if item in ALLOWED_MODULES
    ]
    deactivate = [
        item
        for item in (
            str(value).strip()
            for value in _as_list(raw_updates.get("deactivate"))
        )
        if item in ALLOWED_MODULES
    ]
    return {
        "activate": list(dict.fromkeys(activate)),
        "deactivate": list(dict.fromkeys(deactivate)),
    }


def apply_module_updates(
    *,
    current_modules: list[Any],
    activate: list[str],
    deactivate: list[str],
) -> list[dict[str, Any]]:
    normalized_modules: dict[str, dict[str, Any]] = {}
    for item in current_modules or []:
        if not isinstance(item, dict):
            continue
        module_name = str(item.get("module", "")).strip()
        if module_name not in ALLOWED_MODULES:
            continue
        normalized_modules[module_name] = {
            "module": module_name,
            "is_active": bool(item.get("is_active", True)),
            "activation_reason": str(item.get("activation_reason", "story_unlocked")).strip()
            or "story_unlocked",
        }

    for module_name in deactivate:
        if module_name in normalized_modules:
            normalized_modules[module_name]["is_active"] = False

    for module_name in activate:
        normalized_modules[module_name] = {
            "module": module_name,
            "is_active": True,
            "activation_reason": "story_unlocked",
        }

    return [normalized_modules[name] for name in sorted(normalized_modules.keys())]


def has_meaningful_vitality_stats(
    *,
    current_character: Any,
    incoming_patch: dict[str, Any],
) -> bool:
    character = current_character if isinstance(current_character, dict) else {}
    merged = {
        **character,
        **incoming_patch,
    }
    for key in CHARACTER_NUMERIC_KEYS:
        try:
            if int(merged.get(key, 0) or 0) > 0:
                return True
        except (TypeError, ValueError):
            continue
    return False


def _compact_character_brief(character: dict[str, Any]) -> dict[str, Any]:
    compact: dict[str, Any] = {
        "name": normalize_prompt_text(str(character.get("name", "")), limit=48),
    }
    optional_fields = {
        "gender": 24,
        "race": 48,
        "character_class": 48,
        "personality": 120,
    }
    for key, limit in optional_fields.items():
        value = normalize_prompt_text(str(character.get(key, "")), limit=limit)
        if value:
            compact[key] = value
    skills = normalize_compact_list(character.get("skills"), item_limit=3, text_limit=40)
    perks = normalize_compact_list(character.get("perks"), item_limit=3, text_limit=40)
    if skills:
        compact["skills"] = skills
    if perks:
        compact["perks"] = perks
    return compact


def _compact_character_state(character: dict[str, Any]) -> dict[str, Any]:
    compact = _compact_character_brief(character)
    for key in CHARACTER_NUMERIC_KEYS:
        value = character.get(key)
        if value in (None, "", 0):
            continue
        try:
            compact[key] = int(value)
        except (TypeError, ValueError):
            continue
    compact.pop("prompt_fragment", None)
    return compact


def _compact_memory(memory: dict[str, Any], *, budget: PromptBudgetProfile) -> dict[str, Any]:
    recent_turns_raw = memory.get("recent_turns", []) or []
    compact_recent_turns: list[dict[str, str]] = []
    for item in recent_turns_raw[-budget.max_recent_turns:]:
        if not isinstance(item, dict):
            continue
        normalized_turn: dict[str, str] = {}
        for source_key, target_key in (
            ("player_action", "player_action"),
            ("playerAction", "player_action"),
            ("outcome", "outcome"),
            ("state_hint", "state_hint"),
            ("stateHint", "state_hint"),
        ):
            value = normalize_prompt_text(
                str(item.get(source_key, "")),
                limit=budget.max_recent_turn_chars,
            )
            if value and target_key not in normalized_turn:
                normalized_turn[target_key] = value
        if normalized_turn:
            compact_recent_turns.append(normalized_turn)
    return {
        "rolling_summary": normalize_prompt_text(
            str(memory.get("rolling_summary") or memory.get("rollingSummary") or ""),
            limit=budget.max_memory_chars,
        ),
        "active_goal": normalize_prompt_text(
            str(memory.get("active_goal") or memory.get("activeGoal") or ""),
            limit=budget.max_memory_chars,
        ),
        "active_situation": normalize_prompt_text(
            str(memory.get("active_situation") or memory.get("activeSituation") or ""),
            limit=budget.max_memory_chars,
        ),
        "recent_turns": compact_recent_turns,
    }


def _compact_chronicles(
    chronicles: list[WorldChronicle],
    *,
    budget: PromptBudgetProfile,
) -> list[dict[str, Any]]:
    compact: list[dict[str, Any]] = []
    remaining_chars = budget.max_total_chronicle_chars
    for item in chronicles[: budget.max_chronicles]:
        if remaining_chars <= 0:
            break
        event_text = normalize_prompt_text(
            str(item.event_text),
            limit=min(budget.max_chronicle_chars, remaining_chars),
        )
        if not event_text:
            continue
        chronicle_item: dict[str, Any] = {
            "event_text": event_text,
            "importance": int(item.importance or 0),
        }
        location_slug = normalize_prompt_text(str(item.location_slug or ""), limit=40)
        if location_slug:
            chronicle_item["location_slug"] = location_slug
        source = ""
        if isinstance(item.metadata_json, dict):
            source = normalize_prompt_text(str(item.metadata_json.get("source", "")), limit=24)
        if source:
            chronicle_item["source"] = source
        compact.append(chronicle_item)
        remaining_chars -= len(event_text)
    return compact
