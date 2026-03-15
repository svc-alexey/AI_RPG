# Архитектура: Схема модулей

## 1. Модули верхнего уровня
```mermaid
flowchart LR
    UI[Flutter-клиент UI]
    APP[Слой приложения]
    ENGINE[Игровой движок]
    MEMORY[Система памяти]
    AI[AI Gateway]
    STORE[Локальное хранилище]
    BACKEND[Backend-сервисы]
    PROVIDERS[AI-провайдеры]

    UI --> APP
    APP --> ENGINE
    APP --> MEMORY
    APP --> AI
    APP --> STORE
    AI --> PROVIDERS
    APP --> BACKEND
    MEMORY --> STORE
    ENGINE --> STORE
    BACKEND --> PROVIDERS
```

## 2. Декомпозиция клиентских модулей
```mermaid
flowchart TB
    subgraph Client[Flutter-клиент]
      Screens[Экраны\nSetup/Character/Game/Map/Inventory/Memory/Settings]
      StateMgmt[Управление состоянием]
      Orchestrator[Оркестратор хода]
      Domain[Доменные модели]
      Validator[Валидатор состояния]
      MemoryMgr[Менеджер памяти]
      AiClient[Клиент AI Gateway]
      Repo[Репозитории]
      LocalDB[(SQLite/локальная БД)]
      Secure[(Secure Storage)]
    end

    Screens --> StateMgmt
    StateMgmt --> Orchestrator
    Orchestrator --> AiClient
    Orchestrator --> Validator
    Orchestrator --> MemoryMgr
    Orchestrator --> Repo
    Repo --> LocalDB
    Repo --> Secure
    Domain --> StateMgmt
```

## 3. Адаптеры AI Gateway
```mermaid
flowchart LR
    Contract[Единый AI-контракт\nJSON in/out]
    OpenAI[OpenAI-compatible адаптер]
    LM[LM Studio адаптер]
    Anthropic[Anthropic адаптер]
    Gemini[Gemini адаптер]
    Custom[Кастомный endpoint адаптер]

    Contract --> OpenAI
    Contract --> LM
    Contract --> Anthropic
    Contract --> Gemini
    Contract --> Custom
```

## 4. Конвейер обработки хода
```mermaid
sequenceDiagram
    participant P as Игрок
    participant UI as Экран игры
    participant ORCH as Оркестратор хода
    participant MEM as Менеджер памяти
    participant AI as AI Gateway
    participant VAL as Валидатор
    participant DB as Хранилище

    P->>UI: Отправляет действие
    UI->>ORCH: runTurn(action)
    ORCH->>MEM: buildContext(campaignId)
    MEM-->>ORCH: summary + сущности + недавние ходы
    ORCH->>AI: generateNextTurn(request JSON)
    AI-->>ORCH: narration + state_changes + choices
    ORCH->>VAL: validateAndNormalize(delta, rules)
    VAL-->>ORCH: accepted/rejected changes
    ORCH->>DB: persist turn log + updated state + memory
    ORCH-->>UI: render narration + updated UI state
```

## 5. Матрица ответственности
1. `Screens/UI`: рендеринг, ввод игрока, локальное UI-состояние.
2. `Turn Orchestrator`: центральный use-case поток каждого хода.
3. `State Validator`: принудительное соблюдение детерминированных правил игры.
4. `Memory Manager`: cadence summaries, карточки сущностей, сбор контекста.
5. `AI Gateway`: абстракция провайдеров и нормализация ответа.
6. `Repositories/Storage`: сохранение данных и миграции схем.
7. `Backend`: прокси встроенного ключа, entitlements, аналитика, модерация, облачные сохранения.

## 6. Владение данными
1. Источник истины состояния игры: `игровой движок + сохраненное состояние`.
2. Выход AI: недоверенный proposal до подтверждения валидатором.
3. Канон памяти: обновляется подсистемой памяти, не напрямую из UI.
4. Состояние подписки/прав: authoritative на backend.

## 7. Стратегия версионирования
1. `prompt_version` в AI-запросах.
2. `schema_version` в каждой сохраненной сущности.
3. `ruleset_version` в метаданных кампании.
4. Backward-compatible парсер логов ходов там, где это возможно.
