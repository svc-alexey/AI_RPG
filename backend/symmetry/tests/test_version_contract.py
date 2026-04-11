import pytest

import app.main as main_module


@pytest.mark.asyncio
async def test_version_endpoint_returns_platform_contract(monkeypatch):
    monkeypatch.setattr(main_module.settings, "api_version", "2.0", raising=False)
    monkeypatch.setattr(main_module.settings, "release_id", "release-42", raising=False)
    monkeypatch.setattr(
        main_module.settings,
        "released_at",
        "2026-04-07T12:00:00Z",
        raising=False,
    )
    monkeypatch.setattr(main_module.settings, "web_latest_version", "1.2.0", raising=False)
    monkeypatch.setattr(
        main_module.settings,
        "web_minimum_supported_version",
        "1.1.0",
        raising=False,
    )
    monkeypatch.setattr(
        main_module.settings,
        "web_asset_version",
        "asset-42",
        raising=False,
    )
    monkeypatch.setattr(
        main_module.settings,
        "web_update_message",
        "Reload to continue.",
        raising=False,
    )
    monkeypatch.setattr(
        main_module.settings,
        "desktop_latest_version",
        "2.0.0",
        raising=False,
    )
    monkeypatch.setattr(
        main_module.settings,
        "desktop_minimum_supported_version",
        "1.5.0",
        raising=False,
    )
    monkeypatch.setattr(
        main_module.settings,
        "desktop_update_url",
        "https://example.com/download",
        raising=False,
    )

    response = await main_module.version(
        current_version="1.0.0",
        current_asset_version="asset-10",
    )

    assert response.api_version == "2.0"
    assert response.release_id == "release-42"
    assert response.platforms.web.update_mode == "force"
    assert response.platforms.web.reload_required is True
    assert response.platforms.desktop.update_mode == "force"
    assert response.platforms.desktop.update_url == "https://example.com/download"
