# Agent Mode: Localization Stage 1

## Назначение

Этот агентский режим используется для фичи `localization-ru-en` на первом этапе post-MVP плана.

Режим нужен, чтобы:
- держать в фокусе только локализацию `ru/en`
- не смешивать ее с memory, prompt-оптимизацией и другими фичами
- запускать архитектуру, аналитику, реализацию и QA по этой фиче как отдельный pipeline

## Scope режима

Входит:
- локализация UI
- локализация системных сообщений
- локализация demo/fallback текста
- переключение `ru/en`
- связь выбранного языка с AI prompt и ожидаемым языком ответа

Не входит:
- перевод на третьи языки
- RAG/memory
- переработка game systems
- общий редизайн UI

## Обязательный контекст

Перед работой учитывать:
- [ImplementationPlan.md](D:/AI_PRG/ImplementationPlan.md)
- [PRD.md](D:/AI_PRG/PRD.md)
- [Architecture.md](D:/AI_PRG/Architecture.md)
- [FlutterRules.md](D:/AI_PRG/FlutterRules.md)
- [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md)
- [docs/features/localization-ru-en/01-Architecture.md](D:/AI_PRG/docs/features/localization-ru-en/01-Architecture.md)
- [docs/features/localization-ru-en/02-PRD.md](D:/AI_PRG/docs/features/localization-ru-en/02-PRD.md)

## Порядок ролей

1. Архитектор
2. Аналитик
3. Разработчик
4. Тестировщик

Каждая роль должна работать в отдельном окне/треде.

## Definition of Ready

- feature есть в [docs/features/CATALOG.md](D:/AI_PRG/docs/features/CATALOG.md)
- заполнены `01-Architecture.md` и `02-PRD.md`
- `03-Implementation.md` можно передавать разработчику
