from functools import lru_cache
from time import perf_counter

from sentence_transformers import SentenceTransformer

from app.core.config import get_settings
from app.core.logging import get_logger

logger = get_logger("symmetry.embeddings")

_embedding_runtime_status: dict[str, object] = {
    "ready": False,
    "phase": "idle",
    "model": get_settings().embedding_model,
    "cache_dir": str(get_settings().embedding_model_dir),
    "startup_duration_ms": None,
}


class EmbeddingService:
    def __init__(self) -> None:
        settings = get_settings()
        self._model_name = settings.embedding_model
        self._cache_dir = str(settings.embedding_model_dir)
        self._model = SentenceTransformer(
            settings.embedding_model,
            cache_folder=str(settings.embedding_model_dir),
        )

    def encode(self, text: str) -> list[float]:
        vector = self._model.encode(
            [self._prepare(text)],
            normalize_embeddings=True,
        )[0]
        return [float(item) for item in vector.tolist()]

    def warmup(self) -> None:
        self.encode("warmup")

    @property
    def model_name(self) -> str:
        return self._model_name

    @property
    def cache_dir(self) -> str:
        return self._cache_dir

    @staticmethod
    def _prepare(text: str) -> str:
        cleaned = " ".join(text.split()).strip()
        return f"query: {cleaned}" if cleaned else "query: empty"


@lru_cache
def get_embedding_service() -> EmbeddingService:
    return EmbeddingService()


def preload_embedding_service() -> EmbeddingService:
    started_at = perf_counter()
    _embedding_runtime_status["phase"] = "loading"
    logger.info(
        "embedding_preload_started model=%s cache_dir=%s",
        _embedding_runtime_status["model"],
        _embedding_runtime_status["cache_dir"],
    )
    try:
        service = get_embedding_service()
        service.warmup()
    except Exception:
        _embedding_runtime_status["phase"] = "failed"
        _embedding_runtime_status["ready"] = False
        logger.exception("embedding_preload_failed")
        raise

    duration_ms = int((perf_counter() - started_at) * 1000)
    _embedding_runtime_status["phase"] = "ready"
    _embedding_runtime_status["ready"] = True
    _embedding_runtime_status["startup_duration_ms"] = duration_ms
    _embedding_runtime_status["model"] = service.model_name
    _embedding_runtime_status["cache_dir"] = service.cache_dir
    logger.info(
        "embedding_preload_completed model=%s cache_dir=%s duration_ms=%s",
        service.model_name,
        service.cache_dir,
        duration_ms,
    )
    return service


def get_embedding_runtime_status() -> dict[str, object]:
    return dict(_embedding_runtime_status)
