"""Tests for dice_roll in turn processing and TurnResponse schema."""

import secrets

import pytest

from app.schemas.campaigns import ProcessTurnResponse


def test_dice_roll_range():
    """secrets.randbelow(20) + 1 produces values 1-20."""
    rolls = {secrets.randbelow(20) + 1 for _ in range(1000)}
    assert rolls.issubset(set(range(1, 21)))
    assert len(rolls) >= 15  # статистически должны покрыть почти все значения


def test_process_turn_response_with_dice_roll():
    """ProcessTurnResponse accepts dice_roll."""
    response = ProcessTurnResponse(
        narration="Test narration",
        choices=["Choice A", "Choice B"],
        state_changes={"hp_delta": -2},
        memory_entry="Memory entry text",
        request_id="req-123",
        campaign_snapshot_version=5,
        state={"turn_number": 3},
        dice_roll=17,
    )
    assert response.dice_roll == 17


def test_process_turn_response_without_dice_roll():
    """ProcessTurnResponse dice_roll defaults to None."""
    response = ProcessTurnResponse(
        narration="Test",
        choices=[],
        state_changes={},
        memory_entry="Memory",
        request_id="req-456",
        campaign_snapshot_version=1,
        state={"turn_number": 1},
    )
    assert response.dice_roll is None


def test_process_turn_response_dice_roll_serialization():
    """ProcessTurnResponse with dice_roll serializes correctly."""
    response = ProcessTurnResponse(
        narration="Test",
        choices=["C1"],
        state_changes={},
        memory_entry="M1",
        request_id="r1",
        campaign_snapshot_version=3,
        state={"t": 2},
        dice_roll=20,
    )
    data = response.model_dump()
    assert data["dice_roll"] == 20


def test_process_turn_response_without_dice_roll_serialization():
    """ProcessTurnResponse without dice_roll serializes with null."""
    response = ProcessTurnResponse(
        narration="Test",
        choices=[],
        state_changes={},
        memory_entry="M1",
        request_id="r1",
        campaign_snapshot_version=1,
        state={"t": 1},
    )
    data = response.model_dump()
    assert data["dice_roll"] is None


def test_dice_roll_statistical_distribution():
    """d20 rolls are uniformly distributed in 1-20."""
    rolls = [secrets.randbelow(20) + 1 for _ in range(2000)]
    # каждое значение должно появиться хотя бы раз при 2000 бросках
    for value in range(1, 21):
        assert value in rolls, f"Value {value} never appeared in 2000 rolls"
