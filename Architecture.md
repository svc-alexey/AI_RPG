# Архитектура: схема модулей

## 1. Модули верхнего уровня

```mermaid
flowchart LR
    UI["Flutter UI"]
    APP["Application Layer"]
    ENGINE["Game Engine"]
    MEMORY["Memory Layer"]
    AI["AI Gateway"]
    STORE["Local Storage"]

    UI --> APP
    APP --> ENGINE
    APP --> MEMORY
    APP --> AI
    APP --> STORE
```

## 2. Клиентская декомпозиция

```mermaid
flowchart TB
    subgraph Client["Flutter Client"]
      Screens["Screens"]
      State["State / App Scope"]
      Domain["Domain Models"]
      Services["Services"]
      Repos["Repositories"]
      Local["Local Storage"]
    end

    Screens --> State
    State --> Services
    State --> Repos
    Services --> Domain
    Repos --> Domain
    Repos --> Local
```

## 3. Основные архитектурные правила

1. UI не является источником истины для игрового состояния.
2. AI не является источником истины для игрового состояния.
3. Игровой state изменяется только через детерминированную логику приложения.
4. AI-слой работает через единый gateway и structured contract.
5. Память кампании строится слоями: recent turns, rolling summary, active goal, active situation.

## 4. Ключевые модули текущего MVP

1. `lib/src/app/*` — bootstrapping, app scope, theme, localization.
2. `lib/src/core/models/*` — доменные модели кампании, персонажа, AI settings.
3. `lib/src/core/repositories/*` — локальные репозитории настроек и кампаний.
4. `lib/src/core/services/*` — game engine, AI clients, LM Studio auto-config, memory manager.
5. `lib/src/features/*` — пользовательские экраны и feature-level UI.

## 5. Игровой цикл

```mermaid
sequenceDiagram
    participant U as User
    participant C as Chat Screen
    participant A as AI Client
    participant E as Game Engine
    participant S as Storage

    U->>C: Send action
    C->>A: generateTurn(...)
    A-->>C: structured turn result
    C->>E: applyTurn(...)
    E-->>C: updated CampaignState
    C->>S: saveCampaign(...)
```

## 6. Сохранения и совместимость

1. Кампания хранится как сериализуемая модель состояния.
2. Изменения схемы должны по возможности сохранять обратную совместимость.
3. Новые поля memory-слоя должны иметь fallback для старых save.

**Платформы и данные:** на **web** локальный стор — `SharedPreferences`; на **IO** — **Isar** (при ошибке открытия Isar возможен fallback на SP). Это **кросс-платформа с локальным сейвом на устройстве**, не синхронизация прогресса между телефоном и ПК. Облачный sync — отдельный продуктовый слой, если появится.

**Pre-prod:** импорт старых сейвов из единственного legacy SharedPreferences в Isar **отключён**; новая база Isar стартует с записи версии схемы. Тяжёлые миграции между релизами усиливать ближе к релизу в прод.

## 7. AI слой

1. Поддерживается OpenAI-compatible endpoint (`/models`, `/chat/completions` относительно базового URL).
2. LM Studio используется как локальный AI provider.
3. Для LM Studio поддержан fast mode через `/no_think` с fallback.
4. Невалидный AI-ответ не должен ломать state кампании.

**Пресеты сборки и локальные настройки:** через `dart-define` / `String.fromEnvironment` задаются `AI_PRG_BASE_URL`, `AI_PRG_MODEL`, `AI_PRG_API_KEY` (см. `lib/src/core/config/ai_runtime_env.dart`, пример `tool/ai_local_defines.example.json`). Метод `AiSettings.withEnvFallbacks` заполняет **только пустые** поля сохранённых настроек значениями из окружения сборки. Репозиторий: `loadAiSettingsPersisted()` — как в хранилище; `loadAiSettings()` — уже с merge для рантайма (чат, генерация и т.д.). UI настроек редактирует и отображает сохранённый снимок; подсказки объясняют скрытые пресеты, не копируя секреты в поля.

**Нормализация URL (DeepSeek):** если пользователь или пресет задаёт базовый URL без пути для хоста `api.deepseek.com`, HTTP-клиент дописывает суффикс `/v1` (ожидаемый префикс OpenAI-compatible API). Произвольные другие хосты и пути не изменяются.
