# AI_RPG — Project Configuration

## Commands

### Flutter (client)
- `flutter analyze` — статический анализ, без ошибок перед merge
- `flutter test` — тесты, без падений перед merge
- `flutter run` — запуск приложения
- `flutter build web` — сборка веб-версии

### Backend (Symmetry / FastAPI)
- `cd backend/symmetry && pytest` — запуск тестов
- `cd backend/symmetry && alembic upgrade head` — применение миграций
- `docker compose up -d` — локальный запуск БД и backend
- `docker compose -f docker-compose.prod.yml up -d` — продовый запуск

### Docker
- `docker compose up -d` — локальное окружение (БД + backend)
- `docker compose down` — остановка

## Project Structure

```
lib/src/
  app/          — composition root (app.dart, app_providers.dart)
  core/         — общие сервисы, модели, репозитории, конфиг
  features/     — feature-first: auth, chat, home, new_game, saves,
                  settings, story_admin, story_library, update
backend/symmetry/
  app/
    api/routes/ — auth, campaigns, prompts, providers, stories
    services/   — AI gateway, campaign runtime, RAG, embeddings, auth
    db/         — SQLAlchemy models, async session
    schemas/    — Pydantic-схемы
    core/       — config, security
    workers/    — фоновые задачи
  alembic/      — миграции схемы БД
  tests/        — тесты backend
docs/
  features/<slug>/ — feature packets (01-Architecture, 02-PRD, 03-Implementation, 04-QA)
  AGENT_CONTEXT.md — контекст для AI-агентов
```

## Source of Truth (источники истины)

1. Symmetry backend — источник истины для: пользователей, сессий, кампаний, snapshot-ов, ходов, состояния мира, векторной памяти, story library
2. Flutter — не источник истины для кампаний и мира
3. LLM — не источник истины для игровых изменений
4. Изменения кампании применяются только через серверную игровую логику

## Invariants (нерушимые правила)

1. **AI output distrusted**: любой вывод LLM считается недоверенным до валидации
2. **Structured contracts only**: свободный текст модели не применяется напрямую к состоянию
3. **Engine-first**: движок и сохранённое состояние — источник истины, не LLM
4. **User credentials transient**: пользовательские AI-ключи передаются transiently, никогда не сохраняются в БД/логах/snapshot-ах
5. **DB only through Alembic**: любое изменение схемы БД — через миграцию
6. **Campaign events → world_chronicles**: важные события попадают в chronicles только после серверного отбора
7. **Feature-first architecture**: UI, модели, сервисы, репозитории разделены по фичам

## Flutter Rules (кратко, полные правила в FlutterRules.md)

- Feature-first: `lib/src/features/<feature>/...`
- Не смешивать UI и доменную логику
- AI/API вызовы через сервисный слой, не напрямую из UI
- DI через composition root + Riverpod overrides, без второго service locator
- Виджеты ≤ 200 строк, использовать `const` конструкторы, разбивать на `StatelessWidget`
- Любой асинхронный код из UI обязан проверять `mounted`
- Избегать лишних rebuild, для списков — builder-подход
- Mobile-first: новые экраны проектируются для мобильных, десктоп расширяет

## gstack

### Workflow: Think → Plan → Build → Review → Test → Ship → Reflect

Фичи проходят полный цикл. Bugfix — сокращённый путь.

### Available Skills (slash-команды)

**Think (думай):**
- `/office-hours` — дизайн-док и проработка идеи
- `/plan-ceo-review` — стратегический обзор
- `/plan-eng-review` — архитектурный обзор
- `/plan-design-review` — дизайн-обзор
- `/plan-devex-review` — обзор DX (developer experience)

**Plan (планируй):**
- `/autoplan` — автономное планирование реализации
- `/plan-tune` — настройка плана под проект

**Build (строй):**
- `/pair-agent` — парное программирование с агентом

**Review (проверяй):**
- `/review` — code review
- `/design-review` — визуальный обзор UI
- `/devex-review` — обзор опыта разработки

**Test (тестируй):**
- `/qa` — полный QA (тесты + ревью)
- `/qa-only` — только тестирование без ревью
- `/investigate` — расследование багов (auto-freezes модуль)

