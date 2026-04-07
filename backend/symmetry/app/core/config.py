from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="SYMMETRY_",
        extra="ignore",
    )

    env: str = "development"
    app_name: str = "Symmetry API"
    api_prefix: str = "/v1"
    cors_allow_origin_regex: str = r"https?://(localhost|127\.0\.0\.1)(:\d+)?$"
    log_level: str = "INFO"
    dev_log_http: bool = True
    dev_log_file: Path = Field(default=Path("logs/symmetry-dev.log"))

    database_url: str = (
        "postgresql+asyncpg://postgres:postgres@localhost:5432/symmetry"
    )

    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_ttl_minutes: int = 30
    refresh_token_ttl_days: int = 30

    server_llm_base_url: str = "https://api.deepseek.com/v1"
    server_llm_model: str = "deepseek-chat"
    server_llm_api_key: str = ""
    server_llm_timeout_seconds: int = 90

    embedding_model: str = "intfloat/multilingual-e5-base"
    embedding_backend: str = "onnx"
    embedding_model_file_name: str = "onnx/model.onnx"
    embedding_model_dir: Path = Field(default=Path("models"))
    embedding_batch_size: int = 32
    embedding_cache_size: int = 256
    embedding_cache_ttl_seconds: int = 300
    rag_top_k: int = 5
    rag_hnsw_ef_search: int = 40
    memory_importance_threshold: int = 7
    worker_poll_interval_seconds: float = 2.0
    worker_batch_size: int = 8

    yandex_client_id: str = ""
    yandex_client_secret: str = ""
    yandex_redirect_uri: str = "http://localhost:8080/v1/auth/yandex/callback"
    yandex_authorize_url: str = "https://oauth.yandex.ru/authorize"
    yandex_token_url: str = "https://oauth.yandex.ru/token"
    yandex_userinfo_url: str = "https://login.yandex.ru/info"


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    settings.embedding_model_dir.mkdir(parents=True, exist_ok=True)
    settings.dev_log_file.parent.mkdir(parents=True, exist_ok=True)
    return settings
