from collections import OrderedDict
from dataclasses import dataclass
from functools import lru_cache
from hashlib import sha256
from time import monotonic, perf_counter

from sentence_transformers import SentenceTransformer

from app.core.config import get_settings
from app.core.logging import get_logger

logger = get_logger("symmetry.embeddings")

_embedding_runtime_status: dict[str, object] = {
    "ready": False,
    "phase": "idle",
    "model": get_settings().embedding_model,
    "backend": get_settings().embedding_backend,
    "cache_dir": str(get_settings().embedding_model_dir),
    "cache_entries": 0,
    "cache_hits": 0,
    "cache_misses": 0,
    "cache_ttl_seconds": get_settings().embedding_cache_ttl_seconds,
    "vector_dimension": None,
    "startup_duration_ms": None,
}


@dataclass(slots=True)
class _CacheEntry:
    vector: tuple[float, ...]
    expires_at: float


class EmbeddingService:
    def __init__(self) -> None:
        settings = get_settings()
        self._model_name = settings.embedding_model
        self._backend = settings.embedding_backend.strip() or "torch"
        self._model_file_name = settings.embedding_model_file_name.strip()
        self._cache_dir = str(settings.embedding_model_dir)
        self._batch_size = max(1, settings.embedding_batch_size)
        self._cache_size = max(0, settings.embedding_cache_size)
        self._cache_ttl_seconds = max(0, settings.embedding_cache_ttl_seconds)
        self._query_cache: OrderedDict[str, _CacheEntry] = OrderedDict()
        self._cache_hits = 0
        self._cache_misses = 0
        self._vector_dimension: int | None = None
        model_kwargs: dict[str, object] = {}
        if self._model_file_name:
            model_kwargs["file_name"] = self._model_file_name
        transformer_kwargs: dict[str, object] = {
            "cache_folder": str(settings.embedding_model_dir),
            "backend": self._backend,
        }
        if model_kwargs:
            transformer_kwargs["model_kwargs"] = model_kwargs
        self._model = SentenceTransformer(
            settings.embedding_model,
            **transformer_kwargs,
        )

    def encode_query(self, text: str) -> list[float]:
        prepared = self._prepare(text, prefix="query")
        cached = self._get_cached_query(prepared)
        if cached is not None:
            return cached

        self._cache_misses += 1
        logger.info(
            "embedding_cache_miss kind=query key=%s cache_entries=%s",
            self._cache_key(prepared),
            len(self._query_cache),
        )
        vector = self._encode_prepared(prepared, kind="query", cache_state="miss")
        self._store_cached_query(prepared, vector)
        return vector

    def encode_document(self, text: str) -> list[float]:
        prepared = self._prepare(text, prefix="passage")
        return self._encode_prepared(prepared, kind="document", cache_state="bypass")

    def warmup(self) -> None:
        self._encode_prepared(self._prepare("warmup", prefix="query"), kind="query", cache_state="warmup")
        self._encode_prepared(
            self._prepare("warmup", prefix="passage"),
            kind="document",
            cache_state="warmup",
        )

    @property
    def model_name(self) -> str:
        return self._model_name

    @property
    def backend(self) -> str:
        return self._backend

    @property
    def cache_dir(self) -> str:
        return self._cache_dir

    def runtime_state(self) -> dict[str, object]:
        return {
            "model": self._model_name,
            "backend": self._backend,
            "cache_dir": self._cache_dir,
            "cache_entries": len(self._query_cache),
            "cache_hits": self._cache_hits,
            "cache_misses": self._cache_misses,
            "cache_ttl_seconds": self._cache_ttl_seconds,
            "vector_dimension": self._vector_dimension,
        }

    @staticmethod
    def _prepare(text: str, *, prefix: str) -> str:
        cleaned = " ".join(text.split()).strip()
        return f"{prefix}: {cleaned}" if cleaned else f"{prefix}: empty"

    @staticmethod
    def _cache_key(text: str) -> str:
        return sha256(text.encode("utf-8")).hexdigest()[:12]

    def _get_cached_query(self, prepared: str) -> list[float] | None:
        if self._cache_size <= 0 or self._cache_ttl_seconds <= 0:
            return None

        cached = self._query_cache.get(prepared)
        now = monotonic()
        if cached is None:
            return None
        if cached.expires_at <= now:
            self._query_cache.pop(prepared, None)
            return None

        self._cache_hits += 1
        self._query_cache.move_to_end(prepared)
        logger.info(
            "embedding_cache_hit kind=query key=%s cache_entries=%s",
            self._cache_key(prepared),
            len(self._query_cache),
        )
        return list(cached.vector)

    def _store_cached_query(self, prepared: str, vector: list[float]) -> None:
        if self._cache_size <= 0 or self._cache_ttl_seconds <= 0:
            return

        now = monotonic()
        expired_keys = [
            key for key, entry in self._query_cache.items() if entry.expires_at <= now
        ]
        for key in expired_keys:
            self._query_cache.pop(key, None)

        self._query_cache[prepared] = _CacheEntry(
            vector=tuple(vector),
            expires_at=now + self._cache_ttl_seconds,
        )
        self._query_cache.move_to_end(prepared)
        while len(self._query_cache) > self._cache_size:
            self._query_cache.popitem(last=False)

    def _encode_prepared(
        self,
        prepared: str,
        *,
        kind: str,
        cache_state: str,
    ) -> list[float]:
        started_at = perf_counter()
        vector = self._model.encode(
            [prepared],
            batch_size=self._batch_size,
            normalize_embeddings=True,
        )[0]
        encoded = [float(item) for item in vector.tolist()]
        self._vector_dimension = len(encoded)
        duration_ms = int((perf_counter() - started_at) * 1000)
        logger.info(
            "embedding_encode_completed kind=%s cache=%s duration_ms=%s dimension=%s",
            kind,
            cache_state,
            duration_ms,
            self._vector_dimension,
        )
        return encoded


@lru_cache
def get_embedding_service() -> EmbeddingService:
    return EmbeddingService()


def preload_embedding_service() -> EmbeddingService:
    started_at = perf_counter()
    _embedding_runtime_status["phase"] = "loading"
    logger.info(
        "embedding_preload_started model=%s backend=%s cache_dir=%s",
        _embedding_runtime_status["model"],
        _embedding_runtime_status["backend"],
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
    _embedding_runtime_status.update(service.runtime_state())
    logger.info(
        "embedding_preload_completed model=%s backend=%s cache_dir=%s duration_ms=%s dimension=%s",
        service.model_name,
        service.backend,
        service.cache_dir,
        duration_ms,
        _embedding_runtime_status["vector_dimension"],
    )
    return service


def get_embedding_runtime_status() -> dict[str, object]:
    if _embedding_runtime_status["ready"] and get_embedding_service.cache_info().currsize:
        _embedding_runtime_status.update(get_embedding_service().runtime_state())
    return dict(_embedding_runtime_status)
