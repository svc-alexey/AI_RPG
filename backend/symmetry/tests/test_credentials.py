from app.schemas.campaigns import ProviderCredentialsInput
from app.services.credentials import CredentialResolutionService


def test_transient_user_credentials_take_priority():
    service = CredentialResolutionService()
    credentials = service.resolve(
        ProviderCredentialsInput(
            base_url="https://example.com/v1",
            model="custom-model",
            api_key="secret-key",
        ),
        allow_server_fallback=False,
    )
    assert credentials.source == "user"
    assert credentials.api_key == "secret-key"


def test_missing_credentials_raise_without_fallback():
    service = CredentialResolutionService()
    try:
        service.resolve(None, allow_server_fallback=False)
    except ValueError as exc:
        assert str(exc) == "missing_provider_credentials"
    else:
        raise AssertionError("Expected ValueError for missing credentials")
