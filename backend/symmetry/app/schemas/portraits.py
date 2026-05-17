from __future__ import annotations

from pydantic import BaseModel


class PortraitGenerateRequest(BaseModel):
    target_width: int | None = None
    target_height: int | None = None


class PortraitStatusResponse(BaseModel):
    portrait_status: str | None