**Ship (отгружай):**
- `/ship` — полная отгрузка (тесты + CHANGELOG + version bump)
- `/land-and-deploy` — деплой на сервер

**Reflect (осмысляй):**
- `/retro` — ретроспектива спринта
- `/document-release` — обновление документации

**Safety (безопасность):**
- `/careful` — предупреждает перед опасными командами
- `/guard` — включает careful + freeze
- `/freeze` — ограничивает редактирование одной директорией
- `/unfreeze` — снимает ограничение

**Operational:**
- `/context-save` — сохранить контекст сессии
- `/context-restore` — восстановить контекст
- `/learn` — добавить знание в проектную документацию
- `/gstack-upgrade` — обновить gstack

**Security review:**
- `/cso` — security audit (OWASP Top 10 + STRIDE)

### Skill Routing (proactive)

Когда пользователь просит:
- Новую фичу → `/office-hours` → `/plan-eng-review` → `/autoplan` → реализация → `/review` → `/qa` → `/ship`
- Исправить баг → `/investigate` → исправление → `/qa-only` → commit
- Проверить код → `/review`
- Задеплоить → `/land-and-deploy`
- Security-проверку → `/cso`
- Обновить документацию → `/document-release`

## Testing Discipline

1. **Flutter:** `flutter analyze` + `flutter test` без ошибок перед merge
2. **Backend:** `pytest` без падений
3. **Ключевые user flow** покрыты smoke/widget тестами
4. **Изменения AI-контракта** требуют проверки structured response handling
5. **Bugfix** всегда генерирует регрессионный тест
6. **AI output** всегда валидируется перед сохранением состояния

## Commit Style

1. **Bisect commits**: каждый коммит — одно логическое изменение
2. **Feature branches**: `codex/<feature-slug>`
3. **Не смешивать**: рефакторинг и новую фичу в одном коммите
4. **Сообщения**: на русском или английском, описывают что и зачем
5. **Merge в master** только после проверки (analyze + test)
6. **master** всегда стабильный

## Quality Gates

Перед merge обязательны:
1. `flutter analyze` без compile-level ошибок
2. `flutter test` без падений
3. Обновление документации при изменении требований или контрактов
4. Для backend: `pytest` без падений
5. Валидация AI structured response handling при изменениях AI-контракта

## Feature Packet Workflow

1. Новая фича → `docs/features/<slug>/` (из `_template/`)
2. Регистрация в `docs/features/CATALOG.md`
3. Ветка `codex/<slug>`
4. Порядок: Architecture → PRD → Implementation → QA
5. Реализация до Architecture и PRD — отклонение от процесса

## Security

1. **AI output** — всегда недоверенный до валидации
2. **User credentials** — transient only, никогда не в персистентности
3. **DB schema** — только через Alembic миграции
4. **UI errors** — никогда не показывать сырой stack trace пользователю
5. **Campaign integrity** — ошибка AI не должна портить кампанию
6. **Backend** — единственный источник истины для игровых изменений

## Localization

1. Язык по умолчанию: русский (`ru`)
2. Обязательный второй язык: английский (`en`)
3. Фича не готова, если UX работает только на одном языке
4. Кириллица в исходниках: UTF-8 без BOM

## Platform

- Клиент: Flutter (mobile-first, web, desktop)
- Бэкенд: FastAPI (Symmetry)
- База: PostgreSQL + pgvector
- Embeddings: локальные sentence-transformers
- AI: OpenAI-совместимый gateway на backend

## Key Docs

- `FlutterRules.md` — полные Flutter-правила
- `Architecture.md` — архитектура системы
- `PRD.md` — продуктовые требования
- `Plan.md` — продуктовый план
- `ImplementationPlan.md` — план реализации
- `.specify/memory/constitution.md` — конституция проекта
- `.specify/memory/project-settings.md` — настройки
- `.specify/memory/project-context.md` — контекст и инварианты
- `docs/features/CATALOG.md` — реестр фич
- `docs/AGENT_CONTEXT.md` — контекст для агентов

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore
