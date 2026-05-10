from datetime import datetime
from typing import Any

from pydantic import AliasChoices, BaseModel, ConfigDict, Field, model_validator

from app.schemas.campaigns import CharacterProfileInput


class StoryTemplateUpsertRequest(BaseModel):
    title: str = ""
    summary: str = ""
    prompt_text: str = ""
    setting: str = ""
    literary_genre_slug: str | None = None
    literary_genre: str | None = Field(
        default=None,
        validation_alias=AliasChoices("literary_genre", "literaryGenre"),
    )
    mode: str | None = None
    difficulty: str | None = None
    story_prompt: str | None = Field(
        default=None,
        validation_alias=AliasChoices("story_prompt", "storyPrompt"),
    )
    character_prompt: str | None = Field(
        default=None,
        validation_alias=AliasChoices("character_prompt", "characterPrompt"),
    )
    campaign_title: str | None = Field(
        default=None,
        validation_alias=AliasChoices("campaign_title", "campaignTitle"),
    )
    objective_hint: str | None = Field(
        default=None,
        validation_alias=AliasChoices("objective_hint", "objectiveHint"),
    )
    character: CharacterProfileInput | None = None
    tags: list[str] = Field(default_factory=list)
    is_public: bool = False
    is_master_curated: bool | None = None
    metadata: dict = Field(default_factory=dict)

    @model_validator(mode="before")
    @classmethod
    def _accept_campaign_json_shape(cls, value: Any) -> Any:
        if not isinstance(value, dict):
            return value
        data = dict(value)
        prompt = (
            data.get("prompt_text")
            or data.get("promptText")
            or data.get("story_prompt")
            or data.get("storyPrompt")
            or ""
        )
        if not str(data.get("prompt_text") or "").strip() and str(prompt).strip():
            data["prompt_text"] = str(prompt).strip()
        if not str(data.get("title") or "").strip():
            title_source = (
                data.get("campaign_title")
                or data.get("campaignTitle")
                or data.get("summary")
                or prompt
                or "Story template"
            )
            data["title"] = " ".join(str(title_source).split()[:4]) or "Story template"
        return data


class BulkDeleteRequest(BaseModel):
    ids: list[str]


class BulkDeleteResponse(BaseModel):
    deleted: list[str]
    failed: dict[str, str]


class StoryTemplateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    summary: str
    prompt_text: str
    setting: str
    literary_genre_slug: str | None = None
    literary_genre: str | None = None
    mode: str | None = None
    difficulty: str | None = None
    story_prompt: str | None = None
    character_prompt: str | None = None
    campaign_title: str | None = None
    objective_hint: str | None = None
    character: dict | None = None
    cover_image_href: str | None = None
    is_public: bool
    is_master_curated: bool
    metadata: dict
    author_display_name: str | None
    tags: list[str]
    likes: int
    views: int
    bookmarked: bool
    created_at: datetime
    updated_at: datetime
