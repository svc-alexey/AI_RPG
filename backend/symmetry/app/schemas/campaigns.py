from datetime import datetime
from typing import Any

from pydantic import AliasChoices, BaseModel, ConfigDict, Field, field_validator

from app.services.text_normalization import normalize_compact_list, normalize_prompt_text


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

    @field_validator("base_url", "model", "api_key", mode="before")
    @classmethod
    def _normalize_provider_text(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))


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

    @field_validator(
        "name",
        "gender",
        "race",
        "character_class",
        "personality",
        "prompt_fragment",
        mode="before",
    )
    @classmethod
    def _normalize_text_fields(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))

    @field_validator("skills", "perks", mode="before")
    @classmethod
    def _normalize_list_fields(cls, value: object) -> list[str]:
        if isinstance(value, list):
            items = value
        elif value is None:
            items = []
        else:
            items = [value]
        return normalize_compact_list(items)


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

    @field_validator(
        "title",
        "setting",
        "mode",
        "difficulty",
        "language",
        "story_prompt",
        "objective_hint",
        mode="before",
    )
    @classmethod
    def _normalize_campaign_text(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))


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

    @field_validator("player_action", "language", "trigger_source", mode="before")
    @classmethod
    def _normalize_turn_text(cls, value: object) -> str:
        return normalize_prompt_text(str(value or ""))


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
    location_title: str | None = None
    created_at: datetime


class ProcessTurnResponse(BaseModel):
    narration: str
    choices: list[str]
    state_changes: dict[str, Any]
    memory_entry: str
    request_id: str
    campaign_snapshot_version: int
    state: dict[str, Any]
