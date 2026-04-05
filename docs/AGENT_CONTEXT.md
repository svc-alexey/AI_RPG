# AI PRG — контекст для AI-агентов

Краткая точка входа: продукт, код, фичи, процесс. Подробности — в ссылках ниже.

## Продукт (что это)

- **Жанр:** narrative RPG на Flutter; LLM даёт повествование и варианты действий, **источник истины** — детерминированный движок и сохранённый `CampaignState`.
- **Сейвы:** local-first; на **native (IO)** основной бэкенд — **Isar**, на **web** — **SharedPreferences** (адаптивный слой в репозиториях). Один билд — web / Android / iOS / desktop; **у каждой установки свой локальный прогресс**. Синхронизация между устройствами **не реализована** (отдельная фича, если понадобится).
- **AI:** OpenAI-compatible gateway (`baseUrl`, `model`, ключ, runtime token/window). **Приоритет:** непустые значения из **локального хранилища** важнее compile-time пресетов (`AI_PRG_*` / `AiRuntimeEnv`); `SettingsRepository.loadAiSettings()` применяет `AiSettings.withEnvFallbacks` только для пустых полей. Экран настроек показывает **только сохранённые пользователем** URL/модель/ключ (пресеты в поля не подставляются). Для голого `https://api.deepseek.com` клиент при запросах нормализует путь до `.../v1`; остальные endpoint’ы не меняются.
- **Web + внешний API:** браузер режет прямые вызовы к хостам вроде `api.deepseek.com` из‑за **CORS** (не баг merge настроек). Для статического web-деплоя нужен **прокси на своём домене** или нативный клиент; см. `docs/DEPLOY_WEB.md`, `tool/cloudflare_worker_deepseek_proxy/`.
- **Языки:** UI и AI-слой — **ru** (по умолчанию) и **en**; фича не считается готовой, если затронут UX только на одном языке.
- **UX:** mobile-first (узкие экраны — эталон); чат — главная область экрана; до трёх suggestion chips над вводом; «Отправить» / «Подсказать» в композере; в многострочном вводе чата **Enter** отправляет ход (как кнопка), **Shift+Enter** — новая строка (клавиатура desktop/web).
- **Статус:** pre-prod; **нет** обязательной миграции данных из старого SharedPreferences в Isar при первом открытии (свежая Isar — только версия схемы). **Портреты персонажа:** генерация изображений **заглушка** (`generateCharacterPortrait` → `null`); `CharacterPortraitPromptBuilder` держится для будущего пайплайна и тестов — не удалять как мёртвый код.

## Стек

- Flutter, `flutter_riverpod`, `google_fonts`, `http`, `isar` (+ `isar_flutter_libs` на IO), `path_provider`, `shared_preferences`.
- Анализ: `analysis_options.yaml` → `flutter_lints`, строгие `strict-*`.

## Карта кода

| Зона | Путь |
|------|------|
| Точка входа | `lib/main.dart` |
| Приложение, bootstrap | `lib/src/app/` (`app.dart`, `app_providers.dart`, `theme.dart`, `aether_shell.dart` — палитра Aether / фон / `AetherCard`, localization) |
| Фичи (UI + контроллеры) | `lib/src/features/home`, `chat`, `settings`, `saves`, `new_game` |
| Модели | `lib/src/core/models/` |
| Репозитории | `lib/src/core/repositories/` |
| Сервисы (движок, AI, память, промпты) | `lib/src/core/services/` |
| Данные (Isar, SP, адаптеры) | `lib/src/core/data/` |

Игровой цикл высокоуровнево: экран чата → AI client `generateTurn` → `GameEngine.applyTurn` → `saveCampaign`.

**Типографика чата:** основной текст повествования рассказчика — `bodyLarge` темы (Inter), цвет `AetherPalette.narrativeText`; декоративный Playfair — для крупных заголовков/бренда, не для тела сообщений в ленте.

## Реестр фич (из [CATALOG.md](features/CATALOG.md))

| Slug | Статус (каталог) | Где в коде / заметки |
|------|------------------|----------------------|
| `localization-ru-en` | implemented | `app_localizations.dart`, строки UI, AI language |
| `no-think-fast-mode` | implemented-with-backfill | AI client, LM Studio `/no_think` |
| `summary-memory` | implemented | `campaign_memory_manager`, `context_assembly_service`, модели памяти |
| `docs-encoding-sync` | implemented | мета-доки |
| `quality-pass-stabilization` | analysis-ready | качество, линты, UX-потоки |
| `next-product-layer` | analysis-ready | narrative depth, промпты |
| `engine-mechanics-token-control` | in-progress | Isar, Riverpod, streaming, token controls, детерминизм |
| `campaign-modules` | analysis-ready | модули кампании, сайдбар, `CampaignModule` |
| `deterministic-systems` | implemented | `DiceEngine`, `DeterministicCheckService`, чекы в UI |
| `narrative-settings-genres` | implemented | `CampaignSetting`, `LiteraryGenre`, мастер новой игры; класс персонажа только если `classesBySetting[setting]` непустой (`character_templates.dart`); на шаге персонажа смена расы/пола/класса или сеттинга пересобирает текст промпта через `CharacterPromptBuilder` (`new_game_controller.dart`) |

Документы фич: `docs/features/<slug>/` (`01-Architecture.md`, `02-PRD.md`, … по шаблону процесса).

## Порядок чтения для агента

1. Корень: [`.cursorrules`](../.cursorrules)
2. Правила проекта: [`.specify/memory/constitution.md`](../.specify/memory/constitution.md), [project-context.md](../.specify/memory/project-context.md)
3. Инженерия Flutter: [FlutterRules.md](../FlutterRules.md), [Architecture.md](../Architecture.md)
4. Требования: [PRD.md](../PRD.md) (выборочно по задаче)
5. Реестр: [docs/features/CATALOG.md](features/CATALOG.md)
6. Этот файл и [docs/features/COMMANDS.md](features/COMMANDS.md)
7. Папка конкретной фичи под задачу

## Workflow (новая фича / правки)

- Ветка `codex/<slug>`; фича-пакет в `docs/features/<slug>/`; запись в [CATALOG.md](features/CATALOG.md) и [ImplementationPlan.md](../ImplementationPlan.md) — по [COMMANDS.md](features/COMMANDS.md).
- Перед merge: **`flutter analyze`** и **`flutter test`** без ошибок ([FlutterRules.md](../FlutterRules.md)).
- AI/API не вызывать из произвольного UI — через сервисы и контракты; после `await` в виджетах проверять `mounted`; не смешивать огромный рефакторинг с фичей без причины.
- Перед крупным удалением кода или «чисткой мёртвого кода» — [FlutterRules.md](../FlutterRules.md) §8 и сверка с [CATALOG.md](features/CATALOG.md) / этим файлом.

## Глоссарий

- **CampaignState** — сериализуемое состояние кампании (чат, модули, память, прогресс).
- **Structured contract** — ожидаемый формат ответа модели до применения к state.
- **Gateway** — слой AI-клиента поверх OpenAI-compatible HTTP.
- **Deterministic turn** — заранее посчитанные на клиенте проверки/кости, передаваемые в промпт как известный факт.
- **Memory layer** — summary, цель, ситуация, recent buffer; сборка в `ContextAssemblyService` / `CampaignMemoryManager`.
