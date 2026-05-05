from cryptography.fernet import Fernet

from app.core.config import get_settings


def _get_fernet() -> Fernet:
    key = get_settings().billing_encryption_key
    if not key:
        raise RuntimeError("BILLING_ENCRYPTION_KEY not set")
    return Fernet(key.encode() if isinstance(key, str) else key)


def encrypt_payment_method_id(payment_method_id: str) -> str:
    f = _get_fernet()
    return f.encrypt(payment_method_id.encode()).decode()


def decrypt_payment_method_id(encrypted: str) -> str:
    f = _get_fernet()
    return f.decrypt(encrypted.encode()).decode()
