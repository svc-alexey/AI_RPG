from types import SimpleNamespace

from app.api.routes.campaigns import _resolve_rumor_location_title
from app.services.presentation_text import (
    _trim_trailing_connector,
    normalize_choice_label,
    sanitize_world_rumor_event_text,
)


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


def test_trim_trailing_connector_strips_all_russian_prepositions():
    assert _trim_trailing_connector("Купить ингредиенты для") == "Купить ингредиенты"
    assert _trim_trailing_connector("Спрятаться в тени от") == "Спрятаться в тени"
    assert _trim_trailing_connector("Атаковать под") == "Атаковать"
    assert _trim_trailing_connector("Пройти через") == "Пройти"
    assert _trim_trailing_connector("Выйти из") == "Выйти"
    assert _trim_trailing_connector("Дойти до") == "Дойти"
    assert _trim_trailing_connector("Пролететь над") == "Пролететь"
    assert _trim_trailing_connector("Остаться без") == "Остаться"
    assert _trim_trailing_connector("Встретиться при") == "Встретиться"
    assert _trim_trailing_connector("Остановиться перед") == "Остановиться"
    assert _trim_trailing_connector("Рассказать про") == "Рассказать"
    assert _trim_trailing_connector("Действовать за") == "Действовать"


def test_trim_trailing_connector_handles_multiple_prepositions():
    assert _trim_trailing_connector("Идти в на под") == "Идти"


def test_trim_trailing_connector_does_not_strip_non_prepositions():
    assert _trim_trailing_connector("Атаковать врага") == "Атаковать врага"
    assert _trim_trailing_connector("Спрятаться под столом") == "Спрятаться под столом"
    assert _trim_trailing_connector("Купить зелье") == "Купить зелье"


def test_normalize_choice_label_no_dangling_prepositions():
    assert normalize_choice_label("Купить ингредиенты для зелья", language="ru") == "Купить ингредиенты"
    assert normalize_choice_label("Спрятаться в тени от врага", language="ru") == "Спрятаться в тени"
    assert normalize_choice_label("Убежать от погони в лес", language="ru") == "Убежать от погони"
    assert normalize_choice_label("Поговорить с торговцем о сделке", language="ru") == "Поговорить с торговцем"
