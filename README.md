# AI_PRG

`Стирая Грань` / `Beyond the Verge` is a Flutter narrative RPG client paired
with a server-authoritative backend for world state, campaigns, and turn
processing.

## Current product shape

- `Flutter` is now a thin client for UI, auth, campaign creation, chat, and
  settings.
- the backend owns campaign persistence, world simulation, turn processing,
  vector memory, auth, and story-template APIs.
- `PostgreSQL + pgvector` stores campaign snapshots, world state, and
  `world_chronicles`.
- text embeddings run locally inside the backend via
  `sentence-transformers`.
- narrative generation goes through an OpenAI-compatible server gateway:
  - backend `.env` credentials are used by default;
  - user-supplied provider credentials can be sent transiently per request;
  - those user credentials are never stored on the server.

## What is implemented

- server-first gameplay flow with guest and account-based sessions;
- email/password auth plus Yandex OAuth scaffolding;
- backend-driven campaign creation, loading, deleting, and turn processing;
- server-side RAG over `world_chronicles`;
- background persistence of important story events into vector memory;
- story-template backend/API foundation with tags, likes, views, and bookmarks;
- Alembic migrations and Docker-based local deployment;
- Flutter auth/session flow and server-backed repositories;
- local client persistence only for settings, session, and user-owned AI keys.
- minimal auth UI:
  - no backend URL field on the sign-in form;
  - close button returns the user to the previous screen;
  - settings show a generic `Settings` title instead of `AI Settings`;
  - the account section shows only who is signed in and `Log in` / `Sign out`;
  - the server address is not shown or edited in settings.
- users can optionally provide their own AI model credentials in settings;
  those credentials stay only on the user's device and are sent transiently
  with requests when needed.

## Architecture snapshot

- client: `Flutter` + `flutter_riverpod`
- backend: `FastAPI`
- db: `PostgreSQL + pgvector`
- embeddings: `sentence-transformers` with
  `intfloat/multilingual-e5-base` on `onnx`
- text generation: OpenAI-compatible provider access through backend gateway
- auth/session storage on client: local settings storage only

## Repository layout

- Flutter app: [lib/](/D:/AI_PRG/lib)
- backend: [backend/symmetry/](/D:/AI_PRG/backend/symmetry)
- feature docs: [docs/features/](/D:/AI_PRG/docs/features)
- main architecture doc: [Architecture.md](/D:/AI_PRG/Architecture.md)
- main product requirements: [PRD.md](/D:/AI_PRG/PRD.md)
- roadmap: [ImplementationPlan.md](/D:/AI_PRG/ImplementationPlan.md)

## Local development

### Flutter

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --no-tree-shake-icons
```

### Backend

```bash
cd backend/symmetry
python -m pytest tests
python -m compileall app alembic
```

### Full local stack

```bash
docker compose up --build
```

This starts PostgreSQL with `pgvector` and the `Symmetry` API. The backend
container applies `alembic upgrade head` before launching `uvicorn`.

### Preferred local web preview

For faithful local web preview, especially Material Icons, use the built web
bundle instead of a hot web-server session:

```bash
flutter build web --no-tree-shake-icons
python -m http.server 3010 --directory build/web
```

Then open `http://127.0.0.1:3010` and do a hard refresh after rebuilds if the
browser keeps old assets cached.

## Runtime model credentials

There are two supported ways to reach text-generation models:

1. Server-managed credentials from `backend/symmetry/.env`
2. User-managed credentials entered in the Flutter app

Important rule:

- user-managed credentials are stored only on the user's device;
- Flutter may pass them to the backend for a single request;
- the backend must not write them to the database, snapshots, logs, or
  background jobs.

## Main APIs

- auth:
  - `POST /v1/auth/guest`
  - `POST /v1/auth/register`
  - `POST /v1/auth/login`
  - `POST /v1/auth/refresh`
  - `POST /v1/auth/logout`
  - `GET /v1/auth/me`
  - `GET /v1/auth/yandex/start`
  - `GET /v1/auth/yandex/callback`
- campaigns:
  - `POST /v1/campaigns`
  - `GET /v1/campaigns`
  - `GET /v1/campaigns/{id}`
  - `GET /v1/campaigns/{id}/state`
  - `POST /v1/campaigns/{id}/turns/process`
  - `DELETE /v1/campaigns/{id}`
- prompts:
  - `POST /v1/prompts/generate`
- providers:
  - `POST /v1/providers/check`
- story library:
  - `GET /v1/story-templates`
  - `GET /v1/story-templates/{id}`
  - `POST /v1/story-templates`
  - `PATCH /v1/story-templates/{id}`
  - `POST /v1/story-templates/{id}/like`
  - `POST /v1/story-templates/{id}/view`
  - `POST /v1/story-templates/{id}/bookmark`

## Key documents

- [Agent / AI onboarding](/D:/AI_PRG/docs/AGENT_CONTEXT.md)
- [Feature catalog](/D:/AI_PRG/docs/features/CATALOG.md)
- [Features workflow](/D:/AI_PRG/docs/features/README.md)
- [Backend feature packet](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/README.md)
- [Web deploy notes](/D:/AI_PRG/docs/DEPLOY_WEB.md)

## Current follow-up work

- real end-to-end Yandex OAuth verification with live callback credentials;
- production rollout hardening around migrations, backup, health checks, and
  deploy order;
- next product layer on top of the now server-authoritative gameplay stack.
