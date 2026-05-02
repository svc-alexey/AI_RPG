from __future__ import annotations

from copy import deepcopy
from datetime import UTC, datetime
from typing import Any

from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Campaign, UserProfile, WorldChronicle, WorldEntity, WorldLocation, WorldState
from app.services.ids import new_id
from app.services.presentation_text import build_location_display_name, normalize_location_label, sanitize_world_rumor_event_text
from app.services.text_normalization import normalize_prompt_text

_LOCAL_SCALES = {"room", "district", "city"}
_GLOBAL_SCALES = {"region", "world"}
_SCALE_ORDER = {"room": 0, "district": 1, "city": 2, "region": 3, "world": 4}
_LOCAL_POSITIONS = ((50.0, 50.0), (22.0, 22.0), (78.0, 24.0), (18.0, 76.0), (78.0, 74.0))
_GLOBAL_POSITIONS = ((48.0, 52.0), (18.0, 22.0), (80.0, 26.0), (22.0, 78.0), (78.0, 76.0))


def _meta(node: WorldLocation) -> dict[str, Any]:
    return dict(node.metadata_json or {})


def _slugify(text: str) -> str:
    prepared = normalize_prompt_text(text, limit=120).lower()
    allowed = [char if char.isalnum() else "-" if char in {" ", "-", "_"} else "" for char in prepared]
    slug = "".join(allowed).strip("-")
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug or "unknown-location"


def _travel_prompt(*, title: str, language: str, scale: str) -> str:
    if scale in _GLOBAL_SCALES:
        return f"Отправиться в {title}" if language.startswith("ru") else f"Travel to {title}"
    return f"Иду в {title}" if language.startswith("ru") else f"I head to {title}"


def _node_summary(*, title: str, language: str) -> str:
    if language.startswith("ru"):
        return f"Здесь сходятся слухи, следы и возможные ходы вокруг «{title}»."
    return f"Rumors, routes, and pressure points gather around {title}."


def _default_local_scale(setting: str) -> str:
    return "city" if setting in {"cozyCrime", "altHistorySecret"} else "district"


def _default_global_scale(setting: str) -> str:
    return "region"


