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
