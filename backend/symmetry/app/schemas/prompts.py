from pydantic import AliasChoices, BaseModel, Field

from app.schemas.campaigns import ProviderCredentialsInput


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


class GeneratePromptsResponse(BaseModel):
    story_prompt: str
    character_prompt: str
    campaign_title: str = ""
    objective_hint: str = ""
