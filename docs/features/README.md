# Features Workflow

Каждая новая фича, если это не bugfix, проходит через отдельный feature-пакет.

## Порядок работы

1. Пользователь формулирует задачу.
2. Задача добавляется в [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md).
3. Задача регистрируется в [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md).
4. Для задачи создается отдельная ветка `codex/<feature-slug>`.
5. Для задачи создается папка `docs/features/<feature-slug>/`.
6. Внутри feature-пакета работа идет по этапам:
   - `01-Architecture.md`
   - `02-PRD.md`
   - `03-Implementation.md`
   - `04-QA.md`
7. Только после архитектуры и аналитики допускается реализация.

## Что обязательно учитывать в каждом feature-пакете

- [PRD.md](D:/AI_PRG/PRD.md)
- [Architecture.md](D:/AI_PRG/Architecture.md)
- [FlutterRules.md](D:/AI_PRG/FlutterRules.md)
- [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md)
- [docs/features/COMMANDS.md](D:/AI_PRG/docs/features/COMMANDS.md)
- [.specify/memory/constitution.md](D:/AI_PRG/.specify/memory/constitution.md)
- [.specify/memory/project-context.md](D:/AI_PRG/.specify/memory/project-context.md)
- [.specify/memory/project-settings.md](D:/AI_PRG/.specify/memory/project-settings.md)

## Дополнительно для текущей server-first платформы

- Если фича меняет границы между Flutter и `Symmetry`, нужно обновить:
  - [PRD.md](D:/AI_PRG/PRD.md)
  - [Architecture.md](D:/AI_PRG/Architecture.md)
  - [docs/AGENT_CONTEXT.md](D:/AI_PRG/docs/AGENT_CONTEXT.md)
  - соответствующий feature packet
- Если фича меняет схему БД backend-а, нужно добавить Alembic migration.
- Нельзя возвращать local campaign runtime flow как основной путь приложения.
