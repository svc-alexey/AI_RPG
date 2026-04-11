from dataclasses import dataclass
from email.message import EmailMessage
from email.utils import formatdate
from mimetypes import guess_type
import smtplib
from typing import Sequence

from app.core.config import Settings


@dataclass(slots=True)
class FeedbackAttachment:
    filename: str
    content_type: str
    data: bytes


@dataclass(slots=True)
class FeedbackSubmission:
    message: str
    language: str
    name: str = ""
    contact: str = ""
    page_url: str = ""
    user_agent: str = ""


def is_feedback_email_configured(settings: Settings) -> bool:
    return bool(
        settings.feedback_smtp_host.strip()
        and settings.feedback_sender_email.strip()
        and settings.feedback_recipient_email.strip()
    )


def _build_feedback_message(
    settings: Settings,
    submission: FeedbackSubmission,
    attachments: Sequence[FeedbackAttachment],
) -> EmailMessage:
    message = EmailMessage()
    sender_email = settings.feedback_sender_email.strip()
    recipient_email = settings.feedback_recipient_email.strip()
    author_name = submission.name.strip() or "Website visitor"

    message["Subject"] = (
        f"{settings.feedback_email_subject_prefix.strip()} | {author_name}"
    )
    message["From"] = sender_email
    message["To"] = recipient_email
    message["Date"] = formatdate(localtime=True)
    if "@" in submission.contact:
        message["Reply-To"] = submission.contact.strip()

    body_lines = [
        f"Name: {submission.name.strip() or '-'}",
        f"Contact: {submission.contact.strip() or '-'}",
        f"Language: {submission.language.strip() or '-'}",
        f"Page: {submission.page_url.strip() or '-'}",
        f"User-Agent: {submission.user_agent.strip() or '-'}",
        "",
        "Message:",
        submission.message.strip(),
    ]
    message.set_content("\n".join(body_lines))

    for attachment in attachments:
        content_type = attachment.content_type.strip()
        if not content_type or "/" not in content_type:
            content_type = guess_type(attachment.filename)[0] or "application/octet-stream"
        maintype, subtype = content_type.split("/", 1)
        message.add_attachment(
            attachment.data,
            maintype=maintype,
            subtype=subtype,
            filename=attachment.filename,
        )

    return message


def send_feedback_email(
    settings: Settings,
    submission: FeedbackSubmission,
    attachments: Sequence[FeedbackAttachment],
) -> None:
    if not is_feedback_email_configured(settings):
        raise RuntimeError("feedback_email_not_configured")

    email_message = _build_feedback_message(settings, submission, attachments)

    if settings.feedback_smtp_use_ssl:
        with smtplib.SMTP_SSL(
            settings.feedback_smtp_host,
            settings.feedback_smtp_port,
            timeout=settings.feedback_smtp_timeout_seconds,
        ) as smtp:
            if settings.feedback_smtp_username.strip():
                smtp.login(
                    settings.feedback_smtp_username,
                    settings.feedback_smtp_password,
                )
            smtp.send_message(email_message)
        return

    with smtplib.SMTP(
        settings.feedback_smtp_host,
        settings.feedback_smtp_port,
        timeout=settings.feedback_smtp_timeout_seconds,
    ) as smtp:
        if settings.feedback_smtp_use_starttls:
            smtp.starttls()
        if settings.feedback_smtp_username.strip():
            smtp.login(
                settings.feedback_smtp_username,
                settings.feedback_smtp_password,
            )
        smtp.send_message(email_message)
