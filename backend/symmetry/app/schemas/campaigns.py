from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class ProviderCredentialsInput(BaseModel):
    base_url: str = ""
    model: str = ""
    api_key: str = ""


class CharacterProfileInput(BaseModel):
    name: str = "Stranger"
    gender: str = "other"
    race: str = ""
    character_class: str = "unspecified"
    personality: str = ""
    prompt_fragment: str = ""
    skills: list[str] = Field(default_factory=list)
    perks: list[str] = Field(default_factory=list)


class CreateCampaignRequest(BaseModel):
    title: str
    setting: str
    mode: str
    difficulty: str
    language: str = "ru"
    story_prompt: str = ""
    objective_hint: str = ""
    character: CharacterProfileInput = Field(default_factory=CharacterProfileInput)
    provider_credentials: ProviderCredentialsInput | None = None


class ProcessTurnRequest(BaseModel):
    player_action: str
    language: str = "ru"
    trigger_source: str = "manual"
    provider_credentials: ProviderCredentialsInput | None = None


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


class ProcessTurnResponse(BaseModel):
    narration: str
    choices: list[str]
    state_changes: dict[str, Any]
    memory_entry: str
    request_id: str
    campaign_snapshot_version: int
    state: dict[str, Any]
