# Architecture: Symmetry Hybrid Backend

## Goal

Move campaign state, world simulation, vector memory, auth, and
OpenAI-compatible provider access into a dedicated Python backend.

## Main decisions

1. Backend is the source of truth for campaigns and world state.
2. Flutter keeps only:
   - session tokens;
   - settings and language;
   - backend base URL;
   - optional user-owned transient provider credentials.
3. `PostgreSQL + pgvector` stores campaign snapshots, world chronicles, story
   library data, and future product data.
4. Embeddings are local to the backend.
5. Text generation is proxied through the backend using either:
   - server-managed credentials from `.env`;
   - user-supplied transient credentials.
6. User-supplied credentials must never be written to DB rows, logs, snapshots,
   or background jobs.
7. DB schema is managed through Alembic migrations.

## Architecture boundary

### Flutter

- auth UX
- chat UI
- campaign creation UI
- settings UI
- local storage for settings/session/user-owned AI keys only

### Symmetry backend

- auth/session handling
- campaign storage
- campaign runtime
- world simulation
- RAG and embeddings
- story-template APIs
- credential resolution
- AI gateway

## Authoritative turn flow

1. Flutter sends `campaign_id`, `player_action`, language, and optional
   provider credentials.
2. Backend loads the current campaign snapshot and `world_state`.
3. Backend encodes the request and searches `world_chronicles`.
4. Backend builds compact structured context.
5. Backend resolves which credentials to use.
6. Backend calls the model provider.
7. Backend validates and applies the result.
8. Backend saves a new snapshot and turn row.
9. Backend optionally persists an important chronicle event in the background.

## Storage model

Primary groups:

1. auth: `users`, `user_profiles`, `auth_identities`, `auth_sessions`
2. campaigns: `campaigns`, `campaign_members`, `campaign_snapshots`,
   `campaign_turns`
3. world: `world_state`, `world_locations`, `world_factions`,
   `world_chronicles`, `simulation_ticks`
4. story library: `story_templates`, `story_template_tags`,
   `story_template_tag_links`, `story_template_likes`,
   `story_template_views`, `story_template_bookmarks`
5. billing-ready: `billing_customers`, `billing_plans`,
   `billing_subscriptions`, `credit_ledger`, `payment_events`
