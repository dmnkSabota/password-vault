# Password Vault

A full-stack mobile application for secure credential management. Built with Flutter for Android and a Django REST backend. Credentials are encrypted at rest using AES-256-GCM before being written to the database — the database alone reveals nothing without the encryption key.

## Architecture

```
┌──────────────────────┐       HTTP/JSON        ┌───────────────────────┐
│  Flutter Android App  │ ─────────────────────► │  Django REST API      │
│  Riverpod · go_router │ ◄───────────────────── │  DRF · SimpleJWT      │
│  Dio · local_auth     │                        └──────────┬────────────┘
└──────────────────────┘                                    │
                                                   ┌────────▼────────┐
                                                   │   PostgreSQL    │
                                                   │  (AES-256-GCM   │
                                                   │   encrypted)    │
                                                   └─────────────────┘
```

## Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Mobile UI | Flutter (Android) | >= 3.10.0 |
| State management | flutter_riverpod | ^3.3.1 |
| Navigation | go_router | ^17.2.2 |
| HTTP client | Dio | ^5.4.0 |
| Token storage | flutter_secure_storage (Android Keystore) | ^10.0.0 |
| Biometrics | local_auth | ^3.0.1 |
| Fonts | google_fonts | ^8.0.2 |
| Backend framework | Django + Django REST Framework | 4.2 / 3.14 |
| Authentication | djangorestframework-simplejwt | 5.3.1 |
| Encryption | Python cryptography (AES-256-GCM) | 42.0.8 |
| Database | PostgreSQL | >= 14 |
| Rate limiting | django-ratelimit | 4.1.0 |
| CORS | django-cors-headers | 4.3.1 |
| Config management | python-decouple | 3.8 |

## Project Structure

```
password-vault/
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── .env.example
│   ├── config/
│   │   ├── settings.py          # Django settings, JWT config, CORS
│   │   ├── urls.py              # Root URL dispatcher
│   │   └── wsgi.py
│   └── apps/
│       ├── authentication/      # Register, login, logout, token refresh
│       ├── vault/               # Category and Credential CRUD, AES-256-GCM encryption
│       └── users/               # Profile retrieval, password change, account deletion
└── mobile/
    ├── pubspec.yaml
    ├── .env                     # API base URL, timeouts
    └── lib/
        ├── main.dart
        ├── core/
        │   ├── network/         # ApiClient (Dio), AuthInterceptor (JWT injection + refresh)
        │   ├── router/          # go_router with auth and lock guards
        │   ├── biometrics/      # BiometricService wrapper around local_auth
        │   └── theme/           # Material 3, dark and light themes, AppColors context extension
        └── features/
            ├── auth/            # Login, Register, Lock screens + AuthNotifier
            ├── vault/           # Vault list, Credential detail, Credential form
            ├── generator/       # Password generator screen
            └── settings/        # Theme toggle, biometric toggle, account management
```

## API Reference

All authenticated endpoints require the `Authorization: Bearer <access_token>` header.

### Authentication

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register/` | No | Create a new user account |
| POST | `/api/auth/login/` | No | Authenticate and receive JWT token pair |
| POST | `/api/auth/logout/` | Yes | Blacklist the provided refresh token |
| POST | `/api/auth/token/refresh/` | No | Exchange refresh token for new access token |
| POST | `/api/auth/change-password/` | Yes | Change the authenticated user's password |

### Users

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/users/profile/` | Yes | Retrieve authenticated user's profile |
| DELETE | `/api/users/delete/` | Yes | Permanently delete the user account and all associated data |

### Vault

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| GET | `/api/vault/categories/` | Yes | List all categories for the authenticated user |
| POST | `/api/vault/categories/` | Yes | Create a category |
| PUT | `/api/vault/categories/{id}/` | Yes | Rename a category |
| DELETE | `/api/vault/categories/{id}/` | Yes | Delete a category |
| GET | `/api/vault/credentials/` | Yes | List credentials. Supports `?category=<id>` and `?q=<search>` |
| POST | `/api/vault/credentials/` | Yes | Create a credential |
| GET | `/api/vault/credentials/{id}/` | Yes | Retrieve a single credential |
| PUT | `/api/vault/credentials/{id}/` | Yes | Update a credential |
| DELETE | `/api/vault/credentials/{id}/` | Yes | Delete a credential |

### Request and Response Examples

**Register**
```
POST /api/auth/register/
{
  "username": "john",
  "email": "john@example.com",
  "password": "securepass123",
  "password2": "securepass123"
}
```

**Login**
```
POST /api/auth/login/
{
  "username": "john",
  "password": "securepass123"
}

Response 200:
{
  "access": "<jwt_access_token>",
  "refresh": "<jwt_refresh_token>"
}
```

**Create Credential**
```
POST /api/vault/credentials/
Authorization: Bearer <access_token>
{
  "title": "GitHub",
  "username": "john",
  "password": "mysecretpassword",
  "url": "https://github.com",
  "notes": "Work account",
  "category": 1
}
```

## Setup

### Prerequisites

- Python >= 3.11
- PostgreSQL >= 14
- Flutter SDK >= 3.10.0
- Android Studio with an Android emulator (API 34+) or a physical Android device

