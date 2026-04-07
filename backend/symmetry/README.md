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
- DB-backed butterfly simulation with `simulation_jobs`,
  `pending_consequences`, and persistent `world_entities`
- dedicated worker process for background consequence expansion and chronicle
  persistence
- mode-aware narrative generation:
  - `shortStory` stays compact;
  - `longCampaign` uses richer prompt generation and a visible prologue on the
    first auto intro-turn
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

4. Open docs:

`http://localhost:8080/docs`

If you are resetting the local vector store for the new `768`-dimensional
embeddings, stop the stack and remove the Postgres volume before the next
`docker compose up --build`.

## Web preview pairing

For local web preview, the preferred frontend path is:

```powershell
flutter build web --no-tree-shake-icons
python -m http.server 3010 --directory build/web
```

This mirrors deployed static asset loading more closely than a temporary
Flutter web-server session and avoids common icon/font asset glitches during
development.

## Important credential rule

User-supplied provider credentials are accepted only per request and are never
written to database rows, snapshots, logs, or background jobs.

The request schemas accept both `snake_case` and legacy `camelCase` field names
for web-client compatibility. Examples:

- `literary_genre` or `literaryGenre`
- `story_prompt` or `storyPrompt`
- `provider_credentials` or `providerCredentials`
- `player_action` or `playerAction`

## Main auth and gameplay endpoints

- `POST /v1/auth/guest`
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `POST /v1/auth/logout`
- `GET /v1/auth/me`
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
