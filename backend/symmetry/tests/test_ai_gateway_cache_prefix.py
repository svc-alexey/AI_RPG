from app.services.ai_gateway import (
    _parse_usage,
    build_turn_dynamic_payload,
    build_turn_prefix_messages,
    build_messages,
    build_turn_system_prompt,
)
from app.services.prompt_budget import build_turn_budget


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

    assert short_budget.scenario == "turn_standard_short"
    assert long_intro_budget.scenario == "turn_intro_long"
    assert long_intro_budget.max_output_tokens > short_budget.max_output_tokens


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
