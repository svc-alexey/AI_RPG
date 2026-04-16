# Home Server Deploy

Этот документ фиксирует:

- что именно переносить на домашний сервер
- какие команды выполнить там один в один
- готовый `nginx`-конфиг для VPS reverse proxy

## 0. Текущий production snapshot

На текущем этапе production работает не как прямой `nginx -> домашний сервер`,
а как двухузловая схема:

- публичный VPS принимает домены и HTTPS
- домашний сервер держит Docker Compose стек приложения
- доступ между ними идет через туннель / relay слой

Актуальные production сервисы на домашнем сервере:

- `symmetry-api`
- `symmetry-worker`
- `web`
- `postgres`

Актуальный рабочий путь проекта на домашнем сервере:

```bash
/home/alexeyko/ai-rpg/app
```

Публичный web origin:

```text
https://beyondtheverge.online
```

Важно:

- production health-check идет через `https://beyondtheverge.online/health`
- production version-check идет через `https://beyondtheverge.online/version`
- после пересоздания backend-контейнера иногда нужно отдельно перезапускать
  контейнер `web`, чтобы `nginx` заново подцепил upstream `symmetry-api`

## 1. Что переносить на домашний сервер

Минимально нужны только эти файлы и папки:

```text
docker-compose.yml
backend/symmetry/
infra/postgres/
```

Если хотите держать еще и web bundle на домашнем сервере, дополнительно перенесите:

```text
build/web/
```

На текущем этапе для backend deploy этого не требуется.

## 2. Куда положить на домашнем сервере

Рекомендуемый путь:

```bash
/opt/ai-rpg
```

Итоговая структура должна быть такой:

```text
/opt/ai-rpg/
  docker-compose.yml
  backend/symmetry/
  infra/postgres/
```

## 3. Как перенести с локальной машины

### Вариант A. Через `scp` из PowerShell

Запускать на вашей локальной машине:

```powershell
scp docker-compose.yml user@HOME_SERVER:/opt/ai-rpg/
scp -r backend/symmetry user@HOME_SERVER:/opt/ai-rpg/backend/
scp -r infra/postgres user@HOME_SERVER:/opt/ai-rpg/infra/
```

Замените:

- `user` на пользователя на домашнем сервере
- `HOME_SERVER` на IP или домен домашнего сервера

### Вариант B. Через `git clone`

Если репозиторий доступен на сервере:

```bash
sudo mkdir -p /opt/ai-rpg
sudo chown -R "$USER":"$USER" /opt/ai-rpg
cd /opt/ai-rpg
git clone <YOUR_REPO_URL> .
```

## 4. Подготовка домашнего сервера

Выполнить на домашнем сервере:

```bash
sudo mkdir -p /opt/ai-rpg
sudo chown -R "$USER":"$USER" /opt/ai-rpg
cd /opt/ai-rpg
```

Проверить, что файлы на месте:

```bash
ls
ls backend/symmetry
ls infra/postgres
```

## 5. Команды запуска на домашнем сервере

Ниже команды именно в том порядке, в котором их стоит выполнять.

### 5.1. Перейти в директорию проекта

```bash
cd /opt/ai-rpg
```

### 5.2. Остановить старый стек, если он уже был запущен

```bash
docker compose down
```

### 5.3. Если нужен полностью чистый старт, удалить volume Postgres

Эта команда удалит текущую БД контейнера.

```bash
docker volume rm ai_prg_symmetry_postgres_data || true
```

Если это первый deploy на сервере, volume, скорее всего, еще не существует.

### 5.4. Собрать и поднять стек

```bash
docker compose up --build -d
```

### 5.5. Проверить контейнеры

```bash
docker compose ps
```

Ожидаемо:

- `postgres` в состоянии `healthy`
- `symmetry-api` в состоянии `Up`

### 5.6. Проверить логи API

```bash
docker compose logs --tail=100 symmetry-api
```

В логах должно быть что-то близкое к этому:

```text
embedding_preload_completed model=intfloat/multilingual-e5-base backend=onnx
symmetry_api_ready startup_duration_ms=...
```

### 5.7. Проверить health endpoint

```bash
curl http://127.0.0.1:8080/health
```

Ожидаемый результат:

```json
{
  "status": "ok",
  "phase": "ready",
  "ready": true,
  "embedding": {
    "model": "intfloat/multilingual-e5-base",
    "backend": "onnx",
    "vector_dimension": 768
  }
}
```

### 5.8. Проверить миграцию и индекс

Проверить версию Alembic:

```bash
docker compose exec postgres psql -U postgres -d symmetry -c "SELECT version_num FROM alembic_version;"
```

Ожидаемо:

```text
20260407_000002
```

Проверить тип вектора:

```bash
docker compose exec postgres psql -U postgres -d symmetry -c "SELECT format_type(a.atttypid, a.atttypmod) FROM pg_attribute a JOIN pg_class c ON c.oid = a.attrelid WHERE c.relname = 'world_chronicles' AND a.attname = 'vector';"
```

