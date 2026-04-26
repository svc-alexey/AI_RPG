from collections import defaultdict
from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import Select, delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import defer

from app.db.models import (
    LiteraryGenre,
    StoryTemplate,
    StoryTemplateBookmark,
    StoryTemplateLike,
    StoryTemplateTag,
    StoryTemplateTagLink,
    StoryTemplateView,
    User,
    UserProfile,
)
from app.core.config import get_settings
from app.schemas.stories import StoryTemplateResponse, StoryTemplateUpsertRequest
from app.services.ids import new_id

_CAMPAIGN_SETUP_METADATA_KEY = "campaign_setup"


class StoryLibraryService:
    async def list_templates(
        self,
        session: AsyncSession,
        *,
        user_id: str | None,
        tag: str | None,
        genre: str | None,
        sort: str,
        scope: str = "all",
    ) -> list[StoryTemplateResponse]:
        stmt: Select = select(StoryTemplate).options(
            defer(StoryTemplate.cover_image_data),
        )
        if scope == "master":
            stmt = stmt.where(StoryTemplate.is_master_curated.is_(True))
        elif scope == "community":
            stmt = stmt.where(StoryTemplate.is_master_curated.is_(False))
        if genre and genre.strip():
            stmt = stmt.where(StoryTemplate.literary_genre_slug == genre.strip())
        if tag:
            stmt = stmt.join(
                StoryTemplateTagLink,
                StoryTemplateTagLink.story_template_id == StoryTemplate.id,
            ).join(
                StoryTemplateTag,
                StoryTemplateTag.id == StoryTemplateTagLink.tag_id,
            ).where(StoryTemplateTag.slug == tag)

        result = await session.execute(stmt)
        templates = list(result.scalars().all())
        return await self._serialize_many(session, templates, user_id=user_id, sort=sort)

    async def list_all_templates(
        self,
        session: AsyncSession,
        *,
        user_id: str | None,
        tag: str | None,
        genre: str | None,
        sort: str,
    ) -> list[StoryTemplateResponse]:
        stmt: Select = select(StoryTemplate).options(
            defer(StoryTemplate.cover_image_data),
        )
        if genre and genre.strip():
            stmt = stmt.where(StoryTemplate.literary_genre_slug == genre.strip())
        if tag:
            stmt = stmt.join(
                StoryTemplateTagLink,
                StoryTemplateTagLink.story_template_id == StoryTemplate.id,
            ).join(
                StoryTemplateTag,
                StoryTemplateTag.id == StoryTemplateTagLink.tag_id,
            ).where(StoryTemplateTag.slug == tag)
        result = await session.execute(stmt)
        templates = list(result.scalars().all())
        return await self._serialize_many(session, templates, user_id=user_id, sort=sort)

    async def get_template(
        self, session: AsyncSession, *, template_id: str, user_id: str | None
    ) -> StoryTemplateResponse | None:
        template = await session.get(
            StoryTemplate,
            template_id,
            options=[defer(StoryTemplate.cover_image_data)],
        )
        if template is None:
            return None
        items = await self._serialize_many(session, [template], user_id=user_id, sort="new")
        return items[0]

    async def upsert_template(
        self,
        session: AsyncSession,
        *,
        existing: StoryTemplate | None,
        payload: StoryTemplateUpsertRequest,
        user_id: str,
    ) -> StoryTemplate:
        template = existing or StoryTemplate(
            id=new_id(),
            author_user_id=user_id,
            title=payload.title.strip(),
            summary=payload.summary.strip(),
            prompt_text=payload.prompt_text.strip(),
            setting=payload.setting.strip(),
            literary_genre_slug=None,
            is_public=payload.is_public,
            is_master_curated=False,
            metadata_json=payload.metadata,
        )
        template.title = payload.title.strip()
        template.summary = payload.summary.strip()
        template.prompt_text = payload.prompt_text.strip()
        template.setting = payload.setting.strip()
        template.is_public = payload.is_public
        template.metadata_json = _metadata_with_campaign_setup(payload)
        await self._apply_literary_genre_slug(session, template, payload.literary_genre_slug)
        session.add(template)
        await session.flush()
        await session.execute(
            delete(StoryTemplateTagLink).where(
                StoryTemplateTagLink.story_template_id == template.id
            )
        )
        for tag in payload.tags:
            slug = tag.strip().lower()
            if not slug:
                continue
            tag_row = await session.scalar(
                select(StoryTemplateTag).where(StoryTemplateTag.slug == slug)
            )
            if tag_row is None:
                tag_row = StoryTemplateTag(id=new_id(), slug=slug, title=tag.strip())
                session.add(tag_row)
                await session.flush()
            session.add(
                StoryTemplateTagLink(
                    id=new_id(),
                    story_template_id=template.id,
                    tag_id=tag_row.id,
                )
            )
        if payload.is_master_curated is not None:
            template.is_master_curated = payload.is_master_curated
        return template

    async def _apply_literary_genre_slug(
        self,
        session: AsyncSession,
        template: StoryTemplate,
        raw_slug: str | None,
    ) -> None:
        if raw_slug is None or not str(raw_slug).strip():
            template.literary_genre_slug = None
            return
        slug = str(raw_slug).strip()
        genre_row = await session.get(LiteraryGenre, slug)
        if genre_row is None:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="invalid_literary_genre_slug",
            )
        template.literary_genre_slug = slug

    async def delete_template(self, session: AsyncSession, *, template_id: str) -> bool:
        result = await session.execute(
            delete(StoryTemplate).where(StoryTemplate.id == template_id)
        )
        return (result.rowcount or 0) > 0

    async def set_template_cover(
        self,
        session: AsyncSession,
        *,
        template_id: str,
        data: bytes,
        mime: str,
    ) -> None:
        tid = template_id.strip()
        template = await session.get(StoryTemplate, tid)
        if template is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="story_template_not_found",
            )
        md = dict(template.metadata_json or {})
        md.pop("cover_image_url", None)
        template.metadata_json = md
        template.cover_image_data = data
        template.cover_image_mime = (
            (mime or "").strip().lower()[:128] or "application/octet-stream"
        )
        template.cover_image_populated = True
        template.updated_at = datetime.now(UTC)

    async def clear_template_cover(
        self, session: AsyncSession, *, template_id: str
    ) -> None:
        tid = template_id.strip()
        template = await session.get(StoryTemplate, tid)
        if template is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="story_template_not_found",
            )
        template.cover_image_data = None
        template.cover_image_mime = None
        template.cover_image_populated = False
        template.updated_at = datetime.now(UTC)

    async def toggle_like(
        self, session: AsyncSession, *, template_id: str, user_id: str
    ) -> None:
        existing = await session.scalar(
            select(StoryTemplateLike).where(
                StoryTemplateLike.story_template_id == template_id,
                StoryTemplateLike.user_id == user_id,
            )
        )
        if existing is None:
            session.add(
                StoryTemplateLike(
                    id=new_id(),
                    story_template_id=template_id,
                    user_id=user_id,
                )
            )
            return
        await session.delete(existing)

    async def add_view(
        self, session: AsyncSession, *, template_id: str, user_id: str | None
    ) -> None:
        session.add(
            StoryTemplateView(
                id=new_id(),
                story_template_id=template_id,
                user_id=user_id,
            )
        )

    async def toggle_bookmark(
        self, session: AsyncSession, *, template_id: str, user_id: str
    ) -> None:
        existing = await session.scalar(
            select(StoryTemplateBookmark).where(
                StoryTemplateBookmark.story_template_id == template_id,
                StoryTemplateBookmark.user_id == user_id,
            )
        )
        if existing is None:
            session.add(
                StoryTemplateBookmark(
                    id=new_id(),
                    story_template_id=template_id,
                    user_id=user_id,
                )
            )
            return
        await session.delete(existing)

    async def _serialize_many(
        self,
        session: AsyncSession,
        templates: list[StoryTemplate],
        *,
        user_id: str | None,
        sort: str,
    ) -> list[StoryTemplateResponse]:
        if not templates:
            return []

        ids = [item.id for item in templates]
        tag_rows = await session.execute(
            select(StoryTemplateTagLink.story_template_id, StoryTemplateTag.slug)
            .join(StoryTemplateTag, StoryTemplateTag.id == StoryTemplateTagLink.tag_id)
            .where(StoryTemplateTagLink.story_template_id.in_(ids))
        )
        like_rows = await session.execute(
            select(StoryTemplateLike.story_template_id, func.count(StoryTemplateLike.id))
            .where(StoryTemplateLike.story_template_id.in_(ids))
            .group_by(StoryTemplateLike.story_template_id)
        )
        view_rows = await session.execute(
            select(StoryTemplateView.story_template_id, func.count(StoryTemplateView.id))
            .where(StoryTemplateView.story_template_id.in_(ids))
            .group_by(StoryTemplateView.story_template_id)
        )
        bookmark_rows = None
        if user_id is not None:
            bookmark_rows = await session.execute(
                select(StoryTemplateBookmark.story_template_id).where(
                    StoryTemplateBookmark.story_template_id.in_(ids),
                    StoryTemplateBookmark.user_id == user_id,
                )
            )

        tags_by_story: dict[str, list[str]] = defaultdict(list)
        for story_id, slug in tag_rows.all():
            tags_by_story[story_id].append(slug)

        likes = {story_id: count for story_id, count in like_rows.all()}
        views = {story_id: count for story_id, count in view_rows.all()}
        bookmarked = (
            {story_id for (story_id,) in bookmark_rows.all()}
            if bookmark_rows is not None
            else set()
        )

        settings = get_settings()
        api_prefix = settings.api_prefix
        author_ids = list({item.author_user_id for item in templates})
        author_labels: dict[str, str | None] = {aid: None for aid in author_ids}
        if author_ids:
            user_rows = await session.execute(
                select(User.id, User.email).where(User.id.in_(author_ids))
            )
            emails = {row[0]: row[1] for row in user_rows.all()}
            profile_rows = await session.execute(
                select(UserProfile.user_id, UserProfile.display_name).where(
                    UserProfile.user_id.in_(author_ids)
                )
            )
            display = {row[0]: (row[1] or "").strip() for row in profile_rows.all()}
            for aid in author_ids:
                name = display.get(aid, "")
                author_labels[aid] = name if name else emails.get(aid)

        responses = [
            self._serialize_one(
                item,
                author_display_name=author_labels.get(item.author_user_id),
                tags=sorted(tags_by_story[item.id]),
                likes=int(likes.get(item.id, 0)),
                views=int(views.get(item.id, 0)),
                bookmarked=item.id in bookmarked,
                api_prefix=api_prefix,
            )
            for item in templates
        ]

        if sort == "popular":
            responses.sort(key=lambda item: (item.likes, item.views, item.created_at), reverse=True)
        elif sort == "liked":
            responses.sort(key=lambda item: (item.likes, item.created_at), reverse=True)
        elif sort == "viewed":
            responses.sort(key=lambda item: (item.views, item.created_at), reverse=True)
        else:
            responses.sort(key=lambda item: item.created_at, reverse=True)
        return responses

    def _serialize_one(
        self,
        item: StoryTemplate,
        *,
        author_display_name: str | None,
        tags: list[str],
        likes: int,
        views: int,
        bookmarked: bool,
        api_prefix: str,
    ) -> StoryTemplateResponse:
        metadata = dict(item.metadata_json or {})
        campaign_setup = _campaign_setup_from_metadata(metadata)
        story_prompt = (
            _optional_text(campaign_setup.get("story_prompt")) or item.prompt_text
        )
        character = campaign_setup.get("character")
        return StoryTemplateResponse(
            id=item.id,
            title=item.title,
            summary=item.summary,
            prompt_text=item.prompt_text,
            setting=item.setting,
            literary_genre_slug=item.literary_genre_slug,
            literary_genre=_optional_text(campaign_setup.get("literary_genre")),
            mode=_optional_text(campaign_setup.get("mode")),
            difficulty=_optional_text(campaign_setup.get("difficulty")),
            story_prompt=story_prompt,
            character_prompt=_optional_text(campaign_setup.get("character_prompt")),
            campaign_title=_optional_text(campaign_setup.get("campaign_title")),
            objective_hint=_optional_text(campaign_setup.get("objective_hint")),
            character=character if isinstance(character, dict) else None,
            cover_image_href=(
                f"{api_prefix}/story-templates/{item.id}/cover"
                if item.cover_image_populated
                else None
            ),
            is_public=item.is_public,
            is_master_curated=item.is_master_curated,
            metadata=metadata,
            author_display_name=author_display_name,
            tags=tags,
            likes=likes,
            views=views,
            bookmarked=bookmarked,
            created_at=item.created_at,
            updated_at=item.updated_at,
        )


