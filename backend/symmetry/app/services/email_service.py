import smtplib
from email.message import EmailMessage
from email.utils import formatdate

from app.core.config import Settings


def _is_russian(headers_accept_language: str) -> bool:
    """True if Accept-Language indicates Russian as primary language."""
    if not headers_accept_language:
        return True  # default to Russian (project primary language)
    first = headers_accept_language.split(",")[0].strip().lower()
    return first.startswith("ru")


_LOCALIZED = {
    True: {  # Russian
        "from_name": "Стирая Грань",
        "subject": "Стирая Грань — Подтвердите email",
        "text_body": "Перейдите по ссылке, чтобы подтвердить email:\n{url}",
        "html_title": "Подтвердите email, чтобы продолжить.",
        "html_button": "Подтвердить",
        "html_expiry": "Ссылка действительна 24 часа.",
    },
    False: {  # English
        "from_name": "Beyond The Verge",
        "subject": "Beyond The Verge — Confirm your email",
        "text_body": "Click the link to verify your email:\n{url}",
        "html_title": "Verify your email to continue.",
        "html_button": "Verify",
        "html_expiry": "Link expires in 24 hours.",
    },
}


def send_verification_email(
    settings: Settings,
    *,
    to_email: str,
    verification_url: str,
    accept_language: str = "",
) -> None:
    smtp_host = settings.feedback_smtp_host.strip()
    if not smtp_host:
        raise RuntimeError("auth_email_smtp_not_configured: feedback_smtp_host is empty")

    sender = (settings.auth_email_sender_email or settings.feedback_sender_email).strip()
    if not sender:
        raise RuntimeError("auth_email_sender_not_configured")

    lang = _LOCALIZED[_is_russian(accept_language)]
    from_name = lang["from_name"]

    msg = EmailMessage()
    msg["Subject"] = lang["subject"]
    msg["From"] = f"{from_name} <{sender}>"
    msg["To"] = to_email
    msg["Date"] = formatdate(localtime=True)

    msg.set_content(lang["text_body"].format(url=verification_url))

    msg.add_alternative(_build_html_body(verification_url, lang), subtype="html")

    if settings.feedback_smtp_use_ssl:
        with smtplib.SMTP_SSL(smtp_host, settings.feedback_smtp_port, timeout=20) as smtp:
            if settings.feedback_smtp_username.strip():
                smtp.login(settings.feedback_smtp_username, settings.feedback_smtp_password)
            smtp.send_message(msg)
    else:
        with smtplib.SMTP(smtp_host, settings.feedback_smtp_port, timeout=20) as smtp:
            if settings.feedback_smtp_use_starttls:
                smtp.starttls()
            if settings.feedback_smtp_username.strip():
                smtp.login(settings.feedback_smtp_username, settings.feedback_smtp_password)
            smtp.send_message(msg)


_RESET_LOCALIZED = {
    True: {  # Russian
        "from_name": "Стирая Грань",
        "subject": "Стирая Грань — Сброс пароля",
        "text_body": "Перейдите по ссылке, чтобы задать новый пароль:\n{url}",
        "html_title": "Сбросьте пароль, чтобы продолжить.",
        "html_button": "Сбросить пароль",
        "html_expiry": "Ссылка действительна 15 минут.",
    },
    False: {  # English
        "from_name": "Beyond The Verge",
        "subject": "Beyond The Verge — Password Reset",
        "text_body": "Click the link to set a new password:\n{url}",
        "html_title": "Reset your password to continue.",
        "html_button": "Reset password",
        "html_expiry": "Link expires in 15 minutes.",
    },
}


def send_password_reset_email(
    settings: Settings,
    *,
    to_email: str,
    reset_url: str,
    accept_language: str = "",
) -> None:
    smtp_host = settings.feedback_smtp_host.strip()
    if not smtp_host:
        raise RuntimeError("auth_email_smtp_not_configured: feedback_smtp_host is empty")

    sender = (settings.auth_email_sender_email or settings.feedback_sender_email).strip()
    if not sender:
        raise RuntimeError("auth_email_sender_not_configured")

    lang = _RESET_LOCALIZED[_is_russian(accept_language)]
    from_name = lang["from_name"]

    msg = EmailMessage()
    msg["Subject"] = lang["subject"]
    msg["From"] = f"{from_name} <{sender}>"
    msg["To"] = to_email
    msg["Date"] = formatdate(localtime=True)

    msg.set_content(lang["text_body"].format(url=reset_url))
    msg.add_alternative(_build_html_body(reset_url, lang), subtype="html")

    if settings.feedback_smtp_use_ssl:
        with smtplib.SMTP_SSL(smtp_host, settings.feedback_smtp_port, timeout=20) as smtp:
            if settings.feedback_smtp_username.strip():
                smtp.login(settings.feedback_smtp_username, settings.feedback_smtp_password)
            smtp.send_message(msg)
    else:
        with smtplib.SMTP(smtp_host, settings.feedback_smtp_port, timeout=20) as smtp:
            if settings.feedback_smtp_use_starttls:
                smtp.starttls()
            if settings.feedback_smtp_username.strip():
                smtp.login(settings.feedback_smtp_username, settings.feedback_smtp_password)
            smtp.send_message(msg)


def _build_html_body(verification_url: str, lang: dict[str, str]) -> str:
    return f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600&family=Playfair+Display:wght@400;700&display=swap');
  body {{
    margin: 0; padding: 0;
    background-color: #0A0908;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
  }}
  .card {{
    max-width: 480px; margin: 32px auto;
    background-color: #0F0D0B;
    border-radius: 16px;
    border: 1px solid rgba(61,51,40,0.3);
    padding: 40px 32px;
  }}
  .brand {{
    font-family: 'Playfair Display', Georgia, 'Times New Roman', serif;
    font-size: 24px; font-weight: 700;
    color: #BFA76F;
    text-align: center;
    margin-bottom: 8px;
  }}
  .subtitle {{
    font-size: 16px; font-weight: 400;
    color: #E8E4E0;
    text-align: center;
    margin-bottom: 32px;
    line-height: 1.5;
  }}
  .button {{
    display: block; width: 240px; margin: 0 auto;
    padding: 14px 24px;
    background-color: #C87941;
    color: #FFFFFF;
    text-decoration: none;
    text-align: center;
    border-radius: 12px;
    font-size: 16px; font-weight: 600;
    font-family: 'Inter', Arial, sans-serif;
  }}
  .button:hover {{
    background-color: #D48951;
  }}
  .divider {{
    border: none; border-top: 1px solid rgba(61,51,40,0.3);
    margin: 32px 0 24px;
  }}
  .footer {{
    font-size: 12px; color: #7A7570;
    text-align: center;
    line-height: 1.6;
  }}
  .footer a {{
    color: #BFA76F;
    text-decoration: none;
  }}
</style>
</head>
<body>
<div class="card">
  <div class="brand">{lang["from_name"]}</div>
  <div class="subtitle">{lang["html_title"]}</div>
  <a href="{verification_url}" class="button">{lang["html_button"]}</a>
  <hr class="divider"/>
  <div class="footer">
    {lang["html_expiry"]}
    <br/><br/>
    <a href="{verification_url}">{verification_url}</a>
  </div>
</div>
</body>
</html>"""
