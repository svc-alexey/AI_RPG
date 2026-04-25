# Symmetry backend

Server-authoritative backend for `AI_PRG`.

Note: `Symmetry` is an internal backend codename. User-facing Flutter copy
should not expose it unless there is a deliberate product reason.

## What is included

- `FastAPI` API for auth, campaigns, turn processing, and story templates
- `PostgreSQL + pgvector` storage
- local embeddings via `sentence-transformers`
  with `intfloat/multilingual-e5-base` on the `onnx` backend
- OpenAI-compatible LLM gateway with transient user credentials support
- guest sessions plus account sessions for client access
- Yandex OAuth endpoints for web sign-in, with runtime `redirect_uri`
  override support
- DB-backed butterfly simulation with `simulation_jobs`,
  `pending_consequences`, and persistent `world_entities`
- dedicated worker process for background consequence expansion and chronicle
  persistence
- mode-aware narrative generation:
  - `shortStory` stays compact;
  - `longCampaign` uses richer prompt generation and a visible prologue on the
    first auto intro-turn
- stable-prefix LLM request architecture for prompt caching
- persisted LLM usage metadata on each processed campaign turn
- structured scene continuity state persisted in campaign snapshots and passed
  to the model for immediate beat-to-beat narration
- scenario-aware token budgets and compact turn context assembly
- dev-only usage analytics endpoint protected by a server token
- dev-only turn-debug endpoint for inspecting the exact compact context, scene
  state, and RAG summary used for a processed turn
- root `/version` contract for `web` and `desktop` clients
- `world rumors` API for compact off-screen event summaries consumed by the
  Flutter campaign screen

## Local run

The backend supports two local development modes:

- `python/uvicorn` on Windows/macOS/Linux outside Docker
- `docker compose` with the API container and Postgres inside Docker
- `docker compose` with API + worker + Postgres inside Docker

The default `.env` is now tuned for the first case: local Python process +
Postgres exposed on `localhost:5432`. Docker Compose overrides the DB host and
model directory for the container automatically.

Configuration notes:

- `.env` is resolved relative to `backend/symmetry`, not the current shell
  working directory;
- precedence is `environment variables > .env > code defaults`;
- the same `backend/symmetry/.env` is used by both `symmetry-api` and
  `symmetry-worker` under `docker compose`.

The compose stack also mounts:

- `infra/postgres/postgresql.conf` for PostgreSQL tuning
- `infra/postgres/init/01_pgvector.sql` for initial extension setup

1. Copy `backend/symmetry/.env.example` to `.env` and fill secrets.
2. Apply migrations:

```powershell
alembic upgrade head
```

3. Start services:

```powershell
docker compose up --build
```

The Docker image also runs `alembic upgrade head` before starting `uvicorn`, so
local containers and server deploys use the same schema rollout step.

Compose now starts:

- `postgres`
- `symmetry-api`
- `symmetry-worker`

If you run the backend directly from Python instead of Docker:

```powershell
cd backend/symmetry
alembic upgrade head
python -m uvicorn app.main:app --host 127.0.0.1 --port 8080
python -m app.workers.butterfly_worker
```

Development request logs are written to `backend/symmetry/logs/symmetry-dev.log`.

For private usage analytics, the backend can also expose `GET /v1/dev/usage`
when `SYMMETRY_DEV_ADMIN_TOKEN` is configured. Access requires header
`X-Symmetry-Dev-Token`.

4. Open docs:

`http://localhost:8080/docs`

If you are resetting the local vector store for the new `768`-dimensional
embeddings, stop the stack and remove the Postgres volume before the next
`docker compose up --build`.

## Web preview pairing

For local web preview, the preferred frontend path is:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

This mirrors deployed static asset loading more closely than a temporary
Flutter web-server session and keeps release artifacts aligned, including:

- `version.json`
- `robots.txt`
- `sitemap.xml`
- `flutter_service_worker.js`

## Yandex OAuth notes

The backend exposes:

- `GET /v1/auth/yandex/start`
- `GET /v1/auth/yandex/callback`

The intended web flow is:

1. the Flutter web client opens `/v1/auth/yandex/start`
2. the backend redirects to Yandex
3. Yandex returns the browser to the backend callback
   `/v1/auth/yandex/callback?code=...&state=...`
4. the backend exchanges the code at Yandex `POST /token`, creates a one-time
   auth handoff, and redirects the browser to the Flutter route
   `/auth/yandex/callback?handoff=...`
5. Flutter calls `POST /v1/auth/yandex/complete`
6. Flutter stores the returned auth session locally

Default env configuration should point at the backend callback route plus the
public web origin. Examples:

- local preview:
  `SYMMETRY_YANDEX_REDIRECT_URI=http://127.0.0.1:8080/v1/auth/yandex/callback`
  and `SYMMETRY_WEB_PUBLIC_ORIGIN=http://127.0.0.1:3010`
- production:
  `SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/v1/auth/yandex/callback`
  and `SYMMETRY_WEB_PUBLIC_ORIGIN=https://your-domain.example`

