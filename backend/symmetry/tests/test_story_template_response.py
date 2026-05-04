from datetime import UTC, datetime
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.schemas.stories import StoryTemplateResponse, StoryTemplateUpsertRequest
from app.services.story_library import (
    StoryLibraryService,
    _campaign_setup_from_metadata,
    _metadata_with_campaign_setup,
    _optional_text,
)


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


# ── _optional_text ───────────────────────────────────────────────────

def test_optional_text_returns_none_for_none():
    assert _optional_text(None) is None


def test_optional_text_returns_none_for_empty_string():
    assert _optional_text("") is None
    assert _optional_text("   ") is None


def test_optional_text_returns_stripped_value():
    assert _optional_text("  hello  ") == "hello"


# ── _campaign_setup_from_metadata ────────────────────────────────────

def test_campaign_setup_from_metadata_returns_empty_for_missing_key():
    assert _campaign_setup_from_metadata({}) == {}
    assert _campaign_setup_from_metadata({"other": "value"}) == {}


def test_campaign_setup_from_metadata_returns_dict_when_present():
    metadata = {"campaign_setup": {"story_prompt": "Test", "mode": "story"}}
    result = _campaign_setup_from_metadata(metadata)
    assert result["story_prompt"] == "Test"
    assert result["mode"] == "story"


def test_campaign_setup_from_metadata_ignores_non_dict_value():
    assert _campaign_setup_from_metadata({"campaign_setup": "not_dict"}) == {}


# ── _metadata_with_campaign_setup ────────────────────────────────────

def test_metadata_with_campaign_setup_writes_campaign_setup():
    payload = StoryTemplateUpsertRequest(
        title="Test",
        summary="Sum",
        prompt_text="Prompt",
        setting="fantasy",
        tags=["fantasy"],
        is_public=True,
    )
    result = _metadata_with_campaign_setup(payload)
    assert result["campaign_setup"]["story_prompt"] == "Prompt"


def test_metadata_with_campaign_setup_includes_literary_genre():
    payload = StoryTemplateUpsertRequest(
        title="Test", summary="Sum", prompt_text="P",
        setting="fantasy", tags=["fantasy"], is_public=True,
        literary_genre="fantasyGenre",
    )
    result = _metadata_with_campaign_setup(payload)
    assert result["campaign_setup"]["literary_genre"] == "fantasyGenre"


def test_metadata_with_campaign_setup_includes_mode_and_difficulty():
    payload = StoryTemplateUpsertRequest(
        title="Test", summary="Sum", prompt_text="P",
        setting="fantasy", tags=["fantasy"], is_public=True,
        mode="longCampaign", difficulty="hard",
    )
    result = _metadata_with_campaign_setup(payload)
    assert result["campaign_setup"]["mode"] == "longCampaign"
    assert result["campaign_setup"]["difficulty"] == "hard"


def test_metadata_with_campaign_setup_preserves_existing_metadata():
    payload = StoryTemplateUpsertRequest(
        title="Test", summary="Sum", prompt_text="P",
        setting="fantasy", tags=["fantasy"], is_public=True,
        metadata={"cover_image_url": "https://x.com/img.png", "campaign_setup": {"old": "keep"}},
    )
    result = _metadata_with_campaign_setup(payload)
    assert "cover_image_url" in result
    assert "old" in result["campaign_setup"]


def test_metadata_with_campaign_setup_removes_empty_optional():
    payload = StoryTemplateUpsertRequest(
        title="Test", summary="Sum", prompt_text="P",
        setting="fantasy", tags=["fantasy"], is_public=True,
        literary_genre="",
    )
    result = _metadata_with_campaign_setup(payload)
    assert "campaign_setup" not in result or "literary_genre" not in result.get("campaign_setup", {})


# ── _serialize_one ───────────────────────────────────────────────────

def _make_template(**overrides):
    now = datetime.now(UTC)
    defaults = dict(
        id="t1", title="Test", summary="Sum", prompt_text="Prompt",
        setting="fantasy", literary_genre_slug="fantasyGenre",
        cover_image_data=None, cover_image_mime=None,
        cover_image_populated=False,
        is_public=True, is_master_curated=False,
        metadata_json={},
        author_user_id="au1",
        created_at=now, updated_at=now,
    )
    defaults.update(overrides)
    return SimpleNamespace(**defaults)


def test_serialize_one_basic():
    service = StoryLibraryService()
    template = _make_template()
    result = service._serialize_one(
        template,
        author_display_name="Tester",
        tags=["fantasy"],
        likes=5, views=20, bookmarked=True,
        api_prefix="/v1",
    )
    assert result.id == "t1"
    assert result.title == "Test"
    assert result.author_display_name == "Tester"
    assert result.tags == ["fantasy"]
    assert result.likes == 5
    assert result.views == 20
    assert result.bookmarked is True


def test_serialize_one_cover_href_when_populated():
    service = StoryLibraryService()
    template = _make_template(cover_image_populated=True)
    result = service._serialize_one(
        template, author_display_name=None,
        tags=[], likes=0, views=0, bookmarked=False, api_prefix="/v1",
    )
    assert result.cover_image_href == "/v1/story-templates/t1/cover"


def test_serialize_one_no_cover_when_not_populated():
    service = StoryLibraryService()
    template = _make_template(cover_image_populated=False)
    result = service._serialize_one(
        template, author_display_name=None,
        tags=[], likes=0, views=0, bookmarked=False, api_prefix="/v1",
    )
    assert result.cover_image_href is None


