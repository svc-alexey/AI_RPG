# Implementation: Campaign Modules

## Status

- [x] Architecture documented
- [x] PRD documented
- [x] Stage 6 implementation started
- [x] Stage 6 core slices implemented
- [x] Automated verification added
- [ ] Feature family fully complete

## Delivery slices

### Phase 1. Domain and storage

- [x] Introduce `CampaignModule` and module-aware campaign state
- [x] Separate always-on core state from module-specific slices
- [x] Persist modules, activation reasons, and module payloads in structured storage
- [x] Add compatibility for legacy campaigns and structured migration backfill

### Phase 2. Initial activation

- [x] Add default presets for `fantasy`, `detective`, and `sciFi`
- [x] Infer extra modules from story prompt and character setup hints
- [x] Show active systems during new-campaign review

### Phase 3. Runtime activation and extraction

- [x] Add `CampaignModuleResolver`
- [x] Add `EntityExtractionService`
- [x] Reconcile `Inventory`
- [x] Reconcile `Companions`
- [x] Reconcile `Notes`
- [x] Reconcile `Vitality`
- [x] Reconcile `Resources`
- [x] Reconcile `Progression`
- [x] Reconcile extracted recent `Checks`
- [x] Reconcile active modules before persistence

### Phase 4. Adaptive UI and feedback

- [x] Make the sidebar module-aware
- [x] Add transient overlay notifications
- [x] Highlight newly unlocked modules
- [x] Highlight modules changed on the latest turn
- [x] Preserve drawer/sidebar behavior on narrow layouts

### Phase 5. Deterministic systems

- [x] Attach a local `DiceEngine` to the `Checks` module
- [x] Restrict roll reducers to active deterministic modules
- [x] Update the prompt contract so AI narrates resolved outcomes

## Notes

- The `Checks` implementation now resolves deterministic outcomes on the client and passes them to the model as fixed context.
- Deeper authored combat rules still remain future work, but the Stage 7 deterministic foundation is now in place.
