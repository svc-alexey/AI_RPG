"""Add portrait_status to campaigns, status/completed_at to campaign_portraits.

Revision ID: 20260513_000016
Revises: 20260511_000015
Create Date: 2026-05-13 13:00:00
"""

import sqlalchemy as sa
from alembic import op

revision = "20260513_000016"
down_revision = "20260511_000015"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "campaigns",
        sa.Column("portrait_status", sa.String(length=32), nullable=True),
    )
    op.add_column(
        "campaign_portraits",
        sa.Column("status", sa.String(length=16), nullable=False, server_default="ready"),
    )
    op.add_column(
        "campaign_portraits",
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("campaign_portraits", "completed_at")
    op.drop_column("campaign_portraits", "status")
    op.drop_column("campaigns", "portrait_status")
