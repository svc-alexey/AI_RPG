from app.schemas.prompts import GeneratePromptsResponse
from app.services.ai_gateway import AiGatewayService
from app.services.credentials import ResolvedCredentials
from app.services.presentation_text import (
    normalize_campaign_title,
    normalize_objective_text,
)


class PromptGenerationService:
    def __init__(self) -> None:
        self._ai_gateway = AiGatewayService()

    async def generate(
        self,
        *,
        credentials: ResolvedCredentials,
        setting: str,
        literary_genre: str,
        difficulty: str,
        language: str,
        story_wish: str,
    ) -> GeneratePromptsResponse:
        payload = await self._ai_gateway.generate_json(
            credentials=credentials,
            system_prompt=(
                "Return valid JSON only with keys "
                "`story_prompt`, `character_prompt`, `campaign_title`, and `objective_hint`. "
                f"Write all values in language `{language}`. "
                "campaign_title must be a standalone short title, 2-4 words, "
                "without commas, without subordinate clauses, and no more than 30 characters. "
                "objective_hint must be a short current goal, not a fragment of narration, "
                "and no more than 56 characters."
            ),
            user_payload={
                "task": "generate_campaign_prompts",
                "setting": setting,
                "literary_genre": literary_genre,
                "difficulty": difficulty,
                "story_wish": story_wish,
            },
        )
        return GeneratePromptsResponse(
            story_prompt=str(payload.get("story_prompt", "")).strip(),
            character_prompt=str(payload.get("character_prompt", "")).strip(),
            campaign_title=normalize_campaign_title(
                str(payload.get("campaign_title", "")).strip() or story_wish,
                language=language,
            ),
            objective_hint=normalize_objective_text(
                str(payload.get("objective_hint", "")).strip() or story_wish,
                language=language,
            ),
        )