def _metadata_with_campaign_setup(payload: StoryTemplateUpsertRequest) -> dict:
    metadata = dict(payload.metadata or {})
    setup = _campaign_setup_from_metadata(metadata)

    def set_optional(key: str, value: str | None) -> None:
        normalized = (value or "").strip()
        if normalized:
            setup[key] = normalized
        else:
            setup.pop(key, None)

    set_optional("literary_genre", payload.literary_genre)
    set_optional("mode", payload.mode)
    set_optional("difficulty", payload.difficulty)
    set_optional("story_prompt", payload.story_prompt or payload.prompt_text)
    set_optional("character_prompt", payload.character_prompt)
    set_optional("campaign_title", payload.campaign_title)
    set_optional("objective_hint", payload.objective_hint)
    if payload.character is not None:
        setup["character"] = payload.character.model_dump(mode="json")
    else:
        setup.pop("character", None)

    if setup:
        metadata[_CAMPAIGN_SETUP_METADATA_KEY] = setup
    else:
        metadata.pop(_CAMPAIGN_SETUP_METADATA_KEY, None)
    return metadata


def _campaign_setup_from_metadata(metadata: dict) -> dict:
    raw = metadata.get(_CAMPAIGN_SETUP_METADATA_KEY)
    if isinstance(raw, dict):
        return dict(raw)
    return {}


def _optional_text(value: object) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None
