# Web Deploy

## Storage model

The project now uses platform-aware local storage:

- native platforms use `Isar` as the primary backend;
- web uses `SharedPreferences` as the explicit browser-safe backend;
- repositories delegate to an adaptive storage layer, so backend selection stays below the repository boundary.

This avoids pulling native `Isar` generated code into the browser build while preserving native migration behavior on supported platforms.

## Build command

Use the project script:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

The script:

- runs `flutter build web`;
- patches Flutter's generated `flutter_bootstrap.js`;
- disables service-worker-based startup in the final bootstrap path;
- exposes a deferred launch hook instead of eager auto-start;
- keeps the branded landing shell in `web/index.html` responsible for when Flutter actually starts;
- preserves the custom `index.html` viewport recovery logic used for mobile-browser resume cases.

## Runtime behavior

The shipped web build now has a two-step startup:

1. `index.html` renders a lightweight branded landing page immediately.
2. Flutter starts only when the user presses the main CTA.

This keeps the first paint fast on mobile browsers and avoids showing a raw spinner-only shell while the full Flutter bundle loads.

## Deploy notes

- Deploy the contents of `build/web`.
- If a phone keeps showing an old endless loader, clear site data/cache for that domain before retrying.
- For local network testing, you can serve `build/web` over HTTP and open it from the phone on the same Wi-Fi network.
- The shipped `web/index.html` listens to `visualViewport`, `pageshow`, `focus`, and `visibilitychange` to resync height after app switching on mobile browsers.
- If a tester reports an empty area where the keyboard used to be after returning to the browser, verify that the latest built `index.html` was deployed together with the rest of `build/web`.
- If the landing page appears but the app never launches, verify that the deployed `flutter_bootstrap.js` still contains the deferred launch hook and was not replaced by an older eager-start build artifact.
