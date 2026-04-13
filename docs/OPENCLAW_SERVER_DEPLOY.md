# OpenClaw Server Deploy Guide

This guide is for an AI agent running on the target server through
`OpenClaw`.

It is intentionally explicit:

- which archive is for the frontend
- which Docker files are for the backend
- which `.env` file to create
- which commands to run
- what to verify after startup

## Fill this before handing the task to OpenClaw

Before you give this instruction to the server agent, replace placeholders in:

- [OPENCLAW_DEPLOY_PROMPT_20260407T212959Z.md](/D:/AI_PRG/docs/OPENCLAW_DEPLOY_PROMPT_20260407T212959Z.md)
- `backend/symmetry/.env.production.example` or your production `backend/symmetry/.env`

Minimum fields you should fill in first:

- `SYMMETRY_JWT_SECRET`
- `SYMMETRY_SERVER_LLM_BASE_URL`
- `SYMMETRY_SERVER_LLM_MODEL`
- `SYMMETRY_SERVER_LLM_API_KEY`
- `SYMMETRY_YANDEX_CLIENT_ID` and `SYMMETRY_YANDEX_CLIENT_SECRET` if Yandex login is enabled
- `SYMMETRY_FEEDBACK_RECIPIENT_EMAIL`
- `SYMMETRY_FEEDBACK_SENDER_EMAIL`
- `SYMMETRY_FEEDBACK_SMTP_HOST`
- `SYMMETRY_FEEDBACK_SMTP_PORT`
- `SYMMETRY_FEEDBACK_SMTP_USERNAME`
- `SYMMETRY_FEEDBACK_SMTP_PASSWORD`
- `SYMMETRY_FEEDBACK_SMTP_USE_SSL`
- `SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS`

## Deployment artifacts

### Frontend archive

Use this web build archive:

- `ai_prg_web_build_20260407T212959.zip`

Expected SHA256:

```text
e25d87a1e74f32ca7c5f9ff1b78110f04f3dd1027e618586df74bdf2c4026c3e
```

This archive is safe for server deployment:

- it does **not** embed provider API keys
- it is built for backend access through `AI_PRG_SYMMETRY_BASE_URL=/v1`
- it expects the web server to proxy `/v1/*` to the backend API
- it ships `version.json`, `robots.txt`, `sitemap.xml`, and
  `flutter_service_worker.js`

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
7. Verify `/health`, `/version`, guest auth, prompt generation, campaign
   creation, turn processing, rumors, and web release metadata.

## Required backend env file

Create:

- `/opt/ai-rpg/app/backend/symmetry/.env`

Start from:

- `/opt/ai-rpg/app/backend/symmetry/.env.production.example`

Minimum required values to change:

```env
SYMMETRY_ENV=production
SYMMETRY_JWT_SECRET=replace-with-a-long-random-secret

SYMMETRY_SERVER_LLM_BASE_URL=https://api.deepseek.com/v1
SYMMETRY_SERVER_LLM_MODEL=deepseek-chat
SYMMETRY_SERVER_LLM_API_KEY=replace-with-real-key

SYMMETRY_RELEASE_ID=web-20260407T212959Z
SYMMETRY_RELEASED_AT=2026-04-07T21:29:59Z
SYMMETRY_WEB_LATEST_VERSION=1.0.0+1
SYMMETRY_WEB_MINIMUM_SUPPORTED_VERSION=1.0.0+1
SYMMETRY_WEB_ASSET_VERSION=web-20260407T212959Z

SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/v1/auth/yandex/callback
SYMMETRY_WEB_PUBLIC_ORIGIN=https://your-domain.example
```

Feedback email SMTP credentials:

```env
SYMMETRY_FEEDBACK_RECIPIENT_EMAIL=feedback@your-domain.example
SYMMETRY_FEEDBACK_SENDER_EMAIL=no-reply@your-domain.example
SYMMETRY_FEEDBACK_EMAIL_SUBJECT_PREFIX=Landing feedback
SYMMETRY_FEEDBACK_SMTP_HOST=smtp.your-provider.example
SYMMETRY_FEEDBACK_SMTP_PORT=465
SYMMETRY_FEEDBACK_SMTP_USERNAME=no-reply@your-domain.example
SYMMETRY_FEEDBACK_SMTP_PASSWORD=replace-with-real-password
SYMMETRY_FEEDBACK_SMTP_USE_SSL=true
SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS=false
```

Rules for mail setup:

- put these values into `backend/symmetry/.env` on the server
- `SYMMETRY_FEEDBACK_RECIPIENT_EMAIL` is where landing feedback is delivered
- `SYMMETRY_FEEDBACK_SENDER_EMAIL` is the visible From address
- if your provider requires port `587`, use `SYMMETRY_FEEDBACK_SMTP_USE_SSL=false`
  and `SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS=true`
- if your provider requires implicit SSL on port `465`, keep
  `SYMMETRY_FEEDBACK_SMTP_USE_SSL=true`
- feedback email sending is considered configured only when
  `SYMMETRY_FEEDBACK_SMTP_HOST`, `SYMMETRY_FEEDBACK_SENDER_EMAIL`, and
  `SYMMETRY_FEEDBACK_RECIPIENT_EMAIL` are all set

Recommended:

- point `SYMMETRY_SERVER_LLM_BASE_URL` to your `VPS relay`, not directly to the
  public model provider
- keep the relay reachable by fixed IP or VPN address when possible
- register the exact same `/v1/auth/yandex/callback` URL in the Yandex OAuth app

Yandex OAuth note:

- Yandex returns to the backend callback `/v1/auth/yandex/callback`
- the backend exchanges the `code`, creates a one-time handoff, and redirects
  the browser to the Flutter route `/auth/yandex/callback?handoff=...`
- Flutter completes the flow through `POST /v1/auth/yandex/complete`
- do not configure the Yandex callback to the frontend `/auth/yandex/callback`

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

- `/opt/ai-rpg/packages/ai_prg_web_build_20260407T212959.zip`

Optional integrity check:

```bash
cd /opt/ai-rpg/packages
sha256sum ai_prg_web_build_20260407T212959.zip
```

Expected hash:

```text
e25d87a1e74f32ca7c5f9ff1b78110f04f3dd1027e618586df74bdf2c4026c3e
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
unzip -o /opt/ai-rpg/packages/ai_prg_web_build_20260407T212959.zip -d deploy/web
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

Check release metadata too:

```bash
curl -fsS http://127.0.0.1/version
curl -fsS http://127.0.0.1/version.json
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
- proxies `/v1/*`, `/health`, and `/version` to `symmetry-api:8080`

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
2. `GET /version`
3. `GET /version.json`
4. `POST /v1/auth/guest`
5. `POST /v1/prompts/generate`
6. `POST /v1/campaigns`
7. `POST /v1/campaigns/{id}/turns/process`
8. `GET /v1/campaigns/{id}/rumors`
9. optional: open `/v1/auth/yandex/start` in a browser and verify the redirect
   target uses your configured public callback URL

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

- upload `ai_prg_web_build_20260407T212959.zip`
- verify SHA256 `e25d87a1e74f32ca7c5f9ff1b78110f04f3dd1027e618586df74bdf2c4026c3e`
- unpack into `deploy/web`
- serve through the `web` container from `docker-compose.prod.yml`

Backend:

- copy `backend/symmetry/.env.production.example` to `backend/symmetry/.env`
- fill real production values
- run `docker compose -f docker-compose.prod.yml up --build -d`

Smoke checks:

- `/health`
- `/version`
- `/version.json`
- guest auth
- prompt generation
- campaign creation
- first turn
- rumors
