from app.schemas.campaigns import CreateCampaignRequest, ProcessTurnRequest
from app.schemas.prompts import GeneratePromptsRequest


def test_generate_prompts_request_accepts_camel_case_fields():
    payload = GeneratePromptsRequest.model_validate(
        {
            "setting": "romantasy",
            "literaryGenre": "romance",
            "mode": "shortStory",
            "difficulty": "easy",
            "language": "ru",
            "storyWish": "Quiet magic by the sea",
            "providerCredentials": {
                "baseUrl": "https://example.invalid/v1",
                "model": "gpt-test",
                "apiKey": "secret",
            },
        }
    )

    assert payload.literary_genre == "romance"
    assert payload.story_wish == "Quiet magic by the sea"
    assert payload.provider_credentials is not None
    assert payload.provider_credentials.base_url == "https://example.invalid/v1"
    assert payload.provider_credentials.api_key == "secret"


def test_generate_prompts_request_accepts_nested_character_camel_case():
    payload = GeneratePromptsRequest.model_validate(
        {
            "setting": "romantasy",
            "literaryGenre": "fantasyGenre",
            "mode": "shortStory",
            "difficulty": "easy",
            "language": "ru",
            "storyWish": "A quiet harbor",
            "character": {
                "name": "Mira",
                "gender": "female",
                "race": "elf",
                "characterClass": "ranger",
                "promptFragment": "Watchful",
                "personality": "calm",
                "skills": ["tracking"],
                "perks": ["keen"],
            },
        }
    )

    assert payload.character is not None
    assert payload.character.name == "Mira"
    assert payload.character.character_class == "ranger"
    assert payload.character.prompt_fragment == "Watchful"


def test_create_campaign_request_accepts_camel_case_fields():
    payload = CreateCampaignRequest.model_validate(
        {
            "title": "Harbor Lights",
            "setting": "romantasy",
            "mode": "longCampaign",
            "difficulty": "easy",
            "language": "ru",
            "storyPrompt": "A hidden market stirs beneath the city.",
            "objectiveHint": "Find the missing courier",
            "character": {
                "name": "Lena",
                "gender": "female",
                "race": "human",
                "characterClass": "rogue",
                "promptFragment": "Observant and quick-witted",
                "skills": ["stealth"],
                "perks": ["keen_eyes"],
            },
            "providerCredentials": {
                "baseUrl": "https://example.invalid/v1",
                "model": "gpt-test",
                "apiKey": "secret",
            },
        }
    )

    assert payload.story_prompt == "A hidden market stirs beneath the city."
    assert payload.objective_hint == "Find the missing courier"
    assert payload.character.character_class == "rogue"
    assert payload.character.prompt_fragment == "Observant and quick-witted"
    assert payload.provider_credentials is not None
    assert payload.provider_credentials.base_url == "https://example.invalid/v1"


def test_process_turn_request_accepts_camel_case_fields():
    payload = ProcessTurnRequest.model_validate(
        {
            "playerAction": "Inspect the lantern shop after sunset.",
            "language": "ru",
            "triggerSource": "manual",
            "clientTurnId": "campaign-1:2:123456",
            "providerCredentials": {
                "baseUrl": "https://example.invalid/v1",
                "model": "gpt-test",
                "apiKey": "secret",
            },
        }
    )

    assert payload.player_action == "Inspect the lantern shop after sunset."
    assert payload.trigger_source == "manual"
    assert payload.client_turn_id == "campaign-1:2:123456"
    assert payload.provider_credentials is not None
    assert payload.provider_credentials.api_key == "secret"
