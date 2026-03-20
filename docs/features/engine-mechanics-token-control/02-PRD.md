# PRD: AI RPG Engine (Core, Mechanics & Token Control)

## 1. Product Goal

Превратить текущий AI RPG клиент в local-first RPG engine, где:

- игровое состояние хранится структурированно и живёт дольше одного chat session;
- UI и orchestration остаются отзывчивыми на Desktop, Android, iOS и Web;
- LLM отвечает за narration и вариативность, но не владеет состоянием мира;
- стоимость и размер ответов модели управляются из интерфейса;
- архитектура готова к длинным кампаниям, deterministic mechanics и расширяемому world state.

## 2. Product Principles

1. Источник истины находится в локальном store, а не в свободном тексте модели.
2. UI не содержит бизнес-оркестрацию: async flow живёт в controller/notifier-слое.
3. Модель можно менять без переписывания presentation.
4. Campaign memory должна масштабироваться без отправки полного message log в LLM.
5. Новые игровые механики должны встраиваться поверх уже нормализованного состояния, а не поверх JSON-blob хранения.

## 3. Current Implementation Status

### 3.1 Done

- `Isar` подключен как основной local storage foundation.
- Кампании и настройки разложены по structured collections.
- Есть миграция из `SharedPreferences` и fallback для тестовой среды.
- `Riverpod` используется как основной state-management слой приложения.
- `AppScope` удалён из app shell.
- `Chat`, `Settings` и `New Game` переведены на controller/state orchestration.
- `Saves` и app shell работают через provider overrides.

### 3.2 In Progress

- Переход от UI-simulated response rendering к настоящему network streaming.
- Подготовка model sandbox controls и runtime prompt controls.

### 3.3 Not Started

- `Hybrid Context` memory pipeline
- `Entity Extraction`
- `Dice Engine`
- модульный `World State` (`Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`)
- `Isolates` для тяжёлого background processing

## 4. Users & Core Scenarios

### 4.1 Long Campaign Player

Игрок ведёт длинную кампанию и ожидает, что:

- сюжет не “рассыпается” спустя десятки ходов;
- состояние героя и мира остаётся согласованным;
- прошлые события не требуют ручного копипаста в prompt.

### 4.2 Cost-Conscious Player

Игрок хочет сам балансировать качество, скорость и стоимость ответа через UI:

- выбрать более лёгкую или более сильную модель;
- ограничить объём одного ответа;
- ограничить размер контекста.

### 4.3 Gameplay-Focused Player

Игроку нужен не “чат с красивым текстом”, а управляемая RPG loop-модель:

- системные проверки определяются локально;
- награды и изменения мира не теряются;
- narration следует за state transition, а не заменяет её.

## 5. Functional Requirements

### 5.1 Local-First Storage

Система должна:

1. хранить кампании, сообщения и runtime settings в `Isar`;
2. использовать структурированные сущности вместо одного JSON blob;
3. поддерживать миграцию legacy сохранений;
4. иметь совместимую стратегию для Web/WASM.

Статус: foundation реализован.

### 5.2 State Management & Orchestration

Система должна:

1. использовать `Riverpod` как основной orchestration слой;
2. держать side effects в controller/notifier, а не в widgets;
3. позволять selective rebuilds и дальнейшее дробление state на fine-grained providers.

Статус: реализовано для app shell, chat, settings, new game, saves.

### 5.3 World State

Целевая модель должна включать:

- always-on core state: `location`, `objective`, `summary`, `recent state hints`;
- опциональные модули кампании: `Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`;
- возможность подключать и отключать модули по сеттингу, initial prompt и развитию истории;
- расширяемые derived state и module-specific collections без жёсткой привязки всех кампаний к RPG-экономике.

Статус: частично реализовано. `Inventory` уже есть, базовый sidebar уже показывает часть состояния, но модульная схема и динамическая активация ещё не завершены.

### 5.4 Model Sandbox Controls

Экран настроек должен включать:

1. `Max Response Tokens`
2. `Context Window Size`
3. `Model Selection`
4. при необходимости presets для “fast / smart / cheap”

Статус: provider/model/base URL уже есть, но token/context controls ещё не внедрены.

### 5.5 Hybrid Context

Контекст модели должен собираться из:

1. `Static Header`
2. `Dynamic Summary`
3. `Recent Buffer`
4. текущего world state

Статус: не реализовано.

### 5.6 Entity Extraction

После ответа модели должен работать extraction/reducer pipeline, который умеет:

- добавлять и удалять предметы;
- фиксировать companions/NPC;
- обновлять world notes только при достаточной уверенности;
- предлагать или автоматически включать новый модуль кампании, если narration явно ввела новую системную сущность;
- выполнять reconciliation только для модулей, активных в кампании.

Статус: не реализовано.

### 5.7 Deterministic Checks / Combat Modules

Проверки навыков и боевые roll-механики должны:

- рассчитываться локально;
- передавать модели только outcome и scene context;
- не отдавать LLM контроль над итогом проверки;
- включаться только для кампаний, где активен соответствующий gameplay module.

Статус: не реализовано.

### 5.8 Streaming

Narration должна отображаться через реальный response stream с graceful fallback.

Статус: транспортный streaming не реализован; сейчас есть только UI-level progressive rendering в chat flow.

### 5.9 Background Processing

Тяжёлый parsing, extraction и bulk DB updates должны быть готовы к выносу в isolates.

Статус: не реализовано.

## 6. Non-Goals

На текущий этап не входят:

- multiplayer;
- серверная синхронизация профилей и сохранений;
- tactical grid combat;
- обязательная image generation;
- сложная межкампанийная экономика.

## 7. Stage-Based Delivery

### Stage 1: Foundation

- `Isar` schemas и migration
- initial settings persistence
- storage abstraction cleanup

Статус: выполнено.

### Stage 2: State Architecture

- `Riverpod` app shell
- screen controllers/notifiers
- removal of service-locator-style orchestration from widgets

Статус: выполнено по основным пользовательским flow.

### Stage 3: Model Runtime Controls

- `max response tokens`
- `context window`
- better runtime model presets

Статус: в backlog.

### Stage 4: Gameplay Systems

- hybrid memory
- modular world state
- extraction and module activation pipeline
- dice/check systems as optional modules

Статус: в backlog.

## 8. Definition of Done

Фича считается завершённой, когда:

1. campaign/runtime data живут в `Isar`;
2. UI flows работают через `Riverpod` controllers/notifiers;
3. model runtime limits настраиваются в UI;
4. context assembly использует `header + summary + recent buffer + world state`;
5. streaming работает транспортно, а не только визуально;
6. deterministic mechanics и extraction встроены в reducer pipeline;
7. world state синхронизируется без ручного участия пользователя.
