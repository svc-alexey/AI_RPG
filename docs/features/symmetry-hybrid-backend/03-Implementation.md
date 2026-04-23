# Implementation

## Backend

- [x] Add `backend/symmetry/` FastAPI project
- [x] Add root [docker-compose.yml](/D:/AI_PRG/docker-compose.yml) with
  `PostgreSQL + pgvector` and backend API
- [x] Add auth, campaign, prompt-generation, provider-check, and
  story-template routes
- [x] Add SQLAlchemy models for auth, world, library, and billing scaffolding
- [x] Add local embedding service and OpenAI-compatible AI gateway
- [x] Add `CredentialResolutionService` for server/default vs transient user
  credentials
- [x] Add background chronicle persistence
- [x] Add Alembic configuration and initial migration
- [x] Change startup flow so schema rollout goes through `alembic upgrade head`
- [x] Add root `GET /health` and `GET /version` runtime endpoints
- [x] Add stable-prefix turn payload layout for provider prompt caching
- [x] Persist normalized LLM usage metadata on `CampaignTurn`
- [x] Add scenario-aware token budgets and compact turn-context assembly
- [x] Add private dev usage report endpoint protected by a server token
- [x] Add startup/location safety for `Starting Point` / `Начальная точка`
- [x] Stop storing empty player bubbles for intro-turns
- [x] Let the model activate/deactivate gameplay modules through
  `state_changes.module_updates`

## Flutter

- [x] Add `SymmetryAuthRepository`
- [x] Add `SymmetryCampaignRepository`
- [x] Add `SymmetryApiClient`
- [x] Add auth gate / auth screen
- [x] Move new-campaign flow to backend APIs
- [x] Move chat turn processing to backend APIs
- [x] Move saves screen to backend campaign list
- [x] Remove runtime local campaign persistence fallback
- [x] Keep user AI keys only in local client settings
- [x] Add `/version` client models and update-check repository/service
- [x] Add custom update gate for `soft` / `force` release handling
- [x] Move quick start and prompt generation to server-backed flow even when
  only the backend has provider credentials
- [x] Change chat autoscroll to follow player sends, not narrator growth
- [x] Limit `world rumors` and `recent events` to the latest 5 items
- [x] Stop enabling `vitality` by preset alone for server-backed campaigns

## Cleanup

- [x] Delete legacy local campaign repository and storage code
- [x] Remove campaign collections from client Isar schema
- [x] Rewrite tests to use server-first fakes instead of local campaign storage
- [x] Keep backend `.env` resolution stable across different local working
  directories
- [x] Keep web release artifacts (`version.json`, service worker, SEO files)
  aligned with backend release metadata

## Story library — шаблоны миров и обложки

Зафиксировано состояние на 2026-04: библиотека миров (`/v1/story-templates`),
обложки в БД, клиентский UX для Web.

### Backend (`backend/symmetry`)

- Обложка хранится в PostgreSQL: `cover_image_data` (BYTEA), `cover_image_mime`,
  флаг `cover_image_populated`; миграция `20260417_000009` (и далее по цепочке
  Alembic).
- В ответах каталога и карточки: `cover_image_href` вида
  `{api_prefix}/story-templates/{id}/cover` при `cover_image_populated` (префикс
  API — `/v1`).
- Маршруты: `GET /v1/story-templates/{id}/cover` (требуется Bearer, любой
  валидный пользователь, включая guest); админ: `PUT`/`DELETE`
  `/v1/admin/story-templates/{id}/cover`.
- При загрузке/снятии обложки обновляется `story_templates.updated_at` для
  cache-busting на клиенте.
- Список/карточка шаблонов доступны авторизованным пользователям согласно
  правилам каталога (master/community и т.д.).

### Flutter (`lib/src/...`)

- `SymmetryApiClient`: базовый URL нормализуется до `.../v1` для loopback без
  пути (`normalizeSymmetryApiBaseUrl`).
- `StoryTemplate.resolveCoverDisplayUrl`: склейка `symmetryBaseUrl` + `href`
  без дублирования `/v1` (если база уже `…/v1`, а `href` начинается с
  `/v1/…`, лишний префикс отбрасывается).
- Обложки с API: виджет `AuthenticatedCoverImage` — на **Web** `Image.network`
  не передаёт `Authorization`; загрузка байтов через `http` + `Image.memory`.
- `symmetrySessionProvider`: при отсутствии сессии на диске вызывается
  `ensureSession()` (guest), чтобы до первого логина были `baseUrl` и токен для
  запросов обложек.
- Библиотека: `RouteAware` + `didPopNext` — тихая перезагрузка списка при возврате
  с админки/деталей; к URL обложки добавляется `?v=<updatedAt ms>` против кэша
  браузера.
- Токен для `GET …/cover` передаётся и для **guest**-сессии (не только для
  «полного» логина).
- Старт кампании из карточки библиотеки использует `NewGameScreen(storyTemplateId: ...)`:
  шаблон загружается повторно, фиксируется как `StoryTemplateSeed`, после чего
  пользователь выбирает `shortStory` или `longCampaign`.
- Для `shortStory` открывается quick start с prompt шаблона и настройками
  героя. Для `longCampaign` открывается custom setup со step `foundation`,
  без повторного выбора жанра/сеттинга; на step `story` поле prompt уже
  заполнено текстом шаблона и редактируется пользователем.
- Backend API для этого flow не меняется: выбранный формат уходит как уже
  существующий `CampaignDraft.mode`, а prompt шаблона — как `story_prompt`.

### Ключевые файлы

| Назначение | Путь |
|------------|------|
| Клиент API | `lib/src/core/services/symmetry_api_client.dart` |
| Модель шаблона | `lib/src/core/models/story_template_model.dart` |
| Flow новой кампании | `lib/src/features/new_game/application/new_game_controller.dart` |
| Выбор длины из библиотеки | `lib/src/features/new_game/presentation/widgets/story_template_length_selection_view.dart` |
| Обложка с Bearer (Web) | `lib/src/features/story_library/presentation/widgets/authenticated_cover_image.dart` |
| Провайдер сессии | `lib/src/app/app_providers.dart` (`symmetrySessionProvider`) |
| Route observer | `lib/src/app/app_route_observer.dart` |
| Сервис библиотеки | `backend/symmetry/app/services/story_library.py` |
| GET cover | `backend/symmetry/app/api/routes/stories.py` |
