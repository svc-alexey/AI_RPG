# symmetry-hybrid-backend

Feature packet for the server-first `Symmetry` platform layer.

## Status

`implemented-with-followup`

## What this feature changed

- introduced `backend/symmetry/` as a dedicated FastAPI backend;
- moved campaign authority, auth, world simulation, vector memory, and story
  library APIs to the server;
- added transient user-provider credential support without server-side storage;
- migrated Flutter runtime flow away from local campaign persistence.

## Documents

- [Architecture](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/01-Architecture.md)
- [PRD](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/02-PRD.md)
- [Implementation](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/03-Implementation.md)
- [QA](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/04-QA.md)

## Remaining follow-up

- production rollout hardening around migrations and deploy order;
- live Yandex OAuth verification with real redirect/callback credentials.
