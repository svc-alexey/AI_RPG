from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import Campaign, CampaignMember, CampaignSnapshot, CampaignTurn, User, WorldChronicle, WorldState
from app.db.session import get_db_session
from app.schemas.campaigns import CampaignResponse, CampaignStateResponse, CreateCampaignRequest, ProcessTurnRequest, ProcessTurnResponse, WorldRumorResponse
from app.services.ai_gateway import AiGatewayService, classify_provider_error
from app.services.butterfly import ButterflyService
from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state
from app.services.credentials import CredentialResolutionService
from app.services.embeddings import get_embedding_service
from app.services.ids import new_id
from app.services.map_state_service import MapStateService
from app.services.prompt_budget import build_turn_budget
from app.services.presentation_text import (
    build_location_display_name,
    normalize_campaign_title,
    sanitize_world_rumor_event_text,
)
from app.services.rag import RagService
from app.services.simulation import SimulationService
from app.services.text_normalization import normalize_prompt_text

router = APIRouter(prefix="/campaigns", tags=["campaigns"])
credential_service = CredentialResolutionService()
runtime_service = CampaignRuntimeService()
rag_service = RagService()
simulation_service = SimulationService()
ai_gateway = AiGatewayService()
butterfly_service = ButterflyService()
map_state_service = MapStateService()


def _resolve_rumor_location_title(
    *,
    item: WorldChronicle,
    language: str,
) -> str | None:
    metadata = item.metadata_json if isinstance(item.metadata_json, dict) else {}
    for candidate in (
        metadata.get("location_title"),
        metadata.get("location"),
        item.location_slug,
    ):
        display_name = build_location_display_name(
            str(candidate or ""),
            language=language,
        )
        if display_name:
            return display_name
    return None


def _build_turn_usage_meta(
    *,
    mode: str,
    turn_number: int,
    trigger_source: str,
    usage: dict[str, int],
) -> dict[str, str | int | float]:
    budget = build_turn_budget(
        mode=mode,
        turn_number=turn_number,
        trigger_source=trigger_source,
    )
    prompt_tokens = int(usage.get("prompt_tokens", 0) or 0)
    cache_hit_tokens = int(usage.get("prompt_cache_hit_tokens", 0) or 0)
    return {
        "mode": mode,
        "trigger_source": normalize_prompt_text(trigger_source, limit=32),
        "turn_number": turn_number,
        "budget_scenario": budget.scenario,
        "budget_max_output_tokens": budget.max_output_tokens,
        "prompt_cache_hit_ratio": round(cache_hit_tokens / prompt_tokens, 4)
        if prompt_tokens > 0
        else 0.0,
    }


