# Home Server Deploy

Этот документ фиксирует:

- что именно переносить на домашний сервер
- какие команды выполнить там один в один
- готовый `nginx`-конфиг для VPS reverse proxy

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
