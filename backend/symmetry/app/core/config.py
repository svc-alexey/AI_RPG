from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


APP_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=APP_ROOT / ".env",
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
    dev_admin_token: str = ""
    dev_usage_default_days: int = 7
    dev_usage_max_rows: int = 1000

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
    yandex_redirect_uri: str = "http://127.0.0.1:8080/v1/auth/yandex/callback"
    web_public_origin: str = "http://127.0.0.1:3010"
    yandex_oauth_state_ttl_seconds: int = 300
    yandex_oauth_handoff_ttl_seconds: int = 300
    yandex_authorize_url: str = "https://oauth.yandex.ru/authorize"
    yandex_token_url: str = "https://oauth.yandex.ru/token"
    yandex_userinfo_url: str = "https://login.yandex.ru/info"
    api_version: str = "2.0"
    release_id: str = "dev-local"
    released_at: str = "2026-04-07T00:00:00Z"
    web_latest_version: str = "1.0.0+1"
    web_minimum_supported_version: str = "1.0.0+1"
    web_asset_version: str = "dev-local"
    web_update_message: str = "A new web version is available."
    desktop_latest_version: str = "1.0.0+1"
    desktop_minimum_supported_version: str = "1.0.0+1"
    desktop_update_url: str = ""
    desktop_update_message: str = "A new desktop version is available."
    feedback_recipient_email: str = "a@svc-code.ru"
    feedback_sender_email: str = "a@svc-code.ru"
    feedback_email_subject_prefix: str = "Landing feedback"
    feedback_smtp_host: str = ""
    feedback_smtp_port: int = 465
    feedback_smtp_username: str = ""
    feedback_smtp_password: str = ""
    feedback_smtp_use_ssl: bool = True
    feedback_smtp_use_starttls: bool = False
    feedback_smtp_timeout_seconds: int = 20
    feedback_max_attachments: int = 5
    feedback_max_attachment_bytes: int = 5_000_000
    feedback_max_total_attachment_bytes: int = 15_000_000


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    settings.embedding_model_dir.mkdir(parents=True, exist_ok=True)
    settings.dev_log_file.parent.mkdir(parents=True, exist_ok=True)
    return settings
