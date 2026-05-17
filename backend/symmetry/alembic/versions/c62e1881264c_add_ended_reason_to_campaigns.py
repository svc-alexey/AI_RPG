"""add ended_reason to campaigns

Revision ID: c62e1881264c
Revises: 20260513_000017
Create Date: 2026-05-18 00:47:59.650692
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'c62e1881264c'
down_revision = '20260513_000017'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        'campaigns',
        sa.Column('ended_reason', sa.String(length=64), nullable=True),
    )


def downgrade() -> None:
    op.drop_column('campaigns', 'ended_reason')
