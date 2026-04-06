from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import StoryTemplate, User
from app.db.session import get_db_session
from app.schemas.common import MessageResponse
from app.schemas.stories import StoryTemplateResponse, StoryTemplateUpsertRequest
from app.services.story_library import StoryLibraryService

router = APIRouter(prefix="/story-templates", tags=["story-templates"])
story_service = StoryLibraryService()


@router.get("", response_model=list[StoryTemplateResponse])
async def list_story_templates(
    tag: str | None = Query(default=None),
    sort: str = Query(default="new"),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[StoryTemplateResponse]:
    return await story_service.list_templates(session, user_id=user.id, tag=tag, sort=sort)


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


@router.post("", response_model=StoryTemplateResponse)
async def create_story_template(
    payload: StoryTemplateUpsertRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> StoryTemplateResponse:
    template = await story_service.upsert_template(
        session,
        existing=None,
        payload=payload,
        user_id=user.id,
    )
    await session.commit()
    resolved = await story_service.get_template(session, template_id=template.id, user_id=user.id)
    assert resolved is not None
    return resolved


@router.patch("/{template_id}", response_model=StoryTemplateResponse)
async def update_story_template(
    template_id: str,
    payload: StoryTemplateUpsertRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> StoryTemplateResponse:
    existing = await session.get(StoryTemplate, template_id)
    if existing is None or existing.author_user_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="story_template_not_found")
    template = await story_service.upsert_template(
        session,
        existing=existing,
        payload=payload,
        user_id=user.id,
    )
    await session.commit()
    resolved = await story_service.get_template(session, template_id=template.id, user_id=user.id)
    assert resolved is not None
    return resolved


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
