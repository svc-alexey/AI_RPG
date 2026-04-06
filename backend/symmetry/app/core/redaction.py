from collections.abc import Mapping, Sequence


SENSITIVE_KEYS = {
    "api_key",
    "apikey",
    "authorization",
    "provider_credentials",
    "password",
    "refresh_token",
    "access_token",
}


def redact_value(value: str) -> str:
    if not value:
        return ""
    if len(value) <= 8:
        return "***"
    return f"{value[:4]}***{value[-2:]}"


def redact_data(data):
    if isinstance(data, Mapping):
        redacted = {}
        for key, value in data.items():
            if key.lower() in SENSITIVE_KEYS:
                redacted[key] = "***"
            else:
                redacted[key] = redact_data(value)
        return redacted
    if isinstance(data, Sequence) and not isinstance(data, (str, bytes, bytearray)):
        return [redact_data(item) for item in data]
    return data
