# Zappy Backend (Local MVP)

## Run

```bash
cd backend
npm install
npm start
```

Server: `http://localhost:4000`

## Endpoints

- `GET /health`
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/refresh`
- `POST /api/auth/logout` (Bearer access token + refresh token in body)
- `GET /api/auth/me` (Bearer access token)
- `GET /api/feed`
- `GET /api/chat/threads`
- `GET /api/wallet/summary`

## Auth abuse protection

Login, register, and refresh requests are rate-limited in memory.

- Window: 15 minutes
- Limit: 10 attempts
- Scope: client IP plus email or refresh token fingerprint

## Auth persistence modes

### Default (without DATABASE_URL)

- Users: `backend/data/users.json`
- Access sessions: memory
- Refresh sessions: memory

### PostgreSQL enabled (with DATABASE_URL)

- Users: table `auth_users`
- Access sessions: table `auth_sessions`
- Refresh sessions: table `auth_refresh_tokens`

## Enable PostgreSQL mode

1. Copy `.env.example` and set `DATABASE_URL`.
2. Run SQL scripts:
   - `backend/sql/000_auth_users.sql`
   - `backend/sql/001_auth_sessions.sql`
   - `backend/sql/002_auth_refresh_tokens.sql`
3. Start backend with `DATABASE_URL` set.

When PostgreSQL is active, `/health` returns:

- `"userStore": "postgres"`
- `"sessionStore": "postgres"`
