# AI_PRG Constitution

## Core Principles

### I. Engine-First Source of Truth

LLM никогда не является источником истины состояния игры. Источник истины — детерминированный движок и сохраненное состояние кампании.

### II. Structured AI Contracts Only

Все AI-интеграции работают через единый gateway и structured contract. Свободный текст без парсинга не применяется напрямую к игровому state.

### III. Layered Memory for Coherence

Память кампании строится слоями:

1. recent turns
2. rolling summary
3. active goal / active situation
4. дальнейшее расширение памяти при необходимости

### IV. Flutter Architecture Discipline

Клиент строится по feature-first подходу с явным разделением ответственности между UI, моделями, сервисами и репозиториями.

### V. Quality Gates Before Merge

Перед merge обязательны:

1. `flutter analyze` без compile-level ошибок
2. `flutter test` без падений
3. обновление документации при изменении требований или контрактов

## Development Workflow

1. Любая новая фича проходит цепочку `architecture -> prd -> implementation -> qa`.
2. Для bugfix допустим сокращенный путь, если не меняются архитектура и требования.
3. Если пользователь просит выполнить фичу целиком, агент проходит pipeline автономно.

## Feature Packet Workflow

1. Каждая новая фича, если это не bugfix, обязана иметь отдельный feature packet в `docs/features/<feature-slug>/`.
2. Каждая новая фича обязана быть зарегистрирована в `docs/features/CATALOG.md`.
3. Каждая новая фича обязана иметь отдельную git-ветку `codex/<feature-slug>`.
4. Реализация до завершения архитектуры и PRD считается отклонением от процесса.

## Merge Policy

1. Завершенная и проверенная feature-ветка должна быть слита в `master`.
2. `master` должен оставаться стабильной веткой проекта.
3. После merge в `master` проверки запускаются повторно на объединенном состоянии.

## Governance

1. Конституция имеет приоритет над ad-hoc решениями.
2. Любое исключение из правил должно быть явно зафиксировано.
3. Актуальный продуктовый контекст поддерживается в `.specify/memory/project-context.md`.
