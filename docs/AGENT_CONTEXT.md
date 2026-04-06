# AI_PRG — контекст для AI-агентов

Краткая точка входа: продукт, код, фичи, процесс.

## Продукт

- **Жанр:** narrative RPG на Flutter с server-authoritative backend
  `Symmetry`.
- **Источник истины:** backend runtime и сохранённое серверное состояние
  кампании; не UI и не свободный текст модели.
- **Клиент:** Flutter хранит только настройки, язык, server session и
  пользовательские AI-ключи. Адрес backend-а не редактируется пользователем
  через экран настроек.
- **Кампании:** живут на сервере. Legacy local campaign persistence удалён из
  runtime-кода и тестовой инфраструктуры.
- **AI:** OpenAI-compatible gateway находится на backend. Клиент может
  передавать user-owned provider credentials transiently, но backend не должен
  их сохранять.
- **Языки:** обязательны `ru` и `en`.
- **UX:** mobile-first, но desktop поддерживается.
- **User-facing copy:** не показывать пользователю внутреннее кодовое имя
  backend-а без необходимости; предпочитать нейтральные формулировки вроде
  `аккаунт`, `сервер игры`, `настройки`.
- **Статус:** pre-prod, локальная разработка идёт в server-first модели.

## Стек

- client: Flutter, `flutter_riverpod`
- local client storage: настройки и session state
- backend: FastAPI
- DB: PostgreSQL + pgvector
- embeddings: `sentence-transformers`
- migrations: Alembic

## Карта кода

| Зона | Путь |
|------|------|
| Точка входа Flutter | `lib/main.dart` |
| Приложение и bootstrap | `lib/src/app/` |
| Фичи UI | `lib/src/features/` |
| Репозитории клиента | `lib/src/core/repositories/` |
| API клиент | `lib/src/core/services/symmetry_api_client.dart` |
| Backend | `backend/symmetry/` |
| Backend routes | `backend/symmetry/app/api/routes/` |
| Backend services | `backend/symmetry/app/services/` |
| Backend DB models | `backend/symmetry/app/db/models.py` |
| Миграции | `backend/symmetry/alembic/` |

## Высокоуровневый runtime flow

1. Flutter получает guest session автоматически или обычную account session
   после входа.
2. Flutter хранит session tokens локально.
3. Flutter создаёт или загружает кампанию через backend.
4. Ход уходит в `POST /v1/campaigns/{id}/turns/process`.
5. Backend делает RAG, вызывает модель, применяет state changes, сохраняет
   snapshot и возвращает новое состояние.

## Инварианты

1. AI output недоверенный до валидации.
2. Сервер является источником истины для кампаний и мира.
3. Любая схема БД меняется через Alembic migration.
4. Пользовательские AI-креды не должны попадать в БД, snapshot-ы, логи или
   background jobs.
5. UI-задача не считается завершённой, если она сделана только для одного из
   языков `ru/en`.

## Реестр важных фич

| Slug | Статус | Где смотреть |
|------|--------|--------------|
| `symmetry-hybrid-backend` | implemented-with-followup | `backend/symmetry`, Flutter auth/campaign integration |
| `deterministic-systems` | implemented | исторический продуктовый слой, не authoritative runtime |
| `campaign-modules` | implemented | доменные модели кампании и UI-модули |
| `narrative-settings-genres` | implemented | мастер новой игры и prompt generation |

## Порядок чтения для агента

1. [`.cursorrules`](/D:/AI_PRG/.cursorrules)
2. [`.specify/memory/constitution.md`](/D:/AI_PRG/.specify/memory/constitution.md)
3. [`.specify/memory/project-context.md`](/D:/AI_PRG/.specify/memory/project-context.md)
4. [Architecture.md](/D:/AI_PRG/Architecture.md)
5. [PRD.md](/D:/AI_PRG/PRD.md)
6. [ImplementationPlan.md](/D:/AI_PRG/ImplementationPlan.md)
7. [docs/features/CATALOG.md](/D:/AI_PRG/docs/features/CATALOG.md)
8. папка конкретной фичи

## Workflow

- новая фича -> `docs/features/<slug>/` + запись в catalog + запись в plan
- ветка -> `codex/<slug>`
- до merge:
  - `flutter analyze`
  - `flutter test`
  - `python -m pytest tests` в `backend/symmetry`

## Что не делать

- не возвращать локальный campaign runtime flow;
- не складывать пользовательские provider credentials в серверное хранилище;
- не описывать старую local-first campaign architecture как текущую.
