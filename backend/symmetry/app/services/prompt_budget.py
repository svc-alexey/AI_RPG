from dataclasses import asdict, dataclass


@dataclass(frozen=True, slots=True)
class PromptBudgetProfile:
    scenario: str
    max_output_tokens: int
    max_story_prompt_chars: int
    max_character_prompt_chars: int
    max_recent_turns: int
    max_recent_turn_chars: int
    max_memory_chars: int
    max_chronicles: int
    max_chronicle_chars: int
    max_total_chronicle_chars: int

    def to_dict(self) -> dict[str, int | str]:
        return asdict(self)


def build_prompt_generation_budget(*, mode: str) -> PromptBudgetProfile:
    if mode == "longCampaign":
        return PromptBudgetProfile(
            scenario="prompt_generation_long",
            max_output_tokens=360,
            max_story_prompt_chars=0,
            max_character_prompt_chars=0,
            max_recent_turns=0,
            max_recent_turn_chars=0,
            max_memory_chars=0,
            max_chronicles=0,
            max_chronicle_chars=0,
            max_total_chronicle_chars=0,
        )
    return PromptBudgetProfile(
        scenario="prompt_generation_short",
        max_output_tokens=240,
        max_story_prompt_chars=0,
        max_character_prompt_chars=0,
        max_recent_turns=0,
        max_recent_turn_chars=0,
        max_memory_chars=0,
        max_chronicles=0,
        max_chronicle_chars=0,
        max_total_chronicle_chars=0,
    )


def build_turn_budget(
    *,
    mode: str,
    turn_number: int,
    trigger_source: str,
) -> PromptBudgetProfile:
    normalized_trigger = (trigger_source or "").strip().lower()
    is_intro = turn_number == 0 and normalized_trigger == "intro"
    is_suggestions = normalized_trigger == "suggestions"

    if is_suggestions:
        return PromptBudgetProfile(
            scenario="turn_suggestions",
            max_output_tokens=120,
            max_story_prompt_chars=220,
            max_character_prompt_chars=140,
            max_recent_turns=1,
            max_recent_turn_chars=100,
            max_memory_chars=120,
            max_chronicles=1,
            max_chronicle_chars=120,
            max_total_chronicle_chars=120,
        )

    if mode == "longCampaign" and is_intro:
        return PromptBudgetProfile(
            scenario="turn_intro_long",
            max_output_tokens=420,
            max_story_prompt_chars=520,
            max_character_prompt_chars=220,
            max_recent_turns=2,
            max_recent_turn_chars=140,
            max_memory_chars=220,
            max_chronicles=3,
            max_chronicle_chars=180,
            max_total_chronicle_chars=420,
        )

    if mode == "longCampaign":
        return PromptBudgetProfile(
            scenario="turn_standard_long",
            max_output_tokens=320,
            max_story_prompt_chars=420,
            max_character_prompt_chars=180,
            max_recent_turns=3,
            max_recent_turn_chars=120,
            max_memory_chars=180,
            max_chronicles=3,
            max_chronicle_chars=150,
            max_total_chronicle_chars=360,
        )

    if is_intro:
        return PromptBudgetProfile(
            scenario="turn_intro_short",
            max_output_tokens=220,
            max_story_prompt_chars=300,
            max_character_prompt_chars=150,
            max_recent_turns=1,
            max_recent_turn_chars=100,
            max_memory_chars=120,
            max_chronicles=2,
            max_chronicle_chars=120,
            max_total_chronicle_chars=200,
        )

    return PromptBudgetProfile(
        scenario="turn_standard_short",
        max_output_tokens=180,
        max_story_prompt_chars=260,
        max_character_prompt_chars=140,
        max_recent_turns=2,
        max_recent_turn_chars=96,
        max_memory_chars=120,
        max_chronicles=2,
        max_chronicle_chars=110,
        max_total_chronicle_chars=180,
    )
