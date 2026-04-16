from app.services.campaign_runtime import (
    CampaignRuntimeService,
    build_initial_state,
    normalize_module_updates,
)


class _PayloadCharacter:
    name = "Iris"
    gender = "female"
    race = "human"
    character_class = "detective"
    personality = "calm but relentless"
    prompt_fragment = "A detective with a stubborn streak."
    skills = ["observation"]
    perks = ["keen eye"]


class _Payload:
    title = "Ash Harbor"
    setting = "cozyCrime"
    mode = "shortStory"
    difficulty = "medium"
    language = "ru"
    story_prompt = "A missing witness vanished near the harbor."
    objective_hint = "Find the missing witness"
    character = _PayloadCharacter()


def test_apply_turn_result_accepts_textual_importance_levels():
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    next_state, _, importance, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "The harbor fog parts just enough to reveal a fresh trail.",
            "choices": ["Inspect the trail"],
            "state_changes": {},
            "memory_entry": "A fresh trail appears by the harbor.",
            "importance": "medium",
        },
        player_action="",
    )

    assert next_state["turn_number"] == 1
    assert importance == 6


def test_normalize_module_updates_accepts_plain_activate_list():
    updates = normalize_module_updates(["notes", "companions", "unknown"])

    assert updates == {
        "activate": ["notes", "companions"],
        "deactivate": [],
    }
