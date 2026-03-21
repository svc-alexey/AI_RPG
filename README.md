# AI PRG

`Стирая Грань` / `Beyond the Verge` is a Flutter narrative RPG client with a local-first architecture.

## Project status

The project has already moved beyond the original MVP baseline. The current codebase includes:

- structured local persistence with platform-aware backends:
  - `Isar` on desktop/mobile platforms with native support;
  - `SharedPreferences` on web as the browser-safe local backend;
- `Riverpod`-driven app orchestration instead of UI-owned service location;
- campaign creation, saves, chat, and settings flows managed through controllers/providers;
- provider-scoped AI settings and runtime controls for `max response tokens`, `context window`, and quick profiles;
- real response streaming in chat for OpenAI-compatible endpoints, with automatic fallback to standard completions;
- deduplicated AI turn generation so streaming and fallback no longer produce double requests or rewritten final answers;
- smoother chat rendering during narration streaming with throttled preview updates, calmer autoscroll, and a polished pending-response bubble;
- hybrid context assembly with `static header`, `dynamic summary`, `recent buffer`, and runtime-aware prompt trimming;
- module-aware campaign state with optional `Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`, and `Checks`;
- rule-based entity extraction and reconciliation before persistence for active modules only;
- adaptive sidebar panels and transient overlays for state changes and module unlocks;
- a refreshed product-facing home screen with localized hero copy and presentation-focused CTA flows;
- a streamlined custom campaign wizard with a single story input, AI prompt expansion, and top-bar step navigation instead of bottom action buttons;
- resilient story prompt generation in custom setup, with automatic enrichment into a more vivid hook when the model returns an empty, too-short, or unchanged response;
- a cleaner in-game sidebar with compact module icons, a portrait card, and no exposed technical activation reasons;
- local placeholder portraits prepared for future AI-generated character images;
- shared responsive layout primitives with width-based breakpoints for phones, large phones, tablets, and desktop;
- adaptive typography, spacing, cards, buttons, and form controls across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- a compact mobile chat chrome for narrow screens so campaign metadata remains readable without oversized headers;
- tighter mobile chat behavior while the keyboard is open, so the story keeps priority and the composer does not overflow on small screens;
- demo-mode AI fallback when no model is configured;
- a unified `Aether` visual system across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- soft page/backdrop animations that now also run on desktop outside test mode;
- mobile-browser viewport recovery after app switching so stale keyboard space is less likely to block chat content;
- a fast web landing shell that opens before Flutter and launches the full app only after the user presses the main CTA;
- a staged web/mobile-web startup loader with localized progress steps, rotating flavor text, and a first-frame-aware handoff so the landing overlay stays in place until Flutter has actually painted visible UI.
- web-safe AI diagnostics for mobile browsers, including structured console events, intro-turn tracing, and retry/fallback visibility in browser console logs.

## Current architecture

- UI: `Flutter`
- State management: `flutter_riverpod`
- Local storage:
  - `Isar` as the primary native backend
  - `SharedPreferences` as the explicit browser backend
  - adaptive storage layer under repositories for backend selection
- AI integration: provider-agnostic client/factory layer
- Primary target: Cross-device Flutter UI with explicit responsive behavior for:
  - `320-359 px` small phones
  - `360-389 px` standard phones
  - `390-599 px` large phones
  - `600-1023 px` tablets / narrow landscape
  - `1024+ px` desktop / wide layouts

## Recent milestone

`Stage 8: deterministic systems and implementation finish` is complete.

The app now has client-resolved deterministic checks, stable long-session memory/context behavior, validated settings/runtime UX flows, and a prompt architecture prepared for the next product layer.

## What is next

The next planned implementation step is the product-facing layer:

- `Stage 6: next product layer`;
- chosen direction: `Narrative depth`;
- expand storytelling quality on top of the deterministic, modular, and memory-aware runtime foundation.

## Key documents

- [PRD](D:/AI_PRG/docs/features/engine-mechanics-token-control/02-PRD.md)
- [Feature README](D:/AI_PRG/docs/features/engine-mechanics-token-control/README.md)
- [Architecture](D:/AI_PRG/docs/features/engine-mechanics-token-control/01-Architecture.md)
- [Implementation Plan](D:/AI_PRG/docs/features/engine-mechanics-token-control/03-Implementation.md)
- [Project Implementation Plan](D:/AI_PRG/ImplementationPlan.md)

