# Cursor Rules — AI_PRG

## Текущая структура (упрощённая)

- **`.cursorrules`** — основные правила проекта, всегда применяются Cursor
- **`.cursor/rules/ai-prg-project.mdc`** — правило с `alwaysApply: true`, дублирует ключевые инструкции
- **`.cursor/rules_archive/isolation_rules/`** — архив старых mode-based правил (VAN, PLAN, IMPLEMENT и т.д.)

## Где добавлять новые правила

1. **`.specify/memory/project-settings.md`** — основной файл правил (SpecKit + Cursor)
2. **`.cursorrules`** — краткая выжимка для всегда-применения; при изменении project-settings обновляй и .cursorrules

## SpecKit

SpecKit (`.codex/prompts/speckit.*.md`) использует `.specify/memory/` при выполнении команд `/speckit.implement` и др. Правила из .cursorrules и project-settings применяются всегда.
