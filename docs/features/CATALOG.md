# Features Catalog

Единый реестр feature-пакетов проекта.

## Правила

1. Каждая новая фича, если это не bugfix, должна быть зарегистрирована в каталоге.
2. Запись в каталоге создаётся одновременно с записью в
   [ImplementationPlan.md](/D:/AI_PRG/ImplementationPlan.md).
3. Каталог является частью общего scope проекта для архитектора, аналитика,
   разработчика и тестировщика.

## Активные и завершённые фичи

### `localization-ru-en`

- статус: implemented
- папка: [docs/features/localization-ru-en](/D:/AI_PRG/docs/features/localization-ru-en)
- цель: полная локализация интерфейса и AI-слоя для `ru/en`

### `summary-memory`

- статус: implemented
- папка: [docs/features/summary-memory](/D:/AI_PRG/docs/features/summary-memory)
- цель: rolling summary и устойчивый memory-layer кампании

### `docs-encoding-sync`

- статус: implemented
- папка: [docs/features/docs-encoding-sync](/D:/AI_PRG/docs/features/docs-encoding-sync)
- цель: очистка кодировки документов и синхронизация project docs с текущим состоянием проекта

### `quality-pass-stabilization`

- статус: implemented
- папка: [docs/features/quality-pass-stabilization](/D:/AI_PRG/docs/features/quality-pass-stabilization)
- цель: стабилизация UX и инженерного качества проекта

### `next-product-layer`

- статус: analysis-ready
- папка: [docs/features/next-product-layer](/D:/AI_PRG/docs/features/next-product-layer)
- цель: следующий продуктовый слой после завершения server-first платформы

### `engine-mechanics-token-control`

- статус: historical-implemented
- папка: [docs/features/engine-mechanics-token-control](/D:/AI_PRG/docs/features/engine-mechanics-token-control)
- цель: исторический переход к modular state, token controls, streaming и deterministic foundations до server-first миграции

### `campaign-modules`

- статус: implemented
- папка: [docs/features/campaign-modules](/D:/AI_PRG/docs/features/campaign-modules)
- цель: модульное состояние кампании и адаптивный UI для игровых систем

### `deterministic-systems`

- статус: implemented
- папка: [docs/features/deterministic-systems](/D:/AI_PRG/docs/features/deterministic-systems)
- цель: deterministic checks как продуктовый слой; исторически важен, но не описывает текущий authoritative runtime сам по себе

### `narrative-settings-genres`

- статус: implemented
- папка: [docs/features/narrative-settings-genres](/D:/AI_PRG/docs/features/narrative-settings-genres)
- цель: сеттинги, жанры и richer prompt generation в мастере новой игры

### `symmetry-hybrid-backend`

- статус: implemented-with-followup
- папка: [docs/features/symmetry-hybrid-backend](/D:/AI_PRG/docs/features/symmetry-hybrid-backend)
- источник в плане: [ImplementationPlan.md](/D:/AI_PRG/ImplementationPlan.md)
- цель: вынести кампании, auth, живой мир, RAG и OpenAI-compatible AI gateway
  в серверный backend `Symmetry` с поддержкой временных пользовательских API-ключей
  без хранения на сервере
- follow-up:
  - production rollout hardening
  - живая проверка Yandex OAuth
