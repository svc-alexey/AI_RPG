from pydantic import AliasChoices, BaseModel, Field, field_validator

from app.schemas.campaigns import ProviderCredentialsInput
from app.services.text_normalization import normalize_prompt_text


class GeneratePromptsRequest(BaseModel):
    setting: str
    literary_genre: str = Field(
        validation_alias=AliasChoices("literary_genre", "literaryGenre"),
    )
    mode: str
    difficulty: str
    language: str = "ru"
    story_wish: str = Field(
        default="",
        validation_alias=AliasChoices("story_wish", "storyWish"),
    )
    provider_credentials: ProviderCredentialsInput | None = Field(
        default=None,
        validation_alias=AliasChoices("provider_credentials", "providerCredentials"),
    )

    @field_validator(
        "setting",
        "literary_genre",
        "mode",
        "difficulty",
        "language",
        "story_wish",
        mode="before",
    )
    @classmethod
    def _normalize_prompt_request_text(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))


class GeneratePromptsResponse(BaseModel):
    story_prompt: str
    character_prompt: str
    campaign_title: str = ""
    objective_hint: str = ""
