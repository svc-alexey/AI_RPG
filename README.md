# AI PRG

`Стирая Грань` / `Beyond the Verge` is a Flutter narrative RPG client with a local-first architecture.

## Project status

The project has already moved beyond the original MVP baseline. The current codebase includes:

- structured local persistence with platform-aware backends:
  - `Isar` on desktop/mobile platforms with native support;
  - `SharedPreferences` on web as the browser-safe local backend;
- `Riverpod`-driven app orchestration instead of UI-owned service location;
- campaign creation, saves, chat, and settings flows managed through controllers/providers;
- unified OpenAI-compatible AI settings with runtime controls for `max response tokens`, `context window`, and quick profiles;
- OpenAI-compatible turn generation with resilient streaming transport, automatic fallback to standard completions, and token-limit retries for the final answer;
- deduplicated AI turn generation so streaming and fallback no longer produce double requests or rewritten final answers;
- calmer chat rendering that keeps a stable pending-response bubble while the model works, then reveals the final narrator message with a soft fade/slide entrance and smoother autoscroll;
- hybrid context assembly with `static header`, `dynamic summary`, `recent buffer`, and runtime-aware prompt trimming;
- module-aware campaign state with optional `Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`, and `Checks`;
- rule-based entity extraction and reconciliation before persistence for active modules only;
- adaptive sidebar panels and transient overlays for state changes and module unlocks;
- a refreshed product-facing home screen with localized hero copy and presentation-focused CTA flows;
- a streamlined custom campaign wizard with a single story input, AI prompt expansion, and top-bar step navigation instead of bottom action buttons;
- resilient story prompt generation in custom setup, with automatic enrichment into a more vivid hook when the model returns an empty, too-short, or unchanged response;
- a cleaner in-game sidebar with compact module icons, a portrait card, and no exposed technical activation reasons;
- shared responsive layout primitives with width-based breakpoints for phones, large phones, tablets, and desktop;
- adaptive typography, spacing, cards, buttons, and form controls across `Home`, `New Game`, `Chat`, `Saves`, and `Settings`;
- a compact mobile chat chrome for narrow screens so campaign metadata remains readable without oversized headers;
- tighter mobile chat behavior while the keyboard is open, so the story keeps priority and the composer does not overflow on small screens;
- a denser in-game campaign layout with reduced mobile padding, slimmer sidebar framing, and more room for readable chat text;
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

- [Agent / AI onboarding](docs/AGENT_CONTEXT.md) — продукт, карта кода, фичи, процесс для агентов
- [Feature catalog](docs/features/CATALOG.md)
- [Commands protocol](docs/features/COMMANDS.md)
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

## AI setup

The app now uses a single `OpenAI-compatible` configuration path. In settings, provide:

- `Base URL` for your endpoint
- `Model` id
- `API Key` if the endpoint requires one
- runtime controls for response length and context size

Examples of compatible endpoints include local servers and hosted APIs that follow the OpenAI chat-completions style.

Current limitations:

- The app expects a working OpenAI-compatible `/models` and `/chat/completions` flow.
- Automatic portrait generation through provider-specific integrations has been removed.
- The UI waits for a stable final answer instead of exposing speculative intermediate stream text.

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
  - portrait card that now shows only the character name under the image
  - no user-visible `Enabled by prompt` / `Enabled by setting` copy
- in-game quick choices on the campaign screen now submit immediately on tap instead of only filling the composer first
- the chat composer now also submits the current action on `Enter`, matching the send button behavior

## Recent fixes

- chat streaming no longer races a second standard completion request in the background;
- pending narrator bubbles now stay stable while the model is still drafting, and the final narrator text fades in softly once the completed answer is ready;
- the web shell refreshes viewport metrics when a mobile browser tab/app returns to the foreground;
- the web landing now keeps a staged loading UI during deferred startup and waits for Flutter's first rendered frame before fading out, which removes the blank-screen gap on slower mobile browsers;
- mobile-browser intro turn diagnostics now surface directly in web console output, making repeated generation and fallback chains easier to trace on-device;
- chat turn submission is now single-flight, so duplicate taps or repeated intro triggers no longer start parallel first-turn requests;
- the mobile chat layout now hides nonessential top chrome while the keyboard is open, preventing bottom overflow on small screens;
- overlay choice actions in chat now trigger an immediate turn submission instead of waiting for a second explicit send tap;
- the app now uses a shared responsive layer instead of screen-local breakpoint checks, reducing oversized mobile typography and spacing regressions;
- widget coverage now includes width-based layout smoke checks for common phone/tablet/desktop viewports.
- custom prompt generation now has a tested local fallback that prevents silent no-op behavior when AI prompt expansion fails.
- OpenAI-compatible turn handling includes broader fallback parsing for plain text, broken JSON-like output, alternate narration fields, alternate state containers, alternate location fields, and object-shaped choices.
- the gameplay screen no longer keeps a persistent `turn completed` status card above the chat; transient feedback now uses snackbars so the story gets more vertical space.
