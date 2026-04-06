from time import perf_counter

from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.logging import get_logger
from app.db.models import WorldChronicle

logger = get_logger("symmetry.rag")


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
        started_at = perf_counter()
        ef_search = max(1, self._settings.rag_hnsw_ef_search)
        await session.execute(text(f"SET LOCAL hnsw.ef_search = {ef_search}"))
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
        items = list(result.scalars().all())
        duration_ms = int((perf_counter() - started_at) * 1000)
        logger.info(
            "rag_search_completed campaign_id=%s location=%s results=%s ef_search=%s top_k=%s duration_ms=%s",
            campaign_id,
            location_slug or "-",
            len(items),
            ef_search,
            max(1, self._settings.rag_top_k),
            duration_ms,
        )
        return items
