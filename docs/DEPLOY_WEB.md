# Web Deploy

## Runtime model

The web client is now server-first:

- the browser talks to your game backend;
- the backend talks to model providers and PostgreSQL;
- campaign state is not stored in browser-local campaign persistence.

Browser-local storage remains only for:

- app settings
- language
- session tokens
- optional user-owned AI keys

The backend address is deployment/runtime configuration and is not exposed as a
user-editable field in the settings UI.

## CORS model

The browser no longer needs direct access to external model providers for the
main gameplay flow. The important CORS boundary is now:

- `web app origin` -> `game backend origin`

So for deployed web builds:

1. your backend must allow the web origin;
2. your reverse proxy / CDN must preserve the required CORS headers;
3. model-provider CORS is handled server-side because provider calls are made
   by the backend.

## Build command

Use the project script:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

**Критически важно:** `AI_PRG_SYMMETRY_BASE_URL` должен быть **абсолютным** URL
(например `https://beyondtheverge.online/v1`), а НЕ относительным `/v1`.
При сборке на Windows Dart2JS резолвит относительные URL против `Uri.base`,
который может указывать на `file:///C:/Program%20Files/Git/` — браузер
блокирует такие запросы, и приложение не может связаться с сервером.

Полный набор обязательных флагов для production web:

```bash
flutter build web \
  --dart-define=AI_PRG_APP_VERSION=1.0.0+1 \
  --dart-define=AI_PRG_ASSET_VERSION=$RELEASE_ID \
  --dart-define=AI_PRG_RELEASE_ID=$RELEASE_ID \
  --dart-define=AI_PRG_SYMMETRY_BASE_URL=https://beyondtheverge.online/v1
```

## Backend requirement

The deployed web build is not enough by itself. You also need a reachable
backend with:

- migrated PostgreSQL schema
- running background worker
- working `GET /health`
- working `GET /version`
- working `POST /v1/auth/*`
- working `POST /v1/campaigns/*`
- working `GET /v1/campaigns/{id}/rumors`
- working `POST /v1/campaigns/{id}/portrait` (portrait generation)
- working `GET /v1/campaigns/{id}/portrait/image` (portrait serving)
- valid backend `.env` (включая `SYMMETRY_POLZA_AI_*` для портретов)
- working DNS or relay reachability for the configured AI endpoint
- valid Yandex OAuth callback configuration if `Sign in with Yandex` is enabled
- valid feedback SMTP credentials in `backend/symmetry/.env` if the landing
  feedback form should send email

## Deploy order

1. backup DB
2. deploy new backend image/code
3. run `alembic upgrade head`
4. verify `/health`
5. verify auth and one prompt-generation request
6. verify one campaign creation + one turn-processing request
7. deploy the web bundle

## Runtime behavior

The shipped web build still uses the branded landing shell and staged loader:

1. `index.html` renders a lightweight landing page immediately.
2. Flutter starts only when the user presses the main CTA.
3. The landing stays visible until Flutter paints its first visible frame.

The shipped web bundle now also includes:

- `version.json` with `release_id`, `released_at`, `app_version`,
  and `asset_version`
- `flutter_service_worker.js` for bundle refresh
- `robots.txt`
- `sitemap.xml`

## Yandex OAuth for web

The web login flow now returns from Yandex to the backend callback first, and
only then back to the Flutter route with a one-time handoff.

Set these consistently:

- backend env:
  `SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/v1/auth/yandex/callback`
  `SYMMETRY_WEB_PUBLIC_ORIGIN=https://your-domain.example`
- Yandex OAuth app callback:
  `https://your-domain.example/v1/auth/yandex/callback`

For local preview, use:

- backend callback: `http://127.0.0.1:8080/v1/auth/yandex/callback`
- web public origin: `http://127.0.0.1:3010`

The reverse proxy still only needs to forward `/v1/`, `/health`, and
`/version`; the final `/auth/yandex/callback` route is still handled by the
Flutter app and served from `index.html`, but Yandex itself must call the
backend callback under `/v1/`.

Token exchange: the backend includes `redirect_uri` when calling Yandex
`oauth.yandex.ru/token`; it must be the same backend callback URI as in the
authorize request. After that, the backend redirects the browser back to
Flutter with `?handoff=...`, and Flutter finishes sign-in through
`POST /v1/auth/yandex/complete`.

## Deploy notes

