"""Add campaign_portraits table for AI-generated character portraits.

Revision ID: 20260511_000015
Revises: 20260510_000014
Create Date: 2026-05-11 22:00:00
"""

from alembic import op
import sqlalchemy as sa


revision = "20260511_000015"
down_revision = "20260510_000014"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "campaign_portraits",
        sa.Column("id", sa.String(36), primary_key=True),
        sa.Column(
            "campaign_id",
            sa.String(36),
            sa.ForeignKey("campaigns.id", ondelete="CASCADE"),
            nullable=False,
            index=True,
            unique=True,
        ),
        sa.Column("image_webp", sa.LargeBinary(), nullable=False),
        sa.Column("prompt_used", sa.Text(), nullable=False),
        sa.Column("model_used", sa.String(64), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )


def downgrade() -> None:
    op.drop_table("campaign_portraits")
