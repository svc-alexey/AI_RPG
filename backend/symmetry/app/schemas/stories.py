from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class StoryTemplateUpsertRequest(BaseModel):
    title: str
    summary: str = ""
    prompt_text: str
    setting: str = ""
    tags: list[str] = Field(default_factory=list)
    is_public: bool = False
    metadata: dict = Field(default_factory=dict)


class StoryTemplateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    summary: str
    prompt_text: str
    setting: str
    is_public: bool
    tags: list[str]
    likes: int
    views: int
    bookmarked: bool
    created_at: datetime
    updated_at: datetime
