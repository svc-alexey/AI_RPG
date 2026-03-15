# Features Catalog

Единый реестр всех feature-пакетов проекта.

Правило:
- каждая новая фича, если это не bugfix, должна быть зарегистрирована в этом каталоге
- запись в каталоге создается одновременно с добавлением задачи в [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- каталог является частью общего project scope для архитектора, аналитика, разработчика и тестировщика

## Активные и запланированные фичи

### `localization-ru-en`
- статус: analysis-ready
- папка: [docs/features/localization-ru-en](D:/AI_PRG/docs/features/localization-ru-en)
- этап: разработчик
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: полная локализация интерфейса и AI-слоя для `ru/en`

### `no-think-fast-mode`
- статус: implemented-with-backfill
- папка: [docs/features/no-think-fast-mode](D:/AI_PRG/docs/features/no-think-fast-mode)
- этап: backfill architecture/prd + qa
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: ускорение ответов LM Studio через `/no_think` и строгий JSON-формат

### `summary-memory`
- статус: implemented
- папка: [docs/features/summary-memory](D:/AI_PRG/docs/features/summary-memory)
- этап: qa follow-up
- источник в плане: [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- цель: rolling summary и устойчивая память кампании
