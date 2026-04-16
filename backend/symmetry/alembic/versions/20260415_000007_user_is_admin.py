"""Add users.is_admin.

Catalog story templates are not seeded by schema migrations; admins create cards via API.

Revision ID: 20260415_000007
Revises: 20260414_000006
Create Date: 2026-04-15 12:00:00
"""

import sqlalchemy as sa
from alembic import op

revision = "20260415_000007"
down_revision = "20260414_000006"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column(
            "is_admin",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
    )
    op.alter_column("users", "is_admin", server_default=None)


def downgrade() -> None:
    op.drop_column("users", "is_admin")
