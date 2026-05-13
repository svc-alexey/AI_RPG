from __future__ import annotations

from pydantic import BaseModel


class PortraitStatusResponse(BaseModel):
    portrait_status: str | None
