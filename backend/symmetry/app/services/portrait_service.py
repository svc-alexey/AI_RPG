import asyncio
import uuid
from dataclasses import dataclass

import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.models import CampaignPortrait
from app.services.portrait_optimizer import optimize_portrait
from app.services.portrait_prompt_builder import build_portrait_prompt


@dataclass
class PortraitResponse:
    portrait_id: str
    url: str


@dataclass
class PortraitGenerationConfig:
    api_key: str
    base_url: str
    image_model: str
    timeout_seconds: int
    poll_interval_seconds: float


class PortraitService:
    def __init__(self, db: AsyncSession, config: PortraitGenerationConfig):
        self._db = db
        self._config = config
        self._client = httpx.AsyncClient(
            timeout=httpx.Timeout(config.timeout_seconds),
            headers={"Authorization": f"Bearer {config.api_key}"},
        )

    @classmethod
    def from_settings(cls, db: AsyncSession) -> "PortraitService":
        settings = get_settings()
        return cls(
            db=db,
            config=PortraitGenerationConfig(
                api_key=settings.polza_ai_api_key,
                base_url=settings.polza_ai_base_url,
                image_model=settings.polza_ai_image_model,
                timeout_seconds=settings.polza_ai_timeout_seconds,
                poll_interval_seconds=settings.polza_ai_poll_interval_seconds,
            ),
        )

    async def generate_portrait(
        self,
        campaign_id: str,
        character_name: str,
        character_race: str,
        character_class: str,
        character_gender: str,
        character_personality: str,
        character_prompt_fragment: str,
        story_context: str,
        setting: str,
    ) -> PortraitResponse:
        existing = await self._get_existing_portrait(campaign_id)
        if existing is not None:
            return existing

        prompt = build_portrait_prompt(
            character_name=character_name,
            character_race=character_race,
            character_class=character_class,
            character_gender=character_gender,
            character_personality=character_personality,
            character_prompt_fragment=character_prompt_fragment,
            story_context=story_context,
            setting=setting,
        )

        request_id = await self._post_generation(prompt)
        image_url = await self._poll_until_complete(request_id)
        image_bytes = await self._download_image(image_url)

        compressed, _ = optimize_portrait(image_bytes, "image/png")

        portrait = CampaignPortrait(
            id=str(uuid.uuid4()),
            campaign_id=campaign_id,
            image_webp=compressed,
            prompt_used=prompt,
            model_used=self._config.image_model,
        )
        self._db.add(portrait)
        await self._db.commit()

        settings = get_settings()
        base = settings.web_public_origin.rstrip("/")
        return PortraitResponse(
            portrait_id=str(portrait.id),
            url=f"{base}/v1/campaigns/{campaign_id}/portrait/image",
        )

    async def _get_existing_portrait(self, campaign_id: str) -> PortraitResponse | None:
        result = await self._db.execute(
            select(CampaignPortrait).where(
                CampaignPortrait.campaign_id == campaign_id
            )
        )
        portrait = result.scalar_one_or_none()
        if portrait is None:
            return None
        settings = get_settings()
        base = settings.web_public_origin.rstrip("/")
        return PortraitResponse(
            portrait_id=str(portrait.id),
            url=f"{base}/v1/campaigns/{campaign_id}/portrait/image",
        )

    async def _post_generation(self, prompt: str) -> str:
        try:
            response = await self._client.post(
                f"{self._config.base_url}/images/generations",
                json={
                    "model": self._config.image_model,
                    "prompt": prompt,
                    "n": 1,
                    "size": "1024x1024",
                },
            )
            response.raise_for_status()
            data = response.json()
        except httpx.HTTPError as exc:
            raise PolzaApiError(
                f"Polza.ai generation request failed: {exc}"
            ) from exc

        request_id = data.get("requestId")
        if not request_id:
            raise PolzaApiError(
                f"Polza.ai response missing requestId: {data}"
            )
        return request_id

    async def _poll_until_complete(self, request_id: str) -> str:
        deadline = asyncio.get_event_loop().time() + self._config.timeout_seconds
        while True:
            if asyncio.get_event_loop().time() > deadline:
                raise PolzaTimeoutError(
                    f"Portrait generation timed out after {self._config.timeout_seconds}s"
                )
            try:
                response = await self._client.get(
                    f"{self._config.base_url}/media/{request_id}"
                )
                response.raise_for_status()
                data = response.json()
            except httpx.HTTPError as exc:
                raise PolzaApiError(
                    f"Polza.ai poll failed for {request_id}: {exc}"
                ) from exc

            status = data.get("status", "")
            if status == "completed":
                items = data.get("data", [])
                if not items:
                    raise PolzaApiError(
                        f"Polza.ai completed but returned no images for {request_id}"
                    )
                image_url = items[0].get("url")
                if not image_url:
                    raise PolzaApiError(
                        f"Polza.ai image URL missing for {request_id}"
                    )
                return image_url
            if status == "failed":
                error_msg = data.get("error", "Unknown error")
                raise PolzaApiError(
                    f"Polza.ai generation failed: {error_msg}"
                )

            await asyncio.sleep(self._config.poll_interval_seconds)

    async def _download_image(self, image_url: str) -> bytes:
        try:
            response = await self._client.get(image_url)
            response.raise_for_status()
            return response.content
        except httpx.HTTPError as exc:
            raise PolzaApiError(
                f"Failed to download generated image: {exc}"
            ) from exc

    async def close(self) -> None:
        await self._client.aclose()


class PolzaApiError(Exception):
    pass


class PolzaTimeoutError(PolzaApiError):
    pass
