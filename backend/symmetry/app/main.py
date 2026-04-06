import asyncio
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import auth, campaigns, prompts, providers, stories
from app.core.config import get_settings
from app.core.logging import configure_logging, get_logger
from app.db.init_db import init_db
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
