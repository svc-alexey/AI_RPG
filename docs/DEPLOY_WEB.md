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

For local browser preview, prefer the production-like bundle over a hot
Flutter web-server session:

```powershell
flutter build web --no-tree-shake-icons
python -m http.server 3010 --directory build/web
```

Why this is the preferred dev path:

- asset loading matches real deployment more closely;
- Material Icons are served from the built asset bundle without dev-server
  quirks;
- it is easier to diagnose cache, CORS, and static asset issues;
- the script generates and ships release metadata and SEO assets together.

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
- valid backend `.env`
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

The web login flow now returns from Yandex to the Flutter route
`/auth/yandex/callback`, not directly to a backend-rendered page.

Set these consistently:

- backend env:
  `SYMMETRY_YANDEX_REDIRECT_URI=https://your-domain.example/auth/yandex/callback`
- Yandex OAuth app callback:
  `https://your-domain.example/auth/yandex/callback`

For local preview, use:

- `http://127.0.0.1:3010/auth/yandex/callback`

The reverse proxy still only needs to forward `/v1/`, `/health`, and
`/version`; the `/auth/yandex/callback` route is handled by the Flutter app
itself and served from `index.html`.

## Deploy notes

- Deploy the contents of `build/web`.
- Deploy the entire freshly built `build/web` bundle together.
- Keep `index.html`, `flutter_bootstrap.js`, and `main.dart.js` from the same build.
- Keep `version.json` and backend `/version` synchronized to the same release id.
- Keep the service worker enabled in production; do not strip
  `flutter_service_worker.js` from the bundle.
- If you terminate web traffic in nginx, also proxy `/health`, `/version`, and
  `/v1/` to the backend.
- If Yandex login redirects back but sign-in does not finish, verify that:
  - the browser is returning to `/auth/yandex/callback`
  - the backend `SYMMETRY_YANDEX_REDIRECT_URI` matches that exact URL
  - the same URL is whitelisted in the Yandex OAuth app settings
- If icons or fonts look broken after a fresh build, hard-refresh the browser
  and verify `build/web/assets/FontManifest.json` and
  `build/web/assets/fonts/MaterialIcons-Regular.otf` are being served.
- If the browser keeps serving stale assets, confirm the new `version.json`
  is live and that the service worker has picked up the fresh release.
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
