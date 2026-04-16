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
- background world simulation is persisted through DB-backed jobs and a
  dedicated worker process.
- text embeddings run locally inside the backend via
  `sentence-transformers`.
- narrative generation goes through an OpenAI-compatible server gateway:
  - backend `.env` credentials are used by default;
  - user-supplied provider credentials can be sent transiently per request;
  - those user credentials are never stored on the server.

## What is implemented

- server-first gameplay flow with guest and account-based sessions;
- email/password auth plus wired Yandex OAuth for the web sign-in flow;
- backend-driven campaign creation, loading, deleting, and turn processing;
- lifecycle/version endpoints for clients and web deploys:
  - `GET /health`
  - `GET /version`
- two story modes in campaign creation:
  - `shortStory`: compact entry, fast hook, lighter narration;
  - `longCampaign`: visible prologue on the first auto-turn plus more
    expanded ongoing narration;
- DeepSeek/OpenAI-compatible prompt-caching flow:
  - the backend keeps a stable cached prefix for immutable campaign/world
    bootstrap and character brief;
  - dynamic turn data is sent in the final user message only;
  - per-turn LLM usage now records
    `prompt_cache_hit_tokens` / `prompt_cache_miss_tokens` and total usage;
- token-optimization pass for server-first AI requests:
  - scenario-aware output budgets for prompt generation and turn processing;
  - compact runtime context for memory, chronicles, and player input;
  - a dev-only usage report endpoint protected by a server token;
- butterfly-effect background simulation for both story modes:
  - `shortStory`: lighter, local, short-lived ripple effects;
  - `longCampaign`: broader delayed effects for companies, factions,
    locations, and markets;
- server-side RAG over `world_chronicles`;
- background persistence of important story events plus off-screen world
  rumors into vector memory;
- story-template backend/API foundation with tags, likes, views, and bookmarks;
- Alembic migrations, separate worker runtime, and Docker-based local
  deployment;
- Flutter auth/session flow and server-backed repositories;
- local client persistence only for settings, session, and user-owned AI keys.
- custom update system:
  - backend exposes per-platform release metadata through `/version`;
  - Flutter uses a custom `soft` / `force` update gate instead of store-only
    upgrader flows;
  - web builds ship `version.json` and keep `flutter_service_worker.js`;
- web landing SEO/release artifacts:
  - title, description, canonical URL, Open Graph, and Twitter Card metadata;
  - `robots.txt` and `sitemap.xml` in the web bundle;
  - path-based URL strategy and scroll reset on load;
- minimal auth UI:
  - no backend URL field on the sign-in form;
  - close button returns the user to the previous screen;
  - web auth screen includes a `Sign in with Yandex` button;
  - settings show a generic `Settings` title instead of `AI Settings`;
  - the account section shows only who is signed in and `Log in` / `Sign out`;
  - the game-backend server address is not shown or edited in settings.
- users can optionally provide their own AI model credentials in settings,
  including provider `Base URL`;
  those credentials stay only on the user's device and are sent transiently
  with requests when needed.
- the campaign screen now shows `Слухи мира` directly under `Сводка`.
- chat/runtime bug fixes:
  - intro-turn no longer creates an empty player bubble;
  - `Начальная точка` / `Starting Point` is replaced with a real opening
    location on the first turn;
  - chat autoscroll happens on player send, not on narrator growth;
  - `Слухи мира` and `Последние события` show only the latest 5 entries in
    descending freshness order;
- campaign module logic is less hardcoded:
  - `vitality` is no longer enabled by setting preset alone;
  - server-backed campaigns no longer fabricate default RPG stats when the
    backend did not send them;
  - the backend model can explicitly activate/deactivate modules and provide
    stat blocks when a module like `vitality` is actually needed.

## Campaign creation flow

- `Quick start` now randomizes genre, setting, and story mode.
- quick-start story mode weighting is intentionally biased:
  - `shortStory`: `70%`
  - `longCampaign`: `30%`
- custom setup still lets the player choose `Story Mode` explicitly.
- prompt generation is mode-aware:
  - `shortStory` asks for a compact hook;
  - `longCampaign` asks for a richer story seed with world or hero backstory,
    a longer arc, and a more detailed protagonist brief.
- the backend stores the full `story_prompt` seed inside campaign state so
  long campaigns can keep using the original premise after reload.
- prompt and campaign endpoints accept both `snake_case` and legacy
  `camelCase` request payloads for web-client compatibility.

## Architecture snapshot

- client: `Flutter` + `flutter_riverpod`
- backend: `FastAPI`
- db: `PostgreSQL + pgvector`
- background jobs: DB queue + dedicated Python worker
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

This starts PostgreSQL with `pgvector`, the `Symmetry` API, and the dedicated
background worker. The backend container applies `alembic upgrade head` before
launching `uvicorn`.

### Preferred local web preview

For faithful local web preview, especially release metadata, service-worker
behavior, SEO files, and Material Icons, use the production-like web bundle
instead of a hot web-server session:

```bash
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

Then serve or mount `build/web` through a static host or nginx reverse proxy
that also forwards `/v1`, `/health`, and `/version` to the backend. During
local preview in this repository, `http://127.0.0.1:3010` is used.

