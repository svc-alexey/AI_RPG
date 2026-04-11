from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state


class _PayloadCharacter:
    name = "Iris"
    gender = "female"
    race = "human"
    character_class = "detective"
    personality = "calm but relentless"
    prompt_fragment = "A detective with a stubborn streak and an eye for detail."
    skills = ["observation", "deduction", "surveillance", "forensics", "lockpicking"]
    perks = ["keen eye", "cold reader", "steady hands", "night owl"]


class _Payload:
    title = "Ash Harbor"
    setting = "cozyCrime"
    mode = "longCampaign"
    difficulty = "medium"
    language = "ru"
    story_prompt = (
        "A rain-soaked port city hides an old debt, a missing witness, and a network "
        "of favors that reaches every pier and warehouse."
    )
    objective_hint = "Find the missing witness"
    character = _PayloadCharacter()


class _WorldState:
    current_day = 3
    minute_of_day = 615
    global_vars = {
        "weather": "fog",
        "prices": {"fish": 3},
        "butterfly": {"markets": {"harbor": "tense"}},
    }


class _Chronicle:
    def __init__(self, text: str, importance: int, location_slug: str, metadata_json: dict):
        self.event_text = text
        self.importance = importance
        self.location_slug = location_slug
        self.metadata_json = metadata_json


def test_build_turn_context_compacts_memory_and_chronicles():
    state = build_initial_state(_Payload())
    state["turn_number"] = 4
    state["memory"] = {
        "rolling_summary": "  ".join(["summary"] * 80),
        "active_goal": "  ".join(["goal"] * 40),
        "active_situation": "  ".join(["situation"] * 40),
        "recent_turns": [
            {
                "player_action": "  ".join(["inspect"] * 20),
                "outcome": "  ".join(["outcome"] * 25),
                "state_hint": "  ".join(["hint"] * 25),
            }
            for _ in range(5)
        ],
    }
    state["character"]["hp"] = 11
    state["character"]["prompt_fragment"] = "  ".join(["clue"] * 60)

    service = CampaignRuntimeService()
    chronicles = [
        _Chronicle("  ".join(["harbor"] * 60), 6, "mist-harbor", {"source": "butterfly_effect"}),
        _Chronicle("  ".join(["market"] * 60), 5, "mist-harbor", {"source": "world_state"}),
        _Chronicle("  ".join(["warehouse"] * 60), 4, "mist-harbor", {"source": "world_state"}),
    ]

    context = service.build_turn_context(
        state=state,
        world_state=_WorldState(),
        chronicles=chronicles,
        trigger_source="manual",
    )

    assert len(context["dynamic_context"]["memory"]["recent_turns"]) <= 3
    assert "prompt_fragment" not in context["dynamic_context"]["state"]["character"]
    assert "global_vars" not in context["dynamic_context"]["world_state"]
    assert len(context["dynamic_context"]["relevant_chronicles"]) <= 3
    assert all("metadata" not in item for item in context["dynamic_context"]["relevant_chronicles"])
    assert all(len(item["event_text"]) <= 150 for item in context["dynamic_context"]["relevant_chronicles"])
