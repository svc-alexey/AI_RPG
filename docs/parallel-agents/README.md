# Параллельные агенты — Implementation Plan

Текущее состояние закоммичено. Созданы 4 ветки для параллельной работы. Каждый агент работает **в отдельном окне Cursor** (новый чат/Composer) и **в своей ветке**.

## Как запустить

1. Открой **4 окна Cursor** (или 4 вкладки чата).
2. В каждом окне: **переключись на свою ветку** (`git checkout <branch>`).
3. Вставь в чат **полный текст** из соответствующего файла `AGENT-N-*.md`.
4. Агент выполнит задачи и закоммитит в свою ветку.

## Ветки и агенты

| Окно | Ветка | Файл инструкций | Зона ответственности |
|------|-------|-----------------|------------------------|
| 1 | `codex/next-product-layer` | [AGENT-1-PRODUCT-LAYER.md](AGENT-1-PRODUCT-LAYER.md) | Этап 6: product direction, architecture, PRD |
| 2 | `codex/promo-foundation` | [AGENT-2-PROMO-FOUNDATION.md](AGENT-2-PROMO-FOUNDATION.md) | Позиционирование, описания ru/en, CTA, каналы |
| 3 | `codex/promo-content` | [AGENT-3-PROMO-CONTENT.md](AGENT-3-PROMO-CONTENT.md) | Контент-план, шаблоны постов, рубрики |
| 4 | `codex/promo-outreach` | [AGENT-4-PROMO-OUTREACH.md](AGENT-4-PROMO-OUTREACH.md) | Приглашения тестеров, форма фидбека |

## Зоны файлов (без пересечений)

- **Agent 1**: `docs/features/next-product-layer/` (или narrative-depth / game-systems / content-slice)
- **Agent 2**: `docs/promo/positioning.md`, `description-ru.md`, `description-en.md`, `cta.md`, `channels.md`
- **Agent 3**: `docs/promo/content-plan.md`, `rubrics.md`, `templates/`
- **Agent 4**: `docs/promo/invitations/`, `feedback-form.md`

## После завершения

1. Проверь каждую ветку: `git log`, `git diff master`.
2. Мержи по приоритету. Рекомендуемый порядок:
   - `codex/promo-foundation` → `codex/promo-content` → `codex/promo-outreach` (промо-ветки можно слить в одну)
   - `codex/next-product-layer` — отдельно
3. Конфликты маловероятны: агенты работают в разных файлах.

## Базовый коммит

Все ветки созданы от коммита:
```
chore: snapshot before parallel agents - quality-pass, provider-scoped settings, cursor rules
```
