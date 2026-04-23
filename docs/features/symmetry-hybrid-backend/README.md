# symmetry-hybrid-backend

Feature packet for the server-first `Symmetry` platform layer.

## Status

`implemented-with-followup`

## What this feature changed

- introduced `backend/symmetry/` as a dedicated FastAPI backend;
- moved campaign authority, auth, world simulation, vector memory, and story
  library APIs to the server;
- added DB-backed butterfly simulation, dedicated worker processing, and
  world-rumor delivery for off-screen world events;
- removed setting-based opening-location bootstraps and stock world seeds so
  the first concrete location, factions, companies, markets, and weather come
  from the model/story state instead of reusable backend templates;
- added transient user-provider credential support without server-side storage;
- migrated Flutter runtime flow away from local campaign persistence;
- библиотека миров: обложки шаблонов в БД, маршруты cover, клиент (Web + guest
  session + дедуп `/v1` в URL) — см. раздел **Story library** в
  [03-Implementation.md](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/03-Implementation.md).

## Documents

- [Architecture](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/01-Architecture.md)
- [PRD](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/02-PRD.md)
- [Implementation](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/03-Implementation.md)
- [QA](/D:/AI_PRG/docs/features/symmetry-hybrid-backend/04-QA.md)

## Remaining follow-up

- production rollout hardening around migrations, readiness, worker health,
  deploy order, and Docker DNS / relay reachability;
- live Yandex OAuth verification with real redirect/callback credentials.
