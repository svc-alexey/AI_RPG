# AI PRG

Flutter desktop-first AI RPG client with a local-first architecture.

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
- demo-mode AI fallback when no model is configured;
- a unified `Aether` visual system across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- soft page/backdrop animations that now also run on desktop outside test mode;
- mobile-browser viewport recovery after app switching so stale keyboard space is less likely to block chat content.

## Current architecture

- UI: `Flutter`
- State management: `flutter_riverpod`
- Local storage:
  - `Isar` as the primary native backend
  - `SharedPreferences` as the explicit browser backend
  - adaptive storage layer under repositories for backend selection
- AI integration: provider-agnostic client/factory layer
- Primary target: Desktop-first, with mobile-friendly layout work already underway

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

## Recent fixes

- chat streaming no longer races a second standard completion request in the background;
- pending narrator bubbles now render with a softer, more readable typing experience;
- the web shell refreshes viewport metrics when a mobile browser tab/app returns to the foreground.
