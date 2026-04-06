from collections import defaultdict

from sqlalchemy import Select, delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import (
    StoryTemplate,
    StoryTemplateBookmark,
    StoryTemplateLike,
    StoryTemplateTag,
    StoryTemplateTagLink,
    StoryTemplateView,
)
from app.schemas.stories import StoryTemplateResponse, StoryTemplateUpsertRequest
from app.services.ids import new_id


class StoryLibraryService:
    async def list_templates(
        self,
        session: AsyncSession,
        *,
        user_id: str,
        tag: str | None,
        sort: str,
    ) -> list[StoryTemplateResponse]:
        stmt: Select = select(StoryTemplate).where(
            (StoryTemplate.author_user_id == user_id) | (StoryTemplate.is_public.is_(True))
        )
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
        self, session: AsyncSession, *, template_id: str, user_id: str
    ) -> StoryTemplateResponse | None:
        template = await session.get(StoryTemplate, template_id)
        if template is None:
            return None
        if template.author_user_id != user_id and not template.is_public:
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
            is_public=payload.is_public,
            metadata_json=payload.metadata,
        )
        template.title = payload.title.strip()
        template.summary = payload.summary.strip()
        template.prompt_text = payload.prompt_text.strip()
        template.setting = payload.setting.strip()
        template.is_public = payload.is_public
        template.metadata_json = payload.metadata
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
        return template

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
        user_id: str,
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
        bookmark_rows = await session.execute(
            select(StoryTemplateBookmark.story_template_id)
            .where(
                StoryTemplateBookmark.story_template_id.in_(ids),
                StoryTemplateBookmark.user_id == user_id,
            )
        )

        tags_by_story: dict[str, list[str]] = defaultdict(list)
        for story_id, slug in tag_rows.all():
            tags_by_story[story_id].append(slug)

        likes = {story_id: count for story_id, count in like_rows.all()}
        views = {story_id: count for story_id, count in view_rows.all()}
        bookmarked = {story_id for (story_id,) in bookmark_rows.all()}

        responses = [
            StoryTemplateResponse(
                id=item.id,
                title=item.title,
                summary=item.summary,
                prompt_text=item.prompt_text,
                setting=item.setting,
                is_public=item.is_public,
                tags=sorted(tags_by_story[item.id]),
                likes=int(likes.get(item.id, 0)),
                views=int(views.get(item.id, 0)),
                bookmarked=item.id in bookmarked,
                created_at=item.created_at,
                updated_at=item.updated_at,
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
