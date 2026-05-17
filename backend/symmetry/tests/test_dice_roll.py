"""Tests for dice_roll in turn processing and TurnResponse schema."""

import secrets

import pytest

from app.schemas.campaigns import ChoiceSchema, ProcessTurnResponse


def test_dice_roll_range():
    """secrets.randbelow(20) + 1 produces values 1-20."""
    rolls = {secrets.randbelow(20) + 1 for _ in range(1000)}
    assert rolls.issubset(set(range(1, 21)))
    assert len(rolls) >= 15


def test_process_turn_response_with_dice_roll():
    """ProcessTurnResponse accepts dice_roll."""
    response = ProcessTurnResponse(
        narration="Test narration",
        choices=[
            ChoiceSchema(id="choice-a", label="Choice A"),
            ChoiceSchema(id="choice-b", label="Choice B"),
        ],
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
        choices=[
            ChoiceSchema(id="c1", label="C1"),
            ChoiceSchema(id="c2", label="C2"),
        ],
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
        choices=[
            ChoiceSchema(id="c1", label="C1"),
            ChoiceSchema(id="c2", label="C2"),
        ],
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
        choices=[
            ChoiceSchema(id="c1", label="C1"),
            ChoiceSchema(id="c2", label="C2"),
        ],
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
    for value in range(1, 21):
        assert rolls.count(value) > 0, f"value {value} never appeared in 2000 rolls"


def test_choices_strictly_validated_count():
    """choices must have 2-5 items."""
    with pytest.raises(ValueError, match="at least 2"):
        ProcessTurnResponse(
            narration="Test",
            choices=[ChoiceSchema(id="c1", label="C1")],
            state_changes={},
            memory_entry="M",
            request_id="r",
            campaign_snapshot_version=1,
            state={},
        )
    with pytest.raises(ValueError, match="at most 5"):
        ProcessTurnResponse(
            narration="Test",
            choices=[ChoiceSchema(id=f"c{i}", label=f"C{i}") for i in range(6)],
            state_changes={},
            memory_entry="M",
            request_id="r",
            campaign_snapshot_version=1,
            state={},
        )


def test_choice_schema_validation():
    """ChoiceSchema validates id and label."""
    with pytest.raises(ValueError, match="must not be empty"):
        ChoiceSchema(id="", label="Something")
    with pytest.raises(ValueError, match="must not be empty"):
        ChoiceSchema(id="valid", label="")
