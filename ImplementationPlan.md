# Implementation Plan: Следующие этапы после MVP

## Правила ведения плана

- Каждая задача оформляется чекбоксом.
- Выполненная задача отмечается как `[x]`.
- Новая фича, если это не bugfix, получает:
  - запись в этом плане
  - запись в [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md)
  - отдельную ветку `codex/<feature-slug>`
  - отдельную папку `docs/features/<feature-slug>/`
- До реализации новой фичи должны быть заполнены `01-Architecture.md` и `02-PRD.md`.
- Реализация идет по pipeline: архитектор -> аналитик -> разработчик -> тестировщик.

## Текущее состояние

Уже реализовано:

- [x] Flutter desktop-first каркас
- [x] Базовые экраны: `Home`, `New Game`, `Chat`, `Settings`, `Saves`
- [x] Создание кампании и стартовый `CampaignState`
- [x] Один полный игровой ход через AI
- [x] Локальные сохранения и загрузка кампаний
- [x] LM Studio интеграция через OpenAI-compatible endpoint
- [x] Автоподбор локальной модели LM Studio
- [x] Базовый безопасный fallback при невалидном ответе модели

## Этап 1. Полная локализация `ru/en`

Цель: сделать два полноценных языковых режима приложения и AI-слоя.

Задачи:

- [x] Ввести единый localization layer для UI-строк
- [x] Вынести пользовательские тексты из экранов и сервисов
- [x] Сделать два языковых состояния: `ru` и `en`
- [x] Добавить переключатель языка
- [x] Связать выбранный язык с AI-слоем
- [x] Проверить, что приложение по умолчанию стартует на русском

Результат:

- [x] Пользовательские строки управляются централизованно
- [x] Переключение языка влияет на весь UX
- [x] Код больше не завязан на строки прямо в виджетах

## Этап 2. Ускорение ответов через `/no_think`

Цель: сократить время ответа локальной модели LM Studio.

Задачи:

- [x] Проверить реакцию текущей модели на `/no_think`
- [x] Зафиксировать безопасный prompt-шаблон для быстрого ответа
- [x] Встроить режим в AI-слой
- [x] Убедиться, что JSON-контракт не ломается
- [x] Добавить fallback на обычный prompt
- [x] Проверить субъективное и техническое ускорение

Результат:

- [x] Игровые ответы приходят быстрее на совместимых локальных моделях
- [x] Быстрый режим не привязан жестко к одной модели
- [x] Быстрый режим не ломает AI-контракт

## Этап 3. Summary и память кампании

Цель: сделать устойчивую структуру памяти кампании вместо одного поля `summary`.

Задачи:

- [x] Добавить rolling summary последних ходов
- [x] Отделить краткую сводку кампании от последних событий
- [x] Хранить текущую активную цель отдельно
- [x] Обновлять summary после каждого завершенного хода
- [x] Отображать summary в UI как полезный блок
- [x] Подготовить структуру данных для будущего расширения памяти

Результат:

- [x] Длинная кампания остается понятной после паузы и загрузки save
- [x] AI получает более стабильный контекст
- [x] История меньше разваливается на длинной сессии

## Этап 4. Документация и кодировка документов

Цель: привести проектные документы в чистый UTF-8 и синхронизировать их с текущим состоянием проекта.

Задачи:

- [x] Исправить кодировку в `PRD.md`
- [x] Исправить кодировку в `.specify/memory/project-context.md`
- [x] Проверить остальные markdown-файлы на битую кодировку
- [x] Актуализировать `PRD.md` под текущее состояние MVP
- [x] Синхронизировать SpecKit memory-файлы с фактическими правилами проекта
- [x] Явно зафиксировать post-MVP этапы и ограничения

Результат:

- [x] Документы читаемы
- [x] Архитектурный и продуктовый контекст не расходятся с кодом
- [x] SpecKit может использовать документы как source of truth

## Этап 5. Quality Pass и стабилизация

Цель: снизить технический шум и довести проект до более чистого инженерного состояния.

Задачи:

- [x] Почистить `flutter analyze` до приемлемого уровня
- [x] Убрать повторяющиеся stylistic-проблемы там, где это полезно
- [x] Добавить недостающие smoke/widget tests для ключевых экранов
- [x] Проверить сценарий новой кампании
- [x] Проверить сценарий сохранения
- [x] Проверить сценарий загрузки
- [x] Проверить сценарий ошибки AI
- [x] Проверить работу без настроенной модели
- [x] Проверить поведение при недоступном LM Studio endpoint

Результат:

- [x] Проект легче сопровождать
- [x] Регрессии быстрее замечаются
- [x] MVP становится стабильнее перед следующим продуктовым слоем

## Этап 6. Следующий продуктовый слой

Цель: после стабилизации выбрать и подготовить следующий meaningful слой RPG-логики.

Подготовительные задачи:

