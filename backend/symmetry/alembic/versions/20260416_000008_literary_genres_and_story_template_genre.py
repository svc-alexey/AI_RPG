"""Literary genres catalog and story_templates.literary_genre_slug.

Revision ID: 20260416_000008
Revises: 20260415_000007
Create Date: 2026-04-16 12:00:00
"""

import sqlalchemy as sa
from alembic import op

revision = "20260416_000008"
down_revision = "20260415_000007"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "literary_genres",
        sa.Column("slug", sa.String(length=80), nullable=False),
        sa.Column("title_en", sa.String(length=160), nullable=False),
        sa.Column("title_ru", sa.String(length=160), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.PrimaryKeyConstraint("slug", name="pk_literary_genres"),
    )
    op.create_index(op.f("ix_literary_genres_sort_order"), "literary_genres", ["sort_order"])

    seed = [
        ("romance", "Romance", "Романтика", 10),
        ("romantasyGenre", "Romantasy", "Романтическое фэнтези", 20),
        ("fantasyGenre", "Fantasy", "Фэнтези", 30),
        ("psychologicalThriller", "Psychological thriller", "Психологический триллер", 40),
        ("mysteryCrime", "Mystery & crime", "Детектив и криминал", 50),
        ("horrorGenre", "Horror", "Хоррор", 60),
        ("youngAdult", "Young adult", "Young adult", 70),
        ("speculativeFiction", "Speculative fiction", "Спекулятивная проза", 80),
        ("darkAcademiaGenre", "Dark academia", "Тёмная академия", 90),
        ("cozyFeelGood", "Cozy / feel-good", "Уютное / feel-good", 100),
    ]
    conn = op.get_bind()
    insert_stmt = sa.text(
        "INSERT INTO literary_genres (slug, title_en, title_ru, sort_order) "
        "VALUES (:slug, :en, :ru, :ord)"
    )
    for slug, en, ru, order in seed:
        conn.execute(insert_stmt, {"slug": slug, "en": en, "ru": ru, "ord": order})

    op.add_column(
        "story_templates",
        sa.Column("literary_genre_slug", sa.String(length=80), nullable=True),
    )
    op.create_foreign_key(
        "fk_story_templates_literary_genre_slug",
        "story_templates",
        "literary_genres",
        ["literary_genre_slug"],
        ["slug"],
        ondelete="SET NULL",
    )
    op.create_index(
        op.f("ix_story_templates_literary_genre_slug"),
        "story_templates",
        ["literary_genre_slug"],
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_story_templates_literary_genre_slug"), table_name="story_templates")
    op.drop_constraint("fk_story_templates_literary_genre_slug", "story_templates", type_="foreignkey")
    op.drop_column("story_templates", "literary_genre_slug")
    op.drop_index(op.f("ix_literary_genres_sort_order"), table_name="literary_genres")
    op.drop_table("literary_genres")
