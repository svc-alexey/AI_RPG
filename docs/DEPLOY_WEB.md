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

After the CTA press, the landing now stays visible as a staged loader:

- the CTA is replaced by a progress card with loading steps and rotating flavor lines;
- the overlay is removed only after Flutter paints its first visible frame, and the final fade completes once the ready UI has fully rendered;
- startup stages are driven by real Flutter loader milestones instead of a purely decorative timer, so the progress card better matches actual startup work.

The shipped web client also exposes mobile-browser diagnostics for the first AI turn:

- AI request lifecycle events are written as structured browser console logs under the `AI_PRG_DIAG` channel;
- the first campaign intro turn carries a correlation id across controller start, streaming fallback, retries, responses, and terminal errors;
- the chat screen shows a small on-screen diagnostics panel on web so recent events remain visible even when remote devtools are inconvenient on a phone;
- duplicate submissions are ignored while a turn is already in flight, which helps separate real provider retries from UI-level double triggers.

For local development there is one intentional exception:

- on `localhost`, `127.0.0.1`, and `0.0.0.0`, the landing still renders first, but Flutter auto-starts right away;
- this keeps `flutter run -d web-server` compatible with the Dart debug WebSocket flow while preserving deferred launch in real deployments.

## Deploy notes

- Deploy the contents of `build/web`.
- Deploy the entire freshly built `build/web` bundle together. Do not mix a new `main.dart.js` with an older `index.html` or `flutter_bootstrap.js`.
- If a phone keeps showing an old endless loader, clear site data/cache for that domain before retrying.
- If a phone keeps showing the staged loader at `80%` or similar, the most likely cause is stale cached web assets from before the latest first-frame handoff fix.
- For local network testing, you can serve `build/web` over HTTP and open it from the phone on the same Wi-Fi network.
- The shipped `web/index.html` listens to `visualViewport`, `pageshow`, `focus`, and `visibilitychange` to resync height after app switching on mobile browsers.
- If a tester reports an empty area where the keyboard used to be after returning to the browser, verify that the latest built `index.html` was deployed together with the rest of `build/web`.
- If the landing page appears but the app never launches, verify that the deployed `flutter_bootstrap.js` still contains the deferred launch hook and was not replaced by an older eager-start build artifact.
- If Flutter appears to start but the landing overlay never leaves, verify that both `index.html` and `main.dart.js` come from the same build, then force-refresh the site on the device so the first-frame bridge and web bootstrap stay in sync.
- If local browser debugging fails after pressing `Play`, confirm you are testing a real deployed build rather than the local debug server path; deferred launch is for deployed web, while localhost intentionally auto-starts.
- If a tester reports that the first story generation repeats several times on mobile web, inspect the `AI_PRG_DIAG` console events and compare `flowId`, `triggerSource`, `requestMode`, and `attempt` before blaming the model.
