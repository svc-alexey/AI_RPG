import asyncio
from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from app.api.deps import require_dev_admin_token
from app.services.usage_report import UsageReportService


class _ScalarResult:
    def __init__(self, rows):
        self._rows = rows

    def all(self):
        return self._rows


class _ExecuteResult:
    def __init__(self, rows):
        self._rows = rows

    def scalars(self):
        return _ScalarResult(self._rows)


class _Session:
    def __init__(self, rows):
        self._rows = rows

    async def execute(self, _):
        return _ExecuteResult(self._rows)


def test_require_dev_admin_token_rejects_when_disabled(monkeypatch):
    monkeypatch.setenv("SYMMETRY_DEV_ADMIN_TOKEN", "")
    from app.core.config import get_settings

    get_settings.cache_clear()
    with pytest.raises(HTTPException) as exc:
        require_dev_admin_token(None)
    assert exc.value.status_code == 404


def test_require_dev_admin_token_rejects_invalid_token(monkeypatch):
    monkeypatch.setenv("SYMMETRY_DEV_ADMIN_TOKEN", "secret-token")
    from app.core.config import get_settings

    get_settings.cache_clear()
    with pytest.raises(HTTPException) as exc:
        require_dev_admin_token("wrong-token")
    assert exc.value.status_code == 403


def test_usage_report_service_aggregates_rows(monkeypatch):
    monkeypatch.setenv("SYMMETRY_DEV_USAGE_DEFAULT_DAYS", "7")
    monkeypatch.setenv("SYMMETRY_DEV_USAGE_MAX_ROWS", "100")
    from app.core.config import get_settings

    get_settings.cache_clear()
    service = UsageReportService()
    rows = [
        SimpleNamespace(
            llm_usage_json={
                "prompt_tokens": 100,
                "completion_tokens": 40,
                "total_tokens": 140,
                "prompt_cache_hit_tokens": 60,
                "prompt_cache_miss_tokens": 40,
                "mode": "longCampaign",
                "budget_scenario": "turn_intro_long",
                "prompt_cache_hit_ratio": 0.6,
            }
        ),
        SimpleNamespace(
            llm_usage_json={
                "prompt_tokens": 80,
                "completion_tokens": 20,
                "total_tokens": 100,
                "prompt_cache_hit_tokens": 20,
                "prompt_cache_miss_tokens": 60,
                "mode": "longCampaign",
                "budget_scenario": "turn_standard_long",
                "prompt_cache_hit_ratio": 0.25,
            }
        ),
    ]

    report = asyncio.run(service.build_report(_Session(rows), days=7, limit=50))

    assert report["rows_scanned"] == 2
    assert report["summary"]["total_tokens"] == 240
    assert report["summary"]["prompt_tokens"] == 180
    assert report["summary"]["avg_cache_hit_ratio"] == 0.425
    assert report["by_mode"][0]["key"] == "longCampaign"
    assert report["by_mode"][0]["requests"] == 2
    assert {item["key"] for item in report["by_scenario"]} == {
        "turn_intro_long",
        "turn_standard_long",
    }
