# Implementation Plan

## Правила

- Каждая новая фича, если это не bugfix, получает:
  - запись в этом плане;
  - запись в [docs/features/CATALOG.md](/D:/AI_PRG/docs/features/CATALOG.md);
  - отдельную ветку `codex/<feature-slug>`;
  - отдельную папку `docs/features/<feature-slug>/`.
- До реализации новой фичи должны быть заполнены `01-Architecture.md` и
  `02-PRD.md`.
- Изменения схемы БД делаются через Alembic migrations.
- После инженерных изменений обязательны:
  - `flutter analyze`
  - `flutter test`
  - `python -m pytest tests` в `backend/symmetry`

## Текущее состояние платформы

Уже реализовано:

- [x] Flutter client с auth gate и server-first campaign flow
- [x] `Symmetry` backend на `FastAPI`
- [x] `PostgreSQL + pgvector` в `docker-compose`
- [x] Alembic migrations и container startup rollout
- [x] Email auth, refresh/logout и Yandex OAuth scaffolding
- [x] Серверная обработка кампаний и игровых ходов
- [x] Векторная память мира через `world_chronicles`
- [x] Story library backend/API foundation
- [x] Удаление legacy local campaign persistence из runtime-кода и тестов
- [x] Пользовательские AI-креды как transient request data без хранения на сервере

## Исторические этапы

Ниже перечислены завершённые продуктовые слои, которые важны как история
проекта, но больше не описывают текущую authoritative runtime-модель:

- [x] локализация `ru/en`
- [x] fast mode `/no_think`
- [x] summary/memory слой
- [x] quality/stabilization проход
- [x] визуальный редизайн
- [x] campaign modules
- [x] deterministic systems
- [x] narrative settings / genres

## Текущий главный завершённый этап

### `symmetry-hybrid-backend`

Цель: перевести продукт на server-first архитектуру.

Задачи:

- [x] Создать `backend/symmetry/`
- [x] Поднять `PostgreSQL + pgvector`
- [x] Добавить auth tables и API
- [x] Добавить campaigns tables и server turn processing
- [x] Добавить local embeddings и RAG
- [x] Добавить story library API
- [x] Добавить billing-ready schema placeholders
- [x] Подключить Flutter к backend auth и campaign flow
- [x] Разрешить transient user provider credentials
- [x] Полностью убрать legacy local campaign flow из runtime-кода
- [x] Добавить Alembic migrations и startup rollout

Ожидаемый результат:

- [x] Сервер стал источником истины для кампаний и мира
- [x] Flutter больше не зависит от локального campaign persistence
- [x] Story library доступна в backend/API
- [x] Пользовательские AI-ключи не хранятся на сервере

## Текущие открытые инженерные follow-ups

### 1. OAuth production validation

- [ ] Проверить Yandex OAuth с живыми redirect/callback credentials
- [ ] Зафиксировать production callback URLs и окружения
- [ ] Добавить smoke-check сценарий для OAuth login

### 2. Production rollout hardening

- [ ] Описать deploy checklist для server rollout
- [ ] Добавить backup/restore инструкцию для БД
- [ ] Добавить post-deploy smoke checks
- [ ] Зафиксировать rollback-порядок при неуспешной миграции

### 3. Next product layer

- [ ] Выбрать следующий product layer поверх server-first архитектуры
- [ ] Подготовить новый feature packet
- [ ] Зафиксировать PRD и architecture для следующего слоя

## Definition of Done для текущего плана

- [x] Клиент и backend работают в одной server-first модели
- [x] Кампании больше не живут в локальном runtime storage
- [x] Все изменения схемы БД идут через Alembic
- [x] Игровой ход проходит через backend с RAG и persistence
- [x] Документация обновлена под текущую архитектуру
- [ ] Production rollout hardening завершён
- [ ] Yandex OAuth проверен на живых credentials
