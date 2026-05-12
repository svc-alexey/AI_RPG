import io

import pytest
from PIL import Image, ImageDraw

from app.services.portrait_optimizer import (
    _PORTRAIT_HARD_BYTES,
    _PORTRAIT_MAX_DIM,
    optimize_portrait,
)


def _make_test_png(width: int, height: int) -> bytes:
    img = Image.new("RGB", (width, height), color=(40, 30, 25))
    draw = ImageDraw.Draw(img)
    cx, cy = width // 2, height // 2
    rx, ry = int(width * 0.25), int(height * 0.35)
    draw.ellipse(
        (cx - rx, cy - ry, cx + rx, cy + ry),
        fill=(210, 170, 140),
        outline=(180, 140, 110),
        width=2,
    )
    eye_rx, eye_ry = int(rx * 0.3), int(ry * 0.15)
    draw.ellipse(
        (cx - rx // 2 - eye_rx, cy - ry // 3 - eye_ry,
         cx - rx // 2 + eye_rx, cy - ry // 3 + eye_ry),
        fill=(255, 255, 255),
    )
    draw.ellipse(
        (cx + rx // 2 - eye_rx, cy - ry // 3 - eye_ry,
         cx + rx // 2 + eye_rx, cy - ry // 3 + eye_ry),
        fill=(255, 255, 255),
    )
    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


def _make_portrait_png(width: int, height: int, seed: int = 42) -> bytes:
    import random

    rng = random.Random(seed)
    img = Image.new("RGB", (width, height))
    pixels = img.load()

    for y in range(height):
        t = y / height
        r = int(30 + 25 * t + rng.randint(-5, 5))
        g = int(20 + 20 * t + rng.randint(-5, 5))
        b = int(18 + 22 * t + rng.randint(-5, 5))
        for x in range(width):
            pixels[x, y] = (
                max(0, min(255, r + rng.randint(-3, 3))),
                max(0, min(255, g + rng.randint(-3, 3))),
                max(0, min(255, b + rng.randint(-3, 3))),
            )

    cx, cy = width // 2, height // 2
    face_rx = int(width * 0.22)
    face_ry = int(height * 0.32)
    skin_base = (
        215 + rng.randint(-20, 20),
        175 + rng.randint(-30, 30),
        145 + rng.randint(-30, 30),
    )
    for y in range(max(0, cy - face_ry), min(height, cy + face_ry)):
        for x in range(max(0, cx - face_rx), min(width, cx + face_rx)):
            dx = (x - cx) / face_rx
            dy = (y - cy) / face_ry
            if dx * dx + dy * dy <= 1.0:
                r = max(0, min(255, skin_base[0] + rng.randint(-8, 8)))
                g = max(0, min(255, skin_base[1] + rng.randint(-8, 8)))
                b = max(0, min(255, skin_base[2] + rng.randint(-8, 8)))
                pixels[x, y] = (r, g, b)

    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    return buffer.getvalue()


def test_reduces_large_portrait_below_hard_limit():
    data = _make_portrait_png(1024, 1024, seed=1)
    result, mime = optimize_portrait(data, "image/png")

    assert mime == "image/webp"
    assert len(result) <= _PORTRAIT_HARD_BYTES
    with Image.open(io.BytesIO(result)) as img:
        assert max(img.size) <= _PORTRAIT_MAX_DIM


def test_handles_varied_portrait_sizes():
    configs = [
        (1024, 1024, 1),
        (1024, 1024, 2),
        (1024, 1024, 3),
        (1024, 1024, 4),
        (512, 768, 5),
        (768, 512, 6),
        (800, 800, 7),
        (1200, 1200, 8),
        (640, 960, 9),
        (1536, 1024, 10),
    ]
    for width, height, seed in configs:
        data = _make_portrait_png(width, height, seed=seed)
        result, mime = optimize_portrait(data, "image/png")

        assert mime == "image/webp", f"seed={seed}: expected webp, got {mime}"
        assert len(result) <= _PORTRAIT_HARD_BYTES, (
            f"seed={seed}: {len(result)} bytes exceeds {_PORTRAIT_HARD_BYTES}"
        )
        with Image.open(io.BytesIO(result)) as img:
            assert max(img.size) <= _PORTRAIT_MAX_DIM, (
                f"seed={seed}: max dim {max(img.size)} exceeds {_PORTRAIT_MAX_DIM}"
            )


def test_passes_through_small_images():
    data = _make_test_png(200, 200)
    result, mime = optimize_portrait(data, "image/png")

    assert mime == "image/webp"
    assert len(result) <= _PORTRAIT_HARD_BYTES
    with Image.open(io.BytesIO(result)) as img:
        assert max(img.size) <= 200


def test_preserves_non_optimizable_mime():
    data = b"not-an-image"
    result, mime = optimize_portrait(data, "image/svg+xml")

    assert mime == "image/svg+xml"
    assert result == data


def test_handles_invalid_image_data():
    with pytest.raises(Exception) as exc_info:
        optimize_portrait(b"not valid image bytes", "image/png")
    assert hasattr(exc_info.value, "status_code")
    assert exc_info.value.status_code == 422


def test_compresses_with_acceptable_quality():
    data = _make_portrait_png(1024, 1024, seed=99)
    result, mime = optimize_portrait(data, "image/png")

    assert mime == "image/webp"
    assert len(result) > 1000, "compressed portrait is suspiciously small"
    assert len(result) <= _PORTRAIT_HARD_BYTES


def test_handles_empty_mime():
    data = b"raw-bytes"
    result, mime = optimize_portrait(data, "")

    assert mime == ""
    assert result == data


def test_handles_jpeg_input():
    img = Image.new("RGB", (800, 800), color=(100, 80, 60))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=95)
    data = buf.getvalue()

    result, mime = optimize_portrait(data, "image/jpeg")
    assert mime == "image/webp"
    assert len(result) <= _PORTRAIT_HARD_BYTES


def test_handles_webp_input():
    img = Image.new("RGB", (1024, 1024), color=(80, 60, 40))
    buf = io.BytesIO()
    img.save(buf, format="WEBP", quality=95)
    data = buf.getvalue()

    result, mime = optimize_portrait(data, "image/webp")
    assert mime == "image/webp"
    assert len(result) <= _PORTRAIT_HARD_BYTES
