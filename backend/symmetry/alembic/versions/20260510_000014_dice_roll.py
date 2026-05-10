"""Add dice_roll column to campaign_turns.

Revision ID: 20260510_000014
Revises: 20260510_000013
Create Date: 2026-05-10 21:00:00
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "20260510_000014"
down_revision = "20260510_000013"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "campaign_turns",
        sa.Column("dice_roll", sa.Integer(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("campaign_turns", "dice_roll")
