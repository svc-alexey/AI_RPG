from typing import Literal

from pydantic import BaseModel


UpdateMode = Literal["none", "soft", "force"]


class VersionPlatformResponse(BaseModel):
    latest_version: str
    minimum_supported_version: str
    update_mode: UpdateMode
    message: str
    asset_version: str | None = None
    reload_required: bool | None = None
    update_url: str | None = None


class VersionPlatformsResponse(BaseModel):
    web: VersionPlatformResponse
    desktop: VersionPlatformResponse


class VersionResponse(BaseModel):
    api_version: str
    release_id: str
    released_at: str
    platforms: VersionPlatformsResponse
