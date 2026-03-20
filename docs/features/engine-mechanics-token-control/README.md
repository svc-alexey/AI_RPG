# Feature: AI RPG Engine Core, Mechanics and Token Control

## Summary

This feature package tracks the transition from a basic AI chat MVP to a local-first RPG engine with:

- structured persistence
- controllable LLM runtime cost
- real response streaming
- deterministic gameplay foundations

## Implemented so far

- `Isar` storage foundation and migration from legacy storage
- `Riverpod` as the main state orchestration layer
- removal of `AppScope` from the runtime shell
- controller/state orchestration for `Chat`, `Settings`, and `New Game`
- provider-driven saves flow
- runtime controls for `max response tokens`, `context window`, and quick profiles
- real streaming for OpenAI-compatible chat completions with fallback to non-streaming requests

## Still pending

- hybrid context memory pipeline
- world state expansion for richer gameplay state
- extraction pipeline for inventory, companions, and world notes
- dice engine and deterministic gameplay checks
- richer gameplay UI over expanded world state
- isolates for heavy background processing

## Documents

- `01-Architecture.md` - target architecture and gap analysis
- `02-PRD.md` - product requirements and scope
- `03-Implementation.md` - delivery roadmap and stage sequencing

## Next planned slice

The next stage for this package is `Stage 5: hybrid context`.

That work will introduce:

- `static header + dynamic summary + recent buffer`
- context assembly based on runtime limits
- more compact prompts for long campaigns
