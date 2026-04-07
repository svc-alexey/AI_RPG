import httpx

from app.services.ai_gateway import classify_provider_error


def test_classify_provider_error_for_rate_limit():
    request = httpx.Request("POST", "https://example.invalid/chat/completions")
    response = httpx.Response(429, request=request)
    error = httpx.HTTPStatusError("rate limited", request=request, response=response)

    assert classify_provider_error(error) == (429, "provider_rate_limited")


def test_classify_provider_error_for_network_issue():
    request = httpx.Request("POST", "https://example.invalid/chat/completions")
    error = httpx.ConnectError("dns failed", request=request)

    assert classify_provider_error(error) == (502, "provider_connection_failed")


def test_classify_provider_error_for_invalid_payload():
    assert classify_provider_error(ValueError("invalid_llm_payload")) == (
        502,
        "provider_invalid_response",
    )