The same backend callback URL must also be registered in the Yandex OAuth
application.

## Important credential rule

User-supplied provider credentials are accepted only per request and are never
written to database rows, snapshots, logs, or background jobs.

The request schemas accept both `snake_case` and legacy `camelCase` field names
for web-client compatibility. Examples:

- `literary_genre` or `literaryGenre`
- `story_prompt` or `storyPrompt`
- `provider_credentials` or `providerCredentials`
- `player_action` or `playerAction`
- `client_turn_id` or `clientTurnId`

## Dev usage analytics

The backend now supports dev-only admin endpoints for token analysis and turn
forensics:

- `GET /v1/dev/usage`
- `GET /v1/dev/campaigns/{id}/turn-debug`

Protection model:

- disabled unless `SYMMETRY_DEV_ADMIN_TOKEN` is set;
- requires request header `X-Symmetry-Dev-Token`;
- intended for direct admin/server usage only.

Useful env vars:

- `SYMMETRY_DEV_ADMIN_TOKEN`
- `SYMMETRY_DEV_USAGE_DEFAULT_DAYS`
- `SYMMETRY_DEV_USAGE_MAX_ROWS`

## Main auth and gameplay endpoints

- `GET /health`
- `GET /version`
- `GET /v1/dev/usage` with `X-Symmetry-Dev-Token`
- `GET /v1/dev/campaigns/{id}/turn-debug` with `X-Symmetry-Dev-Token`
- `POST /v1/auth/guest`
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `POST /v1/auth/logout`
- `GET /v1/auth/me`
- `GET /v1/auth/yandex/start`
- `GET /v1/auth/yandex/callback`
- `POST /v1/auth/yandex/complete`
- `POST /v1/campaigns`
- `GET /v1/campaigns`
- `GET /v1/campaigns/{id}`
- `GET /v1/campaigns/{id}/state`
- `GET /v1/campaigns/{id}/rumors`
- `POST /v1/campaigns/{id}/turns/process`
- `POST /v1/prompts/generate`
  - request body includes `setting`, `literary_genre`, `mode`, `difficulty`,
  `language`, `story_wish`
- `POST /v1/providers/check`

## Turn-processing notes

- turn generation is split into:
  - a stable cached prefix
  - a dynamic final user message with mutable runtime state
- immutable campaign bootstrap, world bootstrap, and character brief are kept
  at the start of the `messages` array for provider cache hits
- mutable turn state, recent memory, relevant chronicles, and player action
  are sent only in the dynamic tail
- immediate continuity is carried by `scene_state`, including:
  - `scene_anchor`
  - `current_phase`
  - `last_completed_beat`
  - `interaction_targets`
  - `latest_player_intent`
- the model is expected to return `scene_state_patch` so the runtime can
  advance the current scene instead of replaying already completed beats
- RAG remains responsible for world/background recall, not for "what happened
  one turn ago"
- turn and prompt-generation requests now use scenario-aware output budgets
  instead of one implicit shared output size
- turn processing accepts optional `client_turn_id` to make retried requests
  idempotent when the same turn submission is replayed
- processed turns persist both the parsed LLM payload and normalized usage
  fields such as:
  - `prompt_cache_hit_tokens`
  - `prompt_cache_miss_tokens`
  - `prompt_tokens`
  - `total_tokens`
  - `budget_scenario`
  - `prompt_cache_hit_ratio`
- processed turn usage may also include:
  - `request_id`
  - `client_turn_id`
  - `turn_debug`
- intro-turns do not store an empty player message
- if the current location is still `Starting Point` / `Начальная точка`, the
  runtime replaces it with a concrete opening location before snapshot save
- the model may explicitly activate/deactivate gameplay modules through
  `state_changes.module_updates`
- `vitality` is not expected by default for every campaign; if the model wants
  it, it should also provide the actual stat block through `character_patch`

## Narrative mode notes

- `mode` is persisted in campaign state from creation onward.
- initial campaign snapshots also keep `custom_story_prompt`, which is reused
  in later turn context assembly.
- both story modes feed the butterfly layer:
  - `shortStory` creates fewer, faster consequences;
  - `longCampaign` allows longer chains and broader company/faction fallout.
- for `longCampaign` + `trigger_source=intro` + `turn_number=0`, the LLM is
  instructed to produce:
  - paragraph 1: visible prologue / backstory
  - paragraph 2: opening scene and immediate entry point
  - up to 3 short choices

## Docker production notes

- if the backend reaches the model provider directly, container DNS must be
  able to resolve that upstream host;
- if you deploy through a VPS relay, point
  `SYMMETRY_SERVER_LLM_BASE_URL` at the relay instead of the public provider;
- for home-server deployments, a fixed IP or VPN address to the relay is more
  robust than relying on provider DNS from the game container;
- provider/network errors are normalized to backend `4xx/5xx` responses instead
  of surfacing as raw container exceptions.
