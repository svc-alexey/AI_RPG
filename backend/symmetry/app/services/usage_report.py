from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Any

from sqlalchemy import Select, desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.models import CampaignTurn


@dataclass(slots=True)
class UsageBucket:
    key: str
    requests: int = 0
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0
    cache_hit_tokens: int = 0
    cache_miss_tokens: int = 0
    cache_hit_ratio_sum: float = 0.0

    def to_dict(self) -> dict[str, Any]:
        requests = max(1, self.requests)
        return {
            "key": self.key,
            "requests": self.requests,
            "prompt_tokens": self.prompt_tokens,
            "completion_tokens": self.completion_tokens,
            "total_tokens": self.total_tokens,
            "cache_hit_tokens": self.cache_hit_tokens,
            "cache_miss_tokens": self.cache_miss_tokens,
            "avg_total_tokens": round(self.total_tokens / requests, 2),
            "avg_prompt_tokens": round(self.prompt_tokens / requests, 2),
            "avg_completion_tokens": round(self.completion_tokens / requests, 2),
            "avg_cache_hit_ratio": round(self.cache_hit_ratio_sum / requests, 4),
        }


class UsageReportService:
    def __init__(self) -> None:
        self._settings = get_settings()

    async def build_report(
        self,
        session: AsyncSession,
        *,
        days: int | None = None,
        campaign_id: str | None = None,
        limit: int | None = None,
    ) -> dict[str, Any]:
        resolved_days = max(1, days or self._settings.dev_usage_default_days)
        resolved_limit = max(
            1,
            min(limit or self._settings.dev_usage_max_rows, self._settings.dev_usage_max_rows),
        )
        since = datetime.now(UTC) - timedelta(days=resolved_days)

        stmt: Select[tuple[CampaignTurn]] = (
            select(CampaignTurn)
            .where(CampaignTurn.created_at >= since)
            .order_by(desc(CampaignTurn.created_at))
            .limit(resolved_limit)
        )
        if campaign_id:
            stmt = stmt.where(CampaignTurn.campaign_id == campaign_id)

        result = await session.execute(stmt)
        rows = list(result.scalars().all())

        summary = UsageBucket(key="summary")
        by_scenario: dict[str, UsageBucket] = defaultdict(lambda: UsageBucket(key="unknown"))
        by_mode: dict[str, UsageBucket] = defaultdict(lambda: UsageBucket(key="unknown"))

        for row in rows:
            usage = row.llm_usage_json if isinstance(row.llm_usage_json, dict) else {}
            scenario = _usage_text(usage.get("budget_scenario") or usage.get("scenario")) or "unknown"
            mode = _usage_text(usage.get("mode")) or "unknown"
            usage_entry = _usage_numbers(usage)

            _apply_usage(summary, usage_entry)
            if scenario not in by_scenario:
                by_scenario[scenario] = UsageBucket(key=scenario)
            if mode not in by_mode:
                by_mode[mode] = UsageBucket(key=mode)
            _apply_usage(by_scenario[scenario], usage_entry)
            _apply_usage(by_mode[mode], usage_entry)

        return {
            "generated_at": datetime.now(UTC),
            "days": resolved_days,
            "rows_scanned": len(rows),
            "filters": {
                "days": resolved_days,
                "limit": resolved_limit,
                "campaign_id": campaign_id or "",
            },
            "summary": summary.to_dict(),
            "by_scenario": _sorted_bucket_dicts(by_scenario),
            "by_mode": _sorted_bucket_dicts(by_mode),
        }


def _usage_numbers(usage: dict[str, Any]) -> dict[str, int | float]:
    prompt_tokens = int(usage.get("prompt_tokens", 0) or 0)
    completion_tokens = int(usage.get("completion_tokens", 0) or 0)
    total_tokens = int(usage.get("total_tokens", 0) or 0)
    cache_hit_tokens = int(usage.get("prompt_cache_hit_tokens", 0) or 0)
    cache_miss_tokens = int(usage.get("prompt_cache_miss_tokens", 0) or 0)
    cache_hit_ratio = usage.get("prompt_cache_hit_ratio")
    if cache_hit_ratio is None:
        cache_hit_ratio = (cache_hit_tokens / prompt_tokens) if prompt_tokens > 0 else 0.0
    return {
        "prompt_tokens": prompt_tokens,
        "completion_tokens": completion_tokens,
        "total_tokens": total_tokens,
        "cache_hit_tokens": cache_hit_tokens,
        "cache_miss_tokens": cache_miss_tokens,
        "cache_hit_ratio": float(cache_hit_ratio or 0.0),
    }


def _apply_usage(bucket: UsageBucket, usage: dict[str, int | float]) -> None:
    bucket.requests += 1
    bucket.prompt_tokens += int(usage["prompt_tokens"])
    bucket.completion_tokens += int(usage["completion_tokens"])
    bucket.total_tokens += int(usage["total_tokens"])
    bucket.cache_hit_tokens += int(usage["cache_hit_tokens"])
    bucket.cache_miss_tokens += int(usage["cache_miss_tokens"])
    bucket.cache_hit_ratio_sum += float(usage["cache_hit_ratio"])


def _sorted_bucket_dicts(buckets: dict[str, UsageBucket]) -> list[dict[str, Any]]:
    return [
        item.to_dict()
        for item in sorted(
            buckets.values(),
            key=lambda bucket: (-bucket.requests, bucket.key),
        )
    ]


def _usage_text(value: Any) -> str:
    return str(value or "").strip()
