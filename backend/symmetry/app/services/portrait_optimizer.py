from __future__ import annotations

from io import BytesIO

from PIL import Image, ImageOps

_TARGET_MAX_BYTES = 120 * 1024
_HARD_MAX_BYTES = 200 * 1024
_DIMENSION_STEPS = (512, 448, 384, 320)
_QUALITY_STEPS = (75, 70, 65, 60)


def optimize_portrait(image_bytes: bytes) -> tuple[bytes, int, int]:
    with Image.open(BytesIO(image_bytes)) as opened:
        base = ImageOps.exif_transpose(opened)
        source = base.copy()

    for max_dimension in _DIMENSION_STEPS:
        candidate = source.copy()
        if max(candidate.size) > max_dimension:
            candidate.thumbnail(
                (max_dimension, max_dimension),
                Image.Resampling.LANCZOS,
            )
        encoded = _encode_portrait(candidate)
        if len(encoded) <= _TARGET_MAX_BYTES:
            return encoded, candidate.size[0], candidate.size[1]

    fallback = _encode_portrait(source.copy(), quality=_QUALITY_STEPS[-1])
    with Image.open(BytesIO(fallback)) as img:
        return fallback, img.size[0], img.size[1]


def _encode_portrait(image: Image.Image, *, quality: int | None = None) -> bytes:
    prepared = image.convert("RGB")
    for current_quality in ((quality,) if quality is not None else _QUALITY_STEPS):
        buffer = BytesIO()
        prepared.save(buffer, format="WEBP", quality=current_quality, method=6)
        encoded = buffer.getvalue()
        if len(encoded) <= _HARD_MAX_BYTES:
            return encoded
    return encoded
