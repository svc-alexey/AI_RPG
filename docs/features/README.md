# Features Workflow

Каждая новая фича, если это не bugfix, проходит через отдельную feature-папку.

Порядок работы:
1. Пользователь формулирует задачу.
2. Задача добавляется в [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md) как чекбокс.
3. Задача регистрируется в [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md), чтобы она попадала в общий scope проекта.
4. Для задачи создается отдельная папка в `docs/features/<feature-slug>/`.
5. Папка создается по шаблону из `docs/features/_template/`.
6. Внутри feature-папки работа идет строго по этапам:
   - `01-Architecture.md`
   - `02-PRD.md`
   - `03-Implementation.md`
   - `04-QA.md`
7. Только после архитектуры и аналитики допускается реализация.
8. Каждый этап роли ведется в отдельном окне/треде: архитектор, аналитик, разработчик и тестировщик не смешиваются в одном рабочем окне.

Что обязательно учитывать в каждой feature-папке:
- [PRD.md](D:/AI_PRG/PRD.md)
- [Architecture.md](D:/AI_PRG/Architecture.md)
- [FlutterRules.md](D:/AI_PRG/FlutterRules.md)
- [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md)
- [docs/features/COMMANDS.md](D:/AI_PRG/docs/features/COMMANDS.md)
- [.specify/memory/constitution.md](D:/AI_PRG/.specify/memory/constitution.md)
- [.specify/memory/project-context.md](D:/AI_PRG/.specify/memory/project-context.md)
- [.specify/memory/project-settings.md](D:/AI_PRG/.specify/memory/project-settings.md)
