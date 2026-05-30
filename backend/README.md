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

## Users persistence

Registered users are saved in:

- `backend/data/users.json`

This file is loaded on startup and updated on each successful register.

## Session persistence (PostgreSQL)

By default, sessions run in memory. To persist sessions across backend restarts:

1. Copy `.env.example` and set `DATABASE_URL`.
2. Create the table with `backend/sql/001_auth_sessions.sql`.
3. Start backend with `DATABASE_URL` set.

When PostgreSQL is active, `/health` returns `"sessionStore": "postgres"`.
