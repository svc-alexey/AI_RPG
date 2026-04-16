from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.db.models import User
from app.db.session import get_db_session
from app.schemas.prompts import GeneratePromptsRequest, GeneratePromptsResponse
from app.services.ai_gateway import classify_provider_error
from app.services.credentials import CredentialResolutionService
from app.services.prompt_generation import PromptGenerationService

router = APIRouter(prefix="/prompts", tags=["prompts"])
credential_service = CredentialResolutionService()
prompt_service = PromptGenerationService()


@router.post("/generate", response_model=GeneratePromptsResponse)
async def generate_prompts(
    payload: GeneratePromptsRequest,
    _: User = Depends(get_current_user),
    __: AsyncSession = Depends(get_db_session),
) -> GeneratePromptsResponse:
    try:
        credentials = credential_service.resolve(payload.provider_credentials)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    try:
        return await prompt_service.generate(
            credentials=credentials,
            setting=payload.setting,
            literary_genre=payload.literary_genre,
            mode=payload.mode,
            difficulty=payload.difficulty,
            language=payload.language,
            story_wish=payload.story_wish,
            character=payload.character,
        )
    except Exception as exc:
        status_code, detail = classify_provider_error(exc)
        raise HTTPException(status_code=status_code, detail=detail) from exc
