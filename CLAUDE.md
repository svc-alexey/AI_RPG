# AI_RPG — Project Configuration

## Commands

### Flutter (client)
- `flutter analyze` — статический анализ, без ошибок перед merge
- `flutter test` — тесты, без падений перед merge
- `flutter run` — запуск приложения
- `flutter build web` — сборка веб-версии
- `flutter run -d chrome --debug --dart-define=AI_PRG_MCP_ENABLED=true` — запуск с MCP Marionette

### MCP Marionette (AI Agent Development)

MCP-режим позволяет AI-агенту (Claude Code) инспектировать виджеты, делать скриншоты,
тапать, вводить текст и делать hot reload в запущенном Flutter-приложении.

**Запуск MCP-режима:**
```bash
flutter run -d chrome --debug --dart-define=AI_PRG_MCP_ENABLED=true
```

**Установка CLI (однократно):**
```bash
dart pub global activate marionette_mcp
dart pub global activate marionette_cli
```

**Референс команд для AI-агента:** `docs/MCP_REFERENCE.md`

**Рабочий процесс:**
1. Запустить приложение с флагом `AI_PRG_MCP_ENABLED=true`
2. Скопировать WebSocket URI из вывода (формат: `ws://127.0.0.1:PORT/...=/ws`)
3. Использовать `marionette --uri <ws-uri> <command>` для взаимодействия

**Основные команды:**
- `get-interactive-elements` — интерактивные элементы на экране
- `take-screenshots --output <path>` — скриншот
- `tap --key/keyword` — тап по элементу
- `enter-text --key/keyword --input <text>` — ввод текста
- `scroll-to --text <text>` — скролл до элемента
- `hot-reload` — hot reload без потери состояния
- `press-back-button` — системная кнопка назад

**Важно:** MCP работает только в debug-режиме. В release-сборках код Marionette исключается tree-shaking.
Chrome в debug-режиме использует DDC (не Dart2JS) — Dart VM Service доступен.

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
    api/routes/ — auth, billing, campaigns, map_routes, portraits, prompts, providers, stories
    services/   — AI gateway, campaign runtime, portrait (optimizer, prompt builder, service), RAG, embeddings, auth
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
8. **Guest auto-create**: при отсутствии сессии `requireAccountThen` создаёт гостя через `guestLogin()`, не показывает AuthScreen. Гость получает 5 бесплатных ходов
9. **Email verification gate**: `get_current_verified_user` блокирует неverified пользователей (гости исключены). Billing screen проверяет `_blocked = _isGuest || _needsVerification` для всех кнопок и действий
10. **Never silently catch in auth flows**: ошибки в guestLogin/register должны быть видны, не глотаться через `catch (_)`

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
- `docs/UI_UX_Guidelines.md` — правила UI/UX и дизайна
- `docs/MARKETING.md` — маркетинг и продвижение
- `docs/MONETIZATION.md` — план монетизации
- `docs/DEPLOY_WEB.md` — инструкция деплоя веб-версии
- `README.md` — описание проекта

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

## Infrastructure & Deploy

### Server Architecture

```
User (beyondtheverge.online)
  │ HTTPS
  ▼
VPS (153.80.247.32, root)
  ├── Caddy: SSL termination, reverse proxy
  │     beyondtheverge.online → 127.0.0.1:18083 (FRP → home:8081)
  │     edge1.beyondtheverge.online → 127.0.0.1:18080 (FRP → home:8080)
  │     claw.beyondtheverge.online → 127.0.0.1:18189 (FRP → home:18789)
  └── FRP Server (frps): port 7000, token MyStrongFrpToken_123

Home Server (192.168.1.68, alexeyko)
  ├── AI RPG: /home/alexeyko/ai-rpg/app/
  │     docker compose -f docker-compose.prod.yml
  │     ├── ai-rpg-web (nginx:alpine) — port 8081:80
  │     │     mounts: ./deploy/web → /usr/share/nginx/html (ro)
  │     │     mounts: ./deploy/nginx/default.prod.conf → /etc/nginx/conf.d/default.conf (ro)
  │     ├── ai-rpg-api (FastAPI) — port 8080
  │     │     env_file: ./backend/symmetry/.env
  │     │     volumes: ONLY ./backend/symmetry/models:/app/models
  │     │     CODE IS IN IMAGE, NOT A VOLUME!
  │     ├── ai-rpg-worker — background tasks
  │     └── ai-rpg-postgres — PostgreSQL 16 + pgvector
  └── FRP Client (frpc): tunnels 8080, 8081, 18789 to VPS
```

