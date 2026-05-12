from io import BytesIO

from fastapi import HTTPException, status
from PIL import Image, ImageFile, ImageOps, UnidentifiedImageError

ImageFile.LOAD_TRUNCATED_IMAGES = True

_PORTRAIT_TARGET_BYTES = 120 * 1024
_PORTRAIT_HARD_BYTES = 200 * 1024
_PORTRAIT_MAX_DIM = 512
_PORTRAIT_QUALITY_STEPS = (92, 85, 78, 75)
_OPTIMIZABLE_MIME = frozenset({"image/jpeg", "image/png", "image/webp"})


def optimize_portrait(data: bytes, mime: str) -> tuple[bytes, str]:
    normalized_mime = (mime or "").strip().lower()
    if normalized_mime not in _OPTIMIZABLE_MIME:
        return data, normalized_mime
    try:
        with Image.open(BytesIO(data)) as opened:
            base = ImageOps.exif_transpose(opened)
            source = base.copy()
    except UnidentifiedImageError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="invalid_portrait_image",
        ) from exc

    for max_dim in (_PORTRAIT_MAX_DIM,):
        candidate = source.copy()
        if max(candidate.size) > max_dim:
            candidate.thumbnail(
                (max_dim, max_dim),
                Image.Resampling.LANCZOS,
            )
        encoded = _encode_candidate(candidate)
        if len(encoded) <= _PORTRAIT_TARGET_BYTES:
            return encoded, "image/webp"
        if len(encoded) <= _PORTRAIT_HARD_BYTES:
            return encoded, "image/webp"

    fallback = _encode_candidate(source.copy(), quality=_PORTRAIT_QUALITY_STEPS[-1])
    return fallback, "image/webp"


def _encode_candidate(image: Image.Image, *, quality: int | None = None) -> bytes:
    prepared = image.convert("RGBA") if _has_alpha(image) else image.convert("RGB")
    for current_quality in ((quality,) if quality is not None else _PORTRAIT_QUALITY_STEPS):
        buffer = BytesIO()
        prepared.save(
            buffer,
            format="WEBP",
            quality=current_quality,
            method=6,
        )
        encoded = buffer.getvalue()
        if len(encoded) <= _PORTRAIT_TARGET_BYTES or current_quality == _PORTRAIT_QUALITY_STEPS[-1]:
            return encoded
    raise RuntimeError("portrait_encode_failed")


def _has_alpha(image: Image.Image) -> bool:
    if image.mode in ("RGBA", "LA"):
        return True
    if image.mode != "P":
        return False
    return "transparency" in image.info
