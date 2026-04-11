from app.core.config import Settings
from app.services.feedback import (
    FeedbackAttachment,
    FeedbackSubmission,
    is_feedback_email_configured,
    send_feedback_email,
)


class _DummySMTP:
    def __init__(self, *args, **kwargs):
        self.login_args = None
        self.sent_message = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False

    def login(self, username, password):
        self.login_args = (username, password)

    def send_message(self, message):
        self.sent_message = message


def test_feedback_email_configuration_detected(tmp_path):
    env_file = tmp_path / ".env"
    env_file.write_text(
        "\n".join(
            [
                "SYMMETRY_FEEDBACK_SMTP_HOST=smtp.example.com",
                "SYMMETRY_FEEDBACK_SENDER_EMAIL=bot@example.com",
                "SYMMETRY_FEEDBACK_RECIPIENT_EMAIL=owner@example.com",
            ]
        ),
        encoding="utf-8",
    )

    settings = Settings(_env_file=env_file)

    assert is_feedback_email_configured(settings) is True


def test_send_feedback_email_uses_ssl_and_attaches_files(monkeypatch, tmp_path):
    env_file = tmp_path / ".env"
    env_file.write_text(
        "\n".join(
            [
                "SYMMETRY_FEEDBACK_SMTP_HOST=smtp.example.com",
                "SYMMETRY_FEEDBACK_SMTP_PORT=465",
                "SYMMETRY_FEEDBACK_SMTP_USERNAME=bot@example.com",
                "SYMMETRY_FEEDBACK_SMTP_PASSWORD=secret",
                "SYMMETRY_FEEDBACK_SENDER_EMAIL=bot@example.com",
                "SYMMETRY_FEEDBACK_RECIPIENT_EMAIL=owner@example.com",
                "SYMMETRY_FEEDBACK_SMTP_USE_SSL=true",
            ]
        ),
        encoding="utf-8",
    )
    settings = Settings(_env_file=env_file)
    smtp_instances: list[_DummySMTP] = []

    def _smtp_ssl(*args, **kwargs):
        instance = _DummySMTP(*args, **kwargs)
        smtp_instances.append(instance)
        return instance

    monkeypatch.setattr("app.services.feedback.smtplib.SMTP_SSL", _smtp_ssl)

    send_feedback_email(
        settings,
        FeedbackSubmission(
            name="Alexey",
            contact="alexey@example.com",
            message="Ship this feature.",
            language="ru",
            page_url="https://example.com/?view=feedback",
            user_agent="pytest",
        ),
        [
            FeedbackAttachment(
                filename="idea.txt",
                content_type="text/plain",
                data=b"hello",
            )
        ],
    )

    smtp = smtp_instances[0]
    assert smtp.login_args == ("bot@example.com", "secret")
    assert smtp.sent_message["To"] == "owner@example.com"
    assert smtp.sent_message["Reply-To"] == "alexey@example.com"
    assert "Ship this feature." in smtp.sent_message.get_body().get_content()
    attachments = list(smtp.sent_message.iter_attachments())
    assert len(attachments) == 1
    assert attachments[0].get_filename() == "idea.txt"


def test_send_feedback_email_requires_configuration(tmp_path):
    env_file = tmp_path / ".env"
    env_file.write_text("", encoding="utf-8")
    settings = Settings(_env_file=env_file)

    try:
        send_feedback_email(
            settings,
            FeedbackSubmission(message="Hi", language="ru"),
            [],
        )
    except RuntimeError as exc:
        assert str(exc) == "feedback_email_not_configured"
    else:
        raise AssertionError("Expected RuntimeError for missing SMTP configuration")
