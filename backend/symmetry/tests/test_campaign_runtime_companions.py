from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state


class _PayloadCharacter:
    name = "Alexey"
    gender = "male"
    race = "human"
    character_class = "student"
    personality = "curious"
    prompt_fragment = "A curious student."
    skills = ["observation"]
    perks = ["quick learner"]


class _Payload:
    title = "Test Companions"
    setting = "romantasy"
    mode = "shortStory"
    difficulty = "medium"
    language = "ru"
    story_prompt = "A hero travels with companions."
    objective_hint = "Find the artifact"
    character = _PayloadCharacter()


def test_companion_encountered_merges_by_name_not_duplicates():
    """ISSUE: companion_encountered creates duplicates instead of updating."""
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    # First encounter — adds new companion
    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Варя присоединяется к вам.",
            "choices": ["Продолжить"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Варя",
                    "brief": "воин",
                    "status": "neutral",
                }
            },
            "memory_entry": "Варя стала спутником.",
        },
        player_action="Приветствовать",
    )

    companions = state.get("companions", [])
    assert len(companions) == 1, f"Expected 1 companion, got {len(companions)}"
    assert companions[0]["name"] == "Варя"
    assert companions[0]["notes"] == "воин"

    # Second encounter — same companion, status changed
    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Варя становится дружелюбнее после битвы.",
            "choices": ["Идти дальше"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Варя",
                    "brief": "стала дружелюбнее после битвы",
                    "status": "friendly",
                }
            },
            "memory_entry": "Варя стала дружелюбнее.",
        },
        player_action="Сражаться",
    )

    companions = state.get("companions", [])
    assert len(companions) == 1, (
        f"Expected 1 companion after update, got {len(companions)}: {companions}"
    )
    assert companions[0]["name"] == "Варя"
    assert companions[0]["status"] == "friendly", (
        f"Status should be 'friendly', got '{companions[0]['status']}'"
    )
    assert companions[0]["notes"] == "стала дружелюбнее после битвы", (
        f"Notes should be updated, got '{companions[0]['notes']}'"
    )


def test_companion_encountered_preserves_status_if_not_provided():
    """When an existing companion is encountered without a new status,
    the existing status should be preserved (not reset to 'neutral')."""
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Варя присоединяется.",
            "choices": ["OK"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Варя",
                    "brief": "воин",
                    "status": "friendly",
                }
            },
            "memory_entry": "Варя стала спутником.",
        },
        player_action="Привет",
    )

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Варя всё ещё с вами.",
            "choices": ["OK"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Варя",
                    "brief": "по-прежнему с вами",
                }
            },
            "memory_entry": "Варя рядом.",
        },
        player_action="Осмотреться",
    )

    companions = state.get("companions", [])
    assert len(companions) == 1
    assert companions[0]["status"] == "friendly", (
        f"Status should remain 'friendly', got '{companions[0]['status']}'"
    )


def test_companion_encountered_adds_new_companion_alongside_existing():
    """A genuinely new companion should be added alongside existing ones."""
    service = CampaignRuntimeService()
    state = build_initial_state(_Payload())

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Варя присоединяется.",
            "choices": ["OK"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Варя",
                    "brief": "воин",
                }
            },
            "memory_entry": "Варя стала спутником.",
        },
        player_action="Привет",
    )

    state, _, _, _ = service.apply_turn_result(
        state=state,
        result={
            "narration": "Кир появляется из тени.",
            "choices": ["OK"],
            "state_changes": {
                "companion_encountered": {
                    "name": "Кир",
                    "brief": "лучник",
                }
            },
            "memory_entry": "Кир присоединился.",
        },
        player_action="Позвать",
    )

    companions = state.get("companions", [])
    assert len(companions) == 2, f"Expected 2 companions, got {len(companions)}"
    names = {c["name"] for c in companions}
    assert names == {"Варя", "Кир"}, f"Expected {{Варя, Кир}}, got {names}"
