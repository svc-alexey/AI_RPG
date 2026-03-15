# Architecture Plan: <feature-name>

## 1. Контекст

Перед началом изучить:
- [PRD.md](D:/AI_PRG/PRD.md)
- [Architecture.md](D:/AI_PRG/Architecture.md)
- [FlutterRules.md](D:/AI_PRG/FlutterRules.md)
- [.specify/memory/project-context.md](D:/AI_PRG/.specify/memory/project-context.md)
- [.specify/memory/project-settings.md](D:/AI_PRG/.specify/memory/project-settings.md)

## 2. Цель этапа

Определить, где живет фича, какие слои затрагивает, какие контракты меняются и какие риски появятся.

## 3. Вопросы архитектора

- Где в текущей архитектуре должна жить фича?
- Какие модели, репозитории, сервисы и экраны будут затронуты?
- Нужны ли миграции данных или изменения save/load?
- Как фича повлияет на AI-контракты, summary, memory, локализацию?
- Какие риски и trade-off есть у выбранного решения?

## 4. Результат

- архитектурное решение
- затронутые файлы/модули
- риски
- границы этапа реализации
