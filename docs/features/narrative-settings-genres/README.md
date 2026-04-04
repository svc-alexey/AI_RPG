# Feature: Narrative settings and literary genres

Расширение выбора мира и тона истории: 10 сеттингов (`CampaignSetting`), 10 литературных жанров (`LiteraryGenre`), порядок мастера «жанр → сеттинг → …», быстрый старт с генерацией промптов через ИИ (`generateCampaignPrompts`), скрытые мягкие пресеты в ходовых промптах (`NarrativeNudgeService`), нейтральный старт кампании без принудительной цели «выживания», маппинг устаревших значений `fantasy` / `detective` / `sciFi` при чтении сохранений.

**Класс персонажа в мастере:** не везде RPG-«класс». Список классов задаётся по сеттингу в `lib/src/core/data/character_templates.dart` (`classesBySetting`). Пустой список означает, что шаг «Класс» в UI скрыт, в профиле используется `CharacterClass.unspecified`, промпты персонажа/портрета не подставляют воина по умолчанию. Для LitRPG, гримдарка, детектива, sci-fi и т.п. остаётся свой набор классов; хелпер `settingUsesCharacterClass` синхронизирует экран с данными.

**Промпт персонажа в мастере:** при изменении сеттинга (с коррекцией расы/класса под допустимые значения), расы, пола или класса персонажа поле редактирования промпта пересобирается через `CharacterPromptBuilder` в `NewGameController`, чтобы текст соответствовал реквизитам; инкремент `formRevision` обновляет привязанные `TextEditingController` на экране.

Статус:

- архитектура: aligned с `campaign-modules` и AI gateway
- реализация: done
- QA: `flutter analyze`, `flutter test` перед merge
