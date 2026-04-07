from datetime import datetime
from typing import Any

from pydantic import AliasChoices, BaseModel, ConfigDict, Field


class ProviderCredentialsInput(BaseModel):
    base_url: str = Field(
        default="",
        validation_alias=AliasChoices("base_url", "baseUrl"),
    )
    model: str = ""
    api_key: str = Field(
        default="",
        validation_alias=AliasChoices("api_key", "apiKey"),
    )


class CharacterProfileInput(BaseModel):
    name: str = "Stranger"
    gender: str = "other"
    race: str = ""
    character_class: str = Field(
        default="unspecified",
        validation_alias=AliasChoices("character_class", "characterClass"),
    )
    personality: str = ""
    prompt_fragment: str = Field(
        default="",
        validation_alias=AliasChoices("prompt_fragment", "promptFragment"),
    )
    skills: list[str] = Field(default_factory=list)
    perks: list[str] = Field(default_factory=list)


class CreateCampaignRequest(BaseModel):
    title: str
    setting: str
    mode: str
    difficulty: str
    language: str = "ru"
    story_prompt: str = Field(
        default="",
        validation_alias=AliasChoices("story_prompt", "storyPrompt"),
    )
    objective_hint: str = Field(
        default="",
        validation_alias=AliasChoices("objective_hint", "objectiveHint"),
    )
    character: CharacterProfileInput = Field(default_factory=CharacterProfileInput)
    provider_credentials: ProviderCredentialsInput | None = Field(
        default=None,
        validation_alias=AliasChoices("provider_credentials", "providerCredentials"),
    )


class ProcessTurnRequest(BaseModel):
    player_action: str = Field(
        validation_alias=AliasChoices("player_action", "playerAction"),
    )
    language: str = "ru"
    trigger_source: str = Field(
        default="manual",
        validation_alias=AliasChoices("trigger_source", "triggerSource"),
    )
    provider_credentials: ProviderCredentialsInput | None = Field(
        default=None,
        validation_alias=AliasChoices("provider_credentials", "providerCredentials"),
    )


class CampaignResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    setting: str
    mode: str
    difficulty: str
    language: str
    status: str
    created_at: datetime
    updated_at: datetime


class CampaignStateResponse(BaseModel):
    campaign: CampaignResponse
    snapshot_version: int
    state: dict[str, Any]


class WorldRumorResponse(BaseModel):
    id: str
    entity_type: str
    event_text: str
    importance: int
    location_slug: str = ""
    created_at: datetime


class ProcessTurnResponse(BaseModel):
    narration: str
    choices: list[str]
    state_changes: dict[str, Any]
    memory_entry: str
    request_id: str
    campaign_snapshot_version: int
    state: dict[str, Any]