### Path Mapping

| Локально (репо) | На сервере |
|---|---|
| `deploy/nginx/default.prod.conf` | `/home/alexeyko/ai-rpg/app/deploy/nginx/default.prod.conf` |
| `deploy/web/*.html`, `deploy/web/*.css` | `/home/alexeyko/ai-rpg/app/deploy/web/` |
| `web/index.html` (Flutter build output) | Копируется в `deploy/web/` при деплое |
| `backend/symmetry/app/` | `/home/alexeyko/ai-rpg/app/backend/symmetry/app/` |

### Flutter Web Deploy

```bash
# 1. BUILD — обязательно с версиями и абсолютным URL!
#    AI_PRG_SYMMETRY_BASE_URL: АБСОЛЮТНЫЙ URL прода (!не относительный /v1)
#    Без этого Dart2JS резолвит API-запросы в file:/// и они блокируются браузером.
RELEASE_ID="web-$(date -u +%Y%m%dT%H%M%SZ)"
flutter build web \
  --dart-define=AI_PRG_APP_VERSION=1.0.0+1 \
  --dart-define=AI_PRG_ASSET_VERSION=$RELEASE_ID \
  --dart-define=AI_PRG_RELEASE_ID=$RELEASE_ID \
  --dart-define=AI_PRG_SYMMETRY_BASE_URL=https://beyondtheverge.online/v1

# 2. PACK
tar -czf /tmp/deploy-flutter.tar.gz -C build/web .

# 3. UPLOAD (пароль из локального secrets-файла)
scp /tmp/deploy-flutter.tar.gz alexeyko@192.168.1.68:/tmp/

# 4. DEPLOY на сервере
cd /home/alexeyko/ai-rpg/app
# Бэкап
cp -r deploy/web deploy/web.bak_$(date +%Y%m%d_%H%M)
# Сохранить статические HTML (они НЕ из Flutter build!)
mkdir -p /tmp/web_static
ALL_STATIC="offer.html privacy.html consent.html refunds.html contacts.html pricing.html subscribe.html robots.txt sitemap.xml legal.css worlds.html world-cybernoir.html world-dark-fantasy.html world-romance.html rpg-with-ai.html text-rpg-online.html roadmap.html"
for f in $ALL_STATIC; do
    [ -f "deploy/web/$f" ] && cp "deploy/web/$f" "/tmp/web_static/$f"
done
[ -d "deploy/web/blog" ] && cp -r "deploy/web/blog" "/tmp/web_static/blog"
[ -d "deploy/web/landing" ] && cp -r "deploy/web/landing" "/tmp/web_static/landing"
# Очистить Flutter-файлы (не удалять статические .html!)
rm -rf deploy/web/assets deploy/web/canvaskit deploy/web/icons
rm -f deploy/web/*.js deploy/web/*.wasm deploy/web/*.json deploy/web/*.png deploy/web/*.svg deploy/web/*.ico deploy/web/index.html
# Распаковать новую сборку
tar -xzf /tmp/deploy-flutter.tar.gz -C deploy/web/
# Восстановить статические HTML
for f in $ALL_STATIC; do
    [ -f "/tmp/web_static/$f" ] && cp "/tmp/web_static/$f" "deploy/web/$f"
done
[ -d "/tmp/web_static/blog" ] && cp -r "/tmp/web_static/blog" "deploy/web/blog" && rm -rf "/tmp/web_static/blog"
[ -d "/tmp/web_static/landing" ] && rm -rf "deploy/web/landing" && mv "/tmp/web_static/landing" "deploy/web/landing"
rm -rf /tmp/web_static
# Обновить version.json
cat > deploy/web/version.json << EOF
{
  "app_version": "1.0.0+1",
  "asset_version": "$RELEASE_ID",
  "release_id": "$RELEASE_ID",
  "released_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
# Перезагрузить nginx (graceful reload, без даунтайма)
docker exec ai-rpg-web nginx -s reload
```

### Backend Deploy

**Критически важно:** код backend НЕ в volume — он в Docker-образе. Полная пересборка образа занимает 15+ минут (PyTorch, CUDA). Для мелких изменений используй `docker cp`.

