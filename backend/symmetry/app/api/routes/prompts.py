from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import User
from app.db.session import get_db_session
from app.schemas.prompts import GeneratePromptsRequest, GeneratePromptsResponse
from app.services.ai_gateway import classify_provider_error
from app.services.billing import BillingService
from app.services.credentials import CredentialResolutionService
from app.services.prompt_generation import PromptGenerationService

router = APIRouter(prefix="/prompts", tags=["prompts"])
credential_service = CredentialResolutionService()
prompt_service = PromptGenerationService()
billing_service = BillingService()


@router.post("/generate", response_model=GeneratePromptsResponse)
async def generate_prompts(
    payload: GeneratePromptsRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> GeneratePromptsResponse:
    await billing_service.ensure_ai_access(session, user=user)
    try:
        credentials = credential_service.resolve(payload.provider_credentials)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    try:
        response = await prompt_service.generate(
            credentials=credentials,
            setting=payload.setting,
            literary_genre=payload.literary_genre,
            mode=payload.mode,
            difficulty=payload.difficulty,
            language=payload.language,
            story_wish=payload.story_wish,
            character=payload.character,
        )
        estimated_tokens = sum(
            max(1, len(text or "") // 4)
            for text in (
                response.story_prompt,
                response.character_prompt,
                response.campaign_title,
                response.objective_hint,
            )
        )
        await billing_service.consume_tokens(
            session,
            user_id=user.id,
            total_tokens=estimated_tokens,
            reason="prompt_generation",
            metadata={"mode": payload.mode, "setting": payload.setting},
        )
        await session.commit()
        return response
    except Exception as exc:
        status_code, detail = classify_provider_error(exc)
        raise HTTPException(status_code=status_code, detail=detail) from exc
