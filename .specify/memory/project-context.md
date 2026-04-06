# AI_PRG: Project Context

## 1. Purpose

This file defines the stable project context for SpecKit and feature packets:

1. product goals
2. architecture invariants
3. technical constraints
4. sources of truth for requirements and process

## 2. Product Summary

AI_PRG is a narrative RPG with a Flutter client and the server-authoritative
`Symmetry` backend. Campaigns, world state, turn history, auth, vector memory,
and story-template APIs live on the backend. The Flutter client handles UI,
auth UX, local session/settings, and optional user-owned provider credentials
that are passed transiently to the backend and never stored there.

## 3. Sources of Truth

1. project rules: `.cursorrules`, `.cursor/rules/ai-prg-project.mdc`
2. constitution: `.specify/memory/constitution.md`
3. product requirements: `PRD.md`
4. architecture: `Architecture.md`
5. project Flutter rules: `FlutterRules.md`
6. analyzer and lint config: `analysis_options.yaml`
7. roadmap: `Plan.md`, `ImplementationPlan.md`
8. feature registry: `docs/features/CATALOG.md`
9. team workflow and commands: `docs/features/COMMANDS.md`

## 4. Domain Invariants

1. AI output is never trusted before validation.
2. Backend runtime and persisted campaign state are the source of truth.
3. World changes, progress changes, and campaign updates are applied only
   through deterministic application logic on the server.
4. User-supplied provider credentials must never be written to server
   persistence or logs.
5. DB schema changes must go through Alembic migrations.

## 5. Technology Profile

1. client: Flutter
2. backend: FastAPI
3. database: PostgreSQL + pgvector
4. embeddings: local `sentence-transformers`
5. text-generation access: OpenAI-compatible gateway on the backend
6. client local storage: settings, language, session, server base URL, and
   optional user-owned AI keys

## 6. Documentation Sync Rules

1. update `PRD.md` when requirements change
2. update `Architecture.md` when system boundaries change
3. update `ImplementationPlan.md` when roadmap priorities change
4. update `docs/AGENT_CONTEXT.md` when agent-facing onboarding changes
5. update `docs/features/symmetry-hybrid-backend/*` when server-first
   architecture meaningfully evolves

## 7. Feature Packet Rules

1. every new feature, unless it is a bugfix, gets `docs/features/<slug>/`
2. every new feature is registered in `docs/features/CATALOG.md`
3. every new feature gets branch `codex/<feature-slug>`
4. before implementation, `01-Architecture.md` and `02-PRD.md` must exist
5. feature work follows stages: architect, analyst, developer, tester

## 8. Localization Invariant

1. the application starts in Russian by default
2. two full language modes are required: `ru` and `en`
3. language selection must affect the full user-facing experience

## 9. Mobile-First UX Invariant

1. the product is mobile-adapted by default
2. new UI work is incomplete until verified on narrow phone layouts
3. the gameplay chat remains the primary visual area

## 10. App Restart After Implementation

1. if restart is required to see changes, the agent must restart the app
2. do not leave obvious restart work to the user
