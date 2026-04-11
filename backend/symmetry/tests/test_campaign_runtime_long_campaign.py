from app.services.ai_gateway import build_turn_system_prompt
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


class _WorldState:
    current_day = 1
    minute_of_day = 480
    global_vars = {"weather": "fog"}


def test_build_initial_state_keeps_custom_story_prompt():
    state = build_initial_state(_Payload())

    assert state["mode"] == "longCampaign"
    assert state["custom_story_prompt"] == _Payload.story_prompt
    assert state["character"]["prompt_fragment"] == _PayloadCharacter.prompt_fragment


def test_build_turn_context_exposes_story_seed_and_character_prompt():
    state = build_initial_state(_Payload())
    service = CampaignRuntimeService()

    context = service.build_turn_context(
        state=state,
        world_state=_WorldState(),
        chronicles=[],
        trigger_source="intro",
    )

    assert context["campaign_bootstrap"]["mode"] == "longCampaign"
    assert context["dynamic_context"]["turn_number"] == 0
    assert context["campaign_bootstrap"]["story_prompt"] == _Payload.story_prompt
    assert (
        context["character_brief"]["character_prompt"]
        == _PayloadCharacter.prompt_fragment
    )
    assert context["dynamic_context"]["request"]["trigger_source"] == "intro"
    assert "prompt_fragment" not in context["dynamic_context"]["state"]["character"]


def test_long_campaign_intro_system_prompt_requires_visible_prologue():
    prompt = build_turn_system_prompt(
        language="ru",
        mode="longCampaign",
        turn_number=0,
        trigger_source="intro",
    )

    assert "visible prologue" in prompt.lower()
    assert "two clear paragraphs" in prompt.lower()
    assert "impact seeds" in prompt.lower()


def test_short_story_system_prompt_stays_compact():
    prompt = build_turn_system_prompt(
        language="ru",
        mode="shortStory",
        turn_number=0,
        trigger_source="intro",
    )

    assert "shortstory mode" in prompt.lower()
    assert "move the player into action quickly" in prompt.lower()
    assert "local and fast" in prompt.lower()
