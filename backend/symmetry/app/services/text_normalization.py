import re


def normalize_prompt_text(text: str, *, limit: int | None = None) -> str:
    normalized = re.sub(r"\s+", " ", text or "").strip()
    if limit is None or len(normalized) <= limit:
        return normalized
    if limit <= 3:
        return normalized[:limit]
    clipped = normalized[:limit].rstrip()
    if " " in clipped:
        clipped = clipped.rsplit(" ", 1)[0]
    clipped = clipped.strip()
    return clipped if clipped else normalized[:limit].strip()


def normalize_compact_list(
    items: list[str] | tuple[str, ...] | None,
    *,
    item_limit: int | None = None,
    text_limit: int | None = None,
) -> list[str]:
    normalized: list[str] = []
    for item in items or []:
        value = normalize_prompt_text(str(item), limit=text_limit)
        if not value or value in normalized:
            continue
        normalized.append(value)
        if item_limit is not None and len(normalized) >= item_limit:
            break
    return normalized
