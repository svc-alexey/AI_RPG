from app.schemas.prompts import GeneratePromptsResponse
from app.services.ai_gateway import AiGatewayService
from app.services.credentials import ResolvedCredentials
from app.services.prompt_budget import build_prompt_generation_budget
from app.services.presentation_text import (
    normalize_campaign_title,
    normalize_objective_text,
)
from app.services.text_normalization import normalize_prompt_text


class PromptGenerationService:
    def __init__(self) -> None:
        self._ai_gateway = AiGatewayService()

    async def generate(
        self,
        *,
        credentials: ResolvedCredentials,
        setting: str,
        literary_genre: str,
        mode: str,
        difficulty: str,
        language: str,
        story_wish: str,
    ) -> GeneratePromptsResponse:
        normalized_story_wish = normalize_prompt_text(story_wish, limit=320)
        budget = build_prompt_generation_budget(mode=mode)
        response = await self._ai_gateway.generate_json(
            credentials=credentials,
            system_prompt=_build_prompt_generation_system_prompt(
                language=language,
                mode=mode,
            ),
            user_payload={
                "task": "generate_campaign_prompts",
                "setting": setting,
                "literary_genre": literary_genre,
                "mode": mode,
                "difficulty": difficulty,
                "story_wish": normalized_story_wish,
            },
            max_output_tokens=budget.max_output_tokens,
            scenario=budget.scenario,
        )
        payload = response.payload
        return GeneratePromptsResponse(
            story_prompt=str(payload.get("story_prompt", "")).strip(),
            character_prompt=str(payload.get("character_prompt", "")).strip(),
            campaign_title=normalize_campaign_title(
                str(payload.get("campaign_title", "")).strip() or normalized_story_wish,
                language=language,
            ),
            objective_hint=normalize_objective_text(
                str(payload.get("objective_hint", "")).strip() or normalized_story_wish,
                language=language,
            ),
        )


def _build_prompt_generation_system_prompt(*, language: str, mode: str) -> str:
    is_long_campaign = mode == "longCampaign"
    return (
        "Return valid JSON only with keys "
        "story_prompt, character_prompt, campaign_title, objective_hint. "
        f"Write every value in language `{language}`. "
        "campaign_title: standalone title, 2-4 words, <=30 chars, no commas. "
        "objective_hint: short current goal, <=56 chars, not narration. "
        + (
            "This is a long campaign. story_prompt should be richer and more detailed, with a clear world frame or hero backstory, a durable conflict, and room for a longer arc. "
            "character_prompt should be specific about motivation, internal tension, and tone."
            if is_long_campaign
            else "This is a short story. story_prompt should stay compact, fast to enter, and focused on an immediate hook. "
            "character_prompt should stay concise and action-ready."
        )
    )