- [x] Выбрать один product direction
- [x] Зафиксировать его в отдельном feature plan
- [x] Подготовить архитектурный анализ
- [x] Подготовить PRD для следующего слоя

Возможные направления:

- [x] `Narrative depth` (выбрано)
- [ ] `Game systems`
- [ ] `Content slice`

## Этап 7. Визуальный редизайн по референсам

Цель: привести ключевые экраны приложения к стилю из `pressets/`, сделать цельную атмосферу и добавить анимации.

Задачи:

- [x] Проанализировать референсы из папки `pressets/`
- [x] Собрать единую дизайн-систему цветов, типографики и отступов
- [x] Переработать `Home` под новый визуальный стиль
- [x] Переработать `New Game` под новый визуальный стиль
- [x] Переработать `Chat` под новый визуальный стиль
- [x] Переработать `Saves` под новый визуальный стиль
- [x] Переработать `Settings` под новый визуальный стиль
- [x] Добавить мягкие анимации появления экранов и ключевых блоков
- [x] Проверить адаптацию для desktop и узких размеров окна

Результат:

- [x] Визуальный стиль приложения соответствует референсам по настроению и композиции
- [x] Интерфейс ощущается более премиальным и атмосферным
- [x] Анимации улучшают UX и не мешают сценарию игры

## Stage 8. Deterministic Systems and Implementation Finish

Goal: finish the remaining technical implementation work before any future growth layer and make the client the source of truth for core gameplay outcomes.

Tasks:

- [x] Add local `DiceEngine` for deterministic checks when the active `Checks` module requires it
- [x] Resolve check outcomes on the client before AI narration and pass the result to the model as known state
- [x] Connect deterministic resolution to overlays, side panels, save payloads, and campaign memory updates
- [x] Add widget/unit coverage for deterministic checks, module-aware narrative campaigns, and long-session state stability
- [x] Verify that pure narrative and detective campaigns keep non-relevant RPG chrome hidden even after long play
- [x] Re-validate settings UX for speed, quality, and token controls so the remaining expected-result items are explicitly covered
- [x] Prepare the architecture for the next product layer without returning to baseline infrastructure work
- [ ] Review remaining analyzer warnings and close the ones that now block the next implementation layer

Expected result:

- [x] The client, not the model, is the source of truth for gameplay checks and their outcomes
- [ ] Long campaigns stay coherent without requiring full chat history on every turn
- [x] Detective and pure narrative stories stay free of irrelevant RPG systems throughout the campaign
- [x] Users can tune speed, quality, and token usage confidently from the settings UI
- [x] The architecture is ready for the next product layer across Desktop, Android, iOS, and Web

## Рекомендуемый порядок

- [x] Этап 1: локализация `ru/en`
- [x] Этап 2: ускорение ответов через `/no_think`
- [x] Этап 3: summary и память кампании
- [x] Этап 4: документация и кодировка
- [x] Этап 5: quality pass и стабилизация
- [x] Этап 7: визуальный редизайн по референсам
- [ ] Stage 8: deterministic systems and implementation finish
- [ ] Этап 6: следующий продуктовый слой (перенесён в конец)

## Definition of Done для этого плана

- [x] Приложение работает на `ru` и `en`
- [x] Локальная модель может работать в ускоренном режиме без лишнего рассуждения, где это поддерживается
- [x] Кампания имеет понятную систему summary/memory
- [x] Документы проекта читаемы и синхронизированы
- [x] Основные user flow покрыты проверками и стабилизированы
- [ ] Команда может переходить к следующему product layer без возврата к базовой инфраструктуре
- [x] Ключевые экраны приведены к единому целевому визуальному стилю
- [ ] Deterministic checks and the remaining implementation-validation layer are completed

## Status Update (2026-03-20)

- [x] `Stage 7` is implemented in code and visually completed for all key screens.
- [x] Desktop parity is now in place for the redesigned `Home` and `Saves` screens.
- [x] Soft `Aether` animations now run on desktop runtime and stay disabled in widget-test bindings for stability.
- [ ] `Stage 8: deterministic systems and implementation finish` is now the main open stage in this plan.
- [ ] Remaining open work is concentrated in final engine validation, settings/runtime UX coverage, and next-layer technical readiness.

## Backlog: Provider-scoped AI Settings

Goal: store `apiKey`, `model`, `baseUrl`, and timeout separately for each provider so switching between `LM Studio`, `OpenAI Compatible`, `OpenRouter`, and `DeepSeek` does not overwrite other provider profiles.

Tasks:

- [x] Design a provider-scoped settings structure instead of one shared `AiSettings` payload
- [x] Store `apiKey`, `baseUrl`, `model`, and `timeoutSeconds` independently for each provider
- [x] Add migration from the current shared settings shape so existing user settings are preserved
- [x] Update the settings screen so switching provider restores that provider's saved values immediately
- [x] Make provider switching work on the fly without losing in-progress form values
- [x] Add tests for switching `OpenRouter` -> `DeepSeek` -> back and verifying both profiles stay intact

