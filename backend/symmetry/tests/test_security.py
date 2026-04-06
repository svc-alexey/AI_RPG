from app.core.security import create_refresh_token, hash_password, hash_refresh_token, verify_password


def test_password_hashing_round_trip():
    password_hash = hash_password("super-secret-password")
    assert verify_password("super-secret-password", password_hash)
    assert not verify_password("wrong-password", password_hash)


def test_refresh_token_hash_is_stable():
    raw_token, token_hash = create_refresh_token()
    assert token_hash == hash_refresh_token(raw_token)