@router.post("", response_model=CampaignStateResponse)
async def create_campaign(
    payload: CreateCampaignRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> CampaignStateResponse:
    now = datetime.utcnow()
    campaign = Campaign(
        id=new_id(),
        owner_user_id=user.id,
        title=normalize_campaign_title(
            payload.title.strip(),
            language=payload.language.strip() or "ru",
        ),
        setting=payload.setting.strip(),
        mode=payload.mode.strip(),
        difficulty=payload.difficulty.strip(),
        language=payload.language.strip() or "ru",
        created_at=now,
        updated_at=now,
    )
    state = build_initial_state(payload)
    state["id"] = campaign.id
    state = runtime_service.ensure_playable_location(state=state)
    session.add(campaign)
    await session.flush()

    snapshot = CampaignSnapshot(
        id=new_id(),
        campaign_id=campaign.id,
        version=1,
        state_json=state,
    )
    session.add(snapshot)
    await session.flush()

    campaign.current_snapshot_id = snapshot.id
    session.add(
        CampaignMember(
            id=new_id(),
            campaign_id=campaign.id,
            user_id=user.id,
            role="owner",
        )
    )
    world_state = WorldState(
        id=new_id(),
        campaign_id=campaign.id,
        current_day=1,
        minute_of_day=8 * 60,
        global_vars={"prices": {}, "factions": {}},
    )
    session.add(world_state)
    await session.flush()
    await butterfly_service.seed_world(
        session,
        campaign_id=campaign.id,
        mode=payload.mode,
        language=payload.language.strip() or "ru",
        location=str(state.get("location", "")),
        world_state=world_state,
    )
    await session.commit()
    return CampaignStateResponse(
        campaign=CampaignResponse.model_validate(campaign),
        snapshot_version=snapshot.version,
        state=state,
    )


@router.get("", response_model=list[CampaignResponse])
async def list_campaigns(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[CampaignResponse]:
    result = await session.execute(
        select(Campaign)
        .where(Campaign.owner_user_id == user.id)
        .order_by(desc(Campaign.updated_at))
    )
    return [CampaignResponse.model_validate(item) for item in result.scalars().all()]


async def _load_owned_campaign(
    session: AsyncSession, *, campaign_id: str, user_id: str
) -> Campaign:
    campaign = await session.scalar(
        select(Campaign).where(Campaign.id == campaign_id, Campaign.owner_user_id == user_id)
    )
    if campaign is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="campaign_not_found")
    return campaign


@router.get("/{campaign_id}", response_model=CampaignResponse)
async def get_campaign(
    campaign_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> CampaignResponse:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    return CampaignResponse.model_validate(campaign)


@router.delete("/{campaign_id}")
async def delete_campaign(
    campaign_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> dict[str, str]:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    await session.delete(campaign)
    await session.commit()
    return {"message": "campaign_deleted"}


@router.get("/{campaign_id}/state", response_model=CampaignStateResponse)
async def get_campaign_state(
    campaign_id: str,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> CampaignStateResponse:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    snapshot = await session.get(CampaignSnapshot, campaign.current_snapshot_id)
    if snapshot is None:
        raise HTTPException(status_code=404, detail="snapshot_not_found")
    return CampaignStateResponse(
        campaign=CampaignResponse.model_validate(campaign),
        snapshot_version=snapshot.version,
        state=snapshot.state_json,
    )


@router.get("/{campaign_id}/rumors", response_model=list[WorldRumorResponse])
async def get_campaign_rumors(
    campaign_id: str,
    limit: int = Query(default=5, ge=1, le=20),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> list[WorldRumorResponse]:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    language = str(campaign.language or "ru").strip() or "ru"
    result = await session.execute(
        select(WorldChronicle)
        .where(
            WorldChronicle.campaign_id == campaign.id,
            WorldChronicle.metadata_json.contains({"source": "butterfly_effect"}),
        )
        .order_by(desc(WorldChronicle.created_at))
        .limit(limit)
    )
    return [
        WorldRumorResponse(
            id=item.id,
            entity_type=item.entity_type,
            event_text=sanitize_world_rumor_event_text(
                item.event_text,
                language=language,
            ),
            importance=item.importance,
            location_slug=item.location_slug,
            location_title=_resolve_rumor_location_title(
                item=item,
                language=language,
            ),
            created_at=item.created_at,
        )
        for item in result.scalars().all()
    ]


@router.post("/{campaign_id}/turns/process", response_model=ProcessTurnResponse)
async def process_turn(
    campaign_id: str,
    payload: ProcessTurnRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> ProcessTurnResponse:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    snapshot = await session.get(CampaignSnapshot, campaign.current_snapshot_id)
    world_state = await session.scalar(select(WorldState).where(WorldState.campaign_id == campaign.id))
    if snapshot is None or world_state is None:
        raise HTTPException(status_code=404, detail="campaign_runtime_not_found")

    current_state = snapshot.state_json
    current_state = runtime_service.ensure_bootstrap_state(state=current_state)
    current_state = runtime_service.ensure_playable_location(state=current_state)
    normalized_player_action = normalize_prompt_text(payload.player_action, limit=240)
    await butterfly_service.seed_world(
        session,
        campaign_id=campaign.id,
        mode=campaign.mode,
        language=campaign.language,
        location=str(current_state.get("location", "")),
        world_state=world_state,
    )
    await butterfly_service.apply_due_consequences(
        session,
        campaign_id=campaign.id,
        world_state=world_state,
        upcoming_turn_number=int(current_state.get("turn_number", 0)) + 1,
    )
    await session.flush()

    embedding_service = get_embedding_service()
    query_text = runtime_service.build_rag_query_text(
        state=current_state,
        player_action=normalized_player_action,
    )
    query_vector = embedding_service.encode_query(query_text)
    chronicles = await rag_service.search_relevant_events(
        session,
        campaign_id=campaign.id,
        location_slug=str(current_state.get("location", "")),
        query_vector=query_vector,
    )
    context = runtime_service.build_turn_context(
        state=current_state,
        world_state=world_state,
        chronicles=chronicles,
        trigger_source=payload.trigger_source,
    )
    try:
        credentials = credential_service.resolve(payload.provider_credentials)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    try:
        llm_result = await ai_gateway.generate_turn(
            credentials=credentials,
            context=context,
            player_action=normalized_player_action,
            language=payload.language or campaign.language,
            trigger_source=payload.trigger_source,
        )
    except Exception as exc:
        status_code, detail = classify_provider_error(exc)
        raise HTTPException(status_code=status_code, detail=detail) from exc
    llm_payload = llm_result.payload
    next_state, state_changes, importance, world_event_summary = runtime_service.apply_turn_result(
        state=current_state,
        result=llm_payload,
        player_action=normalized_player_action,
    )
    next_state = runtime_service.ensure_playable_location(
        state=next_state,
        state_changes=state_changes,
    )
    butterfly_service.apply_immediate_world_patch(
        world_state,
        global_vars_patch=state_changes.get("global_vars_patch"),
    )
    await butterfly_service.seed_world(
        session,
        campaign_id=campaign.id,
        mode=campaign.mode,
        language=campaign.language,
        location=str(next_state.get("location", "")),
        world_state=world_state,
    )
    world_state, tick = simulation_service.advance(world_state)
    session.add(tick)
    next_snapshot = CampaignSnapshot(
        id=new_id(),
        campaign_id=campaign.id,
        version=snapshot.version + 1,
        state_json=next_state,
    )
    session.add(next_snapshot)
    await session.flush()
    turn = CampaignTurn(
        id=new_id(),
        campaign_id=campaign.id,
        snapshot_id=next_snapshot.id,
        turn_number=int(next_state.get("turn_number", 0)),
        player_action=normalized_player_action,
        llm_response_json=llm_payload,
        llm_usage_json={
            **llm_result.usage.to_dict(),
            **llm_result.meta,
            **_build_turn_usage_meta(
                mode=campaign.mode,
                turn_number=int(current_state.get("turn_number", 0) or 0),
                trigger_source=payload.trigger_source,
                usage=llm_result.usage.to_dict(),
            ),
        },
    )
    session.add(turn)
    campaign.current_snapshot_id = next_snapshot.id
    campaign.updated_at = datetime.utcnow()

    impact_seeds = butterfly_service.normalize_impact_seeds(
        llm_payload.get("impact_seeds"),
        mode=campaign.mode,
        current_location=str(next_state.get("location", current_state.get("location", ""))),
    )
    needs_background_followup = str(
        llm_payload.get("needs_background_followup", "")
    ).strip().lower() in {"1", "true", "yes"}
    if not impact_seeds and (needs_background_followup or importance >= 6):
        impact_seeds = butterfly_service.fallback_seed_from_turn(
            mode=campaign.mode,
            importance=importance,
            summary=world_event_summary or llm_payload.get("memory_entry", ""),
            current_location=str(next_state.get("location", current_state.get("location", ""))),
        )
    await butterfly_service.enqueue_followup_job(
        session,
        campaign_id=campaign.id,
        mode=campaign.mode,
        language=payload.language or campaign.language,
        turn_id=turn.id,
        source_snapshot_version=next_snapshot.version,
        turn_number=int(next_state.get("turn_number", 0)),
        current_location=str(next_state.get("location", current_state.get("location", ""))),
        impact_seeds=impact_seeds,
        source_summary=world_event_summary or llm_payload.get("memory_entry", ""),
    )
    if importance > 0:
        await butterfly_service.enqueue_chronicle_job(
            session,
            campaign_id=campaign.id,
            location_slug=str(next_state.get("location", "")),
            memory_entry=llm_payload.get("memory_entry", ""),
            world_event_summary=world_event_summary or llm_payload.get("memory_entry", ""),
            importance=importance,
            metadata_json=llm_payload.get("state_changes", {}),
        )
    await session.commit()

    # Sync spatial map with narrative location
    new_location = str(next_state.get("location", ""))
    prev_location = str(current_state.get("location", ""))
    if new_location and new_location != prev_location:
        try:
            await map_state_service.sync_narrative_location(
                session,
                campaign_id=campaign.id,
                location_title=new_location,
                previous_location_title=prev_location if prev_location else None,
            )
            await session.commit()
        except Exception:
            pass

    # Inject map context (best-effort — failure does not fail the turn)
    map_context = None
    try:
        map_context = await map_state_service.get_map_context(session, campaign_id)
    except Exception:
        pass

    return ProcessTurnResponse(
        narration=str(llm_payload.get("narration", "")).strip(),
        choices=[str(item) for item in llm_payload.get("choices", []) if str(item).strip()],
        state_changes=state_changes,
        memory_entry=str(llm_payload.get("memory_entry", "")).strip(),
        request_id=new_id(),
        campaign_snapshot_version=next_snapshot.version,
        state=next_state,
        map_context=map_context,
    )
