# PRD: Symmetry Hybrid Backend

## Summary

Build a backend that owns auth, campaigns, world simulation, vector memory,
story-library APIs, and future billing scaffolding.

## User-facing outcomes

1. User can register, log in, and resume campaigns through the backend.
2. Campaign turns are processed server-side with RAG and world simulation.
3. User can optionally use personal model credentials without the server
   persisting them.
4. Story-template APIs exist even before their Flutter UI is implemented.
5. Flutter no longer relies on local campaign persistence for primary gameplay.

## Non-goals

1. real billing
2. story-library Flutter UI
3. production-complete Yandex OAuth validation
4. server-side storage of user-owned provider credentials

## Acceptance

1. backend auth/session flow works
2. create/list/load/delete campaign works
3. `process_turn` performs RAG + persistence
4. important events are written to `world_chronicles`
5. user-supplied credentials are transient only
6. Alembic migrations are the authoritative schema mechanism
