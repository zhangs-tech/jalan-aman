# backend/AGENTS.md

Root-level AGENTS.md rules also apply here (note: use `ccc search` for code searches).

Use `bun` instead of `node` by default.

## Stack
Bun/TypeScript, Express 5, Prisma 7 (PostgreSQL), JWT + bcrypt, Swagger at `/docs`.
PostgreSQL 18 + SeaweedFS (S3) via Docker Compose.

## Architecture
Layered with DI: `Routes → Controllers → Services → Repositories → Prisma`.
Services are classes with `execute(...)`. Auth via `authMiddleware` → `req.user` (`{ id, email, role }`).

## Directories
`src/routes/` — one router per domain. `src/controllers/` — thin, delegates to services.
`src/services/<domain>/` — business logic. `src/repositories/` — Prisma queries.
`src/middlewares/` — auth. `src/types/` — Express augmentation.

## Scripts
`bun run dev` (port 3000) | `bun run db` (Prisma CLI).

## Setup
Copy `.env.example` → `.env`, then:
```bash
docker compose up -d
bun run db migrate dev
bun run dev
```
