# Feature: Deterministic Systems

## Summary

This feature package tracks the Stage 8 shift where gameplay checks stop being model-decided narration and become client-resolved state.

The implemented slice introduces:

- a local `DiceEngine`
- deterministic `might`, `wit`, and `spirit` checks behind the active `Checks` module
- prompt contracts where AI receives the resolved outcome as known state
- persistence and UI surfacing for resolved checks

## Current status

Status: implemented, with follow-up validation still open in the main Stage 8 checklist.

Implemented:

- client-side deterministic check planning and rolling
- module-aware gating so checks only run when the campaign actually uses `Checks`
- memory/save/sidebar integration for resolved outcomes
- unit/widget coverage for deterministic resolution and detective chrome gating

Still pending at the plan level:

- broader long-session validation
- final settings/runtime UX re-validation
- next-layer architecture cleanup and analyzer debt reduction

## Documents

- `01-Architecture.md` - system placement and contracts
- `02-PRD.md` - user-facing scope and requirements
- `03-Implementation.md` - delivered slice and remaining work
- `04-QA.md` - automated coverage and residual risks
