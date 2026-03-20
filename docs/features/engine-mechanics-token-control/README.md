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
- hybrid context assembly with `static header`, `dynamic summary`, `recent buffer`, and cadence-based summary refresh

## Still pending

- modular world state for genre-flexible gameplay state
- extraction pipeline for active modules such as inventory, companions, notes, vitality, and resources
- dice engine and deterministic gameplay checks as opt-in systems
- adaptive gameplay UI over active campaign modules
- isolates for heavy background processing

## Documents

- `01-Architecture.md` - target architecture and gap analysis
- `02-PRD.md` - product requirements and scope
- `03-Implementation.md` - delivery roadmap and stage sequencing

## Next planned slice

The next stage for this package is `Stage 6: modular world state and extraction`.

That work will start promoting genre-appropriate game entities into structured state on top of the new compact context pipeline.
