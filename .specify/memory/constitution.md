# AI_PRG Constitution

## Core Principles

### I. Engine-First Source of Truth (NON-NEGOTIABLE)
LLM никогда не является источником истины состояния игры.  
Источник истины только один: детерминированный игровой движок + сохраненное состояние.
Любой `ai_response.state_changes` считается недоверенным до прохождения валидатора.

### II. Structured AI Contracts Only
Все интеграции AI работают через единый gateway и строгий JSON-контракт.
Свободный текст без структурированных полей не используется для изменения состояния.
Изменения контракта допускаются только версионируемо и обратно совместимо.

### III. Layered Memory for Coherence
Память кампании строится слоями:
1. Recent turns.
2. Rolling summary.
3. Entity cards.
4. World canon.
Длинные кампании не должны полагаться только на сырой лог ходов.

### IV. Flutter Architecture Discipline
Клиент строится по feature-first структуре с разделением слоев:
`presentation -> application -> domain -> data`.
`domain` не зависит от Flutter UI и провайдерных SDK.
Сетевые вызовы и AI вызовы из UI напрямую запрещены.

### V. Quality Gates Before Merge
Перед merge обязательны:
1. `flutter analyze` без ошибок.
2. `flutter test` без падений.
3. Тесты/валидация для изменений доменных правил и контрактов.
4. Обновление документации при изменении схем и правил.

## Tech Constraints and Standards
1. Клиентский стек: Flutter.
2. Линтинг и анализатор: [analysis_options.yaml](../../analysis_options.yaml).
3. Доменные правила Flutter: [FlutterRules.md](../../FlutterRules.md).
4. Продуктовый источник требований: [PRD.md](../../PRD.md).
5. Архитектурный источник: [Architecture.md](../../Architecture.md).
6. Контракт сущностей: [entities.models.json](../../entities.models.json).
7. Стратегический контекст и этапы: [Plan.md](../../Plan.md).

## Development Workflow
1. `speckit.constitution` обновляется при изменении принципов.
2. Любая новая фича проходит цепочку `specify -> plan -> tasks -> implement`.
3. Изменение контракта данных требует миграционного плана и фиксации версии.
4. Для долгоживущих фич обязательна проверка на совместимость save/load.

## Governance
1. Конституция имеет приоритет над локальными ad-hoc решениями.
2. Любое исключение из принципов документируется в PR с явным обоснованием.
3. Поправки в конституцию:
   - обновление версии;
   - дата изменения;
   - перечень затронутых документов.
4. Контекст проекта поддерживается в `.specify/memory/project-context.md`.

**Version**: 1.0.0 | **Ratified**: 2026-03-15 | **Last Amended**: 2026-03-15
