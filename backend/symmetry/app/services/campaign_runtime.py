import re
from copy import deepcopy
from typing import Any

from app.db.models import WorldChronicle, WorldState
from app.services.ai_gateway import is_placeholder_location
from app.services.prompt_budget import PromptBudgetProfile, build_turn_budget
from app.services.presentation_text import (
    looks_like_opaque_reference,
    normalize_campaign_title,
    normalize_choices,
    normalize_location_label,
    normalize_objective_text,
    sanitize_world_rumor_event_text,
)
from app.services.text_normalization import normalize_compact_list, normalize_prompt_text


ALLOWED_MODULES = {
    "vitality",
    "inventory",
    "notes",
    "companions",
    "resources",
    "progression",
    "checks",
}

_CORE_MODULES: set[str] = {"notes"}

_MODULE_ACTIVATION_MATRIX: dict[str, tuple[list[str], list[str]]] = {
    "inventory": (
        ["romantasy", "grimdarkFantasy", "litRpgProgression", "postApocalypse", "nearFutureSciFi"],
        ["fantasyGenre", "speculativeFiction"],
    ),
    "companions": (
        ["romantasy", "cozyFantasy"],
        ["romance", "romantasyGenre", "youngAdult"],
    ),
    "vitality": (
        ["grimdarkFantasy", "horrorWeird", "postApocalypse"],
        ["horrorGenre"],
    ),
    "resources": (
        ["postApocalypse", "nearFutureSciFi", "litRpgProgression"],
        ["speculativeFiction"],
    ),
    "progression": (
        ["litRpgProgression", "grimdarkFantasy"],
        [],
    ),
    "checks": (
        ["grimdarkFantasy", "litRpgProgression", "horrorWeird"],
        [],
    ),
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

MAX_STORED_RECENT_TURNS = 8
MAX_STORED_KEY_FACTS = 14
MAX_STORED_KNOWN_CHARACTERS = 10
ROLLING_SUMMARY_STORAGE_LIMIT = 420
MEMORY_FACT_TEXT_LIMIT = 180

DURABLE_FACT_MARKERS = (
    "познаком",
    "узнал",
    "выяснил",
    "договор",
    "пообещ",
    "распредел",
    "met ",
    "learned",
    "discovered",
    "agreed",
    "promised",
)


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
        "literary_genre": getattr(payload, "literary_genre", "") or "",
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
            "key_facts": [],
            "known_characters": [],
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
        next_state["memory"] = _normalize_memory_state(
            next_state.get("memory", {}) or {},
            messages=next_state.get("messages", []) or [],
            fallback_summary=str(next_state.get("custom_story_prompt", "")).strip(),
            fallback_goal=str(next_state.get("objective", "")).strip(),
            fallback_situation=str(next_state.get("objective", "")).strip(),
        )
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
                    "factions": (world_state.global_vars or {}).get("factions", {}),
                    "prices": (world_state.global_vars or {}).get("prices", {}),
                },
                "state": {
                    "location": (
                        normalize_location_label(
                            str(current_state.get("location", "")).strip(),
                            language=str(current_state.get("language", "ru")).strip() or "ru",
                        )
                        if looks_like_opaque_reference(
                            str(current_state.get("location", "")).strip()
                        )
                        else normalize_prompt_text(
                            str(current_state.get("location", "")),
                            limit=48,
                        )
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

    def build_rag_query_text(
        self,
        *,
        state: dict[str, Any],
        player_action: str,
    ) -> str:
        current_state = self.ensure_bootstrap_state(state=state)
        memory = current_state.get("memory", {}) or {}
        recent_turns = _normalize_recent_turns(memory.get("recent_turns", []) or [])
        query_parts: list[str] = []

        def _append(label: str, value: str, *, limit: int) -> None:
            normalized = normalize_prompt_text(value, limit=limit)
            if normalized:
                query_parts.append(f"{label}: {normalized}")

        _append("player_action", player_action, limit=240)
        _append("current_objective", str(current_state.get("objective", "")), limit=96)
        _append("current_location", str(current_state.get("location", "")), limit=64)
        _append("rolling_summary", str(memory.get("rolling_summary", "")), limit=220)
        _append("active_goal", str(memory.get("active_goal", "")), limit=96)
        _append("active_situation", str(memory.get("active_situation", "")), limit=140)

        known_characters = normalize_compact_list(
            memory.get("known_characters") or [],
            item_limit=MAX_STORED_KNOWN_CHARACTERS,
            text_limit=48,
        )
        if known_characters:
            query_parts.append("known_characters: " + ", ".join(known_characters))

        for fact in _select_memory_fact_excerpt(
            memory.get("key_facts") or [],
            max_items=4,
        ):
            _append("key_fact", fact, limit=140)

        for item in recent_turns[-4:]:
            _append("recent_state_hint", str(item.get("state_hint", "")), limit=120)
            _append("recent_outcome", str(item.get("outcome", "")), limit=120)

        return "\n".join(query_parts)

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
        if location and not looks_like_opaque_reference(location):
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
        setting = str(next_state.get("setting", "")).strip()
        genre = str(next_state.get("literary_genre", "")).strip() or None
        rejected = self.validate_module_activation(
            modules=module_updates["activate"],
            setting=setting,
            genre=genre,
        )
        if rejected:
            module_updates["activate"] = [
                m for m in module_updates["activate"] if m not in rejected
            ]
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

        # Cross-module wiring
        active_modules = {
            str(m.get("module", "")).strip()
            for m in next_state.get("modules", []) or []
            if isinstance(m, dict) and m.get("is_active", True)
        }
        player_state = dict(next_state.get("player", {}) or {})

        # 1. Inventory → Notes
        inventory_changes = state_changes.get("inventory_add", []) or []
        if inventory_changes and "notes" in active_modules:
            note_text = f"Получено: {', '.join(str(i) for i in inventory_changes[:3])}"
            notes = list(player_state.get("notes", []) or [])
            notes.append({"text": note_text, "turn": next_state.get("turn_number", 0)})
            player_state["notes"] = notes

        # 2. Progression → Vitality: level-up restores hp/energy
        prog = player_state.get("progression", {}) or {}
        prev_state_data = state.get("player", {}) or {}
        prev_prog = prev_state_data.get("progression", {}) or {}
        if prog.get("level", 1) > prev_prog.get("level", 1):
            character = dict(player_state.get("character", {}) or {})
            character["hp"] = character.get("maxHp") or 12
            character["energy"] = character.get("maxEnergy") or 8
            player_state["character"] = character

        next_state["player"] = player_state

        narration = normalize_prompt_text(str(result.get("narration", "")))
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
        recent_turns = _normalize_recent_turns(memory.get("recent_turns", []) or [])
        recent_turn_entry = {
            "outcome": narration,
            "state_hint": memory_entry,
        }
        if trimmed_player_action:
            recent_turn_entry["player_action"] = trimmed_player_action
        recent_turns.append(recent_turn_entry)
        quest_note = str(state_changes.get("quest_note", "")).strip()
        importance = normalize_importance(result.get("importance", 0))
        key_facts = _upsert_memory_fact(
            memory.get("key_facts", []) or [],
            memory_entry,
            importance=importance,
        )
        if quest_note:
            key_facts = _upsert_memory_fact(
                key_facts,
                quest_note,
                importance=max(importance, 6),
            )
        memory["recent_turns"] = recent_turns[-MAX_STORED_RECENT_TURNS:]
        memory["key_facts"] = key_facts
        memory["known_characters"] = _merge_known_characters(
            memory.get("known_characters", []) or [],
            _extract_known_characters(
                memory_entry,
                narration,
            ),
        )
        memory["rolling_summary"] = _build_rolling_summary(
            memory.get("key_facts", []) or [],
            fallback=memory_entry,
        )
        if quest_note:
            memory["active_goal"] = normalize_objective_text(
                quest_note,
                language=language,
            )
        memory["active_situation"] = narration
        world_event_summary = normalize_prompt_text(
            str(result.get("world_event_summary", "")),
            limit=240,
        )
        return next_state, state_changes, importance, world_event_summary

    def validate_module_activation(
        self,
        *,
        modules: list[str],
        setting: str,
        genre: str | None,
    ) -> list[str]:
        rejected: list[str] = []
        for module in modules:
            if module in _CORE_MODULES:
                continue
            matrix = _MODULE_ACTIVATION_MATRIX.get(module)
            if matrix is None:
                rejected.append(module)
                continue
            settings_allowed, genres_allowed = matrix
            if setting not in settings_allowed and (not genre or genre not in genres_allowed):
                rejected.append(module)
        return rejected

    def ensure_playable_location(
        self,
        *,
        state: dict[str, Any],
        state_changes: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        next_state = self.ensure_bootstrap_state(state=state)
        language = str(next_state.get("language", "ru")).strip() or "ru"
        location = str(next_state.get("location", "")).strip()
        if is_placeholder_location(location, language=language):
            return next_state

        bootstrap = next_state.setdefault("bootstrap", {})
        if is_placeholder_location(
            str(bootstrap.get("starting_location", "")).strip(),
            language=language,
        ):
            normalized_location = normalize_location_label(location, language=language)
            next_state["location"] = normalized_location
            bootstrap["starting_location"] = normalized_location
            if state_changes is not None and not str(state_changes.get("location", "")).strip():
                state_changes["location"] = normalized_location
        return next_state


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


def normalize_importance(raw_value: Any) -> int:
    try:
        return max(0, min(10, int(raw_value or 0)))
    except (TypeError, ValueError):
        normalized = str(raw_value or "").strip().lower()
        if normalized in {"low", "minor"}:
            return 3
        if normalized in {"medium", "moderate"}:
            return 6
        if normalized in {"high", "major"}:
            return 8
        if normalized in {"critical", "severe"}:
            return 10
        return 0


def normalize_module_updates(raw_updates: dict[str, Any]) -> dict[str, list[str]]:
    if isinstance(raw_updates, list):
        raw_updates = {"activate": raw_updates}
    elif isinstance(raw_updates, str):
        raw_updates = {"activate": [raw_updates]}
    elif not isinstance(raw_updates, dict):
        raw_updates = {}

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
            compact[key] = int(value)  # type: ignore[arg-type]
        except (TypeError, ValueError):
            continue
    compact.pop("prompt_fragment", None)
    return compact


def _compact_memory(memory: dict[str, Any], *, budget: PromptBudgetProfile) -> dict[str, Any]:
    recent_turns_raw = _normalize_recent_turns(memory.get("recent_turns", []) or [])
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
    compact_memory = {
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
    key_facts = [
        normalize_prompt_text(item, limit=min(140, budget.max_memory_chars))
        for item in _select_memory_fact_excerpt(
            memory.get("key_facts") or memory.get("keyFacts") or [],
            max_items=max(2, budget.max_recent_turns),
        )
    ]
    key_facts = [item for item in key_facts if item]
    if key_facts:
        compact_memory["key_facts"] = key_facts
    known_characters = normalize_compact_list(
        memory.get("known_characters") or memory.get("knownCharacters") or [],
        item_limit=max(4, budget.max_recent_turns + 3),
        text_limit=40,
    )
    if known_characters:
        compact_memory["known_characters"] = known_characters
    return compact_memory


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
        chronicle_language = (
            "en"
            if str(item.event_text).lstrip().startswith("While the hero was occupied")
            else "ru"
        )
        event_text = normalize_prompt_text(
            sanitize_world_rumor_event_text(
                str(item.event_text),
                language=chronicle_language,
            ),
            limit=min(budget.max_chronicle_chars, remaining_chars),
        )
        if not event_text:
            continue
        chronicle_item: dict[str, Any] = {
            "event_text": event_text,
            "importance": int(item.importance or 0),
        }
        location_slug = normalize_prompt_text(str(item.location_slug or ""), limit=40)
        if location_slug and not looks_like_opaque_reference(location_slug):
            chronicle_item["location_slug"] = location_slug
        source = ""
        if isinstance(item.metadata_json, dict):
            source = normalize_prompt_text(str(item.metadata_json.get("source", "")), limit=24)
        if source:
            chronicle_item["source"] = source
        compact.append(chronicle_item)
        remaining_chars -= len(event_text)
    return compact


def _normalize_memory_state(
    memory: dict[str, Any],
    *,
    messages: list[Any],
    fallback_summary: str,
    fallback_goal: str,
    fallback_situation: str,
) -> dict[str, Any]:
    normalized = dict(memory) if isinstance(memory, dict) else {}
    key_facts = normalized.get("key_facts") or normalized.get("keyFacts") or []
    normalized["key_facts"] = _normalize_memory_fact_list(key_facts)
    normalized["recent_turns"] = _normalize_recent_turns(
        normalized.get("recent_turns") or normalized.get("recentTurns") or []
    )[-MAX_STORED_RECENT_TURNS:]
    normalized["known_characters"] = _merge_known_characters(
        normalized.get("known_characters") or normalized.get("knownCharacters") or [],
        _extract_known_characters_from_messages(messages),
    )
    normalized["rolling_summary"] = normalize_prompt_text(
        str(normalized.get("rolling_summary") or normalized.get("rollingSummary") or ""),
        limit=ROLLING_SUMMARY_STORAGE_LIMIT,
    ) or _build_rolling_summary(
        normalized["key_facts"],
        fallback=fallback_summary,
    )
    normalized["active_goal"] = normalize_prompt_text(
        str(normalized.get("active_goal") or normalized.get("activeGoal") or fallback_goal),
        limit=240,
    )
    normalized["active_situation"] = normalize_prompt_text(
        str(
            normalized.get("active_situation")
            or normalized.get("activeSituation")
            or fallback_situation
        ),
        limit=320,
    )
    return normalized


def _normalize_recent_turns(items: Any) -> list[dict[str, str]]:
    normalized_turns: list[dict[str, str]] = []
    raw_items = items if isinstance(items, list) else []
    for item in raw_items:
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
                limit=240,
            )
            if value and target_key not in normalized_turn:
                normalized_turn[target_key] = value
        if normalized_turn:
            normalized_turns.append(normalized_turn)
    return normalized_turns


def _normalize_memory_fact_list(items: Any) -> list[str]:
    raw_items = items if isinstance(items, list) else []
    normalized = [
        normalize_prompt_text(str(item), limit=MEMORY_FACT_TEXT_LIMIT)
        for item in raw_items
    ]
    unique: list[str] = []
    for item in normalized:
        if item and item not in unique:
            unique.append(item)
    return unique[-MAX_STORED_KEY_FACTS:]


def _upsert_memory_fact(
    items: Any,
    fact: str,
    *,
    importance: int,
) -> list[str]:
    normalized_fact = normalize_prompt_text(fact, limit=MEMORY_FACT_TEXT_LIMIT)
    facts = [item for item in _normalize_memory_fact_list(items) if item != normalized_fact]
    if normalized_fact:
        facts.append(normalized_fact)
    while len(facts) > MAX_STORED_KEY_FACTS:
        removable_index = next(
            (index for index, item in enumerate(facts) if not _is_durable_fact(item, importance=0)),
            0,
        )
        facts.pop(removable_index)
    if normalized_fact and not _is_durable_fact(normalized_fact, importance=importance):
        return facts[-MAX_STORED_KEY_FACTS:]
    return facts


def _is_durable_fact(text: str, *, importance: int) -> bool:
    normalized = normalize_prompt_text(text, limit=MEMORY_FACT_TEXT_LIMIT).lower()
    if not normalized:
        return False
    if importance >= 6:
        return True
    if any(marker in normalized for marker in DURABLE_FACT_MARKERS):
        return True
    return bool(_extract_known_characters(text))


def _select_memory_fact_excerpt(items: Any, *, max_items: int) -> list[str]:
    facts = _normalize_memory_fact_list(items)
    if not facts or max_items <= 0:
        return []
    selected: list[str] = []
    head = facts[:1]
    tail = facts[-max(1, max_items - 1) :]
    for item in head:
        if item not in selected:
            selected.append(item)
    for item in tail:
        if item not in selected:
            selected.append(item)
    for item in facts[1:]:
        if len(selected) >= max_items:
            break
        if item not in selected:
            selected.append(item)
    return selected


def _build_rolling_summary(items: Any, *, fallback: str) -> str:
    selected = _select_memory_fact_excerpt(items, max_items=4)
    fallback_text = normalize_prompt_text(fallback, limit=MEMORY_FACT_TEXT_LIMIT)
    if fallback_text and fallback_text not in selected:
        selected.append(fallback_text)
    if not selected:
        return normalize_prompt_text(fallback, limit=ROLLING_SUMMARY_STORAGE_LIMIT)
    return normalize_prompt_text(
        " | ".join(selected),
        limit=ROLLING_SUMMARY_STORAGE_LIMIT,
    )


def _merge_known_characters(items: Any, additions: list[str]) -> list[str]:
    known = normalize_compact_list(
        items if isinstance(items, list) else [],
        item_limit=MAX_STORED_KNOWN_CHARACTERS,
        text_limit=48,
    )
    for item in additions:
        normalized = normalize_prompt_text(item, limit=48)
        if normalized and normalized not in known:
            known.append(normalized)
    return known[-MAX_STORED_KNOWN_CHARACTERS:]


def _extract_known_characters(*texts: str) -> list[str]:
    candidates: list[str] = []
    for text in texts:
        normalized = normalize_prompt_text(text)
        if not normalized:
            continue
        for pattern in (
            r"познаком\w*\s+с\s+([^.!?]+)",
            r"(?:met|meet|introduced myself to)\s+([^.!?]+)",
        ):
            for match in re.finditer(pattern, normalized, flags=re.IGNORECASE):
                fragment = match.group(1)
                for candidate in re.split(r",| и | and ", fragment):
                    cleaned = normalize_prompt_text(candidate, limit=48)
                    cleaned = re.sub(r"\s+(?:в|на|за|у)\s+.*$", "", cleaned, flags=re.IGNORECASE)
                    if _looks_like_character_name(cleaned):
                        candidates.append(cleaned)
    return normalize_compact_list(
        candidates,
        item_limit=MAX_STORED_KNOWN_CHARACTERS,
        text_limit=48,
    )


def _extract_known_characters_from_messages(messages: list[Any]) -> list[str]:
    candidates: list[str] = []
    for item in messages:
        if not isinstance(item, dict):
            continue
        text = normalize_prompt_text(str(item.get("text", "")))
        if not text:
            continue
        candidates.extend(_extract_known_characters(text))
        for pattern in (
            r"(?:привет|здравствуй)[^.!?\n]{0,30}\bя\s+([A-ZА-ЯЁ][A-Za-zА-Яа-яЁё-]+(?:\s+[A-ZА-ЯЁ][A-Za-zА-Яа-яЁё-]+){0,2})",
            r"(?:hello|hi)[^.!?\n]{0,20}\bi[' ]?m\s+([A-Z][A-Za-z-]+(?:\s+[A-Z][A-Za-z-]+){0,2})",
        ):
            for match in re.finditer(pattern, text, flags=re.IGNORECASE):
                candidate = normalize_prompt_text(match.group(1), limit=48)
                if _looks_like_character_name(candidate):
                    candidates.append(candidate)
    return normalize_compact_list(
        candidates,
        item_limit=MAX_STORED_KNOWN_CHARACTERS,
        text_limit=48,
    )


def _looks_like_character_name(text: str) -> bool:
    normalized = normalize_prompt_text(text, limit=48)
    if not normalized:
        return False
    parts = normalized.split()
    if not parts or len(parts) > 4:
        return False
    meaningful_parts = 0
    for part in parts:
        if len(part) < 2:
            return False
        if not part[0].isalpha() or not part[0].isupper():
            return False
        meaningful_parts += 1
    return meaningful_parts > 0
