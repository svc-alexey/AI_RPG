from time import perf_counter

from sqlalchemy import desc, select, text
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
        top_k = max(1, self._settings.rag_top_k)
        candidate_limit = max(top_k * 3, top_k + 2)
        await session.execute(text(f"SET LOCAL hnsw.ef_search = {ef_search}"))
        distance_expr = WorldChronicle.vector.cosine_distance(query_vector).label("distance")
        base_stmt = (
            select(WorldChronicle, distance_expr)
            .where(
                (
                    (WorldChronicle.campaign_id == campaign_id)
                    | (WorldChronicle.campaign_id.is_(None))
                ),
                WorldChronicle.vector.is_not(None),
            )
            .order_by(
                distance_expr,
                desc(WorldChronicle.importance),
                desc(WorldChronicle.created_at),
            )
        )
        local_items: list[WorldChronicle] = []
        normalized_location = location_slug.strip()
        if normalized_location:
            local_stmt = (
                base_stmt.where(
                    (WorldChronicle.location_slug == normalized_location)
                    | (WorldChronicle.location_slug == "")
                )
                .limit(top_k)
            )
            local_result = await session.execute(local_stmt)
            local_items = [row[0] for row in local_result.all()]

        global_result = await session.execute(base_stmt.limit(candidate_limit))
        global_items = [row[0] for row in global_result.all()]

        items: list[WorldChronicle] = []
        seen_ids: set[str] = set()

        def _extend(source: list[WorldChronicle], *, maximum: int, same_location_only: bool | None = None) -> None:
            for entry in source:
                if entry.id in seen_ids:
                    continue
                if same_location_only is True and entry.location_slug not in {normalized_location, ""}:
                    continue
                if same_location_only is False and entry.location_slug == normalized_location:
                    continue
                seen_ids.add(entry.id)
                items.append(entry)
                if len(items) >= maximum:
                    return

        if normalized_location:
            local_quota = min(len(local_items), max(1, min(top_k - 1, (top_k + 1) // 2)))
            _extend(local_items, maximum=local_quota, same_location_only=True)
            _extend(global_items, maximum=top_k, same_location_only=False)
            _extend(local_items, maximum=top_k)
        _extend(global_items, maximum=top_k)

        duration_ms = int((perf_counter() - started_at) * 1000)
        logger.info(
            "rag_search_completed campaign_id=%s location=%s results=%s local_candidates=%s global_candidates=%s ef_search=%s top_k=%s duration_ms=%s",
            campaign_id,
            location_slug or "-",
            len(items),
            len(local_items),
            len(global_items),
            ef_search,
            top_k,
            duration_ms,
        )
        return items
