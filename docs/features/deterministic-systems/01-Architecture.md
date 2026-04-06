# Architecture Plan: Deterministic Systems

> Historical note: this document describes deterministic logic as introduced in
> the earlier client-local runtime. Today the platform is server-first; use this
> packet as historical implementation context, not as the primary architecture
> source of truth.

## 1. Context

This slice lives on top of the existing local-first RPG stack:

- `CampaignState` is already the source of truth for modules, memory, and UI panels.
- `ChatController` orchestrates request assembly and turn persistence.
- `GameEngine` already owns turn application and memory updates.
- `OpenAiCompatibleAiClient` already builds structured prompts from campaign context.

Before this work, the `Checks` module could display extracted check history, but roll resolution still effectively depended on model output.

## 2. Goal

Move core gameplay checks from model inference to deterministic client logic without turning every story into a universal RPG ruleset.

## 3. Architectural decision

The deterministic layer is split into two new services:

1. `DiceEngine`
   - provides stable deterministic rolls for `d20`-style checks
   - uses campaign id, turn number, action text, stat, and difficulty as input

2. `DeterministicCheckService`
   - decides whether the current action requires a check
   - maps actions to `might`, `wit`, or `spirit`
   - calculates difficulty, modifier, total, and outcome
   - returns a `DeterministicTurnContext` that becomes part of the AI request

## 4. Integration points

- `ChatController`
  - resolves deterministic context before calling the AI client
- `OpenAiCompatibleAiClient`
  - injects `deterministic_resolution` into campaign context
  - instructs the model not to reroll or contradict that outcome
- `GameEngine`
  - applies the resolved check into campaign state, notifications, and memory
- `EntityExtractionService`
  - treats resolved checks as canonical check state
  - blocks irrelevant RPG chrome from leaking into non-RPG campaigns

## 5. Data and persistence impact

- No schema redesign was needed.
- Resolved checks are stored through the existing `checks` list in `CampaignState`.
- Save payloads and memory snapshots now persist deterministic outcomes as normal campaign state.

## 6. Main tradeoffs

- The current resolver is intentionally lightweight and heuristic-based.
- Determinism is scoped to active `Checks` campaigns only.
- This protects detective and pure narrative campaigns from accidental RPG system creep, but still leaves room for deeper rules later.
