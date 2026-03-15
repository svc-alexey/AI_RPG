# AI_PRG: Project Context

## 1. Purpose

This file defines the stable project context for SpecKit and feature packets:

1. Product goals
2. Architecture invariants
3. Technical constraints
4. Sources of truth for requirements and process

## 2. Product Summary

AI_PRG is a narrative RPG built with Flutter where AI generates narration and action options, while a deterministic game engine validates and applies only allowed state changes. The project supports local saves, multiple AI providers through an OpenAI-compatible gateway, Russian and English UX, and layered memory for long-running campaigns.

## 3. Sources of Truth

1. Constitution: `.specify/memory/constitution.md`
2. Product requirements: `PRD.md`
3. Architecture: `Architecture.md`
4. Project Flutter rules: `FlutterRules.md`
5. Analyzer and lint config: `analysis_options.yaml`
6. Strategic and implementation roadmap: `Plan.md`, `ImplementationPlan.md`
7. Feature registry: `docs/features/CATALOG.md`
8. Team workflow and commands: `docs/features/COMMANDS.md`

## 4. Domain Invariants

1. AI output is never trusted before validation.
2. The engine and persisted campaign state are the source of truth, not the free-form text returned by a model.
3. World changes, inventory updates, and progress changes are applied only through deterministic application logic.
4. Save and load flows must preserve compatibility as the MVP evolves.

## 5. Technology Profile

1. Client: Flutter
2. AI layer: provider-agnostic gateway plus adapters
3. Local AI mode: LM Studio via OpenAI-compatible API
4. Storage: local campaign saves and local settings

## 6. Documentation Sync Rules

1. Update `PRD.md` when requirements change.
2. Update `Architecture.md` when application structure changes.
3. Update `FlutterRules.md` and `.specify/memory/*` when engineering rules change.
4. Update `ImplementationPlan.md` when roadmap priorities change.

## 7. Feature Packet Rules

1. Every new feature, unless it is a bugfix, gets its own folder in `docs/features/<feature-slug>/`.
2. Every new feature is registered in `docs/features/CATALOG.md`.
3. Every new feature gets its own git branch `codex/<feature-slug>`.
4. Before implementation, `01-Architecture.md` and `02-PRD.md` must be prepared.
5. Feature work follows explicit stages: architect, analyst, developer, tester.

## 8. Localization Invariant

1. The application starts in Russian by default.
2. Two full language modes are required: `ru` and `en`.
3. Language selection must affect the full UX:
   - interface labels
   - buttons and hints
   - errors and statuses
   - starter campaign text
   - AI prompt layer
4. A feature is not considered complete if it affects user-facing UX but is implemented only for one language.

## 9. Mobile-First UX Invariant

1. The product must be treated as mobile-adapted by default, even if desktop remains supported.
2. New UI work is not considered complete until it is verified on narrow phone-sized layouts.
3. Primary gameplay actions must remain reachable with one-thumb interaction zones on small screens.
4. Dense informational blocks must collapse, move to drawers, or move to side panels depending on available width.
5. The game screen must prioritize the playable conversation area over metadata panels.

## 10. Gameplay Screen Layout Expectations

1. The chat transcript should occupy the largest visible area of the play screen.
2. Character stats, quest progress, and secondary campaign metadata should move into a sidebar, drawer, or collapsible panel instead of dominating the main column.
3. Up to three AI suggestion chips should sit directly above the input area.
4. The text input and its action buttons must be part of one bottom composer row or composer block.
5. Send and suggest actions should not live in visually detached sections away from the text field.
6. On mobile widths, the input composer stays pinned near the bottom and the chat content remains the main focus.
