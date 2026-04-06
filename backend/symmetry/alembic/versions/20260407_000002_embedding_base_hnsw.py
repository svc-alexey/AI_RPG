"""Switch embeddings to e5-base vector shape and add HNSW index.

Revision ID: 20260407_000002
Revises: 20260405_000001
Create Date: 2026-04-07 00:00:00
"""

from alembic import op
import sqlalchemy as sa
from pgvector.sqlalchemy import Vector


# revision identifiers, used by Alembic.
revision = "20260407_000002"
down_revision = "20260405_000001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.drop_column("world_chronicles", "vector")
    op.add_column("world_chronicles", sa.Column("vector", Vector(768), nullable=True))
    op.execute("ALTER TABLE world_chronicles ALTER COLUMN vector SET STORAGE PLAIN")
    op.execute(
        """
        CREATE INDEX idx_world_chronicles_hnsw
        ON world_chronicles USING hnsw (vector vector_cosine_ops)
        WITH (m = 32, ef_construction = 128)
        """
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS idx_world_chronicles_hnsw")
    op.drop_column("world_chronicles", "vector")
    op.add_column("world_chronicles", sa.Column("vector", Vector(1024), nullable=True))
