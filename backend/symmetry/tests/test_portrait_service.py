import io
import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.db.models import CampaignPortrait
from app.services.portrait_service import (
    PolzaApiError,
    PolzaTimeoutError,
    PortraitGenerationConfig,
    PortraitService,
)


@pytest.fixture
def portrait_config():
    return PortraitGenerationConfig(
        api_key="test-key",
        base_url="https://polza.ai/api/v1",
        image_model="google/gemini-2.5-flash-image",
        timeout_seconds=2,
        poll_interval_seconds=0.05,
    )


def _make_test_image_bytes() -> bytes:
    from PIL import Image

    img = Image.new("RGB", (200, 200), color=(100, 80, 60))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


class _FakeSession:
    def __init__(self):
        self.items = []
        self.committed = False

    def add(self, item):
        self.items.append(item)

    async def commit(self):
        self.committed = True

    async def execute(self, stmt):
        return _FakeResult(self.items if hasattr(self, "_query_items") else [])

    async def close(self):
        pass


class _FakeResult:
    def __init__(self, items):
        self._items = items

    def scalar_one_or_none(self):
        return self._items[0] if self._items else None


def _fake_post_success(request_json):
    """Simulate successful POST to Polza generations endpoint."""
    return MagicMock(
        status_code=200,
        json=lambda: {"requestId": "gen_test_123"},
        raise_for_status=lambda: None,
    )


def _fake_poll_completed(_request_id):
    """Simulate poll returning completed status."""
    return MagicMock(
        status_code=200,
        json=lambda: {
            "status": "completed",
            "data": [{"url": "https://s3.polza.ai/test_image.png"}],
        },
        raise_for_status=lambda: None,
    )


def _fake_download_image(_url):
    """Simulate image download."""
    return MagicMock(
        status_code=200,
        content=_make_test_image_bytes(),
        raise_for_status=lambda: None,
    )


@pytest.mark.asyncio
async def test_generate_portrait_success(portrait_config):
    """Full generation flow with mocked httpx client."""
    db = _FakeSession()
    service = PortraitService(db=db, config=portrait_config)

    campaign_id = str(uuid.uuid4())

    mock_client = AsyncMock()
    mock_client.post = AsyncMock(return_value=_fake_post_success({}))
    mock_client.get = AsyncMock(
        side_effect=[_fake_poll_completed("gen_test_123"), _fake_download_image("url")]
    )
    mock_client.aclose = AsyncMock()
    service._client = mock_client

    result = await service.generate_portrait(
        campaign_id=campaign_id,
        character_name="Test",
        character_race="human",
        character_class="warrior",
        character_gender="male",
        character_personality="brave",
        character_prompt_fragment="red cloak",
        story_context="Dark forest",
        setting="romantasy",
    )

    assert result.portrait_id
    assert "/portrait/image" in result.url
    assert campaign_id in result.url
    assert db.committed is True
    assert len(db.items) == 1
    assert isinstance(db.items[0], CampaignPortrait)
    assert db.items[0].model_used == portrait_config.image_model
    assert len(db.items[0].image_webp) > 0

    await service.close()


@pytest.mark.asyncio
async def test_idempotency_returns_existing(portrait_config):
    """Second generation call returns existing portrait without API call."""
    db = _FakeSession()
    campaign_id = str(uuid.uuid4())

    existing = CampaignPortrait(
        id=str(uuid.uuid4()),
        campaign_id=campaign_id,
        image_webp=b"test-webp-bytes",
        prompt_used="test prompt",
        model_used="test-model",
    )

    class _FakeQueryResult:
        def scalar_one_or_none(self):
            return existing

    db = MagicMock()
    db.execute = AsyncMock(return_value=_FakeQueryResult())
    db.add = MagicMock()
    db.commit = AsyncMock()

    service = PortraitService(db=db, config=portrait_config)

    mock_client = AsyncMock()
    mock_client.post = AsyncMock()
    mock_client.get = AsyncMock()
    mock_client.aclose = AsyncMock()
    service._client = mock_client

    result = await service.generate_portrait(
        campaign_id=campaign_id,
        character_name="Test",
        character_race="human",
        character_class="warrior",
        character_gender="male",
        character_personality="",
        character_prompt_fragment="",
        story_context="",
        setting="romantasy",
    )

    assert result.portrait_id == str(existing.id)
    # API should NOT be called
    mock_client.post.assert_not_called()

    await service.close()


