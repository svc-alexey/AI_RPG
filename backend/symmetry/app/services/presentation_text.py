import re


TITLE_MAX_LENGTH = 30
LOCATION_MAX_LENGTH = 32
OBJECTIVE_MAX_LENGTH = 56
CHOICE_MAX_LENGTH = 24


def normalize_campaign_title(text: str, *, language: str) -> str:
    cleaned = _extract_first_phrase(text)
    if not cleaned:
        return _fallback_title(language)

    match = re.match(r"^(?:в|in)\s+(.+?),\s+(?:где|where)\b", cleaned, flags=re.IGNORECASE)
    if match:
        cleaned = match.group(1)

    cleaned = _clean_display_text(cleaned)
    cleaned = _strip_leading_connector(cleaned)
    cleaned = _limit_words(cleaned, max_words=4)
    cleaned = _truncate(cleaned, TITLE_MAX_LENGTH)
    return _sentence_case(cleaned, language=language) or _fallback_title(language)


def normalize_location_label(text: str, *, language: str) -> str:
    cleaned = _clean_display_text(text.replace("_", " ").replace("-", " "))
    if language.startswith("ru") and _looks_like_english_slug_source(text):
        return _fallback_unknown_location(language)
    cleaned = _limit_words(cleaned, max_words=4)
    cleaned = _truncate(cleaned, LOCATION_MAX_LENGTH)
    return _sentence_case(cleaned, language=language) or _fallback_location(language)


def normalize_objective_text(text: str, *, language: str) -> str:
    cleaned = _extract_first_phrase(text)
    cleaned = re.sub(
        r"^(?:начало пути|цель|текущая цель|objective|current objective)\s*:\s*",
        "",
        cleaned,
        flags=re.IGNORECASE,
    )
    cleaned = _strip_leading_connector(cleaned)
    cleaned = _clean_display_text(cleaned)
    cleaned = _limit_words(cleaned, max_words=8)
    cleaned = _trim_trailing_connector(cleaned)
    cleaned = _truncate(cleaned, OBJECTIVE_MAX_LENGTH)
    cleaned = _trim_trailing_connector(cleaned)
    return _sentence_case(cleaned, language=language) or _fallback_objective(language)


def normalize_choice_label(text: str, *, language: str) -> str:
    cleaned = re.sub(r"^\s*(?:[-*•]|\d+[.)])\s*", "", text.strip())
    cleaned = _extract_first_phrase(cleaned)
    cleaned = _strip_leading_connector(cleaned)
    cleaned = _clean_display_text(cleaned)
    cleaned = _limit_words(cleaned, max_words=4)
    cleaned = _trim_trailing_connector(cleaned)
    cleaned = _truncate(cleaned, CHOICE_MAX_LENGTH)
    cleaned = _trim_trailing_connector(cleaned)
    return _sentence_case(cleaned, language=language)


def normalize_choices(items: list[str], *, language: str) -> list[str]:
    result: list[str] = []
    for item in items:
        choice = normalize_choice_label(item, language=language)
        if choice and choice not in result:
            result.append(choice)
        if len(result) >= 3:
            break
    return result


def _extract_first_phrase(text: str) -> str:
    candidate = " ".join(text.split()).strip().strip('"\'')
    if not candidate:
        return ""
    parts = re.split(r"[.!?]|(?:, (?=где\b|where\b))|(?:;)|(?:\n)", candidate, maxsplit=1)
    return parts[0].strip()


def _clean_display_text(text: str) -> str:
    cleaned = text.replace("_", " ").replace("-", " ")
    cleaned = re.sub(r"[\"'`~#@%^*+=<>\[\]{}|\\/]+", " ", cleaned)
    cleaned = re.sub(r"[,:;]+", " ", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned.strip(" .,-")


def _limit_words(text: str, *, max_words: int) -> str:
    words = [item for item in text.split(" ") if item]
    if len(words) <= max_words:
        return " ".join(words)
    return " ".join(words[:max_words])


def _truncate(text: str, limit: int) -> str:
    if len(text) <= limit:
        return text
    truncated = text[:limit].rstrip()
    if " " in truncated:
        truncated = truncated.rsplit(" ", 1)[0]
    return truncated.strip(" .,-")


def _sentence_case(text: str, *, language: str) -> str:
    if not text:
        return ""
    words = text.split()
    if all(_is_latin_lower_word(item) for item in words if item.isalpha()):
        return " ".join(
            word.capitalize() if word.isalpha() else word for word in words
        )
    return text[0].upper() + text[1:]


def _strip_leading_connector(text: str) -> str:
    return re.sub(
        r"^(?:и|а|но|или|and|but|or)\s+",
        "",
        text.strip(),
        flags=re.IGNORECASE,
    )


def _trim_trailing_connector(text: str) -> str:
    connectors = {
        "и",
        "а",
        "но",
        "или",
        "в",
        "во",
        "на",
        "по",
        "к",
        "ко",
        "с",
        "со",
        "у",
        "о",
        "об",
        "the",
        "a",
        "an",
        "of",
        "to",
        "in",
        "on",
        "at",
        "by",
        "for",
        "with",
        "and",
        "but",
        "or",
    }
    words = text.split()
    while len(words) > 1 and words[-1].lower() in connectors:
        words.pop()
    return " ".join(words)


def _is_latin_lower_word(text: str) -> bool:
    return text.isascii() and text == text.lower()


def _looks_like_english_slug_source(text: str) -> bool:
    stripped = text.strip()
    if not stripped:
        return False
    if "_" not in stripped and "-" not in stripped:
        return False
    normalized = stripped.replace("_", " ").replace("-", " ")
    return bool(re.fullmatch(r"[a-z0-9 ]+", normalized))


def _fallback_title(language: str) -> str:
    return "Новая кампания" if language.startswith("ru") else "New Campaign"


def _fallback_location(language: str) -> str:
    return "Начальная точка" if language.startswith("ru") else "Starting Point"


def _fallback_unknown_location(language: str) -> str:
    return "Неизвестное место" if language.startswith("ru") else "Unknown Place"


def _fallback_objective(language: str) -> str:
    return (
        "Понять, что происходит"
        if language.startswith("ru")
        else "Understand what is happening"
    )
