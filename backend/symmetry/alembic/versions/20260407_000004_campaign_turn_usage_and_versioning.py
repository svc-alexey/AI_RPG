"""Add campaign turn usage metadata support.

Revision ID: 20260407_000004
Revises: 20260407_000003
Create Date: 2026-04-07 15:30:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = "20260407_000004"
down_revision = "20260407_000003"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "campaign_turns",
        sa.Column(
            "llm_usage_json",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
    )
    op.alter_column("campaign_turns", "llm_usage_json", server_default=None)


def downgrade() -> None:
    op.drop_column("campaign_turns", "llm_usage_json")
