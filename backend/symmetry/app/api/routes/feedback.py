import asyncio
import smtplib
from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, Request, UploadFile, status
from pydantic import BaseModel

from app.core.config import get_settings
from app.core.logging import get_logger
from app.services.feedback import (
    FeedbackAttachment,
    FeedbackSubmission,
    is_feedback_email_configured,
    send_feedback_email,
)


router = APIRouter(tags=["feedback"])
settings = get_settings()
logger = get_logger("symmetry.feedback")


class FeedbackResponse(BaseModel):
    status: str
    attachments_count: int


@router.post("/feedback", response_model=FeedbackResponse)
async def submit_feedback(
    request: Request,
    message: Annotated[str, Form(...)],
    language: Annotated[str, Form()] = "ru",
    name: Annotated[str, Form()] = "",
    contact: Annotated[str, Form()] = "",
    page_url: Annotated[str, Form()] = "",
    files: list[UploadFile] = File(default=[]),
) -> FeedbackResponse:
    normalized_message = message.strip()
    if not normalized_message:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="feedback_message_required",
        )

    if not is_feedback_email_configured(settings):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="feedback_email_not_configured",
        )

    if len(files) > settings.feedback_max_attachments:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="feedback_too_many_attachments",
        )

    attachments: list[FeedbackAttachment] = []
    total_size = 0
    for upload in files:
        filename = (upload.filename or "attachment").strip() or "attachment"
        payload = await upload.read()
        total_size += len(payload)
        if len(payload) > settings.feedback_max_attachment_bytes:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail="feedback_attachment_too_large",
            )
        if total_size > settings.feedback_max_total_attachment_bytes:
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail="feedback_attachments_total_too_large",
            )
        attachments.append(
            FeedbackAttachment(
                filename=filename,
                content_type=upload.content_type or "application/octet-stream",
                data=payload,
            )
        )

    submission = FeedbackSubmission(
        name=name.strip(),
        contact=contact.strip(),
        message=normalized_message,
        language=language.strip() or "ru",
        page_url=page_url.strip(),
        user_agent=request.headers.get("user-agent", "").strip(),
    )

    try:
        await asyncio.to_thread(send_feedback_email, settings, submission, attachments)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc
    except smtplib.SMTPException as exc:
        logger.exception("feedback_email_send_failed smtp_error")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="feedback_email_send_failed",
        ) from exc
    except OSError as exc:
        logger.exception("feedback_email_send_failed network_error")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="feedback_email_send_failed",
        ) from exc

    logger.info(
        "feedback_submitted language=%s attachments=%s",
        submission.language,
        len(attachments),
    )
    return FeedbackResponse(
        status="accepted",
        attachments_count=len(attachments),
    )
