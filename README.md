# AI PRG

Flutter-приложение для AI-driven RPG с local-first архитектурой.

## Что это за проект

`AI PRG` развивает MVP текстовой RPG в полноценный клиентский RPG engine, где:

- кампания, сообщения и runtime-настройки живут локально;
- LLM остаётся narrative-слоем, а не источником истины для состояния мира;
- orchestration и UI-state построены на `Riverpod`;
- хранилище переведено на структурированный `Isar`-слой;
- чат, создание кампании, сохранения и настройки работают через controller/state, а не через service locator в UI.

## Текущее состояние

Уже реализовано:

- `Isar` storage foundation с миграцией из legacy `SharedPreferences`;
- Riverpod-first app shell и удаление `AppScope`;
- controller-слои для `Chat`, `Settings` и `New Game`;
- provider-driven экраны `Chat`, `Settings`, `New Game`, `Saves`;
- локальное сохранение кампаний и настроек модели;
- provider-agnostic AI service layer и fallback demo mode.

Ещё впереди:

- реальные sandbox controls для `max response tokens` и `context window`;
- hybrid context assembly (`header + summary + recent buffer`);
- entity extraction, dice engine и расширенный `World State`;
- настоящий streaming transport вместо UI-level имитации текста;
- isolates для тяжёлого post-processing и bulk storage work.

## Архитектурный вектор

- UI: `Flutter`
- State management: `flutter_riverpod`
- Local storage: `Isar`
- AI integration: provider-agnostic client/factory layer
- Platforms: Desktop-first, с прицелом на Android, iOS и Web

## Важные документы

- [PRD](D:/AI_PRG/docs/features/engine-mechanics-token-control/02-PRD.md)
- [Feature README](D:/AI_PRG/docs/features/engine-mechanics-token-control/README.md)
- [Architecture](D:/AI_PRG/docs/features/engine-mechanics-token-control/01-Architecture.md)
- [Implementation Plan](D:/AI_PRG/docs/features/engine-mechanics-token-control/03-Implementation.md)

## Базовые команды

```bash
flutter pub get
flutter analyze
flutter test
```
