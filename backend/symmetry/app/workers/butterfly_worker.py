import asyncio
import time

from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger
from app.db.init_db import init_db
from app.db.session import SessionLocal
from app.services.butterfly import ButterflyService
from app.services.embeddings import preload_embedding_service


settings = get_settings()
configure_logging(settings)
logger = get_logger("symmetry.butterfly_worker")
butterfly_service = ButterflyService()


async def _run_loop() -> None:
    logger.info("butterfly_worker_starting env=%s", settings.env)
    await init_db()
    await asyncio.to_thread(preload_embedding_service)
    logger.info(
        "butterfly_worker_ready poll_interval=%s batch_size=%s",
        settings.worker_poll_interval_seconds,
        settings.worker_batch_size,
    )

    while True:
        started_at = time.perf_counter()
        processed = 0
        try:
            async with SessionLocal() as session:
                processed = await butterfly_service.process_ready_jobs(
                    session,
                    campaign_id=None,
                    limit=max(1, settings.worker_batch_size),
                )
                await session.commit()
        except Exception:
            logger.exception("butterfly_worker_cycle_failed")
        else:
            if processed > 0:
                duration_ms = int((time.perf_counter() - started_at) * 1000)
                logger.info(
                    "butterfly_worker_cycle_completed processed=%s duration_ms=%s",
                    processed,
                    duration_ms,
                )
        await asyncio.sleep(max(0.2, settings.worker_poll_interval_seconds))


def main() -> None:
    asyncio.run(_run_loop())


if __name__ == "__main__":
    main()
