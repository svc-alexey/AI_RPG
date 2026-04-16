import pytest

from app.services.ai_gateway import (
    _parse_usage,
    AiGatewayService,
    LlmUsage,
    build_turn_dynamic_payload,
    build_turn_prefix_messages,
    build_messages,
    build_turn_system_prompt,
)
from app.services.prompt_budget import build_prompt_generation_budget, build_turn_budget


def _context(turn_number: int) -> dict:
    return {
        "campaign_bootstrap": {
            "title": "Ash Harbor",
            "setting": "cozyCrime",
            "mode": "longCampaign",
            "difficulty": "medium",
            "language": "ru",
            "story_prompt": "A missing witness vanished near the harbor.",
        },
        "world_bootstrap": {
            "starting_location": "Начальная точка",
            "starting_objective": "Найти свидетеля",
        },
        "character_brief": {
            "character": {"name": "Iris"},
            "character_prompt": "A stubborn detective.",
        },
        "dynamic_context": {
            "turn_number": turn_number,
            "state": {
                "location": "Начальная точка" if turn_number == 0 else "Туманный причал",
                "objective": "Найти свидетеля",
                "choices": [],
            },
            "memory": {
                "recent_turns": [],
            },
        },
    }


def test_turn_prefix_messages_stay_stable_when_only_dynamic_tail_changes():
    first_context = _context(turn_number=0)
    second_context = _context(turn_number=1)
    system_prompt = build_turn_system_prompt(
        language="ru",
        mode="longCampaign",
        turn_number=0,
        trigger_source="intro",
    )

    first_prefix = build_turn_prefix_messages(
        system_prompt=system_prompt,
        context=first_context,
    )
    second_prefix = build_turn_prefix_messages(
        system_prompt=system_prompt,
        context=second_context,
    )

    assert first_prefix == second_prefix
    assert build_turn_dynamic_payload(
        context=first_context,
        player_action="",
        trigger_source="intro",
    ) != build_turn_dynamic_payload(
        context=second_context,
        player_action="Inspect the pier",
        trigger_source="manual",
    )


def test_usage_parser_extracts_cache_tokens():
    usage = _parse_usage(
        {
            "prompt_cache_hit_tokens": 128,
            "prompt_cache_miss_tokens": 64,
            "prompt_tokens": 192,
            "completion_tokens": 33,
            "total_tokens": 225,
        }
    )

    assert usage.prompt_cache_hit_tokens == 128
    assert usage.prompt_cache_miss_tokens == 64
    assert usage.prompt_tokens == 192
    assert usage.total_tokens == 225


def test_turn_budget_profiles_are_mode_aware():
    short_intro_budget = build_turn_budget(
        mode="shortStory",
        turn_number=0,
        trigger_source="intro",
    )
    short_budget = build_turn_budget(
        mode="shortStory",
        turn_number=1,
        trigger_source="manual",
    )
    long_intro_budget = build_turn_budget(
        mode="longCampaign",
        turn_number=0,
        trigger_source="intro",
    )

    assert short_intro_budget.scenario == "turn_intro_short"
    assert short_budget.scenario == "turn_standard_short"
    assert long_intro_budget.scenario == "turn_intro_long"
    assert short_intro_budget.max_output_tokens == 420
    assert short_budget.max_output_tokens == 280
    assert long_intro_budget.max_output_tokens == 900


def test_prompt_generation_budget_profiles_match_story_modes():
    short_budget = build_prompt_generation_budget(mode="shortStory")
    long_budget = build_prompt_generation_budget(mode="longCampaign")

    assert short_budget.scenario == "prompt_generation_short"
    assert short_budget.max_output_tokens == 320
    assert long_budget.scenario == "prompt_generation_long"
    assert long_budget.max_output_tokens == 520
    assert long_budget.max_output_tokens > short_budget.max_output_tokens


@pytest.mark.asyncio
async def test_generate_json_retries_when_provider_reports_length_truncation():
    service = AiGatewayService()
    observed_max_tokens: list[int | None] = []
    responses = iter(
        [
            (
                {
                    "choices": [
                        {
                            "message": {
                                "content": '{"narration":"short","choices":["Wait"],"state_changes":{},"memory_entry":"short","importance":3}'
                            },
                            "finish_reason": "length",
                        }
                    ],
                    "usage": {"completion_tokens": 280, "total_tokens": 400},
                },
                LlmUsage(completion_tokens=280, total_tokens=400),
                "length",
            ),
            (
                {
                    "choices": [
                        {
                            "message": {
                                "content": '{"narration":"full","choices":["Go"],"state_changes":{},"memory_entry":"full","importance":4}'
                            },
                            "finish_reason": "stop",
                        }
                    ],
                    "usage": {"completion_tokens": 310, "total_tokens": 470},
                },
                LlmUsage(completion_tokens=310, total_tokens=470),
                "stop",
            ),
        ]
    )

    async def _fake_post_json_completion(*, payload, **_kwargs):
        observed_max_tokens.append(payload.get("max_tokens"))
        return next(responses)

    service._post_json_completion = _fake_post_json_completion  # type: ignore[method-assign]

    result = await service.generate_json(
        credentials=type(
            "_Creds",
            (),
            {
                "model": "test-model",
                "base_url": "https://example.invalid/v1",
                "api_key": "secret",
                "timeout_seconds": 60,
                "safe_summary": "test-creds",
            },
        )(),
        system_prompt="Return JSON",
        user_payload={"hello": "world"},
        max_output_tokens=280,
        scenario="turn_standard_short",
    )

    assert result.payload["narration"] == "full"
    assert observed_max_tokens == [280, 440]
    assert result.meta["finish_reason"] == "stop"
    assert result.meta["completion_truncated"] is False


def test_build_messages_preserves_stable_prefix_and_dynamic_tail():
    context = _context(turn_number=2)
    prefix_messages = build_turn_prefix_messages(
        system_prompt=build_turn_system_prompt(
            language="ru",
            mode="longCampaign",
            turn_number=2,
            trigger_source="manual",
        ),
        context=context,
    )
    dynamic_payload = build_turn_dynamic_payload(
        context=context,
        player_action="  Inspect   the   pier  ",
        trigger_source="manual",
    )

    messages = build_messages(
        prefix_messages=prefix_messages,
        dynamic_payload=dynamic_payload,
    )

    assert messages[:2] == prefix_messages
    assert messages[-1]["content"].count("Inspect the pier") == 1
