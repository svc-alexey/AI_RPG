"""Tests for MapStateService — spatial campaign map."""

import pytest

from app.services.map_state_service import MapStateService


@pytest.fixture
def service():
    return MapStateService()


class TestSpatialChangeValidation:
    def test_add_location_valid(self, service):
        result = service._validate(
            "add_location",
            {"parent_id": "abc123", "x": 5000, "y": 3000},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is True

    def test_add_location_missing_parent(self, service):
        result = service._validate(
            "add_location",
            {"x": 5000, "y": 3000},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "parent_id" in result["reason"]

    def test_add_location_missing_coords(self, service):
        result = service._validate(
            "add_location",
            {"parent_id": "abc123", "x": 5000},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "y" in result["reason"]

    def test_add_location_out_of_bounds(self, service):
        result = service._validate(
            "add_location",
            {"parent_id": "abc123", "x": -1, "y": 5000},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "coordinates" in result["reason"]

        result = service._validate(
            "add_location",
            {"parent_id": "abc123", "x": 5000, "y": 10001},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False

    def test_connect_locations_valid(self, service):
        result = service._validate(
            "connect_locations",
            {"location_id_a": "a", "location_id_b": "b"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is True

    def test_connect_locations_missing_ids(self, service):
        result = service._validate(
            "connect_locations",
            {"location_id_a": "a"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "both" in result["reason"]

    def test_reveal_location_valid(self, service):
        result = service._validate(
            "reveal_location",
            {"location_id": "abc123"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is True

    def test_reveal_location_missing_id(self, service):
        result = service._validate(
            "reveal_location",
            {},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False

    def test_update_state_allowed_transition(self, service):
        result = service._validate(
            "update_state",
            {"location_id": "abc123", "new_state": "explored"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is True

    def test_update_state_unknown_state(self, service):
        result = service._validate(
            "update_state",
            {"location_id": "abc123", "new_state": "nonexistent"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "unknown" in result["reason"].lower()

    def test_unknown_proposal_type(self, service):
        result = service._validate(
            "delete_location",
            {"location_id": "abc123"},
            db=None,
            campaign_id="c1",
        )
        assert result["valid"] is False
        assert "unknown" in result["reason"].lower()


class TestScaleComputation:
    def test_available_scales_from_revealed_nodes(self, service):
        from app.db.models import WorldLocation

        nodes = [
            _make_node("room", revealed=True),
            _make_node("station", revealed=True),
            _make_node("region", revealed=False),
        ]
        scales = service._compute_available_scales(nodes)
        assert "room" in scales
        assert "station" in scales
        assert "region" not in scales  # not revealed

    def test_empty_nodes_returns_empty_scales(self, service):
        scales = service._compute_available_scales([])
        assert scales == []


class TestStateTransitions:
    def test_allowed_transitions(self, service):
        # fog -> rumored
        assert "rumored" in service.ALLOWED_STATE_TRANSITIONS["fog"]
        # fog -> explored
        assert "explored" in service.ALLOWED_STATE_TRANSITIONS["fog"]
        # rumored -> explored
        assert "explored" in service.ALLOWED_STATE_TRANSITIONS["rumored"]
        # explored -> threat
        assert "threat" in service.ALLOWED_STATE_TRANSITIONS["explored"]
        # threat -> explored
        assert "explored" in service.ALLOWED_STATE_TRANSITIONS["threat"]

    def test_blocked_has_no_transitions(self, service):
        assert service.ALLOWED_STATE_TRANSITIONS["blocked"] == set()

    def test_fog_cannot_go_to_threat(self, service):
        assert "threat" not in service.ALLOWED_STATE_TRANSITIONS["fog"]


def _make_node(
    location_type="room",
    node_id="n1",
    title="Test",
    revealed=True,
    node_state="explored",
    parent_id=None,
):
    from app.db.models import WorldLocation

    return WorldLocation(
        id=node_id,
        campaign_id="c1",
        slug=f"slug-{node_id}",
        title=title,
        location_type=location_type,
        node_state=node_state,
        is_revealed=revealed,
        x=5000.0,
        y=5000.0,
        parent_id=parent_id,
        metadata_json={},
    )
