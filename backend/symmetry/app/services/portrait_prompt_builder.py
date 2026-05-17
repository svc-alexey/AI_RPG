from __future__ import annotations


def build_portrait_messages(
    character: dict,
    setting: str,
    story_prompt: str,
    target_width: int | None = None,
    target_height: int | None = None,
) -> list[dict]:
    name = character.get("name", "") or "Персонаж"
    gender = character.get("gender", "") or ""
    race = character.get("race", "") or ""
    char_class = character.get("character_class", "") or ""
    personality = character.get("personality", "") or ""

    parts = [f"Портрет персонажа: {name}"]
    if race and char_class:
        parts.append(f"{race} {char_class}")
    elif race:
        parts.append(race)
    elif char_class:
        parts.append(char_class)
    if gender:
        parts[-1] = f"{parts[-1]}, {gender}" if parts[-1] != name else f"{gender}"
    char_desc = ", ".join(parts)
    if personality:
        char_desc += f". Характер: {personality}"
    char_desc += ". Стиль: детализированный портрет, драматическое освещение, фокус на лице"

    if target_width and target_height:
        char_desc += (
            f". Изображение предназначено для отображения в области "
            f"шириной {target_width}px и высотой {target_height}px. "
            f"Композиция должна учитывать это соотношение сторон."
        )

    messages: list[dict] = [
        {"text": char_desc, "weight": 5},
    ]

    if setting:
        messages.append({"text": f"Сеттинг: {setting}", "weight": 2})

    if story_prompt:
        messages.append({"text": story_prompt, "weight": 1})

    return messages
