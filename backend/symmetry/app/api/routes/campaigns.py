from datetime import datetime

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import Campaign, CampaignMember, CampaignSnapshot, CampaignTurn, User, WorldChronicle, WorldState
from app.db.session import SessionLocal, get_db_session
from app.schemas.campaigns import CampaignResponse, CampaignStateResponse, CreateCampaignRequest, ProcessTurnRequest, ProcessTurnResponse
from app.services.ai_gateway import AiGatewayService
from app.services.campaign_runtime import CampaignRuntimeService, build_initial_state
from app.services.credentials import CredentialResolutionService
from app.services.embeddings import get_embedding_service
from app.services.ids import new_id
from app.services.presentation_text import normalize_campaign_title
from app.services.rag import RagService
from app.services.simulation import SimulationService

router = APIRouter(prefix="/campaigns", tags=["campaigns"])
credential_service = CredentialResolutionService()
runtime_service = CampaignRuntimeService()
rag_service = RagService()
simulation_service = SimulationService()
ai_gateway = AiGatewayService()


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
    session.add(
        WorldState(
            id=new_id(),
            campaign_id=campaign.id,
            current_day=1,
            minute_of_day=8 * 60,
            global_vars={"weather": "clear", "prices": {}, "factions": {}},
        )
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


@router.post("/{campaign_id}/turns/process", response_model=ProcessTurnResponse)
async def process_turn(
    campaign_id: str,
    payload: ProcessTurnRequest,
    background_tasks: BackgroundTasks,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> ProcessTurnResponse:
    campaign = await _load_owned_campaign(session, campaign_id=campaign_id, user_id=user.id)
    snapshot = await session.get(CampaignSnapshot, campaign.current_snapshot_id)
    world_state = await session.scalar(select(WorldState).where(WorldState.campaign_id == campaign.id))
    if snapshot is None or world_state is None:
        raise HTTPException(status_code=404, detail="campaign_runtime_not_found")

    current_state = snapshot.state_json
    embedding_service = get_embedding_service()
    query_vector = embedding_service.encode_query(payload.player_action)
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
    )
    credentials = credential_service.resolve(payload.provider_credentials)
    llm_result = await ai_gateway.generate_turn(
        credentials=credentials,
        context=context,
        player_action=payload.player_action,
        language=payload.language or campaign.language,
    )
    next_state, state_changes, importance, world_event_summary = runtime_service.apply_turn_result(
        state=current_state,
        result=llm_result,
        player_action=payload.player_action,
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
    session.add(
        CampaignTurn(
            id=new_id(),
            campaign_id=campaign.id,
            snapshot_id=next_snapshot.id,
            turn_number=int(next_state.get("turn_number", 0)),
            player_action=payload.player_action,
            llm_response_json=llm_result,
        )
    )
    campaign.current_snapshot_id = next_snapshot.id
    campaign.updated_at = datetime.utcnow()
    await session.commit()

    if importance > 0:
        background_tasks.add_task(
            _persist_chronicle_event,
            campaign.id,
            str(next_state.get("location", "")),
            llm_result.get("memory_entry", ""),
            world_event_summary or llm_result.get("memory_entry", ""),
            importance,
            llm_result.get("state_changes", {}),
        )

    return ProcessTurnResponse(
        narration=str(llm_result.get("narration", "")).strip(),
        choices=[str(item) for item in llm_result.get("choices", []) if str(item).strip()],
        state_changes=state_changes,
        memory_entry=str(llm_result.get("memory_entry", "")).strip(),
        request_id=new_id(),
        campaign_snapshot_version=next_snapshot.version,
        state=next_state,
    )


async def _persist_chronicle_event(
    campaign_id: str,
    location_slug: str,
    memory_entry: str,
    world_event_summary: str,
    importance: int,
    metadata_json: dict,
) -> None:
    event_text = (world_event_summary or memory_entry).strip()
    if not event_text:
        return
    embedding_service = get_embedding_service()
    vector = embedding_service.encode_document(event_text)
    async with SessionLocal() as session:
        session.add(
            WorldChronicle(
                id=new_id(),
                campaign_id=campaign_id,
                location_slug=location_slug,
                event_text=event_text,
                importance=importance,
                metadata_json=metadata_json,
                vector=vector,
            )
        )
        await session.commit()
