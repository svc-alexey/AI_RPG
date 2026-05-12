from pydantic import AliasChoices, BaseModel, Field, field_validator

from app.services.text_normalization import normalize_prompt_text


class GeneratePortraitRequest(BaseModel):
    character_name: str = Field(
        validation_alias=AliasChoices("character_name", "characterName"),
    )
    race: str = Field(
        validation_alias=AliasChoices("race", "character_race"),
    )
    character_class: str = Field(
        validation_alias=AliasChoices("character_class", "class", "characterClass"),
    )
    gender: str = Field(
        validation_alias=AliasChoices("gender", "character_gender"),
    )
    personality: str = Field(
        default="",
        validation_alias=AliasChoices("personality", "character_personality"),
    )
    prompt_fragment: str = Field(
        default="",
        validation_alias=AliasChoices("prompt_fragment", "promptFragment"),
    )
    story_context: str = Field(
        default="",
        validation_alias=AliasChoices("story_context", "storyContext"),
    )
    setting: str = Field(
        default="romantasy",
        validation_alias=AliasChoices("setting", "campaign_setting"),
    )

    @field_validator(
        "character_name",
        "race",
        "character_class",
        "gender",
        "personality",
        "prompt_fragment",
        "story_context",
        "setting",
        mode="before",
    )
    @classmethod
    def _normalize_text(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))


class PortraitResponseBody(BaseModel):
    portrait_id: str = Field(
        validation_alias=AliasChoices("portrait_id", "portraitId"),
    )
    portrait_url: str = Field(
        validation_alias=AliasChoices("portrait_url", "portraitUrl"),
    )
