# Implementation

## Backend

- [x] Add `backend/symmetry/` FastAPI project
- [x] Add root [docker-compose.yml](/D:/AI_PRG/docker-compose.yml) with
  `PostgreSQL + pgvector` and backend API
- [x] Add auth, campaign, prompt-generation, provider-check, and
  story-template routes
- [x] Add SQLAlchemy models for auth, world, library, and billing scaffolding
- [x] Add local embedding service and OpenAI-compatible AI gateway
- [x] Add `CredentialResolutionService` for server/default vs transient user
  credentials
- [x] Add background chronicle persistence
- [x] Add Alembic configuration and initial migration
- [x] Change startup flow so schema rollout goes through `alembic upgrade head`
- [x] Add root `GET /health` and `GET /version` runtime endpoints
- [x] Add stable-prefix turn payload layout for provider prompt caching
- [x] Persist normalized LLM usage metadata on `CampaignTurn`
- [x] Add scenario-aware token budgets and compact turn-context assembly
- [x] Add private dev usage report endpoint protected by a server token
- [x] Add startup/location safety for `Starting Point` / `Начальная точка`
- [x] Stop storing empty player bubbles for intro-turns
- [x] Let the model activate/deactivate gameplay modules through
  `state_changes.module_updates`

## Flutter

- [x] Add `SymmetryAuthRepository`
- [x] Add `SymmetryCampaignRepository`
- [x] Add `SymmetryApiClient`
- [x] Add auth gate / auth screen
- [x] Move new-campaign flow to backend APIs
- [x] Move chat turn processing to backend APIs
- [x] Move saves screen to backend campaign list
- [x] Remove runtime local campaign persistence fallback
- [x] Keep user AI keys only in local client settings
- [x] Add `/version` client models and update-check repository/service
- [x] Add custom update gate for `soft` / `force` release handling
- [x] Move quick start and prompt generation to server-backed flow even when
  only the backend has provider credentials
- [x] Change chat autoscroll to follow player sends, not narrator growth
- [x] Limit `world rumors` and `recent events` to the latest 5 items
- [x] Stop enabling `vitality` by preset alone for server-backed campaigns

## Cleanup

- [x] Delete legacy local campaign repository and storage code
- [x] Remove campaign collections from client Isar schema
- [x] Rewrite tests to use server-first fakes instead of local campaign storage
- [x] Keep backend `.env` resolution stable across different local working
  directories
- [x] Keep web release artifacts (`version.json`, service worker, SEO files)
  aligned with backend release metadata