Expected result:

- [x] Each provider keeps its own token, model, base URL, and timeout
- [x] Provider switching no longer resets previously entered credentials
- [x] The user can compare and switch providers quickly without re-entering secrets and model ids

## Backlog: Mobile Adaptation and Gameplay Screen Redesign

Goal: adapt the app for mobile-sized screens by default and redesign the gameplay screen so the chat area becomes the primary focus instead of the metadata column.

Tasks:

- [x] Add a mobile-adaptation requirement to project memory and SpecKit rules so new screens are treated as mobile-first by default
- [x] Audit all core screens for narrow-width behavior: `Home`, `New Game`, `Chat`, `Settings`, `Saves`
- [x] Redesign the gameplay screen so the conversation occupies most of the visible area
- [x] Move stats, quests, progress, and secondary campaign info into a sidebar, drawer, or collapsible panel
- [x] Keep at most 3 AI suggestion actions directly above the text input as hint chips
- [x] Merge the text field, send action, and suggest action into one composer block at the bottom of the screen
- [x] Remove detached action buttons that sit far away from the input field
- [x] Verify the gameplay layout on desktop, tablet-width, and phone-width breakpoints
- [x] Add widget or golden coverage for narrow-width gameplay layout behavior

Expected result:

- [x] The game screen feels focused on play, not on side metadata
- [x] The main chat area occupies most of the screen on both desktop and mobile
- [x] The input composer and its actions stay grouped at the bottom
- [x] Mobile layouts remain usable without cramped or broken controls

## Backlog: AI RPG Engine Core, Mechanics & Token Control

Goal: evolve the current MVP into a scalable local-first RPG engine with structured world state, controllable LLM costs, real streaming, and deterministic gameplay foundations.

Tasks:

- [x] Replace `SharedPreferences` campaign/settings persistence with `Isar`
- [x] Add migration from legacy JSON campaign blobs to structured collections
- [x] Introduce `Riverpod` providers/notifiers for campaign, messages, world state, and settings
- [x] Remove `AppScope` and move major flows to controller/notifier orchestration
- [x] Add model runtime controls for `max response tokens`, `context window`, and quick model profiles
- [x] Replace fake narration animation with real response streaming plus fallback
- [x] Formalize hybrid context as `static header + dynamic summary + recent buffer`
- [x] Refactor world state into optional campaign modules instead of mandatory RPG-only fields
- [x] Define first module set: `Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`, and `Checks`
- [x] Activate modules at campaign creation from `setting`, story prompt, and generated setup hints
- [x] Allow safe dynamic module activation during a campaign when the story introduces new systems
- [x] Add entity extraction and reconciliation for active modules before persistence
- [ ] Add local `DiceEngine` for deterministic checks only when the corresponding gameplay module is active
- [x] Adapt gameplay UI with module-aware side panels and lightweight state-change notifications

Expected result:

- [ ] Long campaigns remain coherent without sending full chat history every turn
- [ ] Users can tune speed, quality, and token usage from the settings UI
- [ ] The client, not the model, becomes the source of truth for core gameplay outcomes
- [x] Campaigns no longer show irrelevant systems like `Gold` or `Level` when the story does not need them
- [x] The UI reveals newly active systems and state changes without interrupting play
- [ ] The architecture is ready for Android, iOS, Desktop, and Web persistence/runtime scaling

Current status:

- [x] Stage 1 completed: storage foundation and migration
- [x] Stage 2 completed: Riverpod-first app shell and screen orchestration
- [x] Stage 3 completed: runtime token/context controls
- [x] Stage 4 completed: real streaming
- [x] Stage 5 completed: hybrid context assembly
- [x] Stage 6 core slices completed: module-aware state, extraction, reconciliation, and adaptive gameplay UI

## Backlog: Campaign Modules and Adaptive UI

Goal: make campaign state modular so each story only enables the systems it needs, while the chat UI adapts through dynamic side panels and subtle transient notifications.

Tasks:

- [x] Introduce a campaign capability model that separates always-on core state from optional gameplay modules
- [x] Define default module presets for `fantasy`, `detective`, and `sciFi`
- [x] Infer additional modules from the initial story prompt and character setup
- [x] Add runtime module activation when the narration clearly introduces a new system
- [x] Persist module activation reasons and module-specific state in structured storage
- [x] Add module-aware extraction and reconciliation before saving a turn
- [x] Show lightweight translucent notifications for item gains/losses, HP changes, companion joins, module unlocks, and check resolutions
- [x] Make the gameplay sidebar render only the modules that are active in the current campaign
- [ ] Add deterministic resolution on top of the active `Checks` module

Expected result:

- [ ] Detective and pure narrative stories stay free of irrelevant RPG chrome
- [ ] Fantasy and system-heavy stories can progressively unlock richer mechanics
- [x] Users understand state changes immediately without blocking popups or modal interruptions
