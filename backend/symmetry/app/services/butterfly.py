from copy import deepcopy
from datetime import UTC, datetime
from hashlib import sha1
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import PendingConsequence, SimulationJob, WorldChronicle, WorldEntity, WorldState
from app.services.ai_gateway import is_placeholder_location
from app.services.embeddings import get_embedding_service
from app.services.ids import new_id
from app.services.presentation_text import (
    looks_like_opaque_reference,
    normalize_location_label,
    sanitize_world_rumor_event_text,
)


class ButterflyService:
    _MODE_PROFILES = {
        "shortStory": {
            "seed_limit": 2,
            "strength_cap": 2,
            "delay_cap": 2,
            "effect_history_limit": 3,
        },
        "longCampaign": {
            "seed_limit": 4,
            "strength_cap": 4,
            "delay_cap": 5,
            "effect_history_limit": 6,
        },
    }
    _VALID_ENTITY_KINDS = {"company", "faction", "location", "market", "world"}
    _VALID_EFFECT_TYPES = {
        "alertness",
        "instability",
        "influence",
        "opportunity",
        "rumor",
        "scarcity",
        "trust",
    }

    async def seed_world(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        mode: str,
        language: str,
        location: str,
        world_state: WorldState,
    ) -> list[WorldEntity]:
        result = await session.execute(
            select(WorldEntity)
            .where(WorldEntity.campaign_id == campaign_id)
            .order_by(WorldEntity.created_at)
        )
        entities = list(result.scalars().all())
        if not entities:
            if is_placeholder_location(location, language=language):
                self._write_butterfly_summary(
                    world_state,
                    mode=mode,
                    entities=entities,
                )
                return entities
            defaults = self.default_entities_for_mode(
                mode=mode,
                language=language,
                location=location,
            )
            for item in defaults:
                entity = WorldEntity(
                    id=new_id(),
                    campaign_id=campaign_id,
                    slug=item["slug"],
                    title=item["title"],
                    entity_kind=item["entity_kind"],
                    metadata_json={"seeded": True},
                )
                session.add(entity)
                entities.append(entity)
            await session.flush()
        self._write_butterfly_summary(
            world_state,
            mode=mode,
            entities=entities,
        )
        return entities

    def default_entities_for_mode(
        self,
        *,
        mode: str,
        language: str,
        location: str,
    ) -> list[dict[str, str]]:
        location_title = normalize_location_label(location, language=language)
        location_slug = self.slugify(location_title) or "starting-point"
        return [
            {
                "slug": location_slug,
                "title": location_title,
                "entity_kind": "location",
            },
        ]

    def normalize_impact_seeds(
        self,
        raw_items: Any,
        *,
        mode: str,
        current_location: str,
    ) -> list[dict[str, Any]]:
        profile = self.profile(mode)
        items = raw_items if isinstance(raw_items, list) else []
        normalized: list[dict[str, Any]] = []
        seen: set[tuple[str, str, str]] = set()
        for raw in items:
            if not isinstance(raw, dict):
                continue
            entity_kind = str(raw.get("entity_kind", "")).strip().lower()
            if entity_kind not in self._VALID_ENTITY_KINDS:
                entity_kind = "company" if mode == "longCampaign" else "location"
            effect_type = str(raw.get("impact_type", "")).strip().lower()
            if effect_type not in self._VALID_EFFECT_TYPES:
                effect_type = "rumor"
            entity_slug = self.slugify(str(raw.get("entity_slug", "")).strip())
            if not entity_slug:
                entity_slug = self._default_slug_for_kind(
                    entity_kind=entity_kind,
                    current_location=current_location,
                )
            key = (entity_kind, entity_slug, effect_type)
            if key in seen:
                continue
            seen.add(key)
            strength = self._clamp_int(
                raw.get("strength", 1),
                minimum=1,
                maximum=profile["strength_cap"],
            )
            delay_min = self._clamp_int(raw.get("delay_min_turns", 1), minimum=1, maximum=profile["delay_cap"])
            delay_max = self._clamp_int(raw.get("delay_max_turns", delay_min), minimum=delay_min, maximum=profile["delay_cap"])
            visibility = str(raw.get("visibility", "")).strip().lower()
            if visibility not in {"public", "hidden"}:
                visibility = "hidden" if mode == "longCampaign" else "public"
            summary = " ".join(str(raw.get("summary", "")).split()).strip()
            if not summary:
                continue
            normalized.append(
                {
                    "entity_kind": entity_kind,
                    "entity_slug": entity_slug,
                    "impact_type": effect_type,
                    "strength": strength,
                    "delay_min_turns": delay_min,
                    "delay_max_turns": delay_max,
                    "visibility": visibility,
                    "summary": summary,
                }
            )
            if len(normalized) >= profile["seed_limit"]:
                break
        return normalized

    async def seed_from_world_state(
        self,
        *,
        campaign_id: str,
        world_state: WorldState,
        mode: str,
    ) -> list[dict[str, Any]]:
        global_vars = world_state.global_vars or {}
        butterfly = global_vars.get("butterfly", {}) or {}
        factions = global_vars.get("factions", {}) or {}
        prices = global_vars.get("prices", {}) or {}
        prev_factions = butterfly.get("prev_factions", {}) or {}
        prev_prices = butterfly.get("prev_prices", {}) or {}

        seeds: list[dict[str, Any]] = []

        if not prev_factions and factions:
            for slug, value in factions.items():
                try:
                    v = int(value)
                except (TypeError, ValueError):
                    continue
                if abs(v) >= 7:
                    direction = "сильна" if v > 0 else "ослаблена"
                    seeds.append({
                        "entity_kind": "faction",
                        "entity_slug": slug,
                        "impact_type": "influence",
                        "strength": min(4, abs(v) // 3),
                        "delay_min_turns": 2,
                        "delay_max_turns": 3,
                        "visibility": "public",
                        "summary": f"Фракция {slug} {direction} в этом регионе.",
                    })
            if not seeds and prices:
                for slug, value in prices.items():
                    try:
                        v = int(value)
                    except (TypeError, ValueError):
                        continue
                    if abs(v) >= 7:
                        direction_str = "scarcity" if v > 0 else "opportunity"
                        summary_str = f"Ресурс {slug} в дефиците." if v > 0 else f"Ресурс {slug} в избытке."
                        seeds.append({
                            "entity_kind": "market",
                            "entity_slug": slug,
                            "impact_type": direction_str,
                            "strength": min(3, abs(v) // 3),
                            "delay_min_turns": 2,
                            "delay_max_turns": 3,
                            "visibility": "hidden",
                            "summary": summary_str,
                        })
            butterfly["prev_factions"] = dict(factions)
            butterfly["prev_prices"] = dict(prices)
            global_vars["butterfly"] = butterfly
            world_state.global_vars = global_vars
            return self.normalize_impact_seeds(seeds, mode=mode, current_location="")

        for slug, value in factions.items():
            prev = prev_factions.get(slug, 0)
            try:
                delta = int(value) - int(prev)
            except (TypeError, ValueError):
                continue
            if abs(delta) >= 5:
                direction = "растёт" if delta > 0 else "падает"
                seeds.append({
                    "entity_kind": "faction",
                    "entity_slug": slug,
                    "impact_type": "influence" if delta > 0 else "instability",
                    "strength": min(4, abs(delta) // 3),
                    "delay_min_turns": 1,
                    "delay_max_turns": 3,
                    "visibility": "public",
                    "summary": f"Влияние {slug} {direction} (изменение: {delta}).",
                })

        for slug, value in prices.items():
            prev = prev_prices.get(slug, 0)
            try:
                v_int = int(value)
                p_int = int(prev)
            except (TypeError, ValueError):
                continue
            if p_int != 0:
                pct_change = abs(v_int - p_int) / abs(p_int)
                if pct_change > 0.3:
                    direction = "выросли" if v_int > p_int else "упали"
                    seeds.append({
                        "entity_kind": "market",
                        "entity_slug": slug,
                        "impact_type": "scarcity" if v_int > p_int else "opportunity",
                        "strength": min(4, int(pct_change * 5)),
                        "delay_min_turns": 1,
                        "delay_max_turns": 2,
                        "visibility": "hidden",
                        "summary": f"Цены на {slug} {direction} ({int(pct_change * 100)}%).",
                    })

        butterfly["prev_factions"] = dict(factions)
        butterfly["prev_prices"] = dict(prices)
        global_vars["butterfly"] = butterfly
        world_state.global_vars = global_vars

        return self.normalize_impact_seeds(seeds, mode=mode, current_location="")

    async def enqueue_followup_job(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        mode: str,
        language: str,
        turn_id: str,
        source_snapshot_version: int,
        turn_number: int,
        current_location: str,
        impact_seeds: list[dict[str, Any]],
        source_summary: str,
    ) -> SimulationJob | None:
        if not impact_seeds:
            return None
        job = SimulationJob(
            id=new_id(),
            campaign_id=campaign_id,
            job_type="expand_consequences",
            status="pending",
            payload_json={
                "mode": mode,
                "language": language,
                "turn_id": turn_id,
                "source_snapshot_version": source_snapshot_version,
                "turn_number": turn_number,
                "current_location": current_location,
                "impact_seeds": impact_seeds,
                "source_summary": source_summary,
            },
        )
        session.add(job)
        return job

    async def enqueue_chronicle_job(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        location_slug: str,
        memory_entry: str,
        world_event_summary: str,
        importance: int,
        metadata_json: dict,
    ) -> SimulationJob | None:
        event_text = (world_event_summary or memory_entry).strip()
        if not event_text:
            return None
        job = SimulationJob(
            id=new_id(),
            campaign_id=campaign_id,
            job_type="persist_chronicle_event",
            status="pending",
            payload_json={
                "location_slug": location_slug,
                "memory_entry": memory_entry,
                "world_event_summary": world_event_summary,
                "importance": importance,
                "metadata_json": metadata_json,
            },
        )
        session.add(job)
        return job

    async def process_ready_jobs(
        self,
        session: AsyncSession,
        *,
        campaign_id: str | None,
        limit: int = 8,
    ) -> int:
        now = datetime.now(UTC)
        stmt = (
            select(SimulationJob)
            .where(
                SimulationJob.status == "pending",
                SimulationJob.available_at <= now,
            )
            .order_by(SimulationJob.created_at)
            .limit(limit)
        )
        if campaign_id is not None:
            stmt = stmt.where(SimulationJob.campaign_id == campaign_id)
        result = await session.execute(stmt)
        jobs = list(result.scalars().all())
        processed = 0
        for job in jobs:
            job.status = "processing"
            job.attempts += 1
            job.started_at = now
            try:
                if job.job_type == "expand_consequences":
                    await self._expand_job(session, job=job)
                elif job.job_type == "persist_chronicle_event":
                    await self._persist_chronicle_job(session, job=job)
                else:
                    raise ValueError(f"unsupported_job_type:{job.job_type}")
            except Exception as exc:
                job.status = "failed"
                job.last_error = str(exc)[:500]
                job.finished_at = datetime.now(UTC)
            else:
                job.status = "completed"
                job.last_error = ""
                job.finished_at = datetime.now(UTC)
                processed += 1
        return processed

    async def apply_due_consequences(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        world_state: WorldState,
        upcoming_turn_number: int,
    ) -> list[dict[str, Any]]:
        result = await session.execute(
            select(PendingConsequence)
            .where(
                PendingConsequence.campaign_id == campaign_id,
                PendingConsequence.status == "pending",
                PendingConsequence.due_turn_number <= upcoming_turn_number,
            )
            .order_by(PendingConsequence.due_turn_number, PendingConsequence.created_at)
        )
        consequences = list(result.scalars().all())
        if not consequences:
            return []

        global_vars = deepcopy(world_state.global_vars or {})
        butterfly = dict(global_vars.get("butterfly", {}) or {})
        active_effects = list(butterfly.get("active_effects", []) or [])
        recent_events = list(butterfly.get("recent_offscreen_events", []) or [])
        prices = dict(global_vars.get("prices", {}) or {})
        factions = dict(global_vars.get("factions", {}) or {})
        embedding_service = get_embedding_service()
        applied: list[dict[str, Any]] = []
        now = datetime.now(UTC)

        for consequence in consequences:
            entry = {
                "entity_kind": consequence.entity_kind,
                "entity_slug": consequence.entity_slug,
                "effect_type": consequence.effect_type,
                "strength": consequence.strength,
                "summary": consequence.summary,
                "due_turn_number": consequence.due_turn_number,
                "visibility": consequence.visibility,
            }
            active_effects.append(entry)
            recent_events.append(entry)
            self._apply_world_delta(
                prices=prices,
                factions=factions,
                consequence=consequence,
            )
            event_text = self.render_offscreen_event_text(
                consequence=consequence,
                language=str(consequence.payload_json.get("language", "ru")),
            )
            vector = embedding_service.encode_document(event_text)
            session.add(
                WorldChronicle(
                    id=new_id(),
                    campaign_id=campaign_id,
                    location_slug=str(consequence.payload_json.get("location_slug", "")),
                    entity_type=consequence.entity_kind,
                    event_text=event_text,
                    importance=max(1, min(10, consequence.strength + 3)),
                    tags=["background", consequence.effect_type],
                    metadata_json={
                        "source": "butterfly_effect",
                        "visibility": consequence.visibility,
                        "due_turn_number": consequence.due_turn_number,
                    },
                    vector=vector,
                )
            )
            await self._touch_entity(
                session,
                campaign_id=campaign_id,
                entity_slug=consequence.entity_slug,
                delta=consequence.strength,
            )
            consequence.status = "applied"
            consequence.resolved_at = now
            applied.append(entry)

        profile = self.profile(str(butterfly.get("mode", "shortStory")))
        butterfly["active_effects"] = active_effects[-profile["effect_history_limit"] :]
        butterfly["recent_offscreen_events"] = recent_events[-5:]
        global_vars["prices"] = prices
        global_vars["factions"] = factions
        global_vars["butterfly"] = butterfly
        world_state.global_vars = global_vars
        return applied

    def apply_immediate_world_patch(
        self,
        world_state: WorldState,
        *,
        global_vars_patch: Any,
    ) -> None:
        if not isinstance(global_vars_patch, dict) or not global_vars_patch:
            return
        updated = deepcopy(world_state.global_vars or {})
        for key, value in global_vars_patch.items():
            if isinstance(value, dict) and isinstance(updated.get(key), dict):
                merged = dict(updated.get(key, {}) or {})
                merged.update(value)
                updated[key] = merged
            else:
                updated[key] = value
        world_state.global_vars = updated

    def profile(self, mode: str) -> dict[str, int]:
        return self._MODE_PROFILES.get(mode, self._MODE_PROFILES["shortStory"])

    def render_offscreen_event_text(
        self,
        *,
        consequence: PendingConsequence,
        language: str,
    ) -> str:
        entity_title = str(consequence.payload_json.get("entity_title", "")).strip()
        if looks_like_opaque_reference(entity_title):
            entity_title = ""
        summary = consequence.summary.strip()
        event_text = ""
        if language.startswith("ru"):
            if entity_title:
                event_text = f"Пока герой был занят, {entity_title} сдвинула ситуацию: {summary}."
            else:
                event_text = f"Пока герой был занят, обстановка изменилась: {summary}."
        elif entity_title:
            event_text = f"While the hero was occupied, {entity_title} shifted the situation: {summary}."
        else:
            event_text = f"While the hero was occupied, the situation shifted: {summary}."
        return sanitize_world_rumor_event_text(event_text, language=language)

    def _apply_world_delta(
        self,
        *,
        prices: dict[str, int],
        factions: dict[str, int],
        consequence: PendingConsequence,
    ) -> None:
        effect = consequence.effect_type
        if consequence.entity_kind in {"company", "market"}:
            delta = consequence.strength if effect in {"scarcity", "instability", "alertness"} else -consequence.strength
            prices[consequence.entity_slug] = int(prices.get(consequence.entity_slug, 0)) + delta
            return
        if consequence.entity_kind == "faction":
            delta = consequence.strength if effect in {"influence", "trust", "opportunity"} else -consequence.strength
            factions[consequence.entity_slug] = int(factions.get(consequence.entity_slug, 0)) + delta

    async def _expand_job(
        self,
        session: AsyncSession,
        *,
        job: SimulationJob,
    ) -> None:
        payload = job.payload_json or {}
        mode = str(payload.get("mode", "shortStory")).strip() or "shortStory"
        language = str(payload.get("language", "ru")).strip() or "ru"
        current_location = str(payload.get("current_location", "")).strip()
        world_state = await session.scalar(
            select(WorldState).where(WorldState.campaign_id == job.campaign_id)
        )
        if world_state is not None:
            await self.seed_world(
                session,
                campaign_id=job.campaign_id,
                mode=mode,
                language=language,
                location=current_location,
                world_state=world_state,
            )
        seeds = self.normalize_impact_seeds(
            payload.get("impact_seeds"),
            mode=mode,
            current_location=current_location,
        )
        if not seeds:
            return
        source_turn_number = self._clamp_int(payload.get("turn_number", 0), minimum=0, maximum=999999)
        for seed in seeds:
            entity = await self._resolve_entity(
                session,
                campaign_id=job.campaign_id,
                seed=seed,
                language=language,
            )
            summary = self._render_pending_summary(
                seed=seed,
                entity_title=entity.title,
                language=language,
            )
            session.add(
                PendingConsequence(
                    id=new_id(),
                    campaign_id=job.campaign_id,
                    source_turn_id=str(payload.get("turn_id", "")).strip() or None,
                    source_snapshot_version=self._clamp_int(
                        payload.get("source_snapshot_version", 0),
                        minimum=0,
                        maximum=999999,
                    ),
                    mode=mode,
                    due_turn_number=source_turn_number + self._pick_delay(seed),
                    entity_kind=seed["entity_kind"],
                    entity_slug=entity.slug,
                    effect_type=seed["impact_type"],
                    strength=seed["strength"],
                    visibility=seed["visibility"],
                    summary=summary,
                    payload_json={
                        "language": language,
                        "location_slug": self.slugify(current_location),
                        "entity_title": entity.title,
                        "source_summary": str(payload.get("source_summary", "")).strip(),
                    },
                )
            )
        if world_state is not None:
            result = await session.execute(
                select(WorldEntity)
                .where(WorldEntity.campaign_id == job.campaign_id)
                .order_by(WorldEntity.created_at)
            )
            self._write_butterfly_summary(
                world_state,
                mode=mode,
                entities=list(result.scalars().all()),
            )

    async def _persist_chronicle_job(
        self,
        session: AsyncSession,
        *,
        job: SimulationJob,
    ) -> None:
        payload = job.payload_json or {}
        event_text = (
            str(payload.get("world_event_summary", "")).strip()
            or str(payload.get("memory_entry", "")).strip()
        )
        if not event_text:
            return
        embedding_service = get_embedding_service()
        vector = embedding_service.encode_document(event_text)
        session.add(
            WorldChronicle(
                id=new_id(),
                campaign_id=job.campaign_id,
                location_slug=str(payload.get("location_slug", "")).strip(),
                event_text=event_text,
                importance=self._clamp_int(
                    payload.get("importance", 1),
                    minimum=1,
                    maximum=10,
                ),
                metadata_json=dict(payload.get("metadata_json", {}) or {}),
                vector=vector,
            )
        )

    async def _resolve_entity(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        seed: dict[str, Any],
        language: str,
    ) -> WorldEntity:
        entity = await session.scalar(
            select(WorldEntity).where(
                WorldEntity.campaign_id == campaign_id,
                WorldEntity.slug == seed["entity_slug"],
            )
        )
        if entity is not None:
            return entity
        title = self._default_entity_title(
            entity_kind=seed["entity_kind"],
            slug=seed["entity_slug"],
            language=language,
        )
        entity = WorldEntity(
            id=new_id(),
            campaign_id=campaign_id,
            slug=seed["entity_slug"],
            title=title,
            entity_kind=seed["entity_kind"],
            metadata_json={"seeded": False, "source": "impact_seed"},
        )
        session.add(entity)
        await session.flush()
        return entity

    async def _touch_entity(
        self,
        session: AsyncSession,
        *,
        campaign_id: str,
        entity_slug: str,
        delta: int,
    ) -> None:
        entity = await session.scalar(
            select(WorldEntity).where(
                WorldEntity.campaign_id == campaign_id,
                WorldEntity.slug == entity_slug,
            )
        )
        if entity is None:
            return
        entity.influence += delta
        entity.updated_at = datetime.now(UTC)

    def _write_butterfly_summary(
        self,
        world_state: WorldState,
        *,
        mode: str,
        entities: list[WorldEntity],
    ) -> None:
        updated = deepcopy(world_state.global_vars or {})
        butterfly = dict(updated.get("butterfly", {}) or {})
        butterfly.setdefault("active_effects", [])
        butterfly.setdefault("recent_offscreen_events", [])
        butterfly["mode"] = mode
        butterfly["known_entities"] = [
            {
                "slug": item.slug,
                "title": item.title,
                "entity_kind": item.entity_kind,
            }
            for item in entities[:8]
        ]
        updated["butterfly"] = butterfly
        updated.setdefault("prices", {})
        updated.setdefault("factions", {})
        world_state.global_vars = updated

    def _render_pending_summary(
        self,
        *,
        seed: dict[str, Any],
        entity_title: str,
        language: str,
    ) -> str:
        summary = seed["summary"].strip()
        if language.startswith("ru"):
            if seed["entity_kind"] == "company":
                return f"{entity_title} меняет расклад: {summary}"
            if seed["entity_kind"] == "faction":
                return f"{entity_title} реагирует на события: {summary}"
            return f"Обстановка меняется: {summary}"
        if seed["entity_kind"] == "company":
            return f"{entity_title} shifts the balance: {summary}"
        if seed["entity_kind"] == "faction":
            return f"{entity_title} reacts to the fallout: {summary}"
        return f"The situation changes: {summary}"

    def _default_slug_for_kind(
        self,
        *,
        entity_kind: str,
        current_location: str,
    ) -> str:
        if entity_kind == "location":
            return self.slugify(current_location) or "starting-point"
        base_slug = self.slugify(current_location) or "story-world"
        return f"{base_slug}-{entity_kind}"

    def _default_entity_title(
        self,
        *,
        entity_kind: str,
        slug: str,
        language: str,
    ) -> str:
        if looks_like_opaque_reference(slug):
            return "Сущность истории" if language.startswith("ru") else "Story Entity"
        fallback = "Сущность истории" if language.startswith("ru") else "Story Entity"
        return slug.replace("-", " ").title() or fallback

    def _pick_delay(self, seed: dict[str, Any]) -> int:
        minimum = seed["delay_min_turns"]
        maximum = seed["delay_max_turns"]
        if maximum <= minimum:
            return minimum
        stable = sum(ord(char) for char in f'{seed["entity_slug"]}:{seed["impact_type"]}:{seed["summary"]}')
        return minimum + (stable % (maximum - minimum + 1))

    def slugify(self, text: str) -> str:
        allowed = []
        normalized = text.strip().lower()
        for char in normalized:
            if char.isascii() and char.isalnum():
                allowed.append(char)
            elif char in {" ", "-", "_"}:
                allowed.append("-")
        slug = "".join(allowed)
        while "--" in slug:
            slug = slug.replace("--", "-")
        slug = slug.strip("-")
        if slug or not normalized:
            return slug
        digest = sha1(normalized.encode("utf-8")).hexdigest()[:10]
        return f"place-{digest}"

    def _clamp_int(self, value: Any, *, minimum: int, maximum: int) -> int:
        try:
            parsed = int(value)
        except (TypeError, ValueError):
            parsed = minimum
        return max(minimum, min(maximum, parsed))
