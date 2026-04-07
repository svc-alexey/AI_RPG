# Feature: Narrative settings and literary genres

Расширение выбора мира и тона истории: 10 сеттингов (`CampaignSetting`), 10 литературных жанров (`LiteraryGenre`), порядок мастера «жанр → сеттинг → …», story modes (`StoryMode.shortStory` / `StoryMode.longCampaign`), быстрый старт с mode-aware генерацией промптов через ИИ (`generateCampaignPrompts`), скрытые мягкие пресеты в ходовых промптах (`NarrativeNudgeService`), нейтральный старт кампании без принудительной цели «выживания», маппинг устаревших значений `fantasy` / `detective` / `sciFi` при чтении сохранений.

**Story Mode semantics:**
- `shortStory` — короткий вход в историю, compact hook, более лаконичные ответы ИИ.
- `longCampaign` — первый auto-turn показывает видимый пролог, затем стартовую сцену; story seed и character framing генерируются богаче и сохраняются в snapshot state как `custom_story_prompt`.

**Быстрый старт:** mode теперь выбирается случайно с bias `70% shortStory / 30% longCampaign`. Пользователь в quick start не настраивает жанр, сеттинг и mode вручную — они роллятся автоматически.

**Prompt generation:** `/prompts/generate` и client-side request model теперь получают `mode`, чтобы:
- для `shortStory` просить быстрый, компактный story prompt;
- для `longCampaign` просить более длинный story prompt с предысторией героя или мира, устойчивым конфликтом и более содержательным `character_prompt`.

**Класс персонажа в мастере:** не везде RPG-«класс». Список классов задаётся по сеттингу в `lib/src/core/data/character_templates.dart` (`classesBySetting`). Пустой список означает, что шаг «Класс» в UI скрыт, в профиле используется `CharacterClass.unspecified`, промпты персонажа/портрета не подставляют воина по умолчанию. Для LitRPG, гримдарка, детектива, sci-fi и т.п. остаётся свой набор классов; хелпер `settingUsesCharacterClass` синхронизирует экран с данными.

**Промпт персонажа в мастере:** при изменении сеттинга (с коррекцией расы/класса под допустимые значения), расы, пола или класса персонажа поле редактирования промпта пересобирается через `CharacterPromptBuilder` в `NewGameController`, чтобы текст соответствовал реквизитам; инкремент `formRevision` обновляет привязанные `TextEditingController` на экране.

Статус:

- архитектура: aligned с `campaign-modules` и AI gateway
- реализация: done
- QA: `flutter analyze`, `flutter test` перед merge