## Runtime model credentials

There are two supported ways to reach text-generation models:

1. Server-managed credentials from `backend/symmetry/.env`
2. User-managed credentials entered in the Flutter app

Important rule:

- user-managed credentials are stored only on the user's device;
- Flutter may pass them to the backend for a single request;
- the backend must not write them to the database, snapshots, logs, or
  background jobs.

## Dev usage report

For server-side token analysis, the backend now exposes a private usage report
endpoint:

- `GET /v1/dev/usage`

It is intentionally not public:

- the endpoint is disabled unless `SYMMETRY_DEV_ADMIN_TOKEN` is configured on
  the server;
- access requires header `X-Symmetry-Dev-Token`;
- this endpoint is intended for direct server/admin usage, not for client UI.

Related env vars:

- `SYMMETRY_DEV_ADMIN_TOKEN`
- `SYMMETRY_DEV_USAGE_DEFAULT_DAYS`
- `SYMMETRY_DEV_USAGE_MAX_ROWS`

## Yandex OAuth setup

The current web OAuth flow is:

1. Flutter opens `GET /v1/auth/yandex/start`
2. the backend redirects the browser to Yandex OAuth with a signed short-lived
   `state`
3. Yandex returns the browser to the backend callback
   `/v1/auth/yandex/callback?code=...&state=...`
4. the backend exchanges the code with Yandex, creates a one-time auth handoff,
   and redirects the browser to the Flutter route
   `/auth/yandex/callback?handoff=...`
5. Flutter completes sign-in through `POST /v1/auth/yandex/complete`
6. Flutter stores the returned session locally (web: SharedPreferences)

Required backend env values:

- `SYMMETRY_YANDEX_CLIENT_ID`
- `SYMMETRY_YANDEX_CLIENT_SECRET`
- `SYMMETRY_YANDEX_REDIRECT_URI`
- `SYMMETRY_WEB_PUBLIC_ORIGIN`

Important callback note:

- for local backend preview, use
  `http://127.0.0.1:8080/v1/auth/yandex/callback`
- for local web return, use `http://127.0.0.1:3010`
- for production, use
  `SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/v1/auth/yandex/callback`
  and `SYMMETRY_WEB_PUBLIC_ORIGIN=https://your-domain.example`
- the backend callback URL must be allowed in the Yandex OAuth application
  settings
- the backend callback URL in Yandex and `SYMMETRY_YANDEX_REDIRECT_URI` must
  match **byte-for-byte**

## Main APIs

- runtime:
  - `GET /health`
  - `GET /version`
  - `GET /v1/dev/usage` with `X-Symmetry-Dev-Token`
- auth:
  - `POST /v1/auth/guest`
  - `POST /v1/auth/register`
  - `POST /v1/auth/login`
  - `POST /v1/auth/refresh`
  - `POST /v1/auth/logout`
  - `GET /v1/auth/me`
  - `GET /v1/auth/yandex/start`
  - `GET /v1/auth/yandex/callback`
  - `POST /v1/auth/yandex/complete`
- campaigns:
  - `POST /v1/campaigns`
  - `GET /v1/campaigns`
  - `GET /v1/campaigns/{id}`
  - `GET /v1/campaigns/{id}/state`
  - `GET /v1/campaigns/{id}/rumors`
  - `POST /v1/campaigns/{id}/turns/process`
  - `DELETE /v1/campaigns/{id}`
- prompts:
  - `POST /v1/prompts/generate`
    - expects `setting`, `literary_genre`, `mode`, `difficulty`, `language`,
      `story_wish`
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

## Secrets and environment files

- **Never commit** real API keys, OAuth secrets, SMTP passwords, or JWT secrets.
- Gitignored: `.env`, `.env.local`, `backend/symmetry/.env`, and similar (see
  [`.gitignore`](.gitignore)).
- Safe to commit: `*.env.example` templates with placeholders only.

## Key documents

- [Agent / AI onboarding](docs/AGENT_CONTEXT.md)
- [Feature catalog](docs/features/CATALOG.md)
- [Features workflow](docs/features/README.md)
- [Backend feature packet](docs/features/symmetry-hybrid-backend/README.md)
- [Web deploy notes](docs/DEPLOY_WEB.md)

## Current follow-up work

- real end-to-end Yandex OAuth verification with live callback credentials;
- production rollout hardening around migrations, backup, health checks,
  worker readiness, and deploy order;
- Docker production hardening around DNS resolution to the AI relay/provider;
- next product layer on top of the now server-authoritative gameplay stack.

## Recent production notes

Recent production hardening on `beyondtheverge.online` included:

- fixing web release stamping so `asset_version` matches `release_id`
  and web no longer loops on forced refresh prompts;
- hardening backend turn generation against truncated JSON and loose provider
  output types;
- expanding token/output budgets separately for `shortStory` and
  `longCampaign`;
- fixing settings-side provider checks so authenticated users can verify the
  server-managed model connection without filling local custom model fields;
- returning `404` for missing `*.map` files in nginx instead of serving
  `index.html`;
- reducing authenticated image flicker in the web UI;
- confirming production smoke tests with guest auth, campaign creation, intro
  turn, and follow-up manual turn.
