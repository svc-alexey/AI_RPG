from pathlib import Path

from app.core.config import Settings


def test_settings_load_from_env_file(tmp_path: Path):
    env_file = tmp_path / ".env"
    env_file.write_text(
        "SYMMETRY_SERVER_LLM_MODEL=file-model\n"
        "SYMMETRY_WEB_LATEST_VERSION=2.4.0\n",
        encoding="utf-8",
    )

    settings = Settings(_env_file=env_file)

    assert settings.server_llm_model == "file-model"
    assert settings.web_latest_version == "2.4.0"


def test_env_overrides_file(monkeypatch, tmp_path: Path):
    env_file = tmp_path / ".env"
    env_file.write_text(
        "SYMMETRY_SERVER_LLM_MODEL=file-model\n",
        encoding="utf-8",
    )
    monkeypatch.setenv("SYMMETRY_SERVER_LLM_MODEL", "env-model")

    settings = Settings(_env_file=env_file)

    assert settings.server_llm_model == "env-model"


def test_dev_admin_settings_load_from_env_file(tmp_path: Path):
    env_file = tmp_path / ".env"
    env_file.write_text(
        "SYMMETRY_DEV_ADMIN_TOKEN=secret-dev-token\n"
        "SYMMETRY_DEV_USAGE_DEFAULT_DAYS=14\n",
        encoding="utf-8",
    )

    settings = Settings(_env_file=env_file)

    assert settings.dev_admin_token == "secret-dev-token"
    assert settings.dev_usage_default_days == 14
