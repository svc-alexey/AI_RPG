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
- keeps a mobile-friendly loading/error message in the browser splash;
- preserves the custom `index.html` viewport recovery logic used for mobile-browser resume cases.

## Deploy notes

- Deploy the contents of `build/web`.
- If a phone keeps showing an old endless loader, clear site data/cache for that domain before retrying.
- For local network testing, you can serve `build/web` over HTTP and open it from the phone on the same Wi-Fi network.
- The shipped `web/index.html` listens to `visualViewport`, `pageshow`, `focus`, and `visibilitychange` to resync height after app switching on mobile browsers.
- If a tester reports an empty area where the keyboard used to be after returning to the browser, verify that the latest built `index.html` was deployed together with the rest of `build/web`.
