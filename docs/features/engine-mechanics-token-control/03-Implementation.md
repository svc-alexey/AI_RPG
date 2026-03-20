# Implementation Plan: AI RPG Engine Core, Mechanics & Token Control

## 1. Delivery Strategy

Рекомендованный порядок остался таким:

1. storage foundation
2. state architecture
3. runtime model controls
4. real streaming
5. hybrid context
6. world state expansion
7. deterministic gameplay systems

Это по-прежнему минимизирует риск: сначала закрепляется источник истины и orchestration, потом улучшается LLM runtime, и только затем добавляются gameplay layers.

## 2. Status Snapshot

### Completed

- Stage 1: `Isar` foundation, migration path, structured repositories
- Stage 2: `Riverpod` app shell, removal of `AppScope`, screen controllers for `Chat`, `Settings`, `New Game`
- Stage 3: `ModelRuntimeSettings`, provider-scoped persistence, runtime presets, request token caps, and context-window-aware prompt assembly

### Active Next Stage

- Stage 4: real streaming

### Remaining Major Stages

- Stage 4: real streaming
- Stage 5: hybrid context and summary cadence
- Stage 6: world state v2 and extraction
- Stage 7: dice engine and deterministic checks
- Stage 8: UI expansion over richer world state

## 3. Stage 1. Storage Foundation

Статус: done

Done:

- [x] Подключён `Isar` и codegen
- [x] Добавлены structured collections для campaign/runtime data
- [x] Реализованы `CampaignLocalDataSource` и `SettingsLocalDataSource`
- [x] Репозитории переведены на новый persistence layer
- [x] Добавлена миграция из legacy `SharedPreferences`
- [x] Оставлен compatibility fallback для test/runtime environments без `isar.dll`

Exit criteria:

- [x] Старые кампании открываются после миграции
- [x] Новые кампании и settings сохраняются через `Isar`-based persistence
- [x] Save/load flow не деградировал

## 4. Stage 2. State Architecture

Статус: done

Done:

- [x] Введён `ProviderScope` на уровне приложения
- [x] Убран `AppScope` из runtime architecture
- [x] Локализация отвязана от service locator
- [x] `ChatScreen` переведён на controller/state orchestration
- [x] `SettingsScreen` переведён на отдельный controller
- [x] `NewGameScreen` переведён на отдельный controller
- [x] `SavesScreen` работает через providers

Exit criteria:

- [x] UI не содержит core async orchestration
- [x] Основные пользовательские flow работают через `Riverpod`
- [x] App shell больше не зависит от inherited service locator

## 5. Stage 3. Token & Runtime Controls

Статус: done

Goal:

Дать пользователю прямой контроль над ценой, длиной и размером контекста LLM-вызова.

Tasks:

- [x] Расширить runtime settings model под `maxResponseTokens`
- [x] Расширить runtime settings model под `contextWindowSize`
- [x] Добавить sandbox controls в `SettingsScreen`
- [x] Протянуть новые параметры в prompt assembly / transport layer
- [x] Добавить presets или quick profiles для fast/smart/cheap usage
- [x] Добавить persistence и widget coverage для новых controls

Exit criteria:

- [x] Пользователь может менять limits из UI
- [x] Эти значения реально влияют на runtime request assembly

## 6. Stage 4. Real Streaming

Статус: backlog

Goal:

Заменить UI-level progressive rendering на настоящий network streaming.

Tasks:

- [ ] Ввести streaming contract в AI client layer
- [ ] Реализовать parser для OpenAI-compatible stream
- [ ] Обновлять narration buffer по chunk-ам
- [ ] Развести partial message state и final persisted narration
- [ ] Сохранить fallback на non-streaming providers
- [ ] Проверить cancel flow во время stream

Exit criteria:

- [ ] Текст приходит до завершения генерации
- [ ] Cancel корректно обрывает поток
- [ ] В storage попадает финальный текст, а не partial snapshot

## 7. Stage 5. Hybrid Context

Статус: backlog

Goal:

Сделать длинную кампанию компактной для модели и устойчивой по памяти.

Tasks:

- [ ] Выделить `ContextAssemblyService`
- [ ] Формализовать `static header`
- [ ] Формализовать `dynamic summary`
- [ ] Ввести `recent buffer` с настраиваемым окном
- [ ] Ввести cadence обновления summary каждые `N` ходов
- [ ] Ограничить prompt payload по runtime settings

Exit criteria:

- [ ] Модель не получает полный chat log
- [ ] Связность кампании сохраняется на длинной дистанции

## 8. Stage 6. World State v2 and Extraction

Статус: backlog

Goal:

Перевести narration в синхронизированный и расширяемый world state.

Tasks:

- [ ] Расширить world state полями `Gold`, `Exp`, `Level`
- [ ] Довести `Inventory` / `Companions` как first-class data
- [ ] Реализовать `EntityExtractionService`
- [ ] Сначала внедрить rule-based extraction для inventory
- [ ] Затем расширить extraction на companions и world notes
- [ ] Ввести reducer/reconciliation layer перед записью в базу

Exit criteria:

- [ ] Narrative rewards и находки синхронизируются с состоянием
- [ ] Ошибка extractora не ломает кампанию

## 9. Stage 7. Dice Engine and Deterministic Checks

Статус: backlog

Goal:

Забрать у модели право определять исход skill/combat checks.

Tasks:

- [ ] Добавить `DiceEngine`
- [ ] Определить типы проверок: минимум `might`, `wit`, `spirit`
- [ ] Добавить thresholds / modifiers / crit logic
- [ ] Изменить prompt contract: AI только описывает уже известный outcome
- [ ] Ограничить state mutation paths в branches с deterministic checks

Exit criteria:

- [ ] Roll logic воспроизводима локально
- [ ] AI не может переопределять outcome локальной проверки

## 10. Stage 8. UI Expansion

Статус: backlog

Goal:

Визуально раскрыть richer world state на desktop и mobile.

Tasks:

- [ ] Выделить отдельные панели `Stats`, `Inventory`, `Companions`
- [ ] Добавить визуализацию HP / EXP / Level
- [ ] Для desktop развить side-panel layout
- [ ] Для mobile свернуть вторичный state в tabs / sheets / drawers
- [ ] Подготовить UI к richer world-state reducers

Exit criteria:

- [ ] World state читается без перегруза chat UI
- [ ] Mobile сохраняет focus на gameplay loop

## 11. Recommended Next PR Slice

Следующий архитектурно правильный срез:

1. streaming contract в AI client layer
2. parser для OpenAI-compatible SSE/stream chunks
3. partial narration state в UI с fallback на non-streaming providers

Это следующий короткий путь к ощутимому UX-win после того, как runtime controls уже начали реально влиять на запросы.
