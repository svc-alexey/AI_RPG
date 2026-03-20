# Implementation: Deterministic Systems

## Delivered

- [x] Added `DiceEngine` for deterministic `d20` resolution
- [x] Added `DeterministicCheckService` and `DeterministicTurnContext`
- [x] Resolved checks in `ChatController` before AI narration
- [x] Injected `deterministic_resolution` into the AI user prompt
- [x] Updated the system prompt so the model treats check outcomes as fixed
- [x] Applied resolved checks through `GameEngine` and `EntityExtractionService`
- [x] Stored deterministic outcomes in campaign memory and existing save payloads
- [x] Surfaced resolved checks in sidebar history and transient notifications
- [x] Added automated coverage for deterministic resolution and narrative gating
- [x] Re-validated settings runtime UX for preset switching, custom token controls, save persistence, and provider switching

## Files touched

- `lib/src/core/services/dice_engine.dart`
- `lib/src/core/services/deterministic_check_service.dart`
- `lib/src/core/services/ai_client.dart`
- `lib/src/core/services/openai_compatible_ai_client.dart`
- `lib/src/core/services/game_engine.dart`
- `lib/src/core/services/campaign_memory_manager.dart`
- `lib/src/core/services/entity_extraction_service.dart`
- `lib/src/features/chat/application/chat_controller.dart`
- `test/runtime_model_controls_test.dart`
- `test/campaign_modules_test.dart`
- `test/widget_test.dart`

## Remaining Stage 8 work outside this slice

- [ ] long-session validation beyond current automated coverage
- [ ] analyzer cleanup that still blocks the next implementation layer
- [ ] broader next-layer architecture readiness tasks
