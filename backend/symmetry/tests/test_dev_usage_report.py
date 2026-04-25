import asyncio
from datetime import UTC, datetime
from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from app.api.deps import require_dev_admin_token
from app.api.routes.dev import get_turn_debug
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


class _ScalarSession:
    def __init__(self, turn):
        self._turn = turn

    async def scalar(self, _):
        return self._turn


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


def test_get_turn_debug_returns_payload_excerpt():
    turn = SimpleNamespace(
        campaign_id="campaign-1",
        turn_number=14,
        created_at=datetime.now(UTC),
        llm_usage_json={
            "request_id": "req-14",
            "client_turn_id": "campaign-1:14:999",
            "budget_scenario": "turn_standard_long",
            "prompt_characters": 1200,
            "prompt_tokens": 420,
            "completion_tokens": 170,
            "turn_debug": {
                "scene_state": {"current_phase": "conversation_started"},
                "context": {"dynamic_context": {"request": {"player_action": "Поздороваться"}}},
                "rag": {"result_count": 2},
            },
        },
        llm_response_json={
            "narration": "Рон кивает и освобождает для тебя место за столом.",
            "memory_entry": "Рон принял приветствие.",
            "scene_state_patch": {"current_phase": "conversation_started"},
        },
    )

    response = asyncio.run(
        get_turn_debug(
            campaign_id="campaign-1",
            turn_number=14,
            session=_ScalarSession(turn),
        )
    )

    assert response.campaign_id == "campaign-1"
    assert response.request_id == "req-14"
    assert response.client_turn_id == "campaign-1:14:999"
    assert response.scene_state["current_phase"] == "conversation_started"
    assert response.context["dynamic_context"]["request"]["player_action"] == "Поздороваться"
    assert response.rag["result_count"] == 2
    assert response.llm_response_excerpt["scene_state_patch"]["current_phase"] == "conversation_started"


def test_get_turn_debug_raises_404_when_turn_missing():
    with pytest.raises(HTTPException) as exc:
        asyncio.run(
            get_turn_debug(
                campaign_id="missing-campaign",
                turn_number=1,
                session=_ScalarSession(None),
            )
        )

    assert exc.value.status_code == 404
    assert exc.value.detail == "turn_debug_not_found"
