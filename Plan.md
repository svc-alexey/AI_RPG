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

## Next step

The next planned step is `Stage 5: hybrid context`.

This means building a formal context pipeline:

- `static header`
- `dynamic summary`
- `recent buffer`

The goal is to reduce prompt bloat and improve long-campaign coherence.
