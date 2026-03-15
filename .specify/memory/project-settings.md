# AI_PRG: Project Settings for SpecKit and Codex

## 1. Core Quality Commands

```powershell
flutter analyze
flutter test
```

## 2. Localization Policy

1. Default language: Russian (`ru`)
2. Required second language: English (`en`)
3. Language affects both UI and AI behavior
4. A UX-facing feature is incomplete if it works correctly in only one language

## 3. Feature Pipeline

1. If a task is not a bugfix, it starts with an architecture step.
2. Architecture is followed by an analytical step with a PRD or feature spec.
3. Only then does implementation begin.
4. Testing is mandatory after implementation.
5. The project follows explicit roles:
   - architect
   - analyst
   - developer
   - tester

## 4. Required Context for Feature Work

When working on a new feature, always take into account:

1. `.specify/memory/constitution.md`
2. `.specify/memory/project-context.md`
3. `.specify/memory/project-settings.md`
4. `PRD.md`
5. `Architecture.md`
6. `FlutterRules.md`
7. `ImplementationPlan.md`
8. `docs/features/CATALOG.md`
9. `docs/features/COMMANDS.md`

## 5. Implementation Plan Rule

1. The implementation plan is maintained as a checklist.
2. Stages and tasks use `[ ]` and `[x]`.
3. Task status must be updated as work progresses.

## 6. Feature Packet Rule

1. Every new feature gets a folder `docs/features/<feature-slug>/`.
2. The folder is created from `docs/features/_template/`.
3. The feature is registered in `docs/features/CATALOG.md`.
4. The feature gets its own git branch `codex/<feature-slug>`.
5. Each feature packet should contain:
   - `README.md`
   - `01-Architecture.md`
   - `02-PRD.md`
   - `03-Implementation.md`
   - `04-QA.md`

## 7. Autonomous Mode Rule

1. If the user asks to execute a feature, the agent proceeds through the pipeline autonomously.
2. The agent updates the implementation plan, feature catalog, and feature packet as needed.
3. Stop only when there is hidden risk, real ambiguity, or a choice with meaningful consequences.

## 8. Git Workflow

1. Every new feature is developed in a dedicated branch `codex/<feature-slug>`.
2. Implementation, tests, and docs happen inside that feature branch.
3. A validated feature branch is merged into `master`.
4. After merge, checks run again on the integrated state.
5. `master` should remain stable.

## 9. Mobile Adaptation Rule

1. All new UX and layout work must be designed and checked for mobile-sized screens, not only desktop windows.
2. Desktop support should extend the layout, not define it.
3. Wide layouts may introduce sidebars and split panes, but narrow layouts must remain fully usable without horizontal compression or detached controls.
4. If a screen contains gameplay, messaging, or creation flows, those flows must be operable with the primary actions visible in the viewport on mobile.

## 10. Chat Screen Rule

1. The gameplay transcript is the dominant area of the screen.
2. Character stats, quest state, and progress details belong in a sidebar, drawer, or collapsible block.
3. AI suggestion chips live above the input composer and are limited to the top three options.
4. The text field, send action, and suggest action are grouped into one composer area.
5. The chat input must remain visually and spatially connected to its action buttons.
