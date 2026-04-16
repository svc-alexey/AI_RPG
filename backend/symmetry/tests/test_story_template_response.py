from datetime import UTC, datetime

from app.schemas.stories import StoryTemplateResponse


def test_story_template_response_includes_metadata_and_author():
    now = datetime.now(UTC)
    row = StoryTemplateResponse(
        id="t1",
        title="Title",
        summary="Sum",
        prompt_text="Prompt",
        setting="grimdarkFantasy",
        literary_genre_slug="fantasyGenre",
        cover_image_href="/v1/story-templates/t1/cover",
        is_public=True,
        is_master_curated=True,
        metadata={"cover_image_url": "https://example.com/x.png"},
        author_display_name="AI Master",
        tags=["a", "b"],
        likes=3,
        views=10,
        bookmarked=False,
        created_at=now,
        updated_at=now,
    )
    assert row.is_master_curated is True
    assert row.metadata["cover_image_url"].endswith(".png")
    assert row.author_display_name == "AI Master"
