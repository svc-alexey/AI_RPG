# Product Plan

## Откуда проект пришёл

Изначально `AI_PRG` был локальным Flutter MVP с chat-driven narrative RPG
циклом. Этот этап завершён и больше не является целевой архитектурой.

## Где проект находится сейчас

Сейчас проект перешёл в server-first фазу:

1. Flutter отвечает за UX, auth-flow и отображение.
2. `Symmetry` отвечает за кампании, мир, RAG, auth, story library и
   AI-orchestration.
3. Локальная разработка повторяет будущий продовый сценарий:
   - локальная БД;
   - локальный backend;
   - тот же API-контракт, что и на сервере.

## Что уже закрыто

- server-authoritative campaigns
- vector memory via `pgvector`
- transient user AI credentials
- Alembic migrations
- removal of local campaign runtime flow

## Что дальше

1. Дожать production rollout process:
   - backup;
   - migration;
   - deploy;
   - smoke checks;
   - rollback notes.
2. Позже завершить живую проверку Yandex OAuth.
3. После этого выбрать следующий продуктовый слой, который увеличивает
   narrative depth и качество живого мира, а не возвращает нас к
   инфраструктурным переделкам.
