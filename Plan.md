# MVP Plan: AI RPG Desktop

## Original MVP goal

Build a minimal desktop-first Flutter MVP where the player can:

1. Create a new short campaign.
2. Choose basic game parameters.
3. Play through a simple chat flow.
4. Receive AI output in a structured format.
5. Save and load local progress.
6. Connect a local model through LM Studio.

The MVP slice was:

`campaign setup -> opening scene -> player action -> AI response -> state update -> save`

## MVP scope

### Core user flow

1. The player opens the app.
2. The player creates a new game.
3. The player enters the gameplay chat.
4. The player receives scene narration.
5. The player sends an action.
6. The app receives:
   - narration
   - choices
   - state changes
7. The player can save and continue later.

### Minimal screens

1. `Home`
2. `New Game`
3. `Game Chat`
4. `Settings`
5. `Saves`

### Minimal game data

1. Current scene and location
2. Base character
3. Simple inventory
4. Objective and compact campaign memory

## What was intentionally out of MVP

1. Multiplayer
2. Required image or map generation
3. Deep faction systems
4. Full RAG layer
5. Cloud saves
6. Built-in backend

## MVP success criteria

1. A player can create a campaign and complete at least one turn.
2. Campaigns save and load correctly.
3. AI settings work for LM Studio.
4. AI failures do not break the game flow.

## Post-MVP progress

The project has already completed several post-MVP layers:

- `Isar` storage foundation and migration
- `Riverpod` app shell and controller orchestration
- runtime token and context controls
- real streaming with fallback for OpenAI-compatible responses
- hybrid context with `static header`, `dynamic summary`, `recent buffer`, and cadence-based summary refresh
- modular campaign systems with adaptive UI panels and extraction/reconciliation
- visual redesign of the key screens based on `pressets/`, including desktop parity for `Home` and `Saves`

## Next step

The next fully open stage in the implementation plan is `Stage 8: deterministic systems and implementation finish`.

That stage consolidates the remaining implementation work into one place: deterministic checks via a local `DiceEngine`, long-session stability, final settings/runtime UX validation, and readiness for the next product layer.

At this point the project is past the original MVP and has already completed the major world-state, adaptive UI, and visual redesign layers. The remaining plan items are mostly:

1. Deterministic gameplay checks and client-resolved outcomes.
2. Final implementation validation for long campaigns, adaptive chrome, settings UX, and cross-platform readiness.
