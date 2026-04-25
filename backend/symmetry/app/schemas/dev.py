from typing import Any

from datetime import datetime

from pydantic import BaseModel, Field


class UsageBucketResponse(BaseModel):
    key: str
    requests: int
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    cache_hit_tokens: int
    cache_miss_tokens: int
    avg_total_tokens: float
    avg_prompt_tokens: float
    avg_completion_tokens: float
    avg_cache_hit_ratio: float


class UsageSummaryResponse(BaseModel):
    requests: int
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    cache_hit_tokens: int
    cache_miss_tokens: int
    avg_prompt_tokens: float
    avg_completion_tokens: float
    avg_total_tokens: float
    avg_cache_hit_ratio: float


class UsageReportResponse(BaseModel):
    generated_at: datetime
    days: int
    rows_scanned: int
    filters: dict[str, str | int] = Field(default_factory=dict)
    summary: UsageSummaryResponse
    by_scenario: list[UsageBucketResponse] = Field(default_factory=list)
    by_mode: list[UsageBucketResponse] = Field(default_factory=list)


class TurnDebugResponse(BaseModel):
    campaign_id: str
    turn_number: int
    created_at: datetime
    request_id: str = ""
    client_turn_id: str = ""
    budget_scenario: str = ""
    prompt_characters: int = 0
    prompt_tokens: int = 0
    completion_tokens: int = 0
    scene_state: dict[str, Any] = Field(default_factory=dict)
    context: dict[str, Any] = Field(default_factory=dict)
    rag: dict[str, Any] = Field(default_factory=dict)
    llm_response_excerpt: dict[str, Any] = Field(default_factory=dict)
