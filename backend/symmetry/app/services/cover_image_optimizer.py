from io import BytesIO

from fastapi import HTTPException, status
from PIL import Image, ImageOps, UnidentifiedImageError

_TARGET_MAX_BYTES = 600 * 1024
_HARD_MAX_BYTES = 2 * 1024 * 1024
_DIMENSION_STEPS = (1280, 1120, 960, 800, 640)
_QUALITY_STEPS = (82, 74, 66, 58, 50)
_OPTIMIZABLE_MIME = frozenset({"image/jpeg", "image/png", "image/webp"})


def optimize_story_cover(data: bytes, mime: str) -> tuple[bytes, str]:
    normalized_mime = (mime or "").strip().lower()
    if normalized_mime not in _OPTIMIZABLE_MIME:
        return data, normalized_mime
    try:
        with Image.open(BytesIO(data)) as opened:
            base = ImageOps.exif_transpose(opened)
            source = base.copy()
    except (UnidentifiedImageError, OSError) as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="invalid_cover_image",
        ) from exc

    for max_dimension in _DIMENSION_STEPS:
        candidate = source.copy()
        if max(candidate.size) > max_dimension:
            candidate.thumbnail(
                (max_dimension, max_dimension),
                Image.Resampling.LANCZOS,
            )
        encoded = _encode_candidate(candidate)
        if len(encoded) <= _TARGET_MAX_BYTES:
            return encoded, "image/webp"
        if len(encoded) <= _HARD_MAX_BYTES and max_dimension == _DIMENSION_STEPS[-1]:
            return encoded, "image/webp"

    fallback = _encode_candidate(source.copy(), quality=_QUALITY_STEPS[-1])
    return fallback, "image/webp"


def _encode_candidate(image: Image.Image, *, quality: int | None = None) -> bytes:
    prepared = image.convert("RGBA") if _has_alpha(image) else image.convert("RGB")
    for current_quality in ((quality,) if quality is not None else _QUALITY_STEPS):
        buffer = BytesIO()
        prepared.save(
            buffer,
            format="WEBP",
            quality=current_quality,
            method=6,
        )
        encoded = buffer.getvalue()
        if len(encoded) <= _TARGET_MAX_BYTES or current_quality == _QUALITY_STEPS[-1]:
            return encoded
    raise RuntimeError("cover_encode_failed")


def _has_alpha(image: Image.Image) -> bool:
    if image.mode in ("RGBA", "LA"):
        return True
    if image.mode != "P":
        return False
    return "transparency" in image.info
