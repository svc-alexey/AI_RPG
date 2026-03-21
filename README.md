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
- a cleaner in-game sidebar with compact module icons, a portrait card, and no exposed technical activation reasons;
- local placeholder portraits prepared for future AI-generated character images;
- shared responsive layout primitives with width-based breakpoints for phones, large phones, tablets, and desktop;
- adaptive typography, spacing, cards, buttons, and form controls across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- a compact mobile chat chrome for narrow screens so campaign metadata remains readable without oversized headers;
- demo-mode AI fallback when no model is configured;
- a unified `Aether` visual system across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- soft page/backdrop animations that now also run on desktop outside test mode;
- mobile-browser viewport recovery after app switching so stale keyboard space is less likely to block chat content;
- a fast web landing shell that opens before Flutter and launches the full app only after the user presses the main CTA.

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

## Web build

For browser and mobile-browser deployment, use the project build script instead of raw `flutter build web`:

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_web_release.ps1
```

See [DEPLOY_WEB](D:/AI_PRG/docs/DEPLOY_WEB.md) for the deployment flow and mobile-browser notes.

## Start experience

- `native / desktop / mobile app`: the app opens directly into the new branded start screen
- `web`: `web/index.html` first shows a lightweight landing page, and Flutter starts only after the user presses `Play`
- the in-game campaign sidebar now favors presentation over technical labels:
  - compact module icons with tooltips
  - portrait card under the hero name
  - no user-visible `Enabled by prompt` / `Enabled by setting` copy

## Recent fixes

- chat streaming no longer races a second standard completion request in the background;
- pending narrator bubbles now render with a softer, more readable typing experience;
- the web shell refreshes viewport metrics when a mobile browser tab/app returns to the foreground;
- the app now uses a shared responsive layer instead of screen-local breakpoint checks, reducing oversized mobile typography and spacing regressions;
- widget coverage now includes width-based layout smoke checks for common phone/tablet/desktop viewports.
