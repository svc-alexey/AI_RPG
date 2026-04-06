from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.models import WorldChronicle


class RagService:
    def __init__(self) -> None:
        self._settings = get_settings()

    async def search_relevant_events(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        location_slug: str,
        query_vector: list[float],
    ) -> list[WorldChronicle]:
        stmt = (
            select(WorldChronicle)
            .where(
                (WorldChronicle.campaign_id == campaign_id)
                | (WorldChronicle.campaign_id.is_(None))
            )
            .order_by(WorldChronicle.vector.cosine_distance(query_vector))
            .limit(max(1, self._settings.rag_top_k))
        )
        if location_slug.strip():
            stmt = stmt.where(
                (WorldChronicle.location_slug == location_slug)
                | (WorldChronicle.location_slug == "")
            )
        result = await session.execute(stmt)
        return list(result.scalars().all())
