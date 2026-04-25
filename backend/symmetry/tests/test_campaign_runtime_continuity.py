from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state


class _PayloadCharacter:
    name = "Alexey"
    gender = "male"
    race = "human"
    character_class = "student"
    personality = "curious"
    prompt_fragment = "A curious student who notices details."
    skills = ["observation"]
    perks = ["quick learner"]


class _Payload:
    title = "Hogwarts Echoes"
    setting = "magicSchool"
    mode = "shortStory"
    difficulty = "medium"
    language = "ru"
    story_prompt = "A new student arrives at Hogwarts and quickly notices that something is wrong."
    objective_hint = "Understand what is happening at Hogwarts"
    character = _PayloadCharacter()


class _WorldState:
    current_day = 1
    minute_of_day = 540
    global_vars = {"weather": "clear", "butterfly": {}}


def test_apply_turn_result_preserves_durable_facts_and_known_characters():
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Ты знакомишься с Гарри Поттером и Гермионой в вагоне Хогвартс-экспресса.",
            "choices": ["Продолжить разговор"],
            "state_changes": {},
            "memory_entry": "Познакомился с Гарри Поттером и Гермионой в купе.",
            "importance": 7,
        },
        player_action="Поздороваться",
    )

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "За завтраком Рон замечает, что Флитвик носит с собой странную книгу.",
            "choices": ["Спросить о книге"],
            "state_changes": {"objective": "Выяснить, что за книга у Флитвика"},
            "memory_entry": "Рон упомянул книгу Флитвика и музыку для Пушка.",
            "importance": 4,
        },
        player_action="Сесть к Рону",
    )

    known_characters = state["memory"]["known_characters"]
    assert any(item.startswith("Гарри") for item in known_characters)
    assert any(item.startswith("Гермион") for item in known_characters)

    rolling_summary = state["memory"]["rolling_summary"]
    assert "Познакомился с Гарри" in rolling_summary
    assert "книгу Флитвика" in rolling_summary


def test_build_turn_context_exposes_continuity_memory_for_prompt():
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())
    state["memory"] = {
        "rolling_summary": "Познакомился с Гарри Поттером. Рон упомянул книгу Флитвика.",
        "active_goal": "Выяснить, что за книга у Флитвика",
        "active_situation": "Герои обсуждают защиту философского камня.",
        "recent_turns": [
            {
                "player_action": "Сесть к Рону",
                "outcome": "Рон заговорил о книге Флитвика.",
                "state_hint": "Рон упомянул книгу Флитвика.",
            }
        ],
        "key_facts": [
            "Познакомился с Гарри Поттером и Гермионой.",
            "Рон упомянул книгу Флитвика и музыку для Пушка.",
        ],
        "known_characters": ["Гарри Поттер", "Гермиона", "Рон"],
    }
    state["scene_state"] = {
        "scene_anchor": "Большой зал Хогвартса",
        "current_phase": "conversation_started",
        "last_completed_beat": "Уже сидит за столом Гриффиндора.",
        "interaction_targets": ["Гарри Поттер", "Гермиона", "Рон"],
        "next_story_beat": "Понять, почему все обсуждают книгу Флитвика",
        "latest_player_intent": "Сесть к Рону",
        "continuation_required": True,
    }

    context = service.build_turn_context(
        state=state,
        world_state=_WorldState(),
        chronicles=[],
        trigger_source="manual",
    )

    memory = context["dynamic_context"]["memory"]
    assert "key_facts" in memory
    assert "known_characters" in memory
    assert "Гарри Поттер" in memory["known_characters"]
    assert any("книгу Флитвика" in item for item in memory["key_facts"])
    scene_state = context["dynamic_context"]["scene_state"]
    assert scene_state["current_phase"] == "conversation_started"
    assert scene_state["last_completed_beat"] == "Уже сидит за столом Гриффиндора."
    assert "Гарри Поттер" in scene_state["interaction_targets"]


def test_ensure_bootstrap_state_backfills_known_characters_from_old_messages():
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())
    state["memory"] = {
        "rolling_summary": "",
        "active_goal": state["objective"],
        "active_situation": state["objective"],
        "recent_turns": [],
    }
    state["messages"] = [
        {
            "role": "narrator",
            "text": "Гарри улыбается и говорит: «Привет, я Гарри. Рад познакомиться с тобой».",
        },
        {
            "role": "narrator",
            "text": "Гермиона поправляет книгу и представляется соседям по купе.",
        },
    ]

    normalized = service.ensure_bootstrap_state(state=state)

    assert any(item.startswith("Гарри") for item in normalized["memory"]["known_characters"])


def test_scene_state_advances_after_sorting_instead_of_replaying_transition():
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": (
                "Шляпа громко объявляет: «ГРИФФИНДОР!». "
                "Ты снимаешь Шляпу и направляешься к гриффиндорскому столу."
            ),
            "choices": ["Поздороваться"],
            "state_changes": {},
            "memory_entry": "Шляпа распределила в Гриффиндор; идёт к столу факультета.",
            "importance": 7,
        },
        player_action="Решиться на Гриффиндор",
    )

    assert state["scene_state"]["current_phase"] == "walking_to_table"
    assert "Гриффиндор" in state["scene_state"]["last_completed_beat"]

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": (
                "Ты спускаешься с табурета под аплодисменты и подходишь к столу. "
                "Рон хлопает тебя по плечу, Гермиона внимательно смотрит на тебя, "
                "а Гарри смущённо кивает."
            ),
            "choices": ["Ответить Рону"],
            "state_changes": {},
            "memory_entry": "Распределён в Гриффиндор, знаком с Роном, Гермионой и Гарри.",
            "importance": 6,
        },
        player_action="Поздороваться",
    )

    assert state["scene_state"]["current_phase"] in {
        "first_greeting_started",
        "conversation_started",
    }
    assert state["scene_state"]["current_phase"] != "sorted_to_house"
    assert state["scene_state"]["current_phase"] != "walking_to_table"
    assert state["scene_state"]["latest_player_intent"] == "Поздороваться"
    assert "Распределён в Гриффиндор" in state["scene_state"]["last_completed_beat"]