```bash
# Для мелких изменений (новые файлы, правки):
docker cp backend/symmetry/app/schemas/billing.py ai-rpg-api:/app/app/schemas/
docker cp backend/symmetry/app/api/routes/billing.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/api/routes/__init__.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/main.py ai-rpg-api:/app/app/main.py

# Очистить кэш Python после изменений
docker exec ai-rpg-api find /app -type d -name __pycache__ -exec rm -rf {} ';'

# Перезапустить контейнер
docker restart ai-rpg-api

# Для изменений .env — нужен recreate (restart не перечитывает env_file):
docker compose -f docker-compose.prod.yml up -d --force-recreate symmetry-api
# После recreate ВСЕ docker cp нужно применить заново!

# Полная пересборка (только при изменении зависимостей):
docker compose -f docker-compose.prod.yml build symmetry-api --no-cache
docker compose -f docker-compose.prod.yml up -d --force-recreate symmetry-api
```

### Portrait Generation Deploy

При деплое портретной фичи — копировать ВСЕ новые и изменённые файлы:

```bash
# Новые файлы (CREATE):
docker cp backend/symmetry/app/services/portrait_optimizer.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/services/portrait_prompt_builder.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/services/portrait_service.py ai-rpg-api:/app/app/services/
docker cp backend/symmetry/app/api/routes/portraits.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/schemas/portraits.py ai-rpg-api:/app/app/schemas/

# Изменённые файлы (EDIT):
docker cp backend/symmetry/app/api/routes/__init__.py ai-rpg-api:/app/app/api/routes/
docker cp backend/symmetry/app/main.py ai-rpg-api:/app/app/main.py
docker cp backend/symmetry/app/core/config.py ai-rpg-api:/app/app/core/
docker cp backend/symmetry/app/db/models.py ai-rpg-api:/app/app/db/
docker cp backend/symmetry/app/api/routes/campaigns.py ai-rpg-api:/app/app/api/routes/

# Миграция:
docker cp backend/symmetry/alembic/versions/20260511_000015_campaign_portraits.py ai-rpg-api:/app/alembic/versions/

# Очистить кэш и применить миграцию:
docker exec ai-rpg-api find /app -type d -name '__pycache__' -exec rm -rf '{}' ';'
docker exec ai-rpg-api alembic upgrade head
docker restart ai-rpg-api
```

