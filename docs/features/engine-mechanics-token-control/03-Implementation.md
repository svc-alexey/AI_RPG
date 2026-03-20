# Implementation Plan: AI RPG Engine Core, Mechanics and Token Control

## Delivery strategy

Recommended order:

1. storage foundation
2. state architecture
3. runtime model controls
4. real streaming
5. hybrid context
6. world state expansion
7. deterministic gameplay systems
8. richer gameplay UI

This keeps the system stable by locking in source-of-truth and orchestration first, then improving runtime behavior, and only after that expanding gameplay mechanics.

## Status snapshot

### Completed

- Stage 1: `Isar` foundation, migration path, structured repositories
- Stage 2: `Riverpod` app shell, removal of `AppScope`, screen controllers for `Chat`, `Settings`, and `New Game`
- Stage 3: runtime controls, provider-scoped settings, presets, token caps, and context-window-aware prompt assembly
- Stage 4: real response streaming through OpenAI-compatible SSE with fallback to standard completions

### Active next stage

- Stage 5: hybrid context

### Remaining major stages

- Stage 5: hybrid context and summary cadence
- Stage 6: world state v2 and extraction
- Stage 7: dice engine and deterministic checks
- Stage 8: UI expansion over richer world state

## Stage 1. Storage foundation

Status: done

Done:

- [x] Add `Isar` and structured collections for campaign/runtime data
- [x] Implement local data sources and repositories over structured storage
- [x] Add migration from legacy `SharedPreferences`
- [x] Preserve fallback behavior for test/runtime environments without `isar.dll`

Exit criteria:

- [x] Old campaigns remain loadable
- [x] New campaigns and settings persist through structured storage
- [x] Save/load flow does not regress

## Stage 2. State architecture

Status: done

Done:

- [x] Introduce `ProviderScope` at the app layer
- [x] Remove `AppScope` from runtime architecture
- [x] Move `ChatScreen` to controller/state orchestration
- [x] Move `SettingsScreen` to a dedicated controller
- [x] Move `NewGameScreen` to a dedicated controller
- [x] Drive `SavesScreen` through providers

Exit criteria:

- [x] UI no longer owns core async orchestration
- [x] Core user flows run through `Riverpod`
- [x] The app shell no longer depends on inherited service location

## Stage 3. Runtime controls

Status: done

Done:

- [x] Extend runtime settings with `maxResponseTokens`
- [x] Extend runtime settings with `contextWindowSize`
- [x] Add controls to `SettingsScreen`
- [x] Thread runtime settings through prompt assembly and transport
- [x] Add quick profiles/presets
- [x] Add persistence and test coverage

Exit criteria:

- [x] Users can change runtime limits from the UI
- [x] Runtime limits affect real request assembly

## Stage 4. Real streaming

Status: done

Done:

- [x] Add a streaming contract to the AI client layer
- [x] Parse OpenAI-compatible SSE stream chunks
- [x] Update pending narration progressively from real network data
- [x] Keep final persisted narration separate from partial UI state
- [x] Preserve fallback to non-streaming requests/providers
- [x] Verify the cancel flow during streaming

Exit criteria:

- [x] Text appears before generation is fully complete
- [x] Cancel interrupts the in-flight stream correctly
- [x] Storage only persists the final completed narration

## Stage 5. Hybrid context

Status: next

Goal:

Create a formal long-campaign context pipeline that keeps prompts compact and coherent.

Tasks:

- [ ] Introduce `ContextAssemblyService`
- [ ] Formalize `static header`
- [ ] Formalize `dynamic summary`
- [ ] Introduce `recent buffer` with a runtime-aware window
- [ ] Add summary update cadence every `N` turns
- [ ] Trim prompt payload by runtime context settings

Exit criteria:

- [ ] The model no longer receives the full chat log every turn
- [ ] Long campaigns stay coherent with smaller prompt payloads

## Stage 6. World state v2 and extraction

Status: backlog

Tasks:

- [ ] Expand world state with `Gold`, `Exp`, and `Level`
- [ ] Promote `Inventory` and `Companions` to first-class state
- [ ] Add `EntityExtractionService`
- [ ] Start with rule-based extraction for inventory changes
- [ ] Expand extraction to companions and world notes
- [ ] Add reconciliation before persistence

## Stage 7. Dice engine and deterministic checks

Status: backlog

Tasks:

- [ ] Add `DiceEngine`
- [ ] Define at least `might`, `wit`, and `spirit` checks
- [ ] Add thresholds, modifiers, and crit logic
- [ ] Change prompt contract so AI narrates known outcomes instead of deciding them
- [ ] Restrict state mutation paths around deterministic checks

## Stage 8. UI expansion

Status: backlog

Tasks:

- [ ] Add dedicated `Stats`, `Inventory`, and `Companions` panels
- [ ] Visualize HP, EXP, and Level
- [ ] Expand desktop side-panel layout
- [ ] Keep mobile focused through tabs, sheets, or drawers
- [ ] Prepare UI for richer world-state reducers

## Recommended next PR slice

The next clean implementation slice is:

1. `ContextAssemblyService` for `static header + dynamic summary + recent buffer`
2. summary cadence rules for long campaigns
3. prompt trimming tied to `contextWindowSize`

This is the best next step because it reduces prompt bloat, improves long-session coherence, and prepares the path for world-state v2.
