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
