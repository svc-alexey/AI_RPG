import asyncio
import base64
import logging
import random
import uuid
from dataclasses import dataclass

import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.db.models import CampaignPortrait

logger = logging.getLogger("symmetry.portrait")
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

        task_id = await self._post_generation(prompt)
        image_url = await self._poll_until_complete(task_id)
        image_bytes = await self._download_image(image_url)
        logger.info("portrait_download_done campaign=%s bytes=%d", campaign_id, len(image_bytes))
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
        """POST to z.ai async image generation. Returns task id for polling."""
        try:
            response = await self._client.post(
                f"{self._config.base_url}/async/images/generations",
                json={
                    "model": self._config.image_model,
                    "prompt": prompt,
                    "size": "1024x1024",
                },
            )
            response.raise_for_status()
            data = response.json()
            logger.info("portrait_post_response data_keys=%s", list(data.keys()))
        except httpx.HTTPError as exc:
            raise PolzaApiError(f"Image generation request failed: {exc}") from exc

        task_id = data.get("id")
        if task_id:
            logger.info("portrait_async_task id=%s", task_id)
            return task_id

        raise PolzaApiError(f"Unexpected response, missing id: {data}")

    async def _poll_until_complete(self, task_id: str) -> str:
        """Poll z.ai async result endpoint until SUCCESS, return image URL."""
        deadline = asyncio.get_event_loop().time() + self._config.timeout_seconds
        while True:
            if asyncio.get_event_loop().time() > deadline:
                raise PolzaTimeoutError(
                    f"Portrait generation timed out after {self._config.timeout_seconds}s"
                )
            try:
                response = await self._client.get(
                    f"{self._config.base_url}/async-result/{task_id}"
                )
                response.raise_for_status()
                data = response.json()
            except httpx.HTTPError as exc:
                raise PolzaApiError(
                    f"z.ai poll failed for {task_id}: {exc}"
                ) from exc

            task_status = data.get("task_status", "")
            if task_status == "SUCCESS":
                items = data.get("image_result", [])
                if not items:
                    raise PolzaApiError(
                        f"z.ai SUCCESS but no image_result for {task_id}"
                    )
                image_url = items[0].get("url")
                if not image_url:
                    raise PolzaApiError(
                        f"z.ai image URL missing for {task_id}"
                    )
                logger.info("portrait_async_done task_id=%s url=%s", task_id, image_url[:120])
                return image_url
            if task_status == "FAIL":
                error_msg = str(data)[:300]
                raise PolzaApiError(
                    f"z.ai generation failed: {error_msg}"
                )

            await asyncio.sleep(self._config.poll_interval_seconds)

    async def _warmup_cdn(self, image_url: str) -> None:
        """HEAD the CDN URL to trigger propagation. Best-effort only for mfile.z.ai."""
        if "mfile.z.ai" not in image_url:
            return
        for _ in range(5):
            try:
                async with httpx.AsyncClient(timeout=httpx.Timeout(8.0)) as client:
                    resp = await client.head(image_url)
                    if resp.status_code == 200:
                        return
            except httpx.HTTPError:
                pass
            await asyncio.sleep(1.0)

    async def _download_image(self, image_url: str) -> bytes:
        """Download via curl — Python HTTP libs have TLS issues with
        mfile.z.ai (ReadTimeout), but curl works reliably on Linux."""
        max_attempts = 4
        last_err = ""
        for attempt in range(max_attempts):
            try:
                proc = await asyncio.create_subprocess_exec(
                    "curl",
                    "-s", "-S",
                    "--http1.1",
                    "--max-time", "30",
                    "--connect-timeout", "15",
                    "--speed-limit", "100",
                    "--speed-time", "8",
                    "-H", "Accept-Encoding: identity",
                    "-o", "-",
                    image_url,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                stdout, stderr = await proc.communicate()
                if proc.returncode == 0 and stdout:
                    return stdout
                # mfile.z.ai often closes connection without FIN (Docker NAT
                # loses it). Content-Length may be wrong. Accept partial data
                # if we received enough bytes for a real image.
                if len(stdout) > 1000:
                    logger.info("portrait_curl_partial size=%d", len(stdout))
                    return stdout
                last_err = stderr.decode(errors="replace")[:200] if stderr else f"rc={proc.returncode}"
            except Exception as exc:
                last_err = f"{type(exc).__name__}: {exc}"
            if attempt < max_attempts - 1:
                wait = (2 ** attempt) + random.uniform(0, 0.5)
                logger.info("portrait_curl_retry attempt=%d/%d wait=%.1fs", attempt + 1, max_attempts, wait)
                await asyncio.sleep(wait)
        raise PolzaApiError(f"Failed to download after {max_attempts} attempts: {last_err}")

    async def close(self) -> None:
        await self._client.aclose()


class PolzaApiError(Exception):
    pass


class PolzaTimeoutError(PolzaApiError):
    pass
