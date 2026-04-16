import httpx
import pytest

from app.services.ai_gateway import AiGatewayService, LlmUsage, classify_provider_error


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


def test_parse_json_maps_truncated_json_to_invalid_payload():
    service = AiGatewayService()

    with pytest.raises(ValueError, match="invalid_llm_payload"):
        service._parse_json('{"narration":"text","choices":["one"]')


@pytest.mark.asyncio
async def test_generate_json_retries_when_truncated_json_hits_token_cap():
    service = AiGatewayService()
    attempts: list[int | None] = []
    responses = iter(
        [
            (
                {
                    "choices": [
                        {
                            "message": {
                                "content": '{"narration":"text","choices":["one"]'
                            },
                            "finish_reason": "length",
                        }
                    ],
                    "usage": {"completion_tokens": 180, "total_tokens": 320},
                },
                LlmUsage(completion_tokens=180, total_tokens=320),
                "length",
            ),
            (
                {
                    "choices": [
                        {
                            "message": {
                                "content": '{"narration":"text","choices":["one"],"state_changes":{},"memory_entry":"memo","importance":2}'
                            },
                            "finish_reason": "stop",
                        }
                    ],
                    "usage": {"completion_tokens": 220, "total_tokens": 390},
                },
                LlmUsage(completion_tokens=220, total_tokens=390),
                "stop",
            ),
        ]
    )

    async def _fake_post_json_completion(*, payload, **_kwargs):
        attempts.append(payload.get("max_tokens"))
        return next(responses)

    service._post_json_completion = _fake_post_json_completion  # type: ignore[method-assign]

    result = await service.generate_json(
        credentials=type(
            "_Creds",
            (),
            {
                "model": "test-model",
                "base_url": "https://example.invalid/v1",
                "api_key": "secret",
                "timeout_seconds": 60,
                "safe_summary": "test-creds",
            },
        )(),
        system_prompt="Return JSON",
        user_payload={"hello": "world"},
        max_output_tokens=180,
        scenario="turn_standard_short",
    )

    assert result.payload["memory_entry"] == "memo"
    assert attempts == [180, 340]
