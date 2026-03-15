# Feature: Next Product Layer — Narrative Depth

## Краткая сводка

Следующий продуктовый слой после стабилизации MVP. Выбрано направление **Narrative depth** — углубление повествовательного опыта.

## Product direction

**Выбор:** Narrative depth

**Обоснование:**

1. **Core value proposition** — AI RPG позиционируется как narrative RPG; главная ценность — погружение в историю. Narrative depth напрямую усиливает это.
2. **Естественное расширение** — MVP уже имеет memory layer (rolling summary, active goal, recent turns), AI contract (narration, choices, state_changes) и валидацию через движок. Narrative depth расширяет AI-контракт и промпты без перестройки state engine.
3. **Меньше рисков** — Game systems (инвентарь, квесты, навыки) потребуют значительных изменений в state и миграций. Content slice — больше контент, меньше архитектуры. Narrative depth даёт meaningful слой при умеренной сложности.
4. **Синергия с memory** — более богатое повествование лучше использует уже существующий memory layer и summary.

## Состав пакета

- `01-Architecture.md` — архитектурный анализ
- `02-PRD.md` — продуктовые требования
- `03-Implementation.md` — план реализации
- `04-QA.md` — проверки и риски

## Ссылки

- [PRD.md](../../PRD.md)
- [Architecture.md](../../Architecture.md)
- [ImplementationPlan.md](../../ImplementationPlan.md)
