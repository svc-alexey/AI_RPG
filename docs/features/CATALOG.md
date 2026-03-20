# Features Catalog

Единый реестр feature-пакетов проекта.

## Правила

1. Каждая новая фича, если это не bugfix, должна быть зарегистрирована в каталоге.
2. Запись в каталоге создается одновременно с записью в [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md).
3. Каталог является частью общего scope проекта для архитектора, аналитика, разработчика и тестировщика.

## Активные и завершенные фичи

### `localization-ru-en`

- статус: implemented
- папка: [docs/features/localization-ru-en](D:/AI_PRG/docs/features/localization-ru-en)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: полная локализация интерфейса и AI-слоя для `ru/en`

### `no-think-fast-mode`

- статус: implemented-with-backfill
- папка: [docs/features/no-think-fast-mode](D:/AI_PRG/docs/features/no-think-fast-mode)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: ускорение ответов LM Studio через `/no_think` и strict JSON

### `summary-memory`

- статус: implemented
- папка: [docs/features/summary-memory](D:/AI_PRG/docs/features/summary-memory)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: rolling summary и устойчивый memory-layer кампании

### `docs-encoding-sync`

- статус: implemented
- папка: [docs/features/docs-encoding-sync](D:/AI_PRG/docs/features/docs-encoding-sync)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: очистка кодировки документов и синхронизация project docs с текущим состоянием проекта

### `quality-pass-stabilization`

- статус: analysis-ready
- папка: [docs/features/quality-pass-stabilization](D:/AI_PRG/docs/features/quality-pass-stabilization)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: снизить lint-шум, укрепить ключевые user flow и подготовить проект к следующему product layer

### `next-product-layer`

- статус: analysis-ready
- папка: [docs/features/next-product-layer](D:/AI_PRG/docs/features/next-product-layer)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: Narrative depth, то есть углубление повествования через расширение AI-промптов

### `engine-mechanics-token-control`

- статус: in-progress
- папка: [docs/features/engine-mechanics-token-control](D:/AI_PRG/docs/features/engine-mechanics-token-control)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: перевести MVP в local-first RPG engine с `Isar`, `Riverpod`, hybrid context, token controls, streaming и deterministic gameplay foundation

### `campaign-modules`

- статус: analysis-ready
- папка: [docs/features/campaign-modules](D:/AI_PRG/docs/features/campaign-modules)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: сделать состояние кампании модульным, чтобы `Inventory`, `Companions`, `Resources`, `Progression`, `Vitality`, `Notes` и deterministic systems подключались по сеттингу, prompt и развитию истории, а UI адаптировался через ненавязчивые уведомления и динамический sidebar

### `deterministic-systems`

- статус: implemented
- папка: [docs/features/deterministic-systems](D:/AI_PRG/docs/features/deterministic-systems)
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: сделать client-resolved deterministic checks через локальный `DiceEngine`, передавать результат модели как known state и сохранять outcome в memory/UI/save слое
