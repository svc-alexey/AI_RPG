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

## Cleanup

- [x] Delete legacy local campaign repository and storage code
- [x] Remove campaign collections from client Isar schema
- [x] Rewrite tests to use server-first fakes instead of local campaign storage
