"""Spatial campaign map: world_locations extension, location_edges, map_view_states, spatial_change_proposals."""

import sqlalchemy as sa
from alembic import op

revision = "20260503_000010"
down_revision = "20260417_000009"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Extend world_locations with spatial metadata
    op.add_column(
        "world_locations",
        sa.Column("x", sa.Float(), nullable=True, server_default="0"),
    )
    op.add_column(
        "world_locations",
        sa.Column("y", sa.Float(), nullable=True, server_default="0"),
    )
    op.add_column(
        "world_locations",
        sa.Column(
            "parent_id",
            sa.String(36),
            sa.ForeignKey("world_locations.id", ondelete="SET NULL"),
            nullable=True,
        ),
    )
    op.add_column(
        "world_locations",
        sa.Column(
            "location_type",
            sa.String(length=20),
            nullable=False,
            server_default="room",
        ),
    )
    op.add_column(
        "world_locations",
        sa.Column(
            "node_state",
            sa.String(length=20),
            nullable=False,
            server_default="fog",
        ),
    )
    op.add_column(
        "world_locations",
        sa.Column(
            "is_revealed",
            sa.Boolean(),
            nullable=False,
            server_default="false",
        ),
    )
    op.add_column(
        "world_locations",
        sa.Column("travel_prompt", sa.String(length=500), nullable=True),
    )
    op.add_column(
        "world_locations",
        sa.Column(
            "front_badges",
            sa.ARRAY(sa.String(length=30)),
            nullable=False,
            server_default="{}",
        ),
    )

    # Backfill existing locations: mark as revealed with a neutral state
    op.execute(
        sa.text(
            "UPDATE world_locations SET is_revealed = true, "
            "node_state = 'explored', x = 5000, y = 5000 "
            "WHERE x IS NULL AND y IS NULL"
        )
    )

    # location_edges: connections between locations
    op.create_table(
        "location_edges",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("location_id_a", sa.String(36), sa.ForeignKey("world_locations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("location_id_b", sa.String(36), sa.ForeignKey("world_locations.id", ondelete="CASCADE"), nullable=False),
        sa.Column("edge_type", sa.String(length=20), nullable=False, server_default="known"),
        sa.Column("travel_time_minutes", sa.Integer(), nullable=True),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.UniqueConstraint("location_id_a", "location_id_b"),
    )

    # map_view_states: per-user, per-campaign view tracking
    op.create_table(
        "map_view_states",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(36), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("campaign_id", sa.String(36), sa.ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("last_seen_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("active_scale", sa.String(length=20), nullable=False, server_default="room"),
        sa.Column("focus_node_id", sa.String(36), sa.ForeignKey("world_locations.id", ondelete="SET NULL"), nullable=True),
        sa.UniqueConstraint("user_id", "campaign_id"),
    )

    # spatial_change_proposals: LLM-suggested map changes
    op.create_table(
        "spatial_change_proposals",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("campaign_id", sa.String(36), sa.ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("turn_id", sa.String(36), sa.ForeignKey("campaign_turns.id", ondelete="SET NULL"), nullable=True),
        sa.Column("proposal_type", sa.String(length=30), nullable=False),
        sa.Column("payload_json", sa.JSON(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="pending"),
        sa.Column("validation_result", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )


def downgrade() -> None:
    op.drop_table("spatial_change_proposals")
    op.drop_table("map_view_states")
    op.drop_table("location_edges")
    op.drop_column("world_locations", "front_badges")
    op.drop_column("world_locations", "travel_prompt")
    op.drop_column("world_locations", "is_revealed")
    op.drop_column("world_locations", "node_state")
    op.drop_column("world_locations", "location_type")
    op.drop_column("world_locations", "parent_id")
    op.drop_column("world_locations", "y")
    op.drop_column("world_locations", "x")
