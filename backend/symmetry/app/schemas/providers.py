from pydantic import AliasChoices, BaseModel, Field

from app.schemas.campaigns import ProviderCredentialsInput


class ProviderConnectionCheckRequest(BaseModel):
    provider_credentials: ProviderCredentialsInput | None = Field(
        default=None,
        validation_alias=AliasChoices("provider_credentials", "providerCredentials"),
    )
    allow_server_fallback: bool = Field(
        default=True,
        validation_alias=AliasChoices("allow_server_fallback", "allowServerFallback"),
    )