- Deploy the contents of `build/web`.
- Deploy the entire freshly built `build/web` bundle together.
- Keep `index.html`, `flutter_bootstrap.js`, and `main.dart.js` from the same build.
- Keep `version.json` and backend `/version` synchronized to the same release id.
- Keep the service worker enabled in production; do not strip
  `flutter_service_worker.js` from the bundle.

### Nginx: gzip обязателен

`main.dart.js` весит ~3.6 MB без сжатия. Через FRP-туннель такой объём
не проходит — Caddy обрывает соединение с `unexpected EOF`. Включить gzip:

```nginx
gzip on;
gzip_vary on;
gzip_comp_level 6;
gzip_min_length 1000;
gzip_types text/plain text/css text/xml text/javascript
           application/javascript application/json application/wasm
           application/octet-stream image/svg+xml;
```

Со сжатием `main.dart.js` уменьшается до ~1 MB (-71%) и стабильно проходит
через FRP-туннель.

### Caddy: таймауты для FRP

При использовании FRP-туннеля Caddy требует явных таймаутов для reverse_proxy:

```
beyondtheverge.online {
    reverse_proxy 127.0.0.1:18083 {
        transport http {
            read_timeout 120s
            write_timeout 120s
        }
    }
}
```

Без таймаутов Caddy обрывает соединения при передаче больших файлов.

### FRP туннель

Проверить что FRP-туннель активен после деплоя:
- VPS: `systemctl status frps`
- Домашний сервер: `docker ps | grep frpc` (или `systemctl status frpc`)

Проверить цепочку: `curl -s -H "Accept-Encoding: gzip" http://127.0.0.1:18083/main.dart.js | wc -c` на VPS должен вернуть ~1 MB (сжатый размер).

- If the backend container was recreated in Docker, be ready to restart the
  `web` container too; otherwise nginx may keep returning `502` to
  `symmetry-api` even when the API is already healthy again.
- If you terminate web traffic in nginx, also proxy `/health`, `/version`, and
  `/v1/` to the backend.
- For `*.map` files, prefer `try_files $uri =404;` instead of SPA fallback to
  `/index.html`; otherwise browser devtools may report fake source-map JSON
  parse errors for `flutter.js.map`.
- If Yandex login redirects back but sign-in does not finish, verify that:
  - Yandex is returning to `/v1/auth/yandex/callback`
  - the backend `SYMMETRY_YANDEX_REDIRECT_URI` matches that exact URL
  - `SYMMETRY_WEB_PUBLIC_ORIGIN` matches the actual public web origin
  - the same backend callback URL is whitelisted in the Yandex OAuth app
    settings
  - the backend callback redirects the browser to
    `/auth/yandex/callback?handoff=...`
  - the API request to `POST /v1/auth/yandex/complete` succeeds
- If icons or fonts look broken after a fresh build, hard-refresh the browser
  and verify `build/web/assets/FontManifest.json` and
  `build/web/assets/fonts/MaterialIcons-Regular.otf` are being served.
- If the browser keeps serving stale assets, confirm the new `version.json`
  is live and that the service worker has picked up the fresh release.
- If the browser still loops on "update required", verify not only
  `version.json`, but also backend `/version` and the emitted
  `AI_PRG_ASSET_VERSION`; all three must point to the same release.
- If the web app loads but auth or gameplay fails, check the backend URL and
  browser CORS policy against the backend, not against model providers first.
- If the browser reports a CORS error for a gameplay request, check backend
  logs first: a backend `500/502` during model-provider access often appears
  in the browser as a misleading CORS failure.
- For Docker deploys, verify that the API container can resolve the configured
  model relay/provider hostname before shipping the web bundle.
- For home-server deploys behind a VPS relay, prefer routing the backend to the
  relay via fixed IP or VPN address rather than relying on external provider
  DNS directly from the game container.
- If the backend uses cookies or strict auth headers behind a proxy, verify that
  the proxy forwards `Authorization` and CORS headers correctly.
- If landing feedback should work in production, configure these backend env
  vars: `SYMMETRY_FEEDBACK_RECIPIENT_EMAIL`,
  `SYMMETRY_FEEDBACK_SENDER_EMAIL`, `SYMMETRY_FEEDBACK_SMTP_HOST`,
  `SYMMETRY_FEEDBACK_SMTP_PORT`, `SYMMETRY_FEEDBACK_SMTP_USERNAME`,
  `SYMMETRY_FEEDBACK_SMTP_PASSWORD`, `SYMMETRY_FEEDBACK_SMTP_USE_SSL`,
  `SYMMETRY_FEEDBACK_SMTP_USE_STARTTLS`.

