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
- `GET /api/auth/me` (Bearer token)
- `GET /api/feed`
- `GET /api/chat/threads`
- `GET /api/wallet/summary`

## Auth persistence modes

### Default (without DATABASE_URL)

- Users: `backend/data/users.json`
- Sessions: memory

### PostgreSQL enabled (with DATABASE_URL)

- Users: table `auth_users`
- Sessions: table `auth_sessions`

## Enable PostgreSQL mode

1. Copy `.env.example` and set `DATABASE_URL`.
2. Run SQL scripts:
   - `backend/sql/000_auth_users.sql`
   - `backend/sql/001_auth_sessions.sql`
3. Start backend with `DATABASE_URL` set.

When PostgreSQL is active, `/health` returns:

- `"userStore": "postgres"`
- `"sessionStore": "postgres"`
