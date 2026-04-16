from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class StoryTemplateUpsertRequest(BaseModel):
    title: str
    summary: str = ""
    prompt_text: str
    setting: str = ""
    literary_genre_slug: str | None = None
    tags: list[str] = Field(default_factory=list)
    is_public: bool = False
    is_master_curated: bool | None = None
    metadata: dict = Field(default_factory=dict)


class StoryTemplateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    summary: str
    prompt_text: str
    setting: str
    literary_genre_slug: str | None = None
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
