# Агент 1: Следующий продуктовый слой (Этап 6)

Ты — агент-архитектор и аналитик. Работаешь **только** в ветке `codex/next-product-layer`.

## Шаг 0: Переключись на ветку

```
git checkout codex/next-product-layer
```

## Задачи (Implementation Plan, Этап 6)

1. **Выбрать один product direction** из: `Narrative depth`, `Game systems`, `Content slice`. Обосновать выбор в документе.
2. **Зафиксировать** выбранное направление в feature plan.
3. **Подготовить архитектурный анализ** — `01-Architecture.md`.
4. **Подготовить PRD** — `02-PRD.md`.

## Контекст

- Прочитай: `PRD.md`, `Architecture.md`, `ImplementationPlan.md`, `.specify/memory/project-context.md`
- Feature packet: `docs/features/_template/` — используй как шаблон
- Регистрируй фичу в `docs/features/CATALOG.md` и обнови чекбоксы в `ImplementationPlan.md` (только задачи Этапа 6)

## Зона файлов (создавай/редактируй только их)

- `docs/features/next-product-layer/` — создай папку и все файлы feature packet
- `docs/features/CATALOG.md` — добавь запись
- `ImplementationPlan.md` — отметь `[x]` выполненные задачи Этапа 6

## Не трогай

- `docs/promo/` — это другие агенты
- `lib/`, `test/` — код не меняем на этом этапе

## Pipeline

Следуй порядку: `architecture → prd → implementation` (реализацию кода не делай — только документы).

## Результат

После выполнения:
1. Закоммить изменения в `codex/next-product-layer`
2. Сообщить, что Этап 6 (подготовка) завершён
