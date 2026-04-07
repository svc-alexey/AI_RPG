"""Add butterfly world entities, simulation jobs, and pending consequences.

Revision ID: 20260407_000003
Revises: 20260407_000002
Create Date: 2026-04-07 03:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "20260407_000003"
down_revision = "20260407_000002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "world_entities",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("campaign_id", sa.String(length=36), nullable=False),
        sa.Column("slug", sa.String(length=120), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("entity_kind", sa.String(length=64), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("influence", sa.Integer(), nullable=False),
        sa.Column(
            "metadata_json",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["campaign_id"], ["campaigns.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_world_entities_campaign_id"),
        "world_entities",
        ["campaign_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_world_entities_slug"),
        "world_entities",
        ["slug"],
        unique=False,
    )

    op.create_table(
        "simulation_jobs",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("campaign_id", sa.String(length=36), nullable=False),
        sa.Column("job_type", sa.String(length=64), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column(
            "payload_json",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column("attempts", sa.Integer(), nullable=False),
        sa.Column("last_error", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("available_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("finished_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["campaign_id"], ["campaigns.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_simulation_jobs_campaign_id"),
        "simulation_jobs",
        ["campaign_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_simulation_jobs_status"),
        "simulation_jobs",
        ["status"],
        unique=False,
    )

    op.create_table(
        "pending_consequences",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("campaign_id", sa.String(length=36), nullable=False),
        sa.Column("source_turn_id", sa.String(length=36), nullable=True),
        sa.Column("source_snapshot_version", sa.Integer(), nullable=False),
        sa.Column("mode", sa.String(length=50), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("due_turn_number", sa.Integer(), nullable=False),
        sa.Column("entity_kind", sa.String(length=64), nullable=False),
        sa.Column("entity_slug", sa.String(length=120), nullable=False),
        sa.Column("effect_type", sa.String(length=64), nullable=False),
        sa.Column("strength", sa.Integer(), nullable=False),
        sa.Column("visibility", sa.String(length=16), nullable=False),
        sa.Column("summary", sa.Text(), nullable=False),
        sa.Column(
            "payload_json",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["campaign_id"], ["campaigns.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["source_turn_id"],
            ["campaign_turns.id"],
            ondelete="SET NULL",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_pending_consequences_campaign_id"),
        "pending_consequences",
        ["campaign_id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_pending_consequences_entity_slug"),
        "pending_consequences",
        ["entity_slug"],
        unique=False,
    )
    op.create_index(
        op.f("ix_pending_consequences_status"),
        "pending_consequences",
        ["status"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_pending_consequences_status"), table_name="pending_consequences")
    op.drop_index(op.f("ix_pending_consequences_entity_slug"), table_name="pending_consequences")
    op.drop_index(op.f("ix_pending_consequences_campaign_id"), table_name="pending_consequences")
    op.drop_table("pending_consequences")

    op.drop_index(op.f("ix_simulation_jobs_status"), table_name="simulation_jobs")
    op.drop_index(op.f("ix_simulation_jobs_campaign_id"), table_name="simulation_jobs")
    op.drop_table("simulation_jobs")

    op.drop_index(op.f("ix_world_entities_slug"), table_name="world_entities")
    op.drop_index(op.f("ix_world_entities_campaign_id"), table_name="world_entities")
    op.drop_table("world_entities")
