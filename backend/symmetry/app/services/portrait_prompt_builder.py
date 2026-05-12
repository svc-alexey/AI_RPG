def build_portrait_prompt(
    *,
    character_name: str,
    character_race: str,
    character_class: str,
    character_gender: str,
    character_personality: str,
    character_prompt_fragment: str,
    story_context: str,
    setting: str,
) -> str:
    setting_label = _resolve_setting_label(setting)
    gender = _resolve_gender(character_gender)
    class_token = f" {character_class}" if character_class and character_class != "unspecified" else ""

    details = [
        f"{character_name}, a {gender} {character_race}{class_token}",
        "cinematic character portrait",
        f"{setting_label} atmosphere",
        "head and shoulders composition",
        "high detail digital illustration",
    ]

    personality = character_personality.strip()
    fragment = character_prompt_fragment.strip()
    story = story_context.strip()

    if personality:
        details.append(f"personality: {personality}")
    if fragment:
        details.append(f"character details: {fragment}")
    if story:
        details.append(f"story context: {story}")

    base_prompt = ", ".join(details)
    return f"{base_prompt}, expressive lighting, no text, no watermark"


def _resolve_setting_label(setting: str) -> str:
    slug = (setting or "").strip()
    if slug in ("cozyCrime", "cozy_crime"):
        return "detective noir"
    if slug in ("postApocalypse", "post_apocalypse", "nearFutureSciFi", "near_future_sci_fi"):
        return "science fiction"
    return "fantasy"


def _resolve_gender(gender: str) -> str:
    slug = (gender or "").strip()
    if slug == "male":
        return "male"
    if slug == "female":
        return "female"
    if slug == "other":
        return "androgynous"
    return "androgynous"
