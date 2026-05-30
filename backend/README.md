# Zappy Backend (Local MVP)

## Run

```bash
cd backend
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