### Backend

**1. Install dependencies**
```bash
cd backend
pip install -r requirements.txt
```

**2. Configure environment**
```bash
cp .env.example .env
```

Edit `.env` with your values:
```
SECRET_KEY=<generate a long random string>
DB_NAME=password_vault
DB_USER=postgres
DB_PASSWORD=<your postgres password>
DB_HOST=localhost
DB_PORT=5432
AES_ENCRYPTION_KEY=<generate with command below>
JWT_ACCESS_TOKEN_LIFETIME_MINUTES=60
JWT_REFRESH_TOKEN_LIFETIME_DAYS=7
ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://10.0.2.2:8000
```

Generate an AES-256 key:
```bash
python -c "import os, base64; print(base64.b64encode(os.urandom(32)).decode())"
```

**3. Create the PostgreSQL database**
```sql
CREATE DATABASE password_vault;
```

**4. Apply migrations**
```bash
python manage.py migrate
```

**5. Start the development server**
```bash
python manage.py runserver
```

The API will be available at `http://localhost:8000/api/`.

### Flutter Android App

**1. Install dependencies**
```bash
cd mobile
flutter pub get
```

**2. Configure environment**

The file `mobile/.env` is pre-configured for the Android emulator. The emulator reaches the host machine at `10.0.2.2`, which maps to `localhost` on the host.

```
API_BASE_URL=http://10.0.2.2:8000/api
CLIPBOARD_CLEAR_DELAY=30
AUTO_LOCK_TIMEOUT=120
```

If running on a physical device, replace `10.0.2.2` with the host machine's local IP address.

**3. Run the app**
```bash
flutter run
```

## Security

**Encryption at rest**

Credential fields — username, password, URL, and notes — are encrypted with AES-256-GCM before being written to PostgreSQL. The plaintext never touches the database. Each value is encrypted independently with a unique 12-byte random nonce. The format stored in the database is `base64(nonce || ciphertext || 16-byte GCM tag)`. Decryption happens server-side only on authenticated requests.

The encryption key is loaded from the `AES_ENCRYPTION_KEY` environment variable and never committed to source control.

**Authentication**

JWT access tokens expire after 60 minutes. Refresh tokens expire after 7 days. Refresh tokens are rotated and blacklisted on each use and on logout, preventing token replay. Registration and login endpoints are rate-limited to 5 requests per minute per IP.

**Token storage on device**

JWT tokens are stored in the Android Keystore via `flutter_secure_storage`, backed by hardware-level key protection on supported devices.

**Biometric lock**

Biometric unlock is optional. When enabled, the vault locks automatically after `AUTO_LOCK_TIMEOUT` seconds in the background and requires fingerprint or face authentication to resume. The biometric preference is stored alongside the tokens in the Android Keystore.

**Clipboard**

Copied passwords and usernames are cleared from the clipboard after `CLIPBOARD_CLEAR_DELAY` seconds (default: 30).

**Themes**

The app ships with a fully implemented dark theme (near-black terminal aesthetic, gold accents) and a light theme (white/grey backgrounds, same gold accents). The user toggles between dark, light, and system-default in Settings. All colors adapt through an `AppColors` `BuildContext` extension (`context.cBg`, `context.cCard`, `context.cText`, etc.) so every screen reacts to the toggle without restart.

## Environment Variables Reference

### Backend `.env`

| Variable | Description | Default |
|---|---|---|
| `SECRET_KEY` | Django secret key | — |
| `DEBUG` | Enable debug mode | `False` |
| `ALLOWED_HOSTS` | Comma-separated list of allowed hosts | `localhost,127.0.0.1` |
| `DB_NAME` | PostgreSQL database name | `password_vault` |
| `DB_USER` | PostgreSQL user | `postgres` |
| `DB_PASSWORD` | PostgreSQL password | — |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `AES_ENCRYPTION_KEY` | Base64-encoded 32-byte AES key | — |
| `JWT_ACCESS_TOKEN_LIFETIME_MINUTES` | Access token TTL in minutes | `60` |
| `JWT_REFRESH_TOKEN_LIFETIME_DAYS` | Refresh token TTL in days | `7` |
| `CORS_ALLOWED_ORIGINS` | Comma-separated allowed CORS origins | — |

### Mobile `.env`

| Variable | Description | Default |
|---|---|---|
| `API_BASE_URL` | Backend API base URL | `http://10.0.2.2:8000/api` |
| `CLIPBOARD_CLEAR_DELAY` | Seconds before clipboard is cleared | `30` |
| `AUTO_LOCK_TIMEOUT` | Seconds of background time before auto-lock | `120` |

## Data Models

**Category**
- `user` — foreign key to the Django User
- `name` — category label, unique per user
- `created_at`, `updated_at`

**Credential**
- `user` — foreign key to the Django User
- `category` — optional foreign key to Category
- `title` — plaintext label
- `username` — AES-256-GCM encrypted
- `password` — AES-256-GCM encrypted
- `url` — AES-256-GCM encrypted
- `notes` — AES-256-GCM encrypted
- `created_at`, `updated_at`

## Repository

[https://github.com/dmnkSabota/password-vault](https://github.com/dmnkSabota/password-vault)
