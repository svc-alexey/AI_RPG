from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.responses import Response

from app.api.deps import get_current_user
from app.db.models import StoryTemplate, User
from app.db.session import get_db_session
from app.schemas.common import MessageResponse
from app.schemas.stories import StoryTemplateResponse
from app.services.story_library import StoryLibraryService

router = APIRouter(prefix="/story-templates", tags=["story-templates"])
story_service = StoryLibraryService()


@router.get("", response_model=list[StoryTemplateResponse])
async def list_story_templates(
    tag: str | None = Query(default=None),
    genre: str | None = Query(default=None),
    sort: str = Query(default="new"),
    scope: str = Query(default="all"),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[StoryTemplateResponse]:
    if scope not in ("all", "master", "community"):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="invalid_story_template_scope",
        )
    return await story_service.list_templates(
        session,
        user_id=user.id,
        tag=tag,
        genre=genre,
        sort=sort,
        scope=scope,
    )


@router.get("/{template_id}/cover")
async def get_story_template_cover(
    template_id: str,
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> Response:
    row = await session.execute(
        select(StoryTemplate.cover_image_data, StoryTemplate.cover_image_mime).where(
            StoryTemplate.id == template_id
        )
    )
    one = row.one_or_none()
    if one is None:
        raise HTTPException(status_code=404, detail="story_template_not_found")
    data, mime = one[0], one[1]
    if data is None or len(data) == 0:
        raise HTTPException(status_code=404, detail="story_template_cover_not_found")
    return Response(
        content=bytes(data),
        media_type=(mime or "application/octet-stream"),
    )


@router.get("/{template_id}", response_model=StoryTemplateResponse)
async def get_story_template(
    template_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> StoryTemplateResponse:
    template = await story_service.get_template(
        session,
        template_id=template_id,
        user_id=user.id,
    )
    if template is None:
        raise HTTPException(status_code=404, detail="story_template_not_found")
    return template


@router.post("/{template_id}/like", response_model=MessageResponse)
async def toggle_like(
    template_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await story_service.toggle_like(session, template_id=template_id, user_id=user.id)
    await session.commit()
    return MessageResponse(message="like_toggled")


@router.post("/{template_id}/view", response_model=MessageResponse)
async def add_view(
    template_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await story_service.add_view(session, template_id=template_id, user_id=user.id)
    await session.commit()
    return MessageResponse(message="view_recorded")


@router.post("/{template_id}/bookmark", response_model=MessageResponse)
async def toggle_bookmark(
    template_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await story_service.toggle_bookmark(session, template_id=template_id, user_id=user.id)
    await session.commit()
    return MessageResponse(message="bookmark_toggled")
