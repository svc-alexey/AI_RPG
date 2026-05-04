"""MapStateService — single point of access for campaign spatial state."""

import random
from datetime import datetime
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import (
    CampaignSnapshot,
    LocationEdge,
    MapViewState,
    SpatialChangeProposal,
    WorldChronicle,
    WorldLocation,
    WorldState,
)
from app.services.ids import new_id
from app.services.presentation_text import build_location_display_name

_PLACEHOLDER_LOCATIONS = {
    "starting point",
    "starting point.",
    "начальная точка",
    "начальная точка.",
}


def _is_placeholder_location(title: str) -> bool:
    return title.strip().lower() in _PLACEHOLDER_LOCATIONS


class MapStateService:
    """Read/write spatial state for campaign maps."""

    # Validation rules for spatial change proposals
    ALLOWED_STATE_TRANSITIONS = {
        "fog": {"rumored", "explored"},
        "rumored": {"explored"},
        "explored": {"threat"},
        "threat": {"explored"},
        "blocked": set(),
    }

    async def get_map(self, db: AsyncSession, campaign_id: str) -> dict:
        """Return full map graph for a campaign. Auto-seeds if empty."""
        nodes_q = (
            select(WorldLocation)
            .where(WorldLocation.campaign_id == campaign_id)
        )
        result: Any = await db.execute(nodes_q)
        nodes: list[WorldLocation] = list(result.scalars().all())

        # Auto-seed: create nodes for starting and current location if empty
        if not nodes:
            starting_title = await self._resolve_starting_location(db, campaign_id)
            current_title = await self._resolve_current_location(db, campaign_id)

            root = WorldLocation(
                id=new_id(),
                campaign_id=campaign_id,
                slug="starting-point",
                title=starting_title,
                location_type="room",
                node_state=(
                    "explored"
                    if current_title and current_title != starting_title
                    else "current"
                ),
                is_revealed=True,
                x=5000.0,
                y=5000.0,
                metadata_json={},
            )
            db.add(root)
            nodes = [root]

            # If current narrative location differs, create it too
            if (
                current_title
                and current_title != starting_title
                and not _is_placeholder_location(current_title)
            ):
                cur_node = WorldLocation(
                    id=new_id(),
                    campaign_id=campaign_id,
                    slug=current_title.strip().lower().replace(" ", "-"),
                    title=current_title.strip(),
                    location_type="room",
                    node_state="current",
                    is_revealed=True,
                    x=5000.0 + random.uniform(-200, 200),
                    y=5000.0 + random.uniform(-200, 200),
                    parent_id=root.id,
                    metadata_json={},
                )
                db.add(cur_node)
                edge = LocationEdge(
                    id=new_id(),
                    location_id_a=root.id,
                    location_id_b=cur_node.id,
                    edge_type="known",
                )
                db.add(edge)
                nodes.append(cur_node)

            await db.flush()

        edges_q = (
            select(LocationEdge)
            .where(
                LocationEdge.location_id_a.in_(
                    select(WorldLocation.id).where(
                        WorldLocation.campaign_id == campaign_id
                    )
                )
            )
        )
        result: Any = await db.execute(edges_q)
        edges: list[LocationEdge] = list(result.scalars().all())

        # Build breadcrumbs from focus node to root
        current_node = next((n for n in nodes if n.node_state == "current"), None)
        if not current_node and nodes:
            current_node = nodes[0]

        breadcrumbs = await self._build_breadcrumbs(db, current_node)

        # Determine available scales
        available_scales = self._compute_available_scales(nodes)

        # Build front info from nodes with front_badges
        fronts = [
            {
                "node_id": n.id,
                "front_type": badge,
                "description": f"Активный фронт: {badge}",
            }
            for n in nodes
            for badge in (n.front_badges or [])
        ]

        # Recent chronicles as return events
        chronicles_q = (
            select(WorldChronicle)
            .where(WorldChronicle.campaign_id == campaign_id)
            .order_by(WorldChronicle.created_at.desc())
            .limit(10)
        )
        result: Any = await db.execute(chronicles_q)
        chronicles: list[WorldChronicle] = list(result.scalars().all())

        return_events = [
            {
                "chronicle_id": c.id,
                "location_slug": build_location_display_name(
                    c.location_slug, language="ru"
                ) or c.location_slug,
                "event_text": c.event_text,
            }
            for c in chronicles
        ]

        return {
            "active_scale": "room",
            "current_node_id": current_node.id if current_node else None,
            "breadcrumbs": breadcrumbs,
            "nodes": [
                {
                    "id": n.id,
                    "title": n.title,
                    "location_type": n.location_type,
                    "x": n.x,
                    "y": n.y,
                    "parent_id": n.parent_id,
                    "node_state": n.node_state,
                    "is_revealed": n.is_revealed,
                    "front_badges": n.front_badges or [],
                    "events_count": 0,
                    "is_reachable": n.node_state not in ("blocked", "fog"),
                    "travel_prompt": n.travel_prompt,
                }
                for n in nodes
            ],
            "edges": [
                {
                    "id": e.id,
                    "location_id_a": e.location_id_a,
                    "location_id_b": e.location_id_b,
                    "edge_type": e.edge_type,
                    "travel_time_minutes": e.travel_time_minutes,
                }
                for e in edges
            ],
            "fronts": fronts,
            "return_events": return_events,
            "last_seen_delta": {"since_turn": 0, "new_events": len(return_events)},
            "available_scales": available_scales,
        }

    async def get_map_context(self, db: AsyncSession, campaign_id: str) -> dict:
        """Return compact map_context for turn response (best-effort)."""
        try:
            nodes_q = (
                select(WorldLocation)
                .where(WorldLocation.campaign_id == campaign_id)
            )
            result: Any = await db.execute(nodes_q)
            nodes: list[WorldLocation] = list(result.scalars().all())

            available_scales = self._compute_available_scales(nodes)

            # Find recently changed nodes (those with threat state or front_badges)
            changed_node_ids = [
                n.id for n in nodes
                if n.node_state == "threat" or (n.front_badges and len(n.front_badges) > 0)
            ]

            # Get recent rejected proposals for feedback loop
            proposals_q = (
                select(SpatialChangeProposal)
                .where(
                    SpatialChangeProposal.campaign_id == campaign_id,
                    SpatialChangeProposal.status == "rejected",
                )
                .order_by(SpatialChangeProposal.created_at.desc())
                .limit(5)
            )
            proposals_result: Any = await db.execute(proposals_q)
            rejected: list[SpatialChangeProposal] = list(proposals_result.scalars().all())

            rejected_proposals = [
                {
                    "proposal_type": p.proposal_type,
                    "payload_summary": str(p.payload_json)[:200],
                    "rejection_reason": (
                        p.validation_result.get("reason", "unknown")
                        if p.validation_result
                        else "unknown"
                    ),
                }
                for p in rejected
            ]

            return {
                "active_scale": "room",
                "focus_node_id": next(
                    (n.id for n in nodes if n.node_state == "current"), None
                ),
                "changed_node_ids": changed_node_ids,
                "new_return_events_count": 0,
                "available_scales": available_scales,
                "fronts_changed": len(changed_node_ids) > 0,
                "rejected_proposals": rejected_proposals,
            }
        except Exception:
            return {}

    async def get_return_summary(
        self, db: AsyncSession, campaign_id: str, user_id: str
    ) -> dict:
        """Return World Pulse digest for a returning player."""
        # Get user's last_seen_at
        state_q = (
            select(MapViewState)
            .where(
                MapViewState.user_id == user_id,
                MapViewState.campaign_id == campaign_id,
            )
        )
        result: Any = await db.execute(state_q)
        view_state = result.scalar_one_or_none()

        last_seen = view_state.last_seen_at if view_state else datetime.min

        # Get chronicles since last visit
        chronicles_q = (
            select(WorldChronicle)
            .where(
                WorldChronicle.campaign_id == campaign_id,
                WorldChronicle.created_at > last_seen,
            )
            .order_by(WorldChronicle.created_at.desc())
            .limit(5)
        )
        result: Any = await db.execute(chronicles_q)
        chronicles: list[WorldChronicle] = list(result.scalars().all())

        # Group by location + category
        digest = []
        for c in chronicles:
            location_title = build_location_display_name(
                c.location_slug, language="ru"
            ) or "Неизвестное место"
            category = "event"
            if "threat" in (c.tags or []):
                category = "threat"
            elif "rumor" in (c.tags or []):
                category = "rumor"
            digest.append({
                "chronicle_id": c.id,
                "location_title": location_title,
                "event_text": c.event_text,
                "category": category,
            })

        return {
            "since_turn": 0,
            "new_events_count": len(digest),
            "digest": digest,
            "changed_node_ids": [],  # Populated by butterfly
        }

    async def sync_narrative_location(
        self,
        db: AsyncSession,
        campaign_id: str,
        location_title: str,
        previous_location_title: str | None = None,
    ) -> str | None:
        """Ensure a WorldLocation exists for the narrative location.

        Creates the node if missing, connects it to the previous location,
        and updates node states (current → explored for previous, new → current).
        Returns the current node ID or None.
        """
        if not location_title or not location_title.strip():
            return None
        if _is_placeholder_location(location_title):
            return None

        slug = location_title.strip().lower().replace(" ", "-")
        normalized_title = location_title.strip()

        # Find existing node by title
        existing_q = (
            select(WorldLocation)
            .where(
                WorldLocation.campaign_id == campaign_id,
                WorldLocation.title == normalized_title,
            )
        )
        result: Any = await db.execute(existing_q)
        current_node: WorldLocation | None = result.scalar_one_or_none()

        if current_node is None:
            # Find previous node for positioning
            prev_node = None
            if previous_location_title:
                prev_q = (
                    select(WorldLocation)
                    .where(
                        WorldLocation.campaign_id == campaign_id,
                        WorldLocation.title == previous_location_title.strip(),
                    )
                )
                prev_result: Any = await db.execute(prev_q)
                prev_node = prev_result.scalar_one_or_none()

            # Position near previous node or at center
            base_x = prev_node.x if prev_node else 5000.0
            base_y = prev_node.y if prev_node else 5000.0
            offset_x = random.uniform(-300, 300)
            offset_y = random.uniform(-300, 300)

            current_node = WorldLocation(
                id=new_id(),
                campaign_id=campaign_id,
                slug=slug,
                title=normalized_title,
                location_type="room",
                node_state="current",
                is_revealed=True,
                x=base_x + offset_x,
                y=base_y + offset_y,
                parent_id=prev_node.id if prev_node else None,
                metadata_json={},
            )
            db.add(current_node)
            await db.flush()

            # Create edge from previous to current (avoid duplicates)
            if prev_node:
                edge_exists_q = (
                    select(LocationEdge)
                    .where(
                        LocationEdge.location_id_a.in_(
                            [prev_node.id, current_node.id]
                        ),
                        LocationEdge.location_id_b.in_(
                            [prev_node.id, current_node.id]
                        ),
                    )
                )
                edge_result: Any = await db.execute(edge_exists_q)
                if not edge_result.scalar_one_or_none():
                    edge = LocationEdge(
                        id=new_id(),
                        location_id_a=prev_node.id,
                        location_id_b=current_node.id,
                        edge_type="known",
                    )
                    db.add(edge)
                # Mark previous as explored
                prev_node.node_state = "explored"

        # Ensure current node is marked as current
        if current_node.node_state != "current":
            # Demote any existing current node
            others_q = (
                select(WorldLocation)
                .where(
                    WorldLocation.campaign_id == campaign_id,
                    WorldLocation.node_state == "current",
                    WorldLocation.id != current_node.id,
                )
            )
            others_result: Any = await db.execute(others_q)
            for old_current in others_result.scalars().all():
                old_current.node_state = "explored"
            current_node.node_state = "current"

        return current_node.id

    async def seed_map(
        self, db: AsyncSession, campaign_id: str
    ) -> str:
        """Create a fallback starting node for a campaign. Returns node id."""
        node_id = new_id()
        root = WorldLocation(
            id=node_id,
            campaign_id=campaign_id,
            slug="starting-point",
            title="Начальная точка",
            location_type="room",
            node_state="current",
            is_revealed=True,
            x=5000.0,
            y=5000.0,
            metadata_json={},
        )
        db.add(root)
        await db.flush()
        return node_id

    async def mark_seen(
        self, db: AsyncSession, user_id: str, campaign_id: str
    ) -> None:
        """Mark all chronicles up to now as seen."""
        state_q = (
            select(MapViewState)
            .where(
                MapViewState.user_id == user_id,
                MapViewState.campaign_id == campaign_id,
            )
        )
        result: Any = await db.execute(state_q)
        view_state = result.scalar_one_or_none()

        if view_state:
            view_state.last_seen_at = datetime.utcnow()
        else:
            view_state = MapViewState(
                id=new_id(),
                user_id=user_id,
                campaign_id=campaign_id,
                last_seen_at=datetime.utcnow(),
                active_scale="room",
            )
            db.add(view_state)
        await db.flush()

    async def process_proposals(
        self, db: AsyncSession, campaign_id: str, proposals: list[dict]
    ) -> list[dict]:
        """Validate and persist spatial change proposals."""
        results = []
        for p in proposals:
            proposal_type = str(p.get("proposal_type", ""))
            payload: dict = p.get("payload") or {}
            validation = self._validate(proposal_type, payload, db, campaign_id)

            proposal = SpatialChangeProposal(
                id=new_id(),
                campaign_id=campaign_id,
                proposal_type=proposal_type,
                payload_json=payload,
                status="validated" if validation["valid"] else "rejected",
                validation_result=validation,
            )
            db.add(proposal)

            results.append({
                "proposal_type": proposal_type,
                "status": proposal.status,
                "validation_result": validation,
            })

            # Apply validated proposals
            if validation["valid"]:
                await self._apply_proposal(db, campaign_id, proposal_type, payload)

        await db.flush()
        return results

    def _validate(
        self, proposal_type: str, payload: dict, db, campaign_id: str
    ) -> dict:
        """Validate a spatial change proposal against V1 rules."""
        if proposal_type == "add_location":
            parent_id = payload.get("parent_id")
            x = payload.get("x")
            y = payload.get("y")
            if not parent_id:
                return {"valid": False, "reason": "parent_id is required"}
            if x is None or y is None:
                return {"valid": False, "reason": "x and y coordinates are required"}
            if not (0 <= x <= 10000 and 0 <= y <= 10000):
                return {"valid": False, "reason": "coordinates must be in [0, 10000]"}
            return {"valid": True, "reason": "ok"}

        elif proposal_type == "connect_locations":
            loc_a = payload.get("location_id_a")
            loc_b = payload.get("location_id_b")
            if not loc_a or not loc_b:
                return {"valid": False, "reason": "both location IDs are required"}
            return {"valid": True, "reason": "ok"}

        elif proposal_type == "reveal_location":
            loc_id = payload.get("location_id")
            if not loc_id:
                return {"valid": False, "reason": "location_id is required"}
            return {"valid": True, "reason": "ok"}

        elif proposal_type == "update_state":
            new_state = payload.get("new_state")
            if new_state not in self.ALLOWED_STATE_TRANSITIONS:
                return {"valid": False, "reason": f"unknown state: {new_state}"}
            return {"valid": True, "reason": "ok"}

        return {"valid": False, "reason": f"unknown proposal_type: {proposal_type}"}

    async def _apply_proposal(
        self, db: AsyncSession, campaign_id: str, proposal_type: str, payload: dict
    ) -> None:
        """Apply a validated proposal to the database."""
        if proposal_type == "add_location":
            new_node = WorldLocation(
                id=new_id(),
                campaign_id=campaign_id,
                slug=payload.get("slug", f"loc-{new_id()[:8]}"),
                title=payload.get("title", "New Location"),
                x=payload.get("x", 5000),
                y=payload.get("y", 5000),
                parent_id=payload.get("parent_id"),
                location_type=payload.get("location_type", "room"),
                node_state=payload.get("node_state", "fog"),
                is_revealed=False,
                travel_prompt=payload.get("travel_prompt"),
                metadata_json={},
            )
            db.add(new_node)

        elif proposal_type == "connect_locations":
            edge = LocationEdge(
                id=new_id(),
                location_id_a=payload["location_id_a"],
                location_id_b=payload["location_id_b"],
                edge_type=payload.get("edge_type", "known"),
                travel_time_minutes=payload.get("travel_time_minutes"),
            )
            db.add(edge)

        elif proposal_type == "reveal_location":
            q = select(WorldLocation).where(
                WorldLocation.id == payload["location_id"],
                WorldLocation.campaign_id == campaign_id,
            )
            reveal_result: Any = await db.execute(q)
            reveal_node: WorldLocation | None = reveal_result.scalar_one_or_none()
            if reveal_node:
                reveal_node.is_revealed = True
                if reveal_node.node_state == "fog":
                    reveal_node.node_state = "explored"

        elif proposal_type == "update_state":
            q = select(WorldLocation).where(
                WorldLocation.id == payload["location_id"],
                WorldLocation.campaign_id == campaign_id,
            )
            state_result: Any = await db.execute(q)
            state_node: WorldLocation | None = state_result.scalar_one_or_none()
            if state_node:
                new_state = payload["new_state"]
                current_state = state_node.node_state
                if new_state in self.ALLOWED_STATE_TRANSITIONS.get(current_state, set()):
                    state_node.node_state = new_state

    async def _build_breadcrumbs(
        self, db: AsyncSession, node: WorldLocation | None
    ) -> list[dict]:
        """Build breadcrumb trail from root to current node."""
        if not node:
            return []
        crumbs = [{"id": node.id, "title": node.title}]
        visited = {node.id}
        current = node
        while current.parent_id and current.parent_id not in visited:
            q = select(WorldLocation).where(WorldLocation.id == current.parent_id)
            result: Any = await db.execute(q)
            parent = result.scalar_one_or_none()
            if not parent:
                break
            crumbs.insert(0, {"id": parent.id, "title": parent.title})
            visited.add(parent.id)
            current = parent
        return crumbs

    async def _resolve_starting_location(
        self, db: AsyncSession, campaign_id: str
    ) -> str:
        """Extract the campaign's starting location from the latest snapshot.

        Prefers bootstrap.starting_location (narrative origin) over current location.
        """
        snapshot_q = (
            select(CampaignSnapshot)
            .where(CampaignSnapshot.campaign_id == campaign_id)
            .order_by(CampaignSnapshot.version.desc())
            .limit(1)
        )
        result: Any = await db.execute(snapshot_q)
        snapshot = result.scalar_one_or_none()
        if snapshot and snapshot.state_json:
            # Prefer bootstrap starting_location (the story's origin)
            bootstrap = snapshot.state_json.get("bootstrap") or {}
            start_loc = bootstrap.get("starting_location")
            if start_loc and isinstance(start_loc, str) and start_loc.strip():
                return start_loc.strip()
            # Fall back to current location
            loc = snapshot.state_json.get("location")
            if loc and isinstance(loc, str) and loc.strip():
                return loc.strip()
        # Fallback: check world_state for a stored location
        ws_q = (
            select(WorldState)
            .where(WorldState.campaign_id == campaign_id)
        )
        result: Any = await db.execute(ws_q)
        world_state: WorldState | None = result.scalar_one_or_none()
        if world_state and world_state.global_vars:
            loc = world_state.global_vars.get("location")
            if loc and isinstance(loc, str) and loc.strip():
                return loc.strip()
        return "Начальная точка"

    async def _resolve_current_location(
        self, db: AsyncSession, campaign_id: str
    ) -> str | None:
        """Extract the current narrative location from the latest snapshot."""
        snapshot_q = (
            select(CampaignSnapshot)
            .where(CampaignSnapshot.campaign_id == campaign_id)
            .order_by(CampaignSnapshot.version.desc())
            .limit(1)
        )
        result: Any = await db.execute(snapshot_q)
        snapshot = result.scalar_one_or_none()
        if snapshot and snapshot.state_json:
            loc = snapshot.state_json.get("location")
            if loc and isinstance(loc, str) and loc.strip():
                return loc.strip()
        return None

    def _compute_available_scales(self, nodes: list[WorldLocation]) -> list[str]:
        """Determine which scales are available based on revealed node types."""
        scales = set()
        for n in nodes:
            if n.is_revealed and n.location_type:
                scales.add(n.location_type)
        return sorted(scales)
