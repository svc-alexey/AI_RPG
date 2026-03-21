# Implementation: Narrative Depth

## Status

- [x] Architecture documented
- [x] PRD documented
- [x] Prompt fallback enrichment for custom campaign story generation implemented
- [ ] System prompt narrative-depth pass completed
- [ ] Manual QA completed
- [ ] Full verification completed

## Tasks

- [x] Add fallback enrichment for the custom campaign story wish so `Generate prompt` always produces a visibly richer result when the AI response is empty, too short, or effectively unchanged
- [x] Add a local `StoryPromptEnricher` service that expands the story hook by setting and language
- [x] Fill a matching character prompt when the AI response does not provide one
- [x] Cover the fallback behavior with focused tests
- [ ] Extend `openai_compatible_ai_client.dart` prompt instructions for stronger narrative depth in model-generated responses
- [ ] Tune narration constraints for fast mode if needed
- [ ] Run a broader compatibility pass with `campaign_memory_manager` and `game_engine`
- [ ] Manual scenario test for dialogue, atmosphere, and emotional pacing
- [ ] Run `flutter analyze` and the full `flutter test` suite cleanly

## Notes

- The current change is intentionally limited to the prompt layer; no campaign state engine changes are required.
- The custom campaign wizard now uses a local fallback path through `StoryPromptEnricher` to avoid silent no-op behavior on weak AI prompt expansion.
- This gives the user a more atmospheric and detailed hook even when the remote model response cannot be trusted.
- Deeper narrative upgrades inside the main generation prompt remain a separate follow-up.
