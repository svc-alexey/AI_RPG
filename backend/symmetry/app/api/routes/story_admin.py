from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_admin_user
from app.db.models import StoryTemplate, User
from app.db.session import get_db_session
from app.schemas.common import MessageResponse
from app.schemas.stories import StoryTemplateResponse, StoryTemplateUpsertRequest
from app.services.cover_image_optimizer import optimize_story_cover
from app.services.story_library import StoryLibraryService

router = APIRouter(prefix="/admin/story-templates", tags=["admin-story-templates"])
story_service = StoryLibraryService()

_MAX_RAW_COVER_BYTES = 20 * 1024 * 1024
_MAX_STORED_COVER_BYTES = 2 * 1024 * 1024
_ALLOWED_COVER_MIME = frozenset(
    {"image/jpeg", "image/png", "image/webp", "image/gif"},
)


@router.get("", response_model=list[StoryTemplateResponse])
async def admin_list_story_templates(
    tag: str | None = Query(default=None),
    genre: str | None = Query(default=None),
    sort: str = Query(default="new"),
    user: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[StoryTemplateResponse]:
    return await story_service.list_all_templates(
        session, user_id=user.id, tag=tag, genre=genre, sort=sort
    )


@router.post("", response_model=StoryTemplateResponse)
async def admin_create_story_template(
    payload: StoryTemplateUpsertRequest,
    user: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> StoryTemplateResponse:
    template = await story_service.upsert_template(
        session,
        existing=None,
        payload=payload,
        user_id=user.id,
    )
    await session.commit()
    resolved = await story_service.get_template(
        session, template_id=template.id, user_id=user.id
    )
    if resolved is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="story_template_create_failed",
        )
    return resolved


@router.put("/{template_id}/cover", response_model=MessageResponse)
async def admin_put_story_template_cover(
    template_id: str,
    request: Request,
    _: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    template_id = template_id.strip()
    body = await request.body()
    if len(body) == 0:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="cover_body_empty",
        )
    if len(body) > _MAX_RAW_COVER_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="cover_too_large",
        )
    raw_mime = request.headers.get("content-type", "application/octet-stream")
    mime = raw_mime.split(";")[0].strip().lower()
    if mime not in _ALLOWED_COVER_MIME:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="invalid_cover_mime",
        )
    optimized_body, optimized_mime = optimize_story_cover(body, mime)
    if len(optimized_body) > _MAX_STORED_COVER_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="cover_too_large",
        )
    await story_service.set_template_cover(
        session,
        template_id=template_id,
        data=optimized_body,
        mime=optimized_mime,
    )
    await session.commit()
    return MessageResponse(message="cover_updated")


@router.delete("/{template_id}/cover", response_model=MessageResponse)
async def admin_delete_story_template_cover(
    template_id: str,
    _: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    await story_service.clear_template_cover(session, template_id=template_id)
    await session.commit()
    return MessageResponse(message="cover_removed")


@router.patch("/{template_id}", response_model=StoryTemplateResponse)
async def admin_update_story_template(
    template_id: str,
    payload: StoryTemplateUpsertRequest,
    user: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> StoryTemplateResponse:
    existing = await session.get(StoryTemplate, template_id)
    if existing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="story_template_not_found"
        )
    template = await story_service.upsert_template(
        session,
        existing=existing,
        payload=payload,
        user_id=existing.author_user_id,
    )
    await session.commit()
    resolved = await story_service.get_template(
        session, template_id=template.id, user_id=user.id
    )
    if resolved is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="story_template_update_failed",
        )
    return resolved


@router.delete("/{template_id}", response_model=MessageResponse)
async def admin_delete_story_template(
    template_id: str,
    user: User = Depends(get_current_admin_user),
    session: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    existing = await session.get(StoryTemplate, template_id)
    if existing is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="story_template_not_found"
        )
    ok = await story_service.delete_template(session, template_id=template_id)
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="story_template_not_found"
        )
    await session.commit()
    return MessageResponse(message="story_template_deleted")