## Basic commands

```bash
flutter pub get
flutter analyze
flutter test
```

## Sber GigaChat proxy

`Sber GigaChat` now uses a local proxy so the Flutter client never stores Sber secrets directly.

1. Create `.env` from `.env.example`.
2. Fill in `SBER_AUTH_KEY`, `SBER_CLIENT_ID`, and `SBER_CLIENT_SECRET`.
3. Start the proxy:

```bash
dart run tool/sber_proxy.dart
```

The app expects the proxy at `http://127.0.0.1:8787/v1` by default and uses the Sber API model id `GigaChat-2`.

Current limitations:

- `Sber GigaChat` uses standard completions only; streaming stays enabled for the existing OpenAI-compatible providers.
- Some Sber-family models may ignore strict JSON instructions. The app now includes tolerant recovery for plain text and partially structured responses, but the most stable path is still a model that reliably follows structured output.
- The local proxy is required for `Sber GigaChat` on all platforms because Sber credentials are read from `.env` by the proxy, not by the Flutter client.

## Web build

For browser and mobile-browser deployment, use the project build script instead of raw `flutter build web`:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

See [DEPLOY_WEB](D:/AI_PRG/docs/DEPLOY_WEB.md) for the deployment flow and mobile-browser notes.

## Start experience

- `native / desktop / mobile app`: the app opens directly into the new branded start screen
- `web`: `web/index.html` first shows a lightweight landing page, and Flutter starts only after the user presses `Play`
- `web / mobile browser`: after `Play`, the CTA becomes a staged loader with progress, loading phrases, and a guarded handoff that hides the HTML landing only after Flutter paints its first visible frame
- `web / mobile browser / first AI turn`: the chat flow emits structured diagnostic events for intro autostart, retries, fallback behavior, request/response flow, and duplicate-turn suppression in browser console logs
- `localhost / flutter run -d web-server`: the landing still renders by default; add `?autostart=1` to the URL if you explicitly want immediate Flutter startup
- `custom campaign / story step`: there is now one editable story field; typed text expands into a richer prompt, and an empty submit generates a fresh random hook first
- `custom campaign / generate prompt`: when the AI response is weak or effectively echoes the input, the app now rewrites it into a more atmospheric story prompt and fills a matching character prompt instead of leaving the field unchanged
- `custom campaign / step navigation`: moving between steps now uses the top arrows only
- the in-game campaign sidebar now favors presentation over technical labels:
  - compact module icons with tooltips
  - portrait card under the hero name
  - no user-visible `Enabled by prompt` / `Enabled by setting` copy
- in-game quick choices on the campaign screen now submit immediately on tap instead of only filling the composer first
- the chat composer now also submits the current action on `Enter`, matching the send button behavior

## Recent fixes

- chat streaming no longer races a second standard completion request in the background;
- pending narrator bubbles now render with a softer, more readable typing experience;
- the web shell refreshes viewport metrics when a mobile browser tab/app returns to the foreground;
- the web landing now keeps a staged loading UI during deferred startup and waits for Flutter's first rendered frame before fading out, which removes the blank-screen gap on slower mobile browsers;
- mobile-browser intro turn diagnostics now surface directly in web console output, making repeated generation and fallback chains easier to trace on-device;
- chat turn submission is now single-flight, so duplicate taps or repeated intro triggers no longer start parallel first-turn requests;
- the mobile chat layout now hides nonessential top chrome while the keyboard is open, preventing bottom overflow on small screens;
- overlay choice actions in chat now trigger an immediate turn submission instead of waiting for a second explicit send tap;
- the app now uses a shared responsive layer instead of screen-local breakpoint checks, reducing oversized mobile typography and spacing regressions;
- widget coverage now includes width-based layout smoke checks for common phone/tablet/desktop viewports.
- custom prompt generation now has a tested local fallback that prevents silent no-op behavior when AI prompt expansion fails.
- `Sber GigaChat` now runs through a local proxy, disables streaming for turn generation, and includes fallback parsing for plain text, broken JSON-like output, alternative narration fields, and object-shaped choices.