**Важно:** После `docker compose up -d --force-recreate` ВСЕ `docker cp` портретных файлов нужно применять заново (pitfall #2).

### Polza.ai Image Generation Config

В `.env` (локальный и продовый) должны быть настроены:

```env
SYMMETRY_POLZA_AI_API_KEY=pza_...
SYMMETRY_POLZA_AI_BASE_URL=https://polza.ai/api/v1
SYMMETRY_POLZA_AI_IMAGE_MODEL=google/gemini-2.5-flash-image
SYMMETRY_POLZA_AI_TIMEOUT_SECONDS=30
SYMMETRY_POLZA_AI_POLL_INTERVAL_SECONDS=1.5
```

**Модель:** `google/gemini-2.5-flash-image` (~3₽/изображение). Можно переключить на `flux-2-flex` или `flux-2-pro` через `SYMMETRY_POLZA_AI_IMAGE_MODEL`.

**API flow (асинхронный):**
1. `POST https://polza.ai/api/v1/images/generations` → `{"requestId": "gen_..."}`
2. Poll `GET /v1/media/{requestId}` каждые 1.5s, таймаут 30s
3. Download из `data[0].url` (S3 signed URL)

### Version Check Mechanism

Бэкенд (`main.py:/version`) сравнивает версии клиента и сервера:

```python
# Клиент отправляет:
current_asset_version = AppReleaseEnv.assetVersion  # из --dart-define
# Сервер проверяет:
_reload_required = _compare_versions(current, server_web_asset_version) < 0
```

**Ключевые настройки в `.env`:**
- `SYMMETRY_WEB_ASSET_VERSION=` — пусто = проверка отключена (рекомендуется)
- `SYMMETRY_RELEASE_ID=web-YYYYMMDDTHHMMSSZ` — ID релиза
- `SYMMETRY_RELEASED_AT=...` — дата релиза ISO 8601

**Правило:** если `--dart-define=AI_PRG_ASSET_VERSION=$RELEASE_ID` совпадает с `SYMMETRY_WEB_ASSET_VERSION`, блокировки не будет. Оставь `SYMMETRY_WEB_ASSET_VERSION=` пустым чтобы избежать проблем с закэшированными клиентами.

### Nginx Static File Routing

Статические legal/catalog страницы должны обходить Flutter SPA:

```nginx
# ДО SPA fallback:
location ~ ^/(offer|privacy|consent|refunds|contacts|subscribe)\.html$ {
    try_files $uri =404;
}

# API прокси:
location /v1/ {
    proxy_pass http://symmetry-api:8080/v1/;
    ...
}

# SPA fallback — всё остальное:
location / {
    try_files $uri $uri/ /index.html;
}
```

### External Accessibility Checklist

При развёртывании веб-версии для доступа из интернета, проверить ВСЕ пункты:

1. **Сборка с абсолютным URL:** `--dart-define=AI_PRG_SYMMETRY_BASE_URL=https://beyondtheverge.online/v1`
2. **Все `--dart-define` флаги:** `APP_VERSION`, `ASSET_VERSION`, `RELEASE_ID`, `SYMMETRY_BASE_URL`
3. **Nginx gzip включён** для `application/javascript`, `application/wasm` (`deploy/nginx/default.prod.conf`)
4. **Caddy таймауты** для reverse_proxy к FRP (`read_timeout 120s`, `write_timeout 120s`)
5. **Статические HTML сохранены** после очистки `deploy/web/`: offer, privacy, consent, refunds, contacts, pricing, subscribe
6. **`version.json` обновлён** на сервере (Flutter build пишет `dev-local`)
7. **Nginx reload** после замены файлов: `docker exec ai-rpg-web nginx -s reload`
8. **Caddy reload** после изменения Caddyfile: `systemctl reload caddy`
9. **FRP туннель активен:** проверить `systemctl status frps` на VPS и `docker ps | grep frpc` на домашнем
10. **Проверка извне:** открыть `https://beyondtheverge.online/?lang=ru` через мобильный интернет (не локально!)

**Типичные симптомы и причины:**
| Симптом | Причина |
|---|---|
| Загрузка на 12% и стоп | Nginx gzip выключен, `main.dart.js` не проходит FRP |
| `file:///C:/Program%20Files/Git/v1/...` в консоли | `AI_PRG_SYMMETRY_BASE_URL` относительный `/v1` вместо абсолютного |
| `aborting with incomplete response` в логах Caddy | Нет таймаутов на reverse_proxy к FRP |
| Белый экран после загрузки | Статические HTML затёрты при деплое |
| `reload_required: true` бесконечно | `version.json` не обновлён или `ASSET_VERSION=dev-local` |

### Known Pitfalls

1. **`map_routes.py` добавлен, но требует `docker cp` на прод.** Файл существует в репо (создан в `4379030`), зарегистрирован в `__init__.py` и `main.py`. При деплое новых бэкенд-файлов не забывать копировать `map_routes.py`.
2. **После `docker compose up -d --force-recreate` все `docker cp` теряются.** Контейнер создаётся заново из образа. Все правки через `docker cp` нужно применять заново.
3. **`.env` не подхватывается при `docker restart`.** Только `up -d --force-recreate` пересоздаёт контейнер с новыми env vars.
4. **Статические HTML стираются при очистке `deploy/web/`.** После `rm -rf deploy/web/*` и распаковки Flutter build, нужно восстановить legal-страницы из репо.
5. **`flutter build web` НЕ обновляет `version.json`.** Версия в `version.json` всегда "dev-local". Её нужно обновлять вручную на сервере или через скрипт деплоя.
6. **При `flutter build web` без `--dart-define` клиент получает `asset_version: "dev-local"`.** Это ломает версионную проверку (dev-local < любая реальная версия → reload_required: true).
7. **Продовый docker-compose НЕ монтирует `app/` как volume.** В отличие от dev-конфига, где `./app:/app/app` в volume. В проде только `models` в volume. Все изменения кода требуют либо `docker cp`, либо пересборки образа.
8. **`flutter clean` удаляет `.dart_tool/` и ломает `pub get` при недоступном pub.dev.** После `flutter clean` сначала `flutter pub get --offline`, затем `flutter build web --no-pub`.
9. **Dart `_`-префикс = FILE-private, не CLASS-private.** `_blocked` из `_BillingScreenState` доступен в `_TariffCard` внутри того же файла. `replace_all` на `_`-именах опасен.
10. **`FutureProvider` кэширует первое разрешение навсегда.** После `guestLogin()` или `register()` всегда делать `ref.invalidate(symmetrySessionProvider)`.
11. **`Stack` не изолирует `DefaultTextStyle`.** Стили текста из родительских виджетов (HomeScreen, тема Material) протекают в оверлеи. Для диалогов всегда добавлять `decoration: TextDecoration.none` явно.
12. **`history.scrollRestoration` переопределяет `window.scrollTo()`.** На статических HTML-страницах нужно `history.scrollRestoration = 'manual'` перед `scrollTo(0,0)`.
13. **`BillingPlan.metadata_json["is_active"]` отсутствует у активных планов.** Фильтр `!= False` не работает с NULL. Правильно: `or_(field == None, field.as_boolean() == True)`.
14. **`AI_PRG_SYMMETRY_BASE_URL` должен быть АБСОЛЮТНЫМ URL для web-сборки.** Относительный `/v1` Dart2JS на Windows резолвит в `file:///C:/Program%20Files/Git/v1/...` — браузер блокирует такие запросы. Всегда использовать `https://beyondtheverge.online/v1` (или домен прода) при `flutter build web`.
15. **Nginx gzip обязателен для `main.dart.js`.** Без сжатия файл 3.6 MB не проходит через FRP-туннель — Caddy обрывает соединение с `unexpected EOF`. Включить `gzip on` с `application/javascript` в типах.
16. **Caddy reverse_proxy к FRP требует явных таймаутов.** Дефолтные таймауты Caddy (0s = без лимита) не работают с FRP. Добавить `transport http { read_timeout 120s; write_timeout 120s }`.
17. **После деплоя всегда проверять извне (мобильный интернет/VPN).** Локальные тесты не выявляют проблемы с FRP-туннелем, gzip, Caddy и Dart2JS URL-резолвингом.
18. **Ссылка подтверждения почты должна вести на бэкенд, не на SPA.** URL `/?verify_token=...` требует полной загрузки Flutter (1MB JS через FRP) + API-вызова из Dart. При сбое в цепочке токен не потребляется. Правильно: `/v1/auth/verify-email?token=...` — бэкенд верифицирует и 302-редиректит обратно на SPA с `?email_verified=1`. Критический шаг до загрузки Flutter.
19. **Язык письма подтверждения — по Accept-Language.** `_is_russian()` в `email_service.py` проверяет заголовок `Accept-Language`: `ru*` → русский («Стирая Грань»), иначе → английский («Beyond The Verge»). Без заголовка — русский (дефолт). При добавлении новых email-уведомлений использовать тот же паттерн.
20. **`app_localizations.dart` — кастомная локализация, не ARB.** В проекте нет `.arb`-файлов. Все строки — геттеры в классе `AppLocalizations` со `switch (language) { AppLanguage.ru => ..., AppLanguage.en => ... }`. Новые ключи добавлять в конец перед закрывающей `}`.
21. **`PasswordResetToken` — отдельная таблица, не колонки в `users`.** В отличие от плана (который предлагал колонки), использована отдельная таблица `password_reset_tokens` по образцу `EmailVerificationToken` — это идиоматичный подход кодобазы. Токен хранится как SHA-256 хеш, TTL 15 минут.
22. **`ChangePassword` требует verified user.** Роут `POST /v1/auth/change-password` использует `Depends(get_current_verified_user)` — гость и неverified пользователи получат 403. Верификация через `get_current_verified_user` блокирует, в отличие от `get_current_user`.
23. **`MediaQuery.disableAnimationsOf(context)` нельзя вызывать в `initState`.** Flutter запрещает обращение к InheritedWidget (включая MediaQuery) до завершения `initState`. Для проверки reduced motion: хранить флаг `_reducedMotion = false`, устанавливать его в `didChangeDependencies`, а в `initState` всегда запускать анимацию (если `didChangeDependencies` обнаружит reduced motion позже — остановить контроллер). D20RollWidget демонстрирует этот паттерн.
24. **`_normalizeServerState` — трансформация, выбрасывающая неизвестные поля.** В `symmetry_campaign_repository.dart` метод `_normalizeServerState` перестраивает КАЖДОЕ сообщение чата из `state_json` бэкенда. По умолчанию он переносит только `id`, `role`, `text`, `createdAt` — все остальные поля (включая `dice_roll`) ТЕРЯЮТСЯ. Любое новое поле в сообщениях чата ДОЛЖНО быть явно добавлено в этот метод.
25. **D20 бросок — клиент решает, сервер хранит.** `DeterministicCheckService` на клиенте анализирует действие игрока по ключевым словам (атака/взлом/убеждение/поиск/...). Если проверка нужна — бросает D20, передаёт `dice_roll` в `ProcessTurnRequest`. Бэкенд сохраняет в `campaign_turns.dice_roll` и в `state_json.messages[].dice_roll`. Если проверка не нужна — `dice_roll` = null, анимации нет. Сервер НЕ генерирует бросок сам (`secrets.randbelow` убран).
26. **Порт 8080 — конфликт Flutter и Docker.** Docker-контейнер `ai-rpg-api` мапит порт 8080. При локальном запуске `flutter run -d web-server` всегда указывать `--web-port=8081` или `8088`. Старый процесс `dartvm` может продолжать держать порт после падения — проверять через `netstat -ano | findstr ":8080"` и `taskkill /PID X /F`.
27. **`flutter run -d chrome` не работает на этой Windows-машине.** Flutter пытается запустить Chrome со своим `--user-data-dir`, падает с "Failed to launch browser after 3 tries". Использовать `-d web-server`. MCP Marionette в web-server режиме может не показывать VM Service URI в новых версиях Flutter.
28. **`campaigns.id` — VARCHAR(36), не нативный UUID.** Миграции, ссылающиеся на `campaigns.id` через FK, должны использовать `sa.String(36)`, а не `sa.Uuid()`. Несовпадение типов даёт `DatatypeMismatch: foreign key constraint cannot be implemented`.
29. **Портретная генерация требует verified user.** `POST /v1/campaigns/{id}/portrait` использует `get_current_verified_user` — гость и неverified получат 401/403. Это предотвращает бесплатную генерацию портретов вне биллинговой системы. Клиент должен скрывать кнопку "Сгенерировать портрет" для гостей (`session.isGuest`).
30. **Портретный промпт — всегда на английском.** `portrait_prompt_builder.py` генерирует промпты на английском независимо от языка UI — модели изображений дают лучшие результаты на английском. `language` не передаётся в POST-запросе на генерацию.
31. **Портретный оптимизатор — face-safe параметры.** `portrait_optimizer.py` использует q_min=75 (не ниже, иначе артефакты на лицах), max_dim=512px, target=120KB, hard limit=200KB. Не использовать `cover_image_optimizer.py` для портретов — там q падает до 50 и размер до 640px.

## GBrain Configuration (configured by /setup-gbrain)
- Mode: local-stdio
- Engine: pglite
- Config file: ~/.gbrain/config.json (mode 0600)
- Setup date: 2026-05-17
- MCP registered: yes (user scope, wrapper: ~/gbrain/bin/gbrain.sh)
- Embedding model: text-embedding-bge-m3 (1024 dim, via LM Studio http://127.0.0.1:1234/v1)
- Embedding provider: OPENAI_API_KEY=lm-studio OPENAI_BASE_URL=http://127.0.0.1:1234/v1
- Pages: 102 imported, 179 chunks embedded (100%)
- Artifacts sync: artifacts-only → https://github.com/svc-alexey/-gstack-artifacts-Alexey.git (federated source: gstack-artifacts)
- Current repo policy: read-write
- Transcript ingest: incremental

## GBrain Search Guidance (configured by /sync-gbrain)
<!-- gstack-gbrain-search-guidance:start -->

GBrain is set up and synced on this machine. The agent should prefer gbrain
over Grep when the question is semantic or when you don't know the exact
identifier yet.

gbrain 0.18.2 — available search commands:
- `gbrain search "<terms>"` — keyword search (tsvector)
- `gbrain query "<question>"` — hybrid RAG search (RRF + query expansion)
- `gbrain ask "<question>"` — alias for query

Prefer gbrain when:
- "Where is X handled?" / semantic intent, no exact string yet:
    `gbrain search "<terms>"` or `gbrain query "<question>"`
- "What did we decide last time?" / past plans, retros, learnings:
    `gbrain search "<terms>"` (across all indexed pages)
- Exploring imported docs/markdown:
    `gbrain list` (list pages), `gbrain get <slug>` (read a page)

Grep is still right for known exact strings, regex, multiline patterns, and
file globs. Run `/sync-gbrain` to force-refresh code/docs indexing.

<!-- gstack-gbrain-search-guidance:end -->