class CampaignMapService:
    async def build_map_context_for_user(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        state: dict[str, Any],
        world_state: WorldState,
        user_id: str,
    ) -> dict[str, Any]:
        await self.ensure_map_state(
            session,
            campaign=campaign,
            state=state,
            world_state=world_state,
        )
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        current_node = self._find_current_node(
            nodes=nodes,
            current_location=normalize_location_label(
                str(state.get("location", "")),
                language=campaign.language,
            ),
        )
        unseen_events = await self._load_return_events(
            session,
            campaign=campaign,
            user_id=user_id,
            mark_seen=False,
        )
        return self.build_map_context(
            campaign=campaign,
            nodes=nodes,
            world_state=world_state,
            current_node=current_node,
            unseen_events=unseen_events,
        )

    async def ensure_map_state(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        state: dict[str, Any],
        world_state: WorldState,
    ) -> dict[str, Any]:
        current_location = normalize_location_label(str(state.get("location", "")), language=campaign.language)
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        if not nodes:
            await self._create_initial_nodes(
                session,
                campaign=campaign,
                current_location=current_location,
            )
            nodes = await self._load_nodes(session, campaign_id=campaign.id)
        current_node = await self._ensure_current_location_node(
            session,
            campaign=campaign,
            nodes=nodes,
            current_location=current_location,
        )
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        await self._sync_rumored_nodes(
            session,
            campaign=campaign,
            nodes=nodes,
            world_state=world_state,
        )
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        self._mark_node_explored(current_node)
        map_meta = self._map_meta(world_state)
        if map_meta.get("active_scale") not in _SCALE_ORDER:
            map_meta["active_scale"] = _meta(current_node).get("scale", _default_local_scale(campaign.setting))
        map_meta["focus_node_id"] = current_node.id
        self._save_map_meta(world_state, map_meta)
        return self.build_map_context(campaign=campaign, nodes=nodes, world_state=world_state, current_node=current_node, unseen_events=[])

    def build_map_context(
        self,
        *,
        campaign: Campaign,
        nodes: list[WorldLocation],
        world_state: WorldState,
        current_node: WorldLocation | None,
        unseen_events: list[dict[str, Any]],
    ) -> dict[str, Any]:
        active_scale = str(self._map_meta(world_state).get("active_scale") or "")
        if active_scale not in _SCALE_ORDER:
            active_scale = _meta(current_node).get("scale", _default_local_scale(campaign.setting)) if current_node is not None else _default_local_scale(campaign.setting)
        return {
            "active_scale": active_scale,
            "focus_node_id": current_node.id if current_node is not None else "",
            "changed_node_ids": self._changed_node_ids(nodes=nodes, events=unseen_events),
            "new_return_events_count": len(unseen_events),
            "available_scales": sorted({_meta(item).get("scale", "district") for item in nodes}, key=lambda value: _SCALE_ORDER.get(str(value), 99)),
            "fronts_changed": self._fronts_changed(world_state=world_state, events=unseen_events),
        }

    async def build_map(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        state: dict[str, Any],
        world_state: WorldState,
        user_id: str,
    ) -> dict[str, Any]:
        await self.ensure_map_state(session, campaign=campaign, state=state, world_state=world_state)
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        current_location = normalize_location_label(str(state.get("location", "")), language=campaign.language)
        current_node = self._find_current_node(nodes=nodes, current_location=current_location)
        unseen_events = await self._load_return_events(session, campaign=campaign, user_id=user_id, mark_seen=False)
        changed_node_ids = self._changed_node_ids(nodes=nodes, events=unseen_events)
        recent_events = await self._load_recent_events(session, campaign=campaign, limit=12)
        event_index = self._build_event_index(events=[*unseen_events, *recent_events])
        local_nodes = [item for item in nodes if str(_meta(item).get("scale", "")) in _LOCAL_SCALES]
        global_nodes = [item for item in nodes if str(_meta(item).get("scale", "")) in _GLOBAL_SCALES]
        focus_node = next((item for item in nodes if item.id == str(self._map_meta(world_state).get("focus_node_id", ""))), current_node)
        return {
            "active_scale": str(self._map_meta(world_state).get("active_scale") or _default_local_scale(campaign.setting)),
            "breadcrumbs": self._build_breadcrumbs(nodes=nodes, focus_node=focus_node, language=campaign.language),
            "current_node_id": current_node.id if current_node is not None else "",
            "focus_node_id": focus_node.id if focus_node is not None else "",
            "available_scales": sorted({_meta(item).get("scale", "district") for item in nodes}, key=lambda value: _SCALE_ORDER.get(str(value), 99)),
            "changed_node_ids": changed_node_ids,
            "local_view": {
                "scale": local_nodes[0].metadata_json.get("scale", _default_local_scale(campaign.setting)) if local_nodes else _default_local_scale(campaign.setting),
                "title": current_node.title if current_node is not None and str(_meta(current_node).get("scale", "")) in _LOCAL_SCALES else (local_nodes[0].title if local_nodes else campaign.title),
                "nodes": [self._serialize_node(campaign=campaign, node=item, world_state=world_state, current_node=current_node, changed_node_ids=changed_node_ids, event_index=event_index, all_nodes=nodes) for item in local_nodes],
            },
            "global_view": {
                "scale": global_nodes[0].metadata_json.get("scale", _default_global_scale(campaign.setting)) if global_nodes else _default_global_scale(campaign.setting),
                "title": global_nodes[0].title if global_nodes else campaign.title,
                "nodes": [self._serialize_node(campaign=campaign, node=item, world_state=world_state, current_node=current_node, changed_node_ids=changed_node_ids, event_index=event_index, all_nodes=nodes) for item in global_nodes],
            },
            "fronts": self._collect_fronts(campaign=campaign, nodes=nodes, world_state=world_state),
            "return_events": recent_events[:5],
            "last_seen_delta": {
                "unseen_events_count": len(unseen_events),
                "last_seen_at": self._last_seen_at_iso(await self._load_user_profile(session, user_id=user_id), campaign_id=campaign.id),
            },
        }

    async def build_return_summary(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        user_id: str,
        world_state: WorldState,
    ) -> dict[str, Any]:
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        events = await self._load_return_events(session, campaign=campaign, user_id=user_id, mark_seen=True)
        return {
            "unseen_count": len(events),
            "changed_node_ids": self._changed_node_ids(nodes=nodes, events=events),
            "fronts_changed": self._fronts_changed(world_state=world_state, events=events),
            "events": events,
            "generated_at": datetime.now(UTC),
        }

    async def _load_nodes(self, session: AsyncSession, *, campaign_id: str) -> list[WorldLocation]:
        result = await session.execute(select(WorldLocation).where(WorldLocation.campaign_id == campaign_id).order_by(WorldLocation.title, WorldLocation.id))
        return list(result.scalars().all())

    async def _load_entities(self, session: AsyncSession, *, campaign_id: str) -> dict[str, WorldEntity]:
        result = await session.execute(select(WorldEntity).where(WorldEntity.campaign_id == campaign_id))
        return {item.slug: item for item in result.scalars().all()}

    def _global_titles_for_campaign(self, *, campaign: Campaign, current_location: str) -> list[str]:
        ru = campaign.language.startswith("ru")
        base_by_setting = {
            "darkAcademia": [
                current_location,
                "Северная башня" if ru else "North Tower",
                "Склеп архивариуса" if ru else "Archivist Crypt",
                "Каменный двор" if ru else "Stone Court",
                "Забытый корпус" if ru else "Forgotten Annex",
            ],
            "cozyCrime": [
                current_location,
                "Речной рынок" if ru else "River Market",
                "Старый причал" if ru else "Old Pier",
                "Мэрия" if ru else "Town Hall",
                "Окраинный мотель" if ru else "Outskirts Motel",
            ],
            "nearFutureSciFi": [
                current_location,
                "Орбитальный терминал" if ru else "Orbital Terminal",
                "Техноярд" if ru else "Tech Yard",
                "Станция связи" if ru else "Relay Station",
                "Сектор теней" if ru else "Shadow Sector",
            ],
            "postApocalypse": [
                current_location,
                "Ржавая эстакада" if ru else "Rust Span",
                "Обгоревший рынок" if ru else "Burned Bazaar",
                "Релейная вышка" if ru else "Relay Spire",
                "Пепельные пустоши" if ru else "Ash Wastes",
            ],
            "horrorWeird": [
                current_location,
                "Слепой берег" if ru else "Blind Shore",
                "Дом без окон" if ru else "Windowless House",
                "Черная часовня" if ru else "Black Chapel",
                "Болото эха" if ru else "Echo Marsh",
            ],
        }
        titles = list(
            base_by_setting.get(
                campaign.setting,
                [
                    current_location,
                    "Северный тракт" if ru else "Northern Road",
                    "Старые руины" if ru else "Old Ruins",
                    "Торговый пост" if ru else "Trading Post",
                    "Мрачная окраина" if ru else "Shadow Outskirts",
                ],
            ),
        )
        if campaign.mode == "longCampaign":
            titles.append("Далекая граница" if ru else "Far Frontier")
        return titles

    def _local_titles_for_campaign(self, *, campaign: Campaign, current_location: str) -> list[str]:
        ru = campaign.language.startswith("ru")
        base_by_setting = {
            "darkAcademia": [
                current_location,
                "Аудитория теней" if ru else "Shadow Lecture Hall",
                "Галерея портретов" if ru else "Portrait Gallery",
                "Подземный архив" if ru else "Underground Archive",
                "Лестница ректора" if ru else "Rector Stair",
            ],
            "cozyCrime": [
                current_location,
                "Служебный коридор" if ru else "Service Corridor",
                "Комната улик" if ru else "Evidence Room",
                "Задний двор" if ru else "Back Court",
                "Крыша над каналом" if ru else "Canal Roof",
            ],
            "nearFutureSciFi": [
                current_location,
                "Сервисный шлюз" if ru else "Service Airlock",
                "Комм-узел" if ru else "Comm Node",
                "Наблюдательный мост" if ru else "Observation Bridge",
                "Нижний контур" if ru else "Lower Circuit",
            ],
            "postApocalypse": [
                current_location,
                "Разобранный ангар" if ru else "Stripped Hangar",
                "Бункерный тоннель" if ru else "Bunker Tunnel",
                "Водосбор" if ru else "Water Catch",
                "Костровая площадка" if ru else "Bonfire Yard",
            ],
            "horrorWeird": [
                current_location,
                "Тихий коридор" if ru else "Silent Corridor",
                "Комната с зеркалом" if ru else "Mirror Room",
                "Люк под полом" if ru else "Trapdoor Below",
                "Пустая часовня" if ru else "Empty Chapel",
            ],
        }
        titles = list(
            base_by_setting.get(
                campaign.setting,
                [
                    current_location,
                    "Главный проход" if ru else "Main Passage",
                    "Архивная комната" if ru else "Archive Room",
                    "Западное крыло" if ru else "Western Wing",
                    "Нижний ход" if ru else "Lower Passage",
                ],
            ),
        )
        if campaign.mode == "longCampaign":
            titles.append("Скрытый проход" if ru else "Hidden Passage")
        return titles

    def _node_type_for_global(self, *, index: int, campaign: Campaign) -> str:
        if index == 2:
            return "dungeon"
        if campaign.setting in {"nearFutureSciFi", "postApocalypse"} and index == 1:
            return "building"
        return "settlement" if index in {0, 3} else "wilderness"

    def _node_type_for_local(self, *, index: int, campaign: Campaign) -> str:
        if index == 0:
            return "building"
        if campaign.setting in {"darkAcademia", "cozyCrime"} and index == 3:
            return "district"
        return "room"

    async def _create_initial_nodes(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        current_location: str,
    ) -> None:
        language = campaign.language
        global_scale = _default_global_scale(campaign.setting)
        local_scale = _default_local_scale(campaign.setting)
        global_titles = self._global_titles_for_campaign(
            campaign=campaign,
            current_location=current_location,
        )
        local_titles = self._local_titles_for_campaign(
            campaign=campaign,
            current_location=current_location,
        )
        global_nodes: list[WorldLocation] = []
        for index, title in enumerate(global_titles):
            x, y = _GLOBAL_POSITIONS[index % len(_GLOBAL_POSITIONS)]
            node = WorldLocation(
                id=new_id(),
                campaign_id=campaign.id,
                slug=_slugify(title),
                title=title,
                metadata_json={
                    "scale": global_scale,
                    "type": self._node_type_for_global(index=index, campaign=campaign),
                    "parent_id": "",
                    "x": x,
                    "y": y,
                    "connections": [],
                    "summary": _node_summary(title=title, language=language),
                    "is_reachable": index < (5 if campaign.mode == "longCampaign" else 4),
                    "explored": index == 0,
                    "rumored": index > 0,
                    "travel_prompt": _travel_prompt(title=title, language=language, scale=global_scale),
                },
            )
            session.add(node)
            global_nodes.append(node)
        await session.flush()
        for index, title in enumerate(local_titles):
            x, y = _LOCAL_POSITIONS[index % len(_LOCAL_POSITIONS)]
            session.add(
                WorldLocation(
                    id=new_id(),
                    campaign_id=campaign.id,
                    slug=_slugify(title),
                    title=title,
                    metadata_json={
                        "scale": local_scale,
                        "type": self._node_type_for_local(index=index, campaign=campaign),
                        "parent_id": global_nodes[0].id,
                        "x": x,
                        "y": y,
                        "connections": [],
                        "summary": _node_summary(title=title, language=language),
                        "is_reachable": True,
                        "explored": index == 0,
                        "rumored": index > (1 if campaign.mode == "shortStory" else 0),
                        "travel_prompt": _travel_prompt(title=title, language=language, scale=local_scale),
                    },
                )
            )
        await session.flush()
        nodes = await self._load_nodes(session, campaign_id=campaign.id)
        self._wire_connections([item for item in nodes if str(_meta(item).get("scale", "")) == global_scale])
        self._wire_connections([item for item in nodes if str(_meta(item).get("scale", "")) == local_scale])

    async def _ensure_current_location_node(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        nodes: list[WorldLocation],
        current_location: str,
    ) -> WorldLocation:
        current_node = self._find_current_node(nodes=nodes, current_location=current_location)
        if current_node is not None:
            self._mark_node_explored(current_node)
            return current_node
        local_nodes = [item for item in nodes if str(_meta(item).get("scale", "")) in _LOCAL_SCALES]
        parent = next((item for item in nodes if str(_meta(item).get("scale", "")) in _GLOBAL_SCALES and bool(_meta(item).get("explored", False))), None)
        x, y = _LOCAL_POSITIONS[len(local_nodes) % len(_LOCAL_POSITIONS)]
        node = WorldLocation(
            id=new_id(),
            campaign_id=campaign.id,
            slug=_slugify(current_location),
            title=current_location,
            metadata_json={
                "scale": _default_local_scale(campaign.setting),
                "type": "room",
                "parent_id": parent.id if parent is not None else "",
                "x": x,
                "y": y,
                "connections": [item.id for item in local_nodes[:2]],
                "summary": _node_summary(title=current_location, language=campaign.language),
                "is_reachable": True,
                "explored": True,
                "rumored": False,
                "travel_prompt": _travel_prompt(title=current_location, language=campaign.language, scale=_default_local_scale(campaign.setting)),
            },
        )
        session.add(node)
        await session.flush()
        for peer in local_nodes[:2]:
            metadata = _meta(peer)
            connections = list(metadata.get("connections", []) or [])
            if node.id not in connections:
                connections.append(node.id)
                peer.metadata_json = {**metadata, "connections": connections}
        return node

    async def _sync_rumored_nodes(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        nodes: list[WorldLocation],
        world_state: WorldState,
    ) -> None:
        existing_slugs = {_slugify(item.slug): item for item in nodes}
        entities = await self._load_entities(session, campaign_id=campaign.id)
        butterfly = dict((world_state.global_vars or {}).get("butterfly", {}) or {})
        candidates = list(butterfly.get("active_effects", []) or []) + list(butterfly.get("recent_offscreen_events", []) or [])
        for item in candidates:
            entity_slug = _slugify(str(item.get("entity_slug", "")))
            if str(item.get("entity_kind", "")).strip().lower() != "location" or not entity_slug or entity_slug in existing_slugs:
                continue
            entity = entities.get(entity_slug)
            title = entity.title if entity is not None else build_location_display_name(entity_slug, language=campaign.language) or entity_slug.replace("-", " ").title()
            session.add(
                WorldLocation(
                    id=new_id(),
                    campaign_id=campaign.id,
                    slug=entity_slug,
                    title=title,
                    metadata_json={
                        "scale": _default_global_scale(campaign.setting),
                        "type": "wilderness",
                        "parent_id": "",
                        "x": 50.0 + (len(existing_slugs) % 3) * 8.0,
                        "y": 20.0 + (len(existing_slugs) % 4) * 12.0,
                        "connections": [next(iter(existing_slugs.values())).id] if existing_slugs else [],
                        "summary": _node_summary(title=title, language=campaign.language),
                        "is_reachable": False,
                        "explored": False,
                        "rumored": True,
                        "travel_prompt": _travel_prompt(title=title, language=campaign.language, scale=_default_global_scale(campaign.setting)),
                    },
                )
            )
            existing_slugs[entity_slug] = nodes[0] if nodes else None
        await session.flush()

    async def _load_recent_events(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        limit: int,
    ) -> list[dict[str, Any]]:
        result = await session.execute(select(WorldChronicle).where(WorldChronicle.campaign_id == campaign.id).order_by(desc(WorldChronicle.created_at)).limit(max(5, limit * 3)))
        events: list[dict[str, Any]] = []
        for item in result.scalars().all():
            payload = self._event_payload(item=item, language=campaign.language)
            if payload is None:
                continue
            events.append(payload)
            if len(events) >= limit:
                break
        return events

    async def _load_return_events(
        self,
        session: AsyncSession,
        *,
        campaign: Campaign,
        user_id: str,
        mark_seen: bool,
    ) -> list[dict[str, Any]]:
        profile = await self._load_user_profile(session, user_id=user_id)
        last_seen_at = self._parse_last_seen_at(profile=profile, campaign_id=campaign.id)
        result = await session.execute(select(WorldChronicle).where(WorldChronicle.campaign_id == campaign.id).order_by(desc(WorldChronicle.created_at)).limit(18))
        events: list[dict[str, Any]] = []
        newest_seen = last_seen_at
        for item in result.scalars().all():
            if last_seen_at is not None and item.created_at <= last_seen_at:
                continue
            payload = self._event_payload(item=item, language=campaign.language)
            if payload is None:
                continue
            events.append(payload)
            newest_seen = max(newest_seen or item.created_at, item.created_at)
            if len(events) >= 5:
                break
        if mark_seen and newest_seen is not None:
            self._write_last_seen_at(profile=profile, campaign_id=campaign.id, last_seen_at=newest_seen)
            session.add(profile)
            await session.commit()
        return events

    async def _load_user_profile(self, session: AsyncSession, *, user_id: str) -> UserProfile:
        profile = await session.get(UserProfile, user_id)
        if profile is None:
            profile = UserProfile(user_id=user_id, display_name="", avatar_url="", preferences={})
            session.add(profile)
            await session.flush()
        return profile

    def _find_current_node(self, *, nodes: list[WorldLocation], current_location: str) -> WorldLocation | None:
        current_slug = _slugify(current_location)
        for node in nodes:
            if _slugify(node.slug) == current_slug:
                return node
        for node in nodes:
            if normalize_prompt_text(node.title.lower(), limit=120) == normalize_prompt_text(current_location.lower(), limit=120):
                return node
        return None

    def _serialize_node(
        self,
        *,
        campaign: Campaign,
        node: WorldLocation,
        world_state: WorldState,
        current_node: WorldLocation | None,
        changed_node_ids: list[str],
        event_index: dict[str, list[dict[str, Any]]],
        all_nodes: list[WorldLocation],
    ) -> dict[str, Any]:
        metadata = _meta(node)
        fronts = self._front_badges(campaign=campaign, node=node, world_state=world_state)
        node_events = self._events_for_node(node=node, all_nodes=all_nodes, event_index=event_index)
        if current_node is not None and current_node.id == node.id:
            state = "current"
        elif fronts:
            state = "threat"
        elif bool(metadata.get("blocked", False)):
            state = "blocked"
        elif bool(metadata.get("explored", False)):
            state = "explored"
        elif bool(metadata.get("rumored", False)):
            state = "rumored"
        else:
            state = "fog"
        return {
            "id": node.id,
            "slug": node.slug,
            "parent_id": str(metadata.get("parent_id", "") or ""),
            "scale": str(metadata.get("scale", "district") or "district"),
            "name": node.title,
            "type": str(metadata.get("type", "location") or "location"),
            "x": float(metadata.get("x", 50.0) or 50.0),
            "y": float(metadata.get("y", 50.0) or 50.0),
            "state": state,
            "connections": [str(item) for item in metadata.get("connections", []) or []],
            "front_badges": fronts,
            "events_count": len(node_events),
            "is_reachable": bool(metadata.get("is_reachable", True)),
            "travel_prompt": str(metadata.get("travel_prompt", "") or ""),
            "summary": str(metadata.get("summary", "") or ""),
            "events": node_events,
            "is_changed": node.id in changed_node_ids,
        }

    def _front_badges(self, *, campaign: Campaign, node: WorldLocation, world_state: WorldState) -> list[dict[str, Any]]:
        labels_ru = {"alertness": "Тревога", "instability": "Нестабильность", "influence": "Влияние", "opportunity": "Шанс", "rumor": "Слух", "scarcity": "Дефицит", "trust": "Доверие"}
        labels_en = {"alertness": "Alert", "instability": "Instability", "influence": "Influence", "opportunity": "Opportunity", "rumor": "Rumor", "scarcity": "Scarcity", "trust": "Trust"}
        labels = labels_ru if campaign.language.startswith("ru") else labels_en
        butterfly = dict((world_state.global_vars or {}).get("butterfly", {}) or {})
        badges: list[dict[str, Any]] = []
        for item in list(butterfly.get("active_effects", []) or []):
            if _slugify(str(item.get("entity_slug", ""))) != _slugify(node.slug):
                continue
            effect_type = str(item.get("effect_type", "rumor")).strip().lower() or "rumor"
            strength = int(item.get("strength", 1) or 1)
            badges.append(
                {
                    "id": f"front_{_slugify(node.slug)}_{effect_type}",
                    "label": labels.get(effect_type, labels["rumor"]),
                    "severity": "high" if strength >= 4 else "medium" if strength >= 2 else "low",
                    "summary": normalize_prompt_text(str(item.get("summary", "")), limit=160),
                }
            )
        return badges

    def _collect_fronts(self, *, campaign: Campaign, nodes: list[WorldLocation], world_state: WorldState) -> list[dict[str, Any]]:
        fronts: list[dict[str, Any]] = []
        seen: set[str] = set()
        for node in nodes:
            for badge in self._front_badges(campaign=campaign, node=node, world_state=world_state):
                if badge["id"] in seen:
                    continue
                seen.add(badge["id"])
                fronts.append({**badge, "node_id": node.id, "node_name": node.title})
        return fronts[:6]

    def _changed_node_ids(self, *, nodes: list[WorldLocation], events: list[dict[str, Any]]) -> list[str]:
        by_slug = {_slugify(item.slug): item.id for item in nodes}
        changed: list[str] = []
        for event in events:
            node_id = by_slug.get(_slugify(str(event.get("location_slug", ""))))
            if node_id and node_id not in changed:
                changed.append(node_id)
        return changed

    def _fronts_changed(self, *, world_state: WorldState, events: list[dict[str, Any]]) -> list[str]:
        butterfly = dict((world_state.global_vars or {}).get("butterfly", {}) or {})
        available = {
            f"front_{_slugify(str(item.get('entity_slug', '')))}_{str(item.get('effect_type', 'rumor')).strip().lower()}"
            for item in list(butterfly.get("active_effects", []) or [])
            if _slugify(str(item.get("entity_slug", "")))
        }
        changed: list[str] = []
        for event in events:
            slug = _slugify(str(event.get("location_slug", "")))
            for front_id in available:
                if f"front_{slug}_" in front_id and front_id not in changed:
                    changed.append(front_id)
        return changed[:5]

    def _build_breadcrumbs(self, *, nodes: list[WorldLocation], focus_node: WorldLocation | None, language: str) -> list[dict[str, Any]]:
        lookup = {item.id: item for item in nodes}
        breadcrumbs: list[dict[str, Any]] = []
        current = focus_node
        while current is not None:
            breadcrumbs.append(
                {
                    "id": current.id,
                    "label": build_location_display_name(current.title, language=language) or current.title,
                    "scale": str(_meta(current).get("scale", "district") or "district"),
                }
            )
            parent_id = str(_meta(current).get("parent_id", "") or "")
            current = lookup.get(parent_id) if parent_id else None
        return list(reversed(breadcrumbs))

    def _wire_connections(self, nodes: list[WorldLocation]) -> None:
        if not nodes:
            return
        anchor = nodes[0]
        for index, node in enumerate(nodes):
            metadata = _meta(node)
            connections = list(metadata.get("connections", []) or [])
            if node.id != anchor.id and anchor.id not in connections:
                connections.append(anchor.id)
            if node.id == anchor.id:
                for peer in nodes[1:]:
                    if peer.id not in connections:
                        connections.append(peer.id)
            if index > 1 and nodes[index - 1].id not in connections:
                connections.append(nodes[index - 1].id)
            node.metadata_json = {**metadata, "connections": connections}

    def _mark_node_explored(self, node: WorldLocation) -> None:
        metadata = _meta(node)
        node.metadata_json = {**metadata, "explored": True, "rumored": False}

    def _event_payload(self, *, item: WorldChronicle, language: str) -> dict[str, Any] | None:
        metadata = item.metadata_json if isinstance(item.metadata_json, dict) else {}
        source = str(metadata.get("source", "") or "")
        if source not in {"butterfly_effect", "turn_result"} and int(item.importance or 0) < 6:
            return None
        return {
            "id": item.id,
            "text": sanitize_world_rumor_event_text(item.event_text, language=language),
            "location_slug": item.location_slug,
            "location_title": build_location_display_name(str(metadata.get("location_title") or item.location_slug or ""), language=language) or "",
            "importance": int(item.importance or 0),
            "created_at": item.created_at.isoformat(),
        }

    def _build_event_index(self, *, events: list[dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
        indexed: dict[str, list[dict[str, Any]]] = {}
        seen_ids: set[str] = set()
        for event in events:
            event_id = str(event.get("id", "") or "")
            slug = _slugify(str(event.get("location_slug", "") or ""))
            if not event_id or not slug or event_id in seen_ids:
                continue
            seen_ids.add(event_id)
            indexed.setdefault(slug, []).append(event)
        for items in indexed.values():
            items.sort(key=lambda item: str(item.get("created_at", "")), reverse=True)
        return indexed

    def _events_for_node(
        self,
        *,
        node: WorldLocation,
        all_nodes: list[WorldLocation],
        event_index: dict[str, list[dict[str, Any]]],
    ) -> list[dict[str, Any]]:
        metadata = _meta(node)
        collected: list[dict[str, Any]] = []
        seen_ids: set[str] = set()

        def add_events(slug: str) -> None:
            for item in event_index.get(_slugify(slug), []):
                event_id = str(item.get("id", "") or "")
                if event_id and event_id not in seen_ids:
                    seen_ids.add(event_id)
                    collected.append(item)

        add_events(node.slug)
        parent_id = str(metadata.get("parent_id", "") or "")
        if parent_id:
            parent = next((item for item in all_nodes if item.id == parent_id), None)
            if parent is not None:
                add_events(parent.slug)
        for connection_id in list(metadata.get("connections", []) or [])[:2]:
            peer = next((item for item in all_nodes if item.id == str(connection_id)), None)
            if peer is not None:
                add_events(peer.slug)
        return collected[:4]

    def _map_meta(self, world_state: WorldState) -> dict[str, Any]:
        return dict(deepcopy(world_state.global_vars or {}).get("map", {}) or {})

    def _save_map_meta(self, world_state: WorldState, metadata: dict[str, Any]) -> None:
        global_vars = deepcopy(world_state.global_vars or {})
        global_vars["map"] = metadata
        world_state.global_vars = global_vars

    def _parse_last_seen_at(self, *, profile: UserProfile, campaign_id: str) -> datetime | None:
        raw = self._last_seen_at_iso(profile, campaign_id=campaign_id)
        return datetime.fromisoformat(raw) if raw else None

    def _last_seen_at_iso(self, profile: UserProfile, *, campaign_id: str) -> str | None:
        preferences = dict(profile.preferences or {})
        campaign_views = dict(preferences.get("campaign_map_views", {}) or {})
        raw = str(dict(campaign_views.get(campaign_id, {}) or {}).get("last_return_summary_at", "") or "").strip()
        return raw or None

    def _write_last_seen_at(self, *, profile: UserProfile, campaign_id: str, last_seen_at: datetime) -> None:
        preferences = dict(profile.preferences or {})
        campaign_views = dict(preferences.get("campaign_map_views", {}) or {})
        campaign_views[campaign_id] = {
            **dict(campaign_views.get(campaign_id, {}) or {}),
            "last_return_summary_at": last_seen_at.isoformat(),
        }
        preferences["campaign_map_views"] = campaign_views
        profile.preferences = preferences