def test_serialize_one_extracts_campaign_setup():
    service = StoryLibraryService()
    template = _make_template(metadata_json={
        "campaign_setup": {
            "story_prompt": "Custom story",
            "character_prompt": "Brave knight",
            "mode": "campaign",
            "difficulty": "medium",
            "campaign_title": "Epic Journey",
            "objective_hint": "Find the grail",
        }
    })
    result = service._serialize_one(
        template, author_display_name="GM",
        tags=[], likes=0, views=0, bookmarked=False, api_prefix="/v1",
    )
    assert result.story_prompt == "Custom story"
    assert result.character_prompt == "Brave knight"
    assert result.mode == "campaign"
    assert result.difficulty == "medium"
    assert result.campaign_title == "Epic Journey"
    assert result.objective_hint == "Find the grail"


# ── toggle_like ──────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_toggle_like_adds_when_not_exists():
    service = StoryLibraryService()
    session = AsyncMock()
    session.scalar = AsyncMock(return_value=None)
    session.add = MagicMock()
    session.delete = MagicMock()

    await service.toggle_like(session, template_id="t1", user_id="u1")
    session.add.assert_called_once()
    session.delete.assert_not_called()


@pytest.mark.asyncio
async def test_toggle_like_removes_when_exists():
    service = StoryLibraryService()
    existing = SimpleNamespace(id="like1")
    session = AsyncMock()
    session.scalar = AsyncMock(return_value=existing)
    session.add = MagicMock()
    session.delete = AsyncMock()

    await service.toggle_like(session, template_id="t1", user_id="u1")
    session.add.assert_not_called()
    session.delete.assert_called_once_with(existing)


# ── toggle_bookmark ──────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_toggle_bookmark_adds_when_not_exists():
    service = StoryLibraryService()
    session = AsyncMock()
    session.scalar = AsyncMock(return_value=None)
    session.add = MagicMock()
    session.delete = MagicMock()

    await service.toggle_bookmark(session, template_id="t1", user_id="u1")
    session.add.assert_called_once()
    session.delete.assert_not_called()


@pytest.mark.asyncio
async def test_toggle_bookmark_removes_when_exists():
    service = StoryLibraryService()
    existing = SimpleNamespace(id="bm1")
    session = AsyncMock()
    session.scalar = AsyncMock(return_value=existing)
    session.add = MagicMock()
    session.delete = AsyncMock()

    await service.toggle_bookmark(session, template_id="t1", user_id="u1")
    session.add.assert_not_called()
    session.delete.assert_called_once_with(existing)


# ── add_view ─────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_add_view_creates_view_record():
    service = StoryLibraryService()
    session = AsyncMock()
    session.add = MagicMock()

    await service.add_view(session, template_id="t1", user_id="u1")
    session.add.assert_called_once()


@pytest.mark.asyncio
async def test_add_view_with_none_user():
    service = StoryLibraryService()
    session = AsyncMock()
    session.add = MagicMock()

    await service.add_view(session, template_id="t1", user_id=None)
    session.add.assert_called_once()


# ── delete_template ──────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_delete_template_returns_true_when_row_affected():
    service = StoryLibraryService()
    session = AsyncMock()
    mock_result = MagicMock()
    mock_result.rowcount = 1
    session.execute = AsyncMock(return_value=mock_result)

    result = await service.delete_template(session, template_id="t1")
    assert result is True


@pytest.mark.asyncio
async def test_delete_template_returns_false_when_no_rows():
    service = StoryLibraryService()
    session = AsyncMock()
    mock_result = MagicMock()
    mock_result.rowcount = 0
    session.execute = AsyncMock(return_value=mock_result)

    result = await service.delete_template(session, template_id="gone")
    assert result is False


# ── set_template_cover ───────────────────────────────────────────────

@pytest.mark.asyncio
async def test_set_template_cover_updates_template():
    service = StoryLibraryService()
    template = _make_template(cover_image_data=None, cover_image_populated=False)
    session = AsyncMock()
    session.get = AsyncMock(return_value=template)

    await service.set_template_cover(
        session, template_id="t1", data=b"image_bytes", mime="image/jpeg",
    )
    assert template.cover_image_data == b"image_bytes"
    assert template.cover_image_mime == "image/jpeg"
    assert template.cover_image_populated is True


@pytest.mark.asyncio
async def test_set_template_cover_raises_404_when_not_found():
    service = StoryLibraryService()
    session = AsyncMock()
    session.get = AsyncMock(return_value=None)

    from fastapi import HTTPException
    try:
        await service.set_template_cover(
            session, template_id="gone", data=b"x", mime="image/png",
        )
        assert False, "should raise"
    except HTTPException as e:
        assert e.status_code == 404


# ── clear_template_cover ─────────────────────────────────────────────

@pytest.mark.asyncio
async def test_clear_template_cover_nulls_cover_fields():
    service = StoryLibraryService()
    template = _make_template(
        cover_image_data=b"old", cover_image_mime="image/png", cover_image_populated=True,
    )
    session = AsyncMock()
    session.get = AsyncMock(return_value=template)

    await service.clear_template_cover(session, template_id="t1")
    assert template.cover_image_data is None
    assert template.cover_image_mime is None
    assert template.cover_image_populated is False


@pytest.mark.asyncio
async def test_clear_template_cover_raises_404_when_not_found():
    service = StoryLibraryService()
    session = AsyncMock()
    session.get = AsyncMock(return_value=None)

    from fastapi import HTTPException
    try:
        await service.clear_template_cover(session, template_id="gone")
        assert False, "should raise"
    except HTTPException as e:
        assert e.status_code == 404


# ── get_template ─────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_template_returns_none_when_not_found():
    service = StoryLibraryService()
    session = AsyncMock()
    session.get = AsyncMock(return_value=None)

    result = await service.get_template(session, template_id="gone", user_id="u1")
    assert result is None
