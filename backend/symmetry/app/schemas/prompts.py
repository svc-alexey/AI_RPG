from pydantic import BaseModel

from app.schemas.campaigns import ProviderCredentialsInput


class GeneratePromptsRequest(BaseModel):
    setting: str
    literary_genre: str
    difficulty: str
    language: str = "ru"
    story_wish: str = ""
    provider_credentials: ProviderCredentialsInput | None = None


class GeneratePromptsResponse(BaseModel):
    story_prompt: str
    character_prompt: str
    campaign_title: str = ""
    objective_hint: str = ""
