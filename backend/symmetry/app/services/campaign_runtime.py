from copy import deepcopy
from typing import Any

from app.db.models import WorldChronicle, WorldState
from app.services.presentation_text import (
    normalize_campaign_title,
    normalize_choices,
    normalize_location_label,
    normalize_objective_text,
)


def build_initial_state(payload) -> dict[str, Any]:
    language = payload.language.strip() or "ru"
    location = normalize_location_label("", language=language)
    objective = normalize_objective_text(
        payload.objective_hint.strip() or payload.story_prompt.strip(),
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
        "location": location,
        "objective": objective,
        "character": {
            "name": payload.character.name,
            "gender": payload.character.gender,
            "race": payload.character.race,
            "character_class": payload.character.character_class,
            "personality": payload.character.personality,
            "prompt_fragment": payload.character.prompt_fragment,
            "skills": payload.character.skills,
            "perks": payload.character.perks,
        },
        "memory": {
            "rolling_summary": payload.story_prompt.strip(),
            "active_goal": objective,
            "active_situation": objective,
            "recent_turns": [],
        },
        "messages": [],
        "choices": [],
    }


class CampaignRuntimeService:
    def build_turn_context(
        self,
        *,
        state: dict[str, Any],
        world_state: WorldState,
        chronicles: list[WorldChronicle],
    ) -> dict[str, Any]:
        return {
            "campaign": {
                "title": state.get("title", ""),
                "setting": state.get("setting", ""),
                "mode": state.get("mode", ""),
                "difficulty": state.get("difficulty", ""),
                "turn_number": state.get("turn_number", 0),
            },
            "memory": state.get("memory", {}),
            "world_state": {
                "current_day": world_state.current_day,
                "minute_of_day": world_state.minute_of_day,
                "global_vars": world_state.global_vars,
            },
            "state": {
                "location": state.get("location", ""),
                "objective": state.get("objective", ""),
                "character": state.get("character", {}),
                "choices": state.get("choices", []),
            },
            "relevant_chronicles": [
                {
                    "event_text": item.event_text,
                    "importance": item.importance,
                    "location_slug": item.location_slug,
                    "metadata": item.metadata_json,
                }
                for item in chronicles
            ],
        }

    def apply_turn_result(
        self,
        *,
        state: dict[str, Any],
        result: dict[str, Any],
        player_action: str,
    ) -> tuple[dict[str, Any], dict[str, Any], int, str]:
        next_state = deepcopy(state)
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
        character_patch = state_changes.get("character_patch", {}) or {}
        if character_patch:
            next_state.setdefault("character", {}).update(character_patch)

        narration = str(result.get("narration", "")).strip()
        memory_entry = str(result.get("memory_entry", narration)).strip() or narration
        next_state.setdefault("messages", []).extend(
            [
                {"role": "player", "text": player_action},
                {"role": "narrator", "text": narration},
            ]
        )
        memory = next_state.setdefault("memory", {})
        recent_turns = list(memory.get("recent_turns", []))
        recent_turns.append(
            {
                "player_action": player_action,
                "outcome": narration,
                "state_hint": memory_entry,
            }
        )
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
        world_event_summary = str(result.get("world_event_summary", "")).strip()
        return next_state, state_changes, importance, world_event_summary
