from types import SimpleNamespace

from app.api.routes.campaigns import _resolve_rumor_location_title
from app.services.presentation_text import sanitize_world_rumor_event_text


def test_resolve_rumor_location_title_hides_opaque_slug():
    item = SimpleNamespace(
        location_slug="place 08d822431e",
        metadata_json={},
    )

    title = _resolve_rumor_location_title(item=item, language="ru")

    assert title is None


def test_resolve_rumor_location_title_prefers_human_readable_metadata():
    item = SimpleNamespace(
        location_slug="place 08d822431e",
        metadata_json={"location": "Большой зал Хогвартса"},
    )

    title = _resolve_rumor_location_title(item=item, language="ru")

    assert title == "Большой зал Хогвартса"


def test_sanitize_world_rumor_event_text_rewrites_opaque_prefix():
    text = sanitize_world_rumor_event_text(
        "Пока герой был занят, Place 08D822431E сдвинула ситуацию: Обстановка меняется: Первокурсники собираются у входа.",
        language="ru",
    )

    assert "08D822431E" not in text
    assert text.startswith("Пока герой был занят, обстановка изменилась:")
