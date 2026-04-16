from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db_session
from app.schemas.literary_genres import LiteraryGenreResponse
from app.services.literary_genres import LiteraryGenreService

router = APIRouter(prefix="/literary-genres", tags=["literary-genres"])
_genre_service = LiteraryGenreService()


@router.get("", response_model=list[LiteraryGenreResponse])
async def list_literary_genres(
    session: AsyncSession = Depends(get_db_session),
) -> list[LiteraryGenreResponse]:
    return await _genre_service.list_genres(session)
