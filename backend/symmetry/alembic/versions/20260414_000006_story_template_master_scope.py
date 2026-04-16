"""Add story_templates.is_master_curated.

Revision ID: 20260414_000006
Revises: 20260413_000005
Create Date: 2026-04-14 12:00:00
"""

import sqlalchemy as sa
from alembic import op

revision = "20260414_000006"
down_revision = "20260413_000005"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "story_templates",
        sa.Column(
            "is_master_curated",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
    )
    op.alter_column("story_templates", "is_master_curated", server_default=None)


def downgrade() -> None:
    op.drop_column("story_templates", "is_master_curated")