@pytest.mark.asyncio
async def test_polza_post_error(portrait_config):
    """When POST to Polza fails, PolzaApiError is raised."""
    db = MagicMock()
    db.execute = AsyncMock(return_value=_FakeResult([]))
    db.commit = AsyncMock()

    service = PortraitService(db=db, config=portrait_config)
    campaign_id = str(uuid.uuid4())

    mock_client = AsyncMock()
    mock_client.post = AsyncMock(
        side_effect=__import__("httpx").ConnectError("Connection refused")
    )
    mock_client.aclose = AsyncMock()
    service._client = mock_client

    with pytest.raises(PolzaApiError, match="Connection refused"):
        await service.generate_portrait(
            campaign_id=campaign_id,
            character_name="Test",
            character_race="human",
            character_class="warrior",
            character_gender="male",
            character_personality="",
            character_prompt_fragment="",
            story_context="",
            setting="romantasy",
        )

    await service.close()


@pytest.mark.asyncio
async def test_polza_failed_status(portrait_config):
    """When Polza returns status=failed, PolzaApiError is raised."""
    db = MagicMock()
    db.execute = AsyncMock(return_value=_FakeResult([]))
    db.commit = AsyncMock()

    service = PortraitService(db=db, config=portrait_config)
    campaign_id = str(uuid.uuid4())

    mock_client = AsyncMock()
    mock_client.post = AsyncMock(return_value=_fake_post_success({}))
    mock_client.get = AsyncMock(
        return_value=MagicMock(
            status_code=200,
            json=lambda: {"status": "failed", "error": "NSFW content detected"},
            raise_for_status=lambda: None,
        )
    )
    mock_client.aclose = AsyncMock()
    service._client = mock_client

    with pytest.raises(PolzaApiError, match="NSFW"):
        await service.generate_portrait(
            campaign_id=campaign_id,
            character_name="Test",
            character_race="human",
            character_class="warrior",
            character_gender="male",
            character_personality="",
            character_prompt_fragment="",
            story_context="",
            setting="romantasy",
        )

    await service.close()


@pytest.mark.asyncio
async def test_prompt_builder_integration(portrait_config):
    """Generated prompt includes all character details."""
    db = MagicMock()
    db.execute = AsyncMock(return_value=_FakeResult([]))
    db.commit = AsyncMock()

    service = PortraitService(db=db, config=portrait_config)
    campaign_id = str(uuid.uuid4())

    captured_prompts = []

    async def capture_prompt(*args, **kwargs):
        body = kwargs.get("json", {})
        if body:
            captured_prompts.append(body["prompt"])
        return _fake_post_success({})

    mock_client = AsyncMock()
    mock_client.post = AsyncMock(side_effect=capture_prompt)
    mock_client.get = AsyncMock(
        side_effect=[_fake_poll_completed("gen_1"), _fake_download_image("url")]
    )
    mock_client.aclose = AsyncMock()
    service._client = mock_client

    await service.generate_portrait(
        campaign_id=campaign_id,
        character_name="Lyra",
        character_race="elf",
        character_class="mage",
        character_gender="female",
        character_personality="mysterious",
        character_prompt_fragment="silver hair, glowing eyes",
        story_context="Ancient ruins",
        setting="fantasy",
    )

    prompt = captured_prompts[0]
    assert "Lyra" in prompt
    assert "female elf" in prompt
    assert "mage" in prompt
    assert "mysterious" in prompt
    assert "silver hair" in prompt
    assert "Ancient ruins" in prompt
    assert "no watermark" in prompt

    await service.close()
