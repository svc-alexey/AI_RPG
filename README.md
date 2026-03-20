# AI PRG

Flutter desktop-first AI RPG client with a local-first architecture.

## Project status

The project has already moved beyond the original MVP baseline. The current codebase includes:

- structured local persistence on `Isar` with fallback for environments where native Isar libraries are unavailable;
- `Riverpod`-driven app orchestration instead of UI-owned service location;
- campaign creation, saves, chat, and settings flows managed through controllers/providers;
- provider-scoped AI settings and runtime controls for `max response tokens`, `context window`, and quick profiles;
- real response streaming in chat for OpenAI-compatible endpoints, with automatic fallback to standard completions;
- demo-mode AI fallback when no model is configured.

## Current architecture

- UI: `Flutter`
- State management: `flutter_riverpod`
- Local storage: `Isar`
- AI integration: provider-agnostic client/factory layer
- Primary target: Desktop-first, with mobile-friendly layout work already underway

## What is next

The next planned implementation step is `Stage 5: hybrid context`.

That stage will formalize:

- `static header`
- `dynamic summary`
- `recent buffer`
- context trimming based on `contextWindowSize`

The goal is to keep long campaigns coherent without sending the full chat history on every turn.

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