Ожидаемо:

```text
vector(768)
```

Проверить индекс:

```bash
docker compose exec postgres psql -U postgres -d symmetry -c "SELECT indexname FROM pg_indexes WHERE schemaname='public' AND tablename='world_chronicles' ORDER BY indexname;"
```

Ожидаемо наличие:

```text
idx_world_chronicles_hnsw
```

## 6. Если порт `8080` на домашнем сервере уже занят

Если на домашнем сервере уже есть что-то на `8080`, перед deploy измените в `docker-compose.yml`:

```yaml
ports:
  - "8082:8080"
```

Тогда:

- локальная проверка будет идти через `http://127.0.0.1:8082/health`
- в `nginx` на VPS нужно будет проксировать на `:8082`

## 7. Готовый nginx-конфиг для VPS

Ниже конфиг для VPS, который принимает внешний трафик и проксирует его на домашний сервер.

### 7.1. Файл `/etc/nginx/conf.d/ai-rpg-api.conf`

```nginx
limit_req_zone $binary_remote_addr zone=ai_rpg_api_limit:10m rate=10r/s;

server {
    listen 80;
    server_name api.example.com;

    client_max_body_size 10m;

    location / {
        limit_req zone=ai_rpg_api_limit burst=20 nodelay;

        proxy_pass http://HOME_SERVER_IP:8080;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Authorization $http_authorization;

        proxy_connect_timeout 30s;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;

        proxy_buffering off;
    }
}
```

Замените:

- `api.example.com` на ваш домен API
- `HOME_SERVER_IP` на внешний IP домашнего сервера
- если backend поднят на `8082`, поменяйте `proxy_pass` на `http://HOME_SERVER_IP:8082`

### 7.2. Проверка и перезапуск nginx на VPS

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 7.3. Проверка с VPS

```bash
curl http://127.0.0.1
curl http://api.example.com/health
```

## 8. Минимальный smoke test после deploy

После того как backend поднят на домашнем сервере и `nginx` настроен на VPS:

1. Открыть `http://api.example.com/health`
2. Открыть `http://api.example.com/docs`
3. Выполнить `POST /v1/auth/guest`
4. Создать кампанию
5. Сделать 1-3 хода
6. Проверить, что backend не падает и health остается `ok`

### Актуальный production smoke test

Для текущего production мало проверить только `health`. После каждого backend
deploy нужно обязательно прогонять такой минимальный сценарий:

1. `GET /health`
2. `GET /version`
3. `POST /v1/auth/guest`
4. `POST /v1/campaigns`
5. `POST /v1/campaigns/{id}/turns/process` с `triggerSource=intro`
6. еще один `POST /v1/campaigns/{id}/turns/process` с обычным действием игрока

Почему это важно:

- часть недавних production-багов проявлялась только на первом или втором ходе
- `health=ok` сам по себе не гарантирует, что LLM-генерация реально работает
- web мог отвечать `502`, даже когда сам API-контейнер уже был `healthy`

## 8.1. Зафиксированные production hotfix notes

Ниже список исправлений, которые уже были нужны на production и которые важно
учитывать при следующих деплоях.

### Auth и роли

- исправлен backend-баг, из-за которого `is_admin` мог приходить как `null`
- пользователю `svc.alexey@gmail.com` выдан `is_admin=true` в production БД

### Генерация и LLM runtime

- backend стал устойчивее к ответам модели с нестрогим форматом
- `importance` теперь принимает не только числа, но и текстовые уровни
  (`low`, `medium`, `high`, `critical`)
- `module_updates` теперь принимает не только объект, но и `list` / `string`
- добавлен retry на случай обрезанного JSON от модели
- retry теперь срабатывает не только на битом JSON, но и на
  `finish_reason=length` или упоре в лимит токенов
- бюджеты вывода разделены по режимам:
  - `shortStory`: быстрые, но безопасные лимиты
  - `longCampaign`: заметно более широкие лимиты для атмосферы и контекста

### Web/runtime release

- release web-сборки теперь обязан публиковаться с
  `AI_PRG_ASSET_VERSION = release_id`
- если этого не сделать, web-клиент может бесконечно просить обновление
- backend `/version` и web bundle должны быть синхронизированы по одному
  `release_id`

### Reverse proxy / nginx

- для `*.map` production nginx теперь должен отдавать `404`, а не `index.html`
- иначе Firefox DevTools пытается распарсить HTML как source map и пишет
  `JSON.parse ... flutter.js.map`
- после backend recreate контейнер `web` может потребовать `docker compose restart web`
  для обновления связи с upstream

## 9. Быстрый rollback

Если после нового deploy что-то пошло не так:

```bash
cd /opt/ai-rpg
docker compose down
```

Если проблема в новой пустой БД, просто пересоберите стек после исправления конфигурации:

```bash
docker compose up --build -d
```

Если нужна более жесткая переинициализация:

```bash
docker compose down
docker volume rm ai_prg_symmetry_postgres_data || true
docker compose up --build -d
```
