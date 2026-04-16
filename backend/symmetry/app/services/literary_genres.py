from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import LiteraryGenre
from app.schemas.literary_genres import LiteraryGenreResponse


class LiteraryGenreService:
    async def list_genres(self, session: AsyncSession) -> list[LiteraryGenreResponse]:
        result = await session.execute(
            select(LiteraryGenre).order_by(LiteraryGenre.sort_order.asc(), LiteraryGenre.slug.asc())
        )
        rows = list(result.scalars().all())
        return [
            LiteraryGenreResponse(
                slug=item.slug,
                title_en=item.title_en,
                title_ru=item.title_ru,
                sort_order=item.sort_order,
            )
            for item in rows
        ]
