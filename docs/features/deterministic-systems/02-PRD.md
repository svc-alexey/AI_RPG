# PRD: Deterministic Systems

## 1. User goal

Players should feel that check outcomes are fair, stable, and consistent across save/load and long sessions, while the AI focuses on narration instead of deciding hidden dice results.

## 2. User scenarios

- A fantasy player attempts a risky action and receives a narrated outcome that matches a client-resolved roll.
- A saved campaign reloads and still shows the same recent deterministic checks in the sidebar and memory trail.
- A detective campaign continues to hide irrelevant combat/inventory chrome even if the model tries to mention RPG-like deltas.

## 3. Functional requirements

- The client must resolve checks locally when the active campaign uses the `Checks` module.
- The model must receive deterministic check outcomes as known context before narration.
- Resolved checks must be written into campaign state, saves, recent memory, and check UI.
- The sidebar and overlays must react to resolved checks the same way as other structured state changes.
- Non-relevant RPG chrome must stay hidden in campaigns that do not support those systems.

## 4. Non-functional requirements

- Deterministic resolution must not require network access.
- The implementation must preserve existing save compatibility.
- The logic must remain testable at unit and widget levels.
- The prompt contract must stay compact and compatible with the existing runtime token controls.

## 5. Definition of done for this slice

- `DiceEngine` exists and is used by the active `Checks` flow.
- AI requests contain client-resolved deterministic context.
- Campaign state and memory reflect resolved checks after the turn is applied.
- Automated coverage verifies deterministic checks and detective chrome gating.