## Recent production fixes

These fixes are already reflected in the current production code and are worth
preserving in future deploys.

### Dart2JS file:// URL resolution (2026-05-08)

**Проблема:** при сборке на Windows `flutter build web` с
`AI_PRG_SYMMETRY_BASE_URL=/v1` (относительный путь) Dart2JS резолвит API-запросы
против `Uri.base`, который указывает на `file:///C:/Program%20Files/Git/`.
Браузер блокирует `file:///` запросы — приложение загружается, но не может
связаться с сервером ("сервер игры не доступен").

**Исправление:** всегда использовать абсолютный URL при сборке:
`--dart-define=AI_PRG_SYMMETRY_BASE_URL=https://beyondtheverge.online/v1`

Дополнительно:
- `web/index.html` сохраняет `window.location.origin + '/v1'` в localStorage
- `symmetry_api_client.dart._join()` форсирует абсолютные URL через
  `@JS('self.location.origin')` как fallback

### Nginx gzip + Caddy timeouts (2026-05-08)

**Проблема:** `main.dart.js` (3.6 MB без сжатия) не проходил через FRP-туннель.
Caddy обрывал соединение с `aborting with incomplete response: unexpected EOF`
за 0.117 сек. Прогресс загрузки останавливался на 12%.

**Исправление:** включён gzip в nginx (3.6 MB → 1.0 MB), добавлены таймауты
`read_timeout 120s` / `write_timeout 120s` в Caddy для reverse_proxy к FRP.

### Settings and auth UX

- Settings no longer claim "log in first" just because user-owned AI fields are
  empty.
- If a valid session exists, provider connectivity checks can fall back to the
  server-managed credentials from backend `.env`.

### Story generation resilience

- Short and long campaign modes now use different output budgets.
- Long campaigns keep more room for prologue, world context, and ongoing
  narration.
- The backend now retries when the provider signals truncation via
  `finish_reason=length` or when completion tokens hit the configured ceiling.
- The backend also tolerates non-ideal structured fields such as textual
  `importance` or non-object `module_updates`.

### Image rendering

- Authenticated cover images on web were adjusted to reduce visible blinking
  during reloads or token refreshes by keeping the previous image visible while
  the refreshed bytes are loading.

### Portrait generation (Polza.ai)

**Backend requirements:**
- `SYMMETRY_POLZA_AI_API_KEY` — API-ключ Polza.ai
- `SYMMETRY_POLZA_AI_BASE_URL=https://polza.ai/api/v1`
- `SYMMETRY_POLZA_AI_IMAGE_MODEL=google/gemini-2.5-flash-image`
- `SYMMETRY_POLZA_AI_TIMEOUT_SECONDS=30`
- `SYMMETRY_POLZA_AI_POLL_INTERVAL_SECONDS=1.5`
- Таблица `campaign_portraits` создана через миграцию

**Deploy portrait files (docker cp):**
```bash
# Новые файлы
docker cp backend/symmetry/app/services/portrait_optimizer.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/services/portrait_prompt_builder.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/services/portrait_service.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/api/routes/portraits.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/schemas/portraits.py ai-rpg-api:/app/app/schemas/

# Изменённые файлы
docker cp backend/symmetry/app/api/routes/__init__.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/main.py ai-rpg-api:/app/app/main.py
docker cp backend/symmetry/app/core/config.py ai-rpg-api:/app/app/core/
docker cp backend/symmetry/app/db/models.py ai-rpg-api:/app/app/db/
docker cp backend/symmetry/app/api/routes/campaigns.py ai-rpg-api:/app/app/api/routes/

# Миграция
docker cp backend/symmetry/alembic/versions/20260511_000015_campaign_portraits.py ai-rpg-api:/app/alembic/versions/

# Применить
docker exec ai-rpg-api find /app -type d -name '__pycache__' -exec rm -rf '{}' ';'
docker exec ai-rpg-api alembic upgrade head
docker restart ai-rpg-api
```

**Клиент (Flutter):** стандартный `flutter build web` деплой, портретная кнопка
и `Image.network` уже в коде клиента. `portrait_url` приходит в ответе
`GET /v1/campaigns/{id}/state`.
