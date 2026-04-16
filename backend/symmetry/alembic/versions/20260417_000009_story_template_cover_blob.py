"""story_templates cover image stored in database (BYTEA)."""

import sqlalchemy as sa
from alembic import op

revision = "20260417_000009"
down_revision = "20260416_000008"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "story_templates",
        sa.Column("cover_image_mime", sa.String(length=128), nullable=True),
    )
    op.add_column(
        "story_templates",
        sa.Column("cover_image_data", sa.LargeBinary(), nullable=True),
    )
    op.add_column(
        "story_templates",
        sa.Column(
            "cover_image_populated",
            sa.Boolean(),
            nullable=False,
            server_default="false",
        ),
    )
    op.execute(
        sa.text(
            "UPDATE story_templates SET cover_image_populated = "
            "(cover_image_data IS NOT NULL)"
        )
    )
    op.alter_column("story_templates", "cover_image_populated", server_default=None)


def downgrade() -> None:
    op.drop_column("story_templates", "cover_image_populated")
    op.drop_column("story_templates", "cover_image_data")
    op.drop_column("story_templates", "cover_image_mime")
