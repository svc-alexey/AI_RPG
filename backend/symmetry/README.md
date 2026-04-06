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

## Local run

The backend supports two local development modes:

- `python/uvicorn` on Windows/macOS/Linux outside Docker
- `docker compose` with the API container and Postgres inside Docker

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

If you run the backend directly from Python instead of Docker:

```powershell
cd backend/symmetry
alembic upgrade head
python -m uvicorn app.main:app --host 127.0.0.1 --port 8080
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
- `POST /v1/campaigns/{id}/turns/process`
- `POST /v1/prompts/generate`
- `POST /v1/providers/check`
