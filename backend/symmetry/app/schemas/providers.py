from pydantic import BaseModel

from app.schemas.campaigns import ProviderCredentialsInput


class ProviderConnectionCheckRequest(BaseModel):
    provider_credentials: ProviderCredentialsInput | None = None
    allow_server_fallback: bool = True
