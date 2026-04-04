# AI_PRG: Project Settings for SpecKit and Codex

**Применение правил**: Правила из этого файла и `.specify/memory/` всегда применяются через `.cursorrules` и `.cursor/rules/ai-prg-project.mdc`. При добавлении новых правил — обновляй этот файл и `.cursorrules`.

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

## 2a. Source Encoding (Cyrillic and UTF-8)

1. All project text files that contain Cyrillic (`.dart`, `.md`, `.arb`, `.yaml`, and others) must be saved as **UTF-8 without BOM**.
2. Do not commit mojibake (garbled Cyrillic such as sequences starting with `РЎ` / `Р` where readable Russian was intended). If a string looks wrong, fix the bytes to UTF-8 or take the wording from `AppLocalizations` / the English counterpart.
3. After editing localized or Russian-literal strings, prefer `flutter analyze` to catch accidental encoding issues where the toolchain reports them.

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

1. `.cursorrules` (always applied by Cursor)
2. `.specify/memory/constitution.md`
3. `.specify/memory/project-context.md`
4. `.specify/memory/project-settings.md`
5. `PRD.md`
6. `Architecture.md`
7. `FlutterRules.md`
8. `ImplementationPlan.md`
9. `docs/features/CATALOG.md`
10. `docs/features/COMMANDS.md`

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

1. New screens are treated as mobile-first by default; desktop extends the layout.
2. All new UX and layout work must be designed and checked for mobile-sized screens, not only desktop windows.
3. Desktop support should extend the layout, not define it.
4. Wide layouts may introduce sidebars and split panes, but narrow layouts must remain fully usable without horizontal compression or detached controls.
5. If a screen contains gameplay, messaging, or creation flows, those flows must be operable with the primary actions visible in the viewport on mobile.

## 10. App Restart Rule

1. After implementing changes, if an app restart is required to see the changes (e.g., hot reload is insufficient, native code changed, manifest changed), the agent **MUST** restart the application.
2. For Flutter: use `flutter run` (or hot restart if the app is already running in a terminal).
3. Do not skip restart when it is clearly needed; the user should not have to restart manually.

## 11. Chat Screen Rule

1. The gameplay transcript is the dominant area of the screen.
2. Character stats, quest state, and progress details belong in a sidebar, drawer, or collapsible block.
3. AI suggestion chips live above the input composer and are limited to the top three options.
4. The text field, send action, and suggest action are grouped into one composer area.
5. The chat input must remain visually and spatially connected to its action buttons.
