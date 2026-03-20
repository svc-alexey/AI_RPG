# Feature: Campaign Modules

## Summary

This feature package tracks the move from a hard-wired RPG-only world state to a modular campaign model where each story enables only the systems it actually needs.

Core idea:

- campaigns keep an always-on core state;
- optional modules layer on top of that core state: `Inventory`, `Companions`, `Notes`, `Vitality`, `Resources`, `Progression`, and `Checks`;
- modules can be enabled at campaign creation from `setting`, story prompt, and character setup;
- modules can also unlock later when narration clearly introduces a new structured system;
- the UI shows only active systems and surfaces changes through lightweight overlays instead of intrusive blockers.

## Current implementation status

The Stage 6 groundwork is now in place:

- module-aware campaign state and persistence are implemented;
- initial activation works for `fantasy`, `detective`, and `sciFi`;
- runtime extraction and reconciliation work for inventory, companions, notes, vitality, resources, progression, and recent checks;
- the chat sidebar renders only active modules;
- transient overlays show item, companion, resource, vitality, progression, check, and module-unlock feedback.

What is still ahead:

- deterministic roll resolution through a local `DiceEngine`;
- stricter contracts around when `Checks` moves from extracted history to fully deterministic gameplay;
- any optional polish around manual module controls or richer adaptive panels.

## Package contents

- `01-Architecture.md` - architecture decisions
- `02-PRD.md` - product requirements
- `03-Implementation.md` - implementation status and next steps
- `04-QA.md` - QA coverage, risks, and acceptance notes

## Related documents

- [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- [Engine Mechanics Implementation](D:/AI_PRG/docs/features/engine-mechanics-token-control/03-Implementation.md)
