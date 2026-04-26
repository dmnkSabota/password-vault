from django.db import models
from django.conf import settings

from apps.vault.encryption import encrypt, decrypt


class Category(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='categories',
    )
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'name')
        ordering = ['name']

    def __str__(self):
        return f'{self.user.username} / {self.name}'


class Credential(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='credentials',
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='credentials',
    )
    title = models.CharField(max_length=200)
    _username = models.TextField(blank=True, db_column='username')
    _password = models.TextField(blank=True, db_column='password')
    _url = models.TextField(blank=True, db_column='url')
    _notes = models.TextField(blank=True, db_column='notes')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['title']

    def __str__(self):
        return f'{self.user.username} / {self.title}'

    # --- username ---
    @property
    def username(self) -> str:
        try:
            return decrypt(self._username)
        except Exception:
            raise ValueError(f"Failed to decrypt username for credential '{self.title}'")

    @username.setter
    def username(self, value: str):
        self._username = encrypt(value) if value else ''

    # --- password ---
    @property
    def password(self) -> str:
        try:
            return decrypt(self._password)
        except Exception:
            raise ValueError(f"Failed to decrypt password for credential '{self.title}'")

    @password.setter
    def password(self, value: str):
        self._password = encrypt(value) if value else ''

    # --- url ---
    @property
    def url(self) -> str:
        try:
            return decrypt(self._url)
        except Exception:
            raise ValueError(f"Failed to decrypt url for credential '{self.title}'")

    @url.setter
    def url(self, value: str):
        self._url = encrypt(value) if value else ''

    # --- notes ---
    @property
    def notes(self) -> str:
        try:
            return decrypt(self._notes)
        except Exception:
            raise ValueError(f"Failed to decrypt notes for credential '{self.title}'")

    @notes.setter
    def notes(self, value: str):
        self._notes = encrypt(value) if value else ''
