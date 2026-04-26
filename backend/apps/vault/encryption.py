import base64
import os

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from django.conf import settings


def _get_key() -> bytes:
    raw = settings.AES_ENCRYPTION_KEY
    return base64.b64decode(raw)


def encrypt(plaintext: str) -> str:
    """Encrypt plaintext using AES-256-GCM.

    Returns base64(nonce + ciphertext + tag).
    """
    if not plaintext:
        return plaintext

    key = _get_key()
    nonce = os.urandom(12)
    aesgcm = AESGCM(key)
    ciphertext_with_tag = aesgcm.encrypt(nonce, plaintext.encode('utf-8'), None)
    return base64.b64encode(nonce + ciphertext_with_tag).decode('utf-8')


def decrypt(ciphertext_b64: str) -> str:
    """Decrypt a base64(nonce + ciphertext + tag) string produced by encrypt()."""
    if not ciphertext_b64:
        return ciphertext_b64

    key = _get_key()
    raw = base64.b64decode(ciphertext_b64)
    # Minimum: 12-byte nonce + 16-byte GCM tag = 28 bytes
    if len(raw) < 28:
        raise ValueError("Ciphertext too short to be a valid AES-256-GCM payload.")
    nonce = raw[:12]
    ciphertext_with_tag = raw[12:]
    aesgcm = AESGCM(key)
    plaintext = aesgcm.decrypt(nonce, ciphertext_with_tag, None)
    return plaintext.decode('utf-8')
