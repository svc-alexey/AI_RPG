from app.services.ai_gateway import is_placeholder_location
from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state


class _PayloadCharacter:
    name = "Iris"
    gender = "female"
    race = "human"
    character_class = "detective"
    personality = "calm"
    prompt_fragment = "A detective with a stubborn streak."
    skills = ["observation"]
    perks = ["keen eye"]


class _Payload:
    title = "Ash Harbor"
    setting = "cozyCrime"
    mode = "longCampaign"
    difficulty = "medium"
    language = "ru"
    story_prompt = "A rain-soaked port city hides an old debt and a missing witness."
    objective_hint = "Find the missing witness"
    character = _PayloadCharacter()


def test_apply_turn_result_skips_empty_player_message_for_intro_turn():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()

    next_state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Дождь шуршит по крышам, а впереди проступает первый причал.",
            "choices": ["Осмотреть причал"],
            "state_changes": {},
            "memory_entry": "Ирис выходит к первому причалу под дождем.",
        },
        player_action="",
    )

    assert [item["role"] for item in next_state["messages"]] == ["narrator"]
    assert next_state["memory"]["recent_turns"][0].get("player_action", "") == ""


def test_ensure_playable_location_preserves_placeholder_for_ai():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()
    state_changes = {}

    next_state = service.ensure_playable_location(
        state=state,
        state_changes=state_changes,
    )

    assert next_state["location"] == "Начальная точка"
    assert state_changes == {}


class _StubWorldState:
    current_day = 1
    minute_of_day = 480
    global_vars = {"weather": "clear", "butterfly": {}}


def test_build_turn_context_keeps_placeholder_for_ai_location_generation():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()
    resolved = service.ensure_playable_location(state=state)
    context = service.build_turn_context(
        state=resolved,
        world_state=_StubWorldState(),
        chronicles=[],
        trigger_source="manual",
    )
    location = str(
        context["dynamic_context"]["state"].get("location", "")
    ).strip()
    assert is_placeholder_location(location, language="ru")
    starting = str(
        context["world_bootstrap"].get("starting_location", "")
    ).strip()
    assert is_placeholder_location(starting, language="ru")


def test_ai_generated_location_updates_starting_bootstrap():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()

    next_state, state_changes, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Ирис стоит у закрытого склада, где пахнет мокрой солью.",
            "choices": ["Осмотреть склад"],
            "state_changes": {
                "location": "Склад у старого причала",
            },
            "memory_entry": "Ирис начинает расследование у склада на причале.",
        },
        player_action="",
    )
    next_state = service.ensure_playable_location(
        state=next_state,
        state_changes=state_changes,
    )

    assert next_state["location"] == "Склад у старого причала"
    assert next_state["bootstrap"]["starting_location"] == "Склад у старого причала"
    assert state_changes["location"] == "Склад у старого причала"


def test_apply_turn_result_can_activate_vitality_and_assign_stats():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()

    next_state, state_changes, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "На причале начинается драка, и Ирис вынуждена быстро оценить силы.",
            "choices": ["Принять бой"],
            "state_changes": {
                "module_updates": {
                    "activate": ["vitality"],
                },
                "character_patch": {
                    "hp": 11,
                    "max_hp": 11,
                    "energy": 7,
                    "max_energy": 7,
                    "might": 2,
                    "wit": 4,
                    "spirit": 3,
                },
            },
            "memory_entry": "Ирис впервые вступает в опасную стычку на причале.",
        },
        player_action="Вступаю в драку",
    )

    assert next_state["modules"] == [
        {
            "module": "vitality",
            "is_active": True,
            "activation_reason": "story_unlocked",
        }
    ]
    assert next_state["character"]["max_hp"] == 11
    assert next_state["character"]["spirit"] == 3
    assert state_changes["module_updates"]["activate"] == ["vitality"]
