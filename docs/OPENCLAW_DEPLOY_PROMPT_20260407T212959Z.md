# OpenClaw deploy task for AI_RPG production

You are on the production server for AI_RPG. Deploy the new backend and web release safely using the repository checkout and Docker Compose.

## Fill these values before handing this task to the agent

Replace every placeholder below with real production values:

```env
PUBLIC_DOMAIN=beyondtheverge.online
REPO_ROOT=/opt/ai-rpg/app
PACKAGES_DIR=/opt/ai-rpg/packages
WEB_ARCHIVE_NAME=ai_prg_web_build_20260407T212959.zip

SYMMETRY_JWT_SECRET=replace-with-a-long-random-secret

SYMMETRY_SERVER_LLM_BASE_URL=https://api.deepseek.com/v1
SYMMETRY_SERVER_LLM_MODEL=deepseek-chat
SYMMETRY_SERVER_LLM_API_KEY=replace-with-llm-api-key

SYMMETRY_YANDEX_CLIENT_ID=36ed51485bd446b1acb805275a605500
SYMMETRY_YANDEX_CLIENT_SECRET=28f769a5119b47549510260582318b23
SYMMETRY_YANDEX_REDIRECT_URI=https://beyondtheverge.online/auth/yandex/callback

SYMMETRY_FEEDBACK_RECIPIENT_EMAIL=aleksey.shvetsov97@yandex.ru
SYMMETRY_FEEDBACK_SENDER_EMAIL=aleksey.shvetsov97@yandex.ru
SYMMETRY_FEEDBACK_EMAIL_SUBJECT_PREFIX=Landing feedback
SYMMETRY_FEEDBACK_SMTP_HOST=smtp.yandex.ru
SYMMETRY_FEEDBACK_SMTP_PORT=465
SYMMETRY_FEEDBACK_SMTP_USERNAME=aleksey.shvetsov97@yandex.ru
SYMMETRY_FEEDBACK_SMTP_PASSWORD=aqivgqzjoqykbpio
SYMMETRY_FEEDBACK_SMTP_USE_SSL=true
SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS=false
```

If your SMTP provider uses port `587`, set:

```env
SYMMETRY_FEEDBACK_SMTP_PORT=587
SYMMETRY_FEEDBACK_SMTP_USE_SSL=false
SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS=true
```

## Release payload

- Web archive: `ai_prg_web_build_20260407T212959.zip`
- Expected SHA256: `e25d87a1e74f32ca7c5f9ff1b78110f04f3dd1027e618586df74bdf2c4026c3e`
- Release ID: `web-20260407T212959Z`
- Released at: `2026-04-07T21:29:59Z`

## Goal

Update production so that:

- the backend serves `GET /health` and `GET /version`
- the frontend serves the new web bundle from `deploy/web`
- `/version.json` is reachable from the public site
- `/v1/*`, `/health`, and `/version` are proxied from web to backend
- the AI worker is running together with the API

## Working assumptions

- The repository is already present on the server.
- The production stack uses `docker-compose.prod.yml`.
- The public nginx config is based on `deploy/nginx/default.prod.conf`.
- The web archive is available on the server or can be uploaded into the repo root.

## Required files

1. Put the web archive in the repository root.
2. Verify its SHA256 before unpacking.
3. Copy `backend/symmetry/.env.production.example` to `backend/symmetry/.env` if the production env file is missing.
4. Make sure `backend/symmetry/.env` contains real production values and these release fields:

```env
SYMMETRY_API_VERSION=2.0
SYMMETRY_RELEASE_ID=web-20260407T212959Z
SYMMETRY_RELEASED_AT=2026-04-07T21:29:59Z
SYMMETRY_WEB_LATEST_VERSION=1.0.0+1
SYMMETRY_WEB_MINIMUM_SUPPORTED_VERSION=1.0.0+1
SYMMETRY_WEB_ASSET_VERSION=web-20260407T212959Z
SYMMETRY_WEB_UPDATE_MESSAGE=A new web version is available.
SYMMETRY_DESKTOP_LATEST_VERSION=1.0.0+1
SYMMETRY_DESKTOP_MINIMUM_SUPPORTED_VERSION=1.0.0+1
SYMMETRY_DESKTOP_UPDATE_URL=
SYMMETRY_DESKTOP_UPDATE_MESSAGE=A new desktop version is available.
```

## Deployment steps

1. Go to the repository root.
2. Verify archive checksum.
3. Remove old extracted files from `deploy/web`.
4. Unpack `ai_prg_web_build_20260407T212959.zip` into `deploy/web`.
5. Confirm that `deploy/web/version.json`, `deploy/web/robots.txt`, `deploy/web/sitemap.xml`, and `deploy/web/flutter_service_worker.js` exist.
6. Review `backend/symmetry/.env` and confirm the release fields match this release.
7. Rebuild and restart production with:

```bash
docker compose -f docker-compose.prod.yml up --build -d
```

8. Wait for `api`, `worker`, `web`, and `postgres` containers to become healthy or stable.
9. Inspect logs if any container is restarting.

## Smoke tests

Run and record the result of each check:

1. `GET /health`
2. `GET /version`
3. `GET /version.json`
4. `POST /v1/auth/guest`
5. `POST /v1/prompts/generate`
6. `POST /v1/campaigns`
7. `POST /v1/campaigns/{id}/turns/process`
8. `GET /v1/campaigns/{id}/rumors`

If Yandex auth is enabled, also open `/v1/auth/yandex/start` in a browser and verify the callback domain matches the production public URL.

## Rules

- Do not deploy only the API; the worker must run too.
- Do not manually edit frontend bundle files.
- Do not store user AI credentials in server-side files or database rows.
- If there is a gameplay failure from the browser, inspect backend logs before changing nginx.
- Use `docker-compose.prod.yml`, not the local development compose file.

## Expected output

Return a concise report with:

- whether the archive checksum matched
- whether containers restarted successfully
- the result of each smoke test
- any remaining blockers

Do not guess missing secrets. If a required value was not filled in this task,
stop and report which field is missing.
