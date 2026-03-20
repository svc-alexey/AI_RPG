# Feature: AI RPG Engine Core, Mechanics & Token Control

## Summary

Этот feature-пакет описывает переход проекта от AI-chat MVP к local-first RPG engine с управляемой стоимостью LLM, структурированным world state и предсказуемым orchestration layer.

## Актуальный статус

Уже реализовано в коде:

- `Isar` storage foundation и миграция с legacy storage;
- `Riverpod` как основной state-management слой;
- удаление `AppScope` из app shell;
- controller/state orchestration для `Chat`, `Settings` и `New Game`;
- provider-driven `Saves` flow;
- локализация отвязана от service locator и живёт через отдельный localization scope.

Ещё не реализовано:

- model sandbox controls: `max response tokens`, `context window`, presets;
- hybrid context memory pipeline;
- extraction pipeline для inventory / companions / world notes;
- dice engine и расширенный deterministic gameplay layer;
- настоящий streaming transport;
- isolates для тяжёлых background операций.

## Документы пакета

- `01-Architecture.md` — целевая архитектура и gap-analysis
- `02-PRD.md` — продуктовые требования и обновлённый scope
- `03-Implementation.md` — roadmap и sequencing работ

## Текущий architectural decision

Проект теперь движется по модели:

- `Riverpod` управляет состоянием экранов и orchestration;
- `Isar` остаётся источником локальной истины для campaign/runtime data;
- UI отвечает за rendering и navigation, а не за side effects;
- LLM provider слой остаётся заменяемым и не должен протекать в presentation.
