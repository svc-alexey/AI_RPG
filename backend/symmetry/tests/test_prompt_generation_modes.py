import asyncio
from unittest.mock import AsyncMock

from app.api.routes.prompts import generate_prompts
from app.schemas.campaigns import CharacterProfileInput
from app.schemas.prompts import GeneratePromptsRequest
from app.services.ai_gateway import LlmJsonResult, LlmUsage
from app.services.prompt_generation import (
    PromptGenerationService,
    _build_prompt_generation_system_prompt,
)


def test_prompt_generation_system_prompt_is_mode_aware():
    short_prompt = _build_prompt_generation_system_prompt(
        language="ru",
        mode="shortStory",
        has_locked_character=False,
    )
    long_prompt = _build_prompt_generation_system_prompt(
        language="ru",
        mode="longCampaign",
        has_locked_character=False,
    )

    assert "short story" in short_prompt.lower()
    assert "long campaign" in long_prompt.lower()
    assert "hero backstory" in long_prompt.lower()


def test_prompt_generation_system_prompt_includes_locked_hero():
    locked = _build_prompt_generation_system_prompt(
        language="en",
        mode="shortStory",
        has_locked_character=True,
    )
    assert "player already fixed" in locked.lower()


def test_generate_prompts_route_passes_mode_to_service(monkeypatch):
    mocked = AsyncMock(
        return_value={
            "story_prompt": "story",
            "character_prompt": "character",
            "campaign_title": "title",
            "objective_hint": "goal",
        }
    )
    monkeypatch.setattr(
        "app.api.routes.prompts.prompt_service.generate",
        mocked,
    )
    monkeypatch.setattr(
        "app.api.routes.prompts.credential_service.resolve",
        lambda _: object(),
    )

    payload = GeneratePromptsRequest(
        setting="romantasy",
        literary_genre="fantasyGenre",
        mode="longCampaign",
        difficulty="easy",
        language="ru",
        story_wish="hero returns home",
    )

    asyncio.run(generate_prompts(payload=payload, _=object(), __=object()))

    assert mocked.await_count == 1
    assert mocked.await_args.kwargs["mode"] == "longCampaign"


def test_prompt_generation_service_sends_mode_to_ai_gateway():
    service = PromptGenerationService()
    service._ai_gateway.generate_json = AsyncMock(
        return_value=LlmJsonResult(
            payload={
                "story_prompt": "Long-form story seed",
                "character_prompt": "Driven hero",
                "campaign_title": "Ash Harbor",
                "objective_hint": "Find the witness",
            },
            usage=LlmUsage(),
            meta={},
        )
    )

    result = asyncio.run(
        service.generate(
            credentials=object(),
            setting="cozyCrime",
            literary_genre="mysteryCrime",
            mode="longCampaign",
            difficulty="medium",
            language="en",
            story_wish="A witness vanishes before dawn.",
        )
    )

    kwargs = service._ai_gateway.generate_json.await_args.kwargs
    assert kwargs["user_payload"]["mode"] == "longCampaign"
    assert "long campaign" in kwargs["system_prompt"].lower()
    assert kwargs["max_output_tokens"] > 0
    assert kwargs["scenario"] == "prompt_generation_long"
    assert result.story_prompt == "Long-form story seed"


def test_prompt_generation_service_includes_character_in_payload():
    service = PromptGenerationService()
    service._ai_gateway.generate_json = AsyncMock(
        return_value=LlmJsonResult(
            payload={
                "story_prompt": "seed",
                "character_prompt": "hero",
                "campaign_title": "T",
                "objective_hint": "g",
            },
            usage=LlmUsage(),
            meta={},
        )
    )
    character = CharacterProfileInput(
        name="Lena",
        gender="female",
        race="human",
        character_class="rogue",
        personality="calm",
        prompt_fragment="quick",
    )
    asyncio.run(
        service.generate(
            credentials=object(),
            setting="cozyCrime",
            literary_genre="mysteryCrime",
            mode="shortStory",
            difficulty="easy",
            language="ru",
            story_wish="Rain.",
            character=character,
        )
    )
    kwargs = service._ai_gateway.generate_json.await_args.kwargs
    assert kwargs["user_payload"]["character"]["name"] == "Lena"
    assert "player already fixed" in kwargs["system_prompt"].lower()
