import asyncio
from datetime import UTC, datetime
from types import SimpleNamespace

from app.api.routes.campaigns import (
    _build_process_turn_response,
    _build_turn_debug_payload,
    _load_existing_turn_by_client_id,
)


def test_build_turn_debug_payload_keeps_scene_state_and_rag_summary():
    context = {
        "campaign_bootstrap": {"title": "Hogwarts Echoes"},
        "world_bootstrap": {"setting": "magicSchool"},
        "character_brief": {"name": "Alexey"},
        "dynamic_context": {
            "turn_number": 8,
            "memory": {"known_characters": ["Гарри Поттер"]},
            "scene_state": {
                "current_phase": "conversation_started",
                "last_completed_beat": "Уже сидит за столом Гриффиндора.",
            },
            "state": {"location": "great_hall"},
            "request": {"player_action": "Поздороваться"},
        },
    }
    chronicles = [
        SimpleNamespace(
            id="chron-1",
            event_text="Рон уже заметил нового ученика за столом.",
            importance=6,
            location_slug="great_hall",
            metadata_json={"source": "rag"},
        )
    ]

    payload = _build_turn_debug_payload(
        context=context,
        chronicles=chronicles,
        query_text="scene_anchor: Большой зал",
    )

    assert payload["scene_state"]["current_phase"] == "conversation_started"
    assert payload["context"]["dynamic_context"]["request"]["player_action"] == "Поздороваться"
    assert payload["rag"]["result_count"] == 1
    assert payload["rag"]["results"][0]["id"] == "chron-1"
    assert payload["rag"]["results"][0]["source"] == "rag"


def test_build_process_turn_response_reuses_saved_request_id():
    turn = SimpleNamespace(
        llm_response_json={
            "narration": "Гермиона отвечает на приветствие и освобождает место.",
            "choices": ["Сесть рядом", "Спросить о шляпе"],
            "state_changes": {"location": "great_hall"},
            "memory_entry": "Поздоровался с гриффиндорским столом.",
        },
        llm_usage_json={"request_id": "req-123"},
    )
    snapshot = SimpleNamespace(
        version=5,
        state_json={"scene_state": {"current_phase": "conversation_started"}},
    )

    response = _build_process_turn_response(turn=turn, snapshot=snapshot)

    assert response.request_id == "req-123"
    assert response.campaign_snapshot_version == 5
    assert response.state["scene_state"]["current_phase"] == "conversation_started"
    assert response.choices == ["Сесть рядом", "Спросить о шляпе"]


class _ScalarSpySession:
    def __init__(self):
        self.scalar_called = False

    async def scalar(self, _):
        self.scalar_called = True
        return None


def test_load_existing_turn_by_client_id_skips_blank_values():
    session = _ScalarSpySession()

    result = asyncio.run(
        _load_existing_turn_by_client_id(
            session,
            campaign_id="campaign-1",
            client_turn_id="   ",
        )
    )

    assert result is None
    assert session.scalar_called is False
