import asyncio
import time
from contextlib import asynccontextmanager
from datetime import UTC, datetime
import re

from fastapi import FastAPI, Query, Request
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, campaigns, dev, feedback, prompts, providers, stories
from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger
from app.db.init_db import init_db
from app.schemas.version import (
    VersionPlatformResponse,
    VersionPlatformsResponse,
    VersionResponse,
)
from app.services.embeddings import get_embedding_runtime_status, preload_embedding_service

settings = get_settings()
configure_logging(settings)
logger = get_logger("symmetry.app")
startup_runtime_status: dict[str, object] = {
    "phase": "booting",
    "ready": False,
    "startup_duration_ms": None,
}


@asynccontextmanager
async def lifespan(_: FastAPI):
    started_at = time.perf_counter()
    logger.info("starting_symmetry_api env=%s", settings.env)
    startup_runtime_status["phase"] = "database_check"
    try:
        await init_db()
        startup_runtime_status["phase"] = "embedding_preload"
        await asyncio.to_thread(preload_embedding_service)
        startup_duration_ms = int((time.perf_counter() - started_at) * 1000)
        startup_runtime_status["phase"] = "ready"
        startup_runtime_status["ready"] = True
        startup_runtime_status["startup_duration_ms"] = startup_duration_ms
        logger.info("symmetry_api_ready startup_duration_ms=%s", startup_duration_ms)
        yield
    except Exception:
        startup_runtime_status["phase"] = "failed"
        startup_runtime_status["ready"] = False
        logger.exception(
            "symmetry_api_startup_failed phase=%s",
            startup_runtime_status["phase"],
        )
        raise


app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=settings.cors_allow_origin_regex,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    started_at = time.perf_counter()
    origin = request.headers.get("origin", "")
    user_agent = request.headers.get("user-agent", "")
    if settings.dev_log_http:
        logger.info(
            "request_started method=%s path=%s origin=%s ua=%s",
            request.method,
            request.url.path,
            origin or "-",
            user_agent[:120] or "-",
        )
    try:
        response = await call_next(request)
    except Exception:
        logger.exception(
            "request_failed method=%s path=%s origin=%s",
            request.method,
            request.url.path,
            origin or "-",
        )
        raise

    duration_ms = int((time.perf_counter() - started_at) * 1000)
    if settings.dev_log_http:
        logger.info(
            "request_completed method=%s path=%s status=%s duration_ms=%s",
            request.method,
            request.url.path,
            response.status_code,
            duration_ms,
        )
    return response

app.include_router(auth.router, prefix=settings.api_prefix)
app.include_router(campaigns.router, prefix=settings.api_prefix)
app.include_router(dev.router, prefix=settings.api_prefix)
app.include_router(feedback.router, prefix=settings.api_prefix)
app.include_router(prompts.router, prefix=settings.api_prefix)
app.include_router(providers.router, prefix=settings.api_prefix)
app.include_router(stories.router, prefix=settings.api_prefix)


@app.get("/health")
async def health() -> dict[str, object]:
    return {
        "status": "ok" if startup_runtime_status["ready"] else "starting",
        "phase": startup_runtime_status["phase"],
        "ready": startup_runtime_status["ready"],
        "startup_duration_ms": startup_runtime_status["startup_duration_ms"],
        "embedding": get_embedding_runtime_status(),
    }


def _version_parts(value: str) -> tuple[int, ...]:
    parts = [int(item) for item in re.findall(r"\d+", value)]
    return tuple(parts or [0])


def _compare_versions(left: str, right: str) -> int:
    left_parts = _version_parts(left)
    right_parts = _version_parts(right)
    max_length = max(len(left_parts), len(right_parts))
    padded_left = left_parts + (0,) * (max_length - len(left_parts))
    padded_right = right_parts + (0,) * (max_length - len(right_parts))
    if padded_left < padded_right:
        return -1
    if padded_left > padded_right:
        return 1
    return 0


def _resolve_update_mode(
    *,
    current_version: str | None,
    minimum_supported_version: str,
    latest_version: str,
) -> str:
    if not current_version or not current_version.strip():
        return "none"
    if _compare_versions(current_version, minimum_supported_version) < 0:
        return "force"
    if _compare_versions(current_version, latest_version) < 0:
        return "soft"
    return "none"


@app.get("/version", response_model=VersionResponse)
async def version(
    current_version: str | None = Query(default=None),
    current_asset_version: str | None = Query(default=None),
) -> VersionResponse:
    web_update_mode = _resolve_update_mode(
        current_version=current_version,
        minimum_supported_version=settings.web_minimum_supported_version,
        latest_version=settings.web_latest_version,
    )
    desktop_update_mode = _resolve_update_mode(
        current_version=current_version,
        minimum_supported_version=settings.desktop_minimum_supported_version,
        latest_version=settings.desktop_latest_version,
    )
    web_reload_required = (
        current_asset_version.strip() != settings.web_asset_version.strip()
        if current_asset_version is not None and current_asset_version.strip()
        else None
    )

    return VersionResponse(
        api_version=settings.api_version,
        release_id=settings.release_id,
        released_at=settings.released_at or datetime.now(UTC).isoformat(),
        platforms=VersionPlatformsResponse(
            web=VersionPlatformResponse(
                latest_version=settings.web_latest_version,
                minimum_supported_version=settings.web_minimum_supported_version,
                update_mode=web_update_mode,
                message=settings.web_update_message,
                asset_version=settings.web_asset_version,
                reload_required=web_reload_required,
            ),
            desktop=VersionPlatformResponse(
                latest_version=settings.desktop_latest_version,
                minimum_supported_version=settings.desktop_minimum_supported_version,
                update_mode=desktop_update_mode,
                message=settings.desktop_update_message,
                update_url=settings.desktop_update_url or None,
            ),
        ),
    )
