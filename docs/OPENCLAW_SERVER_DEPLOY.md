# OpenClaw Server Deploy Guide

This guide is for an AI agent running on the target server through
`OpenClaw`.

It is intentionally explicit:

- which archive is for the frontend
- which Docker files are for the backend
- which `.env` file to create
- which commands to run
- what to verify after startup

## Deployment artifacts

### Frontend archive

Use this web build archive:

- `ai_prg_web_build_20260407_142100.zip`

Expected SHA256:

```text
56528ded3baa49d7c47c6b9f46e7a3738812dc9c7983d0730c65132c7f764c36
```

This archive is safe for server deployment:

- it does **not** embed provider API keys
- it is built for backend access through `AI_PRG_SYMMETRY_BASE_URL=/v1`
- it expects the web server to proxy `/v1/*` to the backend API

### Backend Docker files

The backend Docker deployment uses these files from the repository:

- `docker-compose.prod.yml`
- `backend/symmetry/Dockerfile`
- `backend/symmetry/start.sh`
- `backend/symmetry/start_worker.sh`
- `backend/symmetry/.env.production.example`
- `deploy/nginx/default.prod.conf`

## Recommended server layout

Example layout:

- `/opt/ai-rpg/app` for the git repository
- `/opt/ai-rpg/packages` for uploaded archives
- `/opt/ai-rpg/app/deploy/web` for unpacked frontend files

## What the AI agent must do

1. Clone or update the repository.
2. Upload or place the frontend archive on the server.
3. Copy `backend/symmetry/.env.production.example` to `backend/symmetry/.env`.
4. Fill production secrets and URLs.
5. Unpack the frontend archive into `deploy/web`.
6. Start the production Docker stack with `docker-compose.prod.yml`.
7. Verify health and smoke-test auth, prompt generation, campaign creation,
   turn processing, and rumors.

## Required backend env file

Create:

- `/opt/ai-rpg/app/backend/symmetry/.env`

Start from:

- `/opt/ai-rpg/app/backend/symmetry/.env.production.example`

Minimum required values to change:

```env
SYMMETRY_ENV=production
SYMMETRY_JWT_SECRET=replace-with-a-long-random-secret

SYMMETRY_SERVER_LLM_BASE_URL=https://your-relay-or-provider.example/v1
SYMMETRY_SERVER_LLM_MODEL=deepseek-chat
SYMMETRY_SERVER_LLM_API_KEY=replace-with-real-key

SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/v1/auth/yandex/callback
```

Recommended:

- point `SYMMETRY_SERVER_LLM_BASE_URL` to your `VPS relay`, not directly to the
  public model provider
- keep the relay reachable by fixed IP or VPN address when possible

## Full deployment sequence for the AI agent

### 1. Prepare directories

```bash
mkdir -p /opt/ai-rpg
mkdir -p /opt/ai-rpg/packages
mkdir -p /opt/ai-rpg/app
```

### 2. Fetch repository

```bash
cd /opt/ai-rpg
if [ ! -d app/.git ]; then
  git clone https://github.com/svc-alexey/AI_RPG.git app
else
  cd app && git pull --ff-only && cd ..
fi
```

### 3. Put the frontend archive on the server

Place:

- `/opt/ai-rpg/packages/ai_prg_web_build_20260407_142100.zip`

Optional integrity check:

```bash
cd /opt/ai-rpg/packages
sha256sum ai_prg_web_build_20260407_142100.zip
```

Expected hash:

```text
56528ded3baa49d7c47c6b9f46e7a3738812dc9c7983d0730c65132c7f764c36
```

### 4. Create backend env

```bash
cd /opt/ai-rpg/app
cp backend/symmetry/.env.production.example backend/symmetry/.env
```

Then edit:

- `/opt/ai-rpg/app/backend/symmetry/.env`

### 5. Unpack frontend into the Docker-served web folder

```bash
cd /opt/ai-rpg/app
rm -rf deploy/web
mkdir -p deploy/web
unzip -o /opt/ai-rpg/packages/ai_prg_web_build_20260407_142100.zip -d deploy/web
```

### 6. Start production Docker stack

```bash
cd /opt/ai-rpg/app
docker compose -f docker-compose.prod.yml up --build -d
```

This starts:

- `postgres`
- `symmetry-api`
- `symmetry-worker`
- `web` (`nginx`)

### 7. Check container state

```bash
cd /opt/ai-rpg/app
docker compose -f docker-compose.prod.yml ps
```

### 8. Check backend health

From the server itself:

```bash
curl -fsS http://127.0.0.1/health
```

Or directly to the API container through published nginx proxy:

```bash
curl -fsS http://127.0.0.1/v1/auth/guest -X POST -H 'Content-Type: application/json' -d '{}'
```

### 9. Check logs if needed

```bash
docker logs ai-rpg-api --tail 100
docker logs ai-rpg-worker --tail 100
docker logs ai-rpg-web --tail 100
```

## How the production Docker stack works

### Web

- container: `web`
- image: `nginx:alpine`
- serves static files from `deploy/web`
- proxies `/v1/*` to `symmetry-api:8080`

### Backend API

- container: `ai-rpg-api`
- built from `backend/symmetry/Dockerfile`
- startup command comes from `backend/symmetry/start.sh`
- runs `alembic upgrade head` before starting `uvicorn`

### Worker

- container: `ai-rpg-worker`
- built from the same backend image
- startup command comes from `backend/symmetry/start_worker.sh`
- required for butterfly jobs and rumor generation

### Database

- container: `ai-rpg-postgres`
- uses `pgvector/pgvector:pg16`

## DNS and model-provider note

If direct provider access is used, the agent should verify DNS inside the API
container:

```bash
docker exec ai-rpg-api python -c "import socket; print(socket.gethostbyname('api.deepseek.com'))"
```

If using a VPS relay instead, replace the hostname above with the relay host.

If DNS resolution fails:

- do not blame the web app first
- inspect `docker logs ai-rpg-api`
- verify the relay/provider hostname from inside the API container
- prefer a VPS relay reachable by fixed IP or VPN address for home-server
  production

## Smoke tests the AI agent should run

The agent should verify all of these after deploy:

1. `GET /health`
2. `POST /v1/auth/guest`
3. `POST /v1/prompts/generate`
4. `POST /v1/campaigns`
5. `POST /v1/campaigns/{id}/turns/process`
6. `GET /v1/campaigns/{id}/rumors`

## Minimal smoke sequence

### Guest auth

```bash
curl -fsS http://127.0.0.1/v1/auth/guest \
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{}'
```

### Backend health

```bash
curl -fsS http://127.0.0.1/health
```

### Provider reachability

```bash
curl -fsS http://127.0.0.1/v1/providers/check \
  -X POST \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"allow_server_fallback":true}'
```

## Important rules for the AI agent

- do not deploy only the API container; the worker is mandatory
- do not edit the frontend archive contents manually
- do not store user AI credentials in server-side files or database rows
- if the browser shows a CORS-looking gameplay failure, inspect backend logs
  before changing nginx
- use `docker-compose.prod.yml` for server deployment, not the local dev compose

## Quick summary

Frontend:

- upload `ai_prg_web_build_20260407_141200.zip`
- upload `ai_prg_web_build_20260407_142100.zip`
- unpack into `deploy/web`
- serve through the `web` container from `docker-compose.prod.yml`

Backend:

- copy `backend/symmetry/.env.production.example` to `backend/symmetry/.env`
- fill real production values
- run `docker compose -f docker-compose.prod.yml up --build -d`

Smoke checks:

- `/health`
- guest auth
- prompt generation
- campaign creation
- first turn
- rumors
