"""Make image_webp and prompt_used nullable for pending portrait rows.

Revision ID: 20260513_000017
Revises: 20260513_000016
Create Date: 2026-05-13 13:30:00
"""

from alembic import op

revision = "20260513_000017"
down_revision = "20260513_000016"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column("campaign_portraits", "image_webp", nullable=True)
    op.alter_column("campaign_portraits", "prompt_used", nullable=True)


def downgrade() -> None:
    op.alter_column("campaign_portraits", "image_webp", nullable=False)
    op.alter_column("campaign_portraits", "prompt_used", nullable=False)
