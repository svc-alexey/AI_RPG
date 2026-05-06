import smtplib
from email.message import EmailMessage
from email.utils import formatdate

from app.core.config import Settings


def send_verification_email(
    settings: Settings,
    *,
    to_email: str,
    verification_url: str,
) -> None:
    smtp_host = settings.feedback_smtp_host.strip()
    if not smtp_host:
        raise RuntimeError("auth_email_smtp_not_configured: feedback_smtp_host is empty")

    sender = (settings.auth_email_sender_email or settings.feedback_sender_email).strip()
    if not sender:
        raise RuntimeError("auth_email_sender_not_configured")

    from_name = settings.auth_email_from_name.strip() or "Symmetry"

    msg = EmailMessage()
    msg["Subject"] = f"{from_name} — Confirm your email / Подтвердите email"
    msg["From"] = f"{from_name} <{sender}>"
    msg["To"] = to_email
    msg["Date"] = formatdate(localtime=True)

    msg.set_content(
        f"Click the link to verify your email:\n{verification_url}\n\n"
        f"Перейдите по ссылке, чтобы подтвердить email:\n{verification_url}"
    )

    msg.add_alternative(_build_html_body(verification_url, from_name), subtype="html")

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


def _build_html_body(verification_url: str, from_name: str) -> str:
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
  <div class="brand">{from_name}</div>
  <div class="subtitle">
    Подтвердите email, чтобы продолжить.<br/>
    Verify your email to continue.
  </div>
  <a href="{verification_url}" class="button">
    Подтвердить &nbsp;/&nbsp; Verify
  </a>
  <hr class="divider"/>
  <div class="footer">
    Ссылка действительна 24 часа.<br/>
    Link expires in 24 hours.
    <br/><br/>
    <a href="{verification_url}">{verification_url}</a>
  </div>
</div>
</body>
</html>"""
