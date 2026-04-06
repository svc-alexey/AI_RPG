from dataclasses import dataclass

from app.core.config import get_settings
from app.core.redaction import redact_value
from app.schemas.campaigns import ProviderCredentialsInput


@dataclass(slots=True)
class ResolvedCredentials:
    source: str
    base_url: str
    model: str
    api_key: str
    timeout_seconds: int

    @property
    def safe_summary(self) -> dict[str, str | int]:
        return {
            "source": self.source,
            "base_url": self.base_url,
            "model": self.model,
            "api_key": redact_value(self.api_key),
            "timeout_seconds": self.timeout_seconds,
        }


class CredentialResolutionService:
    def __init__(self) -> None:
        self._settings = get_settings()

    def resolve(
        self,
        transient_credentials: ProviderCredentialsInput | None,
        *,
        allow_server_fallback: bool = True,
    ) -> ResolvedCredentials:
        if transient_credentials is not None:
            base_url = transient_credentials.base_url.strip()
            model = transient_credentials.model.strip()
            api_key = transient_credentials.api_key.strip()
            if base_url and model and api_key:
                return ResolvedCredentials(
                    source="user",
                    base_url=base_url,
                    model=model,
                    api_key=api_key,
                    timeout_seconds=self._settings.server_llm_timeout_seconds,
                )

        if allow_server_fallback:
            base_url = self._settings.server_llm_base_url.strip()
            model = self._settings.server_llm_model.strip()
            api_key = self._settings.server_llm_api_key.strip()
            if base_url and model and api_key:
                return ResolvedCredentials(
                    source="server",
                    base_url=base_url,
                    model=model,
                    api_key=api_key,
                    timeout_seconds=self._settings.server_llm_timeout_seconds,
                )

        raise ValueError("missing_provider_credentials")
