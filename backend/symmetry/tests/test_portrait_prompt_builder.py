from app.services.portrait_prompt_builder import build_portrait_prompt


def test_includes_story_and_character_details():
    """Cross-validated against Dart CharacterPortraitPromptBuilder test."""
    prompt = build_portrait_prompt(
        character_name="Iris",
        character_race="human",
        character_class="detective",
        character_gender="female",
        character_personality="calm, observant, relentless",
        character_prompt_fragment="long dark coat, sharp gaze",
        story_context="A stormbound city mystery with occult undertones.",
        setting="cozyCrime",
    )

    assert "stormbound city mystery" in prompt
    assert "Iris" in prompt
    assert "detective" in prompt
    assert "long dark coat" in prompt
    assert "observant" in prompt


def test_output_matches_dart_builder_format():
    """Full output matches the exact format expected by Dart builder."""
    prompt = build_portrait_prompt(
        character_name="Iris",
        character_race="human",
        character_class="detective",
        character_gender="female",
        character_personality="calm, observant, relentless",
        character_prompt_fragment="long dark coat, sharp gaze",
        story_context="A stormbound city mystery with occult undertones.",
        setting="cozyCrime",
    )

    expected = (
        "Iris, a female human detective, "
        "cinematic character portrait, "
        "detective noir atmosphere, "
        "head and shoulders composition, "
        "high detail digital illustration, "
        "personality: calm, observant, relentless, "
        "character details: long dark coat, sharp gaze, "
        "story context: A stormbound city mystery with occult undertones., "
        "expressive lighting, no text, no watermark"
    )
    assert prompt == expected


def test_setting_fantasy_default():
    prompt = build_portrait_prompt(
        character_name="Thorn",
        character_race="elf",
        character_class="mage",
        character_gender="male",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="romantasy",
    )

    assert "fantasy atmosphere" in prompt
    assert "Thorn, a male elf mage" in prompt


def test_setting_scifi():
    prompt = build_portrait_prompt(
        character_name="Nova",
        character_race="cyborg",
        character_class="engineer",
        character_gender="female",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="nearFutureSciFi",
    )

    assert "science fiction atmosphere" in prompt


def test_setting_post_apocalypse():
    prompt = build_portrait_prompt(
        character_name="Ash",
        character_race="mutant",
        character_class="medic",
        character_gender="other",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="postApocalypse",
    )

    assert "science fiction atmosphere" in prompt


def test_unspecified_class_omitted():
    prompt = build_portrait_prompt(
        character_name="Hero",
        character_race="human",
        character_class="unspecified",
        character_gender="other",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="romantasy",
    )

    assert "human," in prompt  # no class appended
    assert "unspecified" not in prompt


def test_empty_fields_produce_clean_prompt():
    prompt = build_portrait_prompt(
        character_name="Hero",
        character_race="human",
        character_class="warrior",
        character_gender="male",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="romantasy",
    )

    assert "personality:" not in prompt
    assert "character details:" not in prompt
    assert "story context:" not in prompt
    assert prompt.endswith(", expressive lighting, no text, no watermark")


def test_always_english_output():
    """Prompts are always in English regardless of input language context."""
    prompt = build_portrait_prompt(
        character_name="Герой",
        character_race="человек",
        character_class="warrior",
        character_gender="male",
        character_personality="смелый и отважный",
        character_prompt_fragment="красный плащ",
        story_context="Мрачный лес полный опасностей",
        setting="romantasy",
    )

    # The output still contains English structural parts
    assert "cinematic character portrait" in prompt
    assert "personality:" in prompt
    assert "character details:" in prompt
    assert "story context:" in prompt
    assert "expressive lighting, no text, no watermark" in prompt
