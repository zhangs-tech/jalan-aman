# Jalan Aman

Jalan Aman is a community road-safety reporting app. The repository contains:

- `backend/`: REST API built with Bun, Express, Prisma, PostgreSQL, JWT auth, and S3-compatible object storage.
- `jalan_aman/`: Flutter mobile app that consumes the backend API.
- `docs/`: use-case, lifecycle, ERD, and project report documentation.

## Contributors

- Danielson ([@orde-r](https://github.com/orde-r))
- Jeremy Auriel Zhang ([@jeremzhg](https://github.com/jeremzhg))
- Kristopher Nathanael ([@KrisNathan](https://github.com/KrisNathan))

## Prerequisites

Install these before starting the app:

- Docker Desktop
- Bun
- Flutter SDK
- Android Studio or another Flutter-supported device target

## 1. Start the Backend

Open a terminal at the repository root.

```powershell
cd backend
bun install
Copy-Item .env.example .env
bun run scripts/genkey.ts
docker compose up -d
bun run db migrate dev
bun dev
```

The API should now run at:

```text
http://localhost:3000
```

API documentation is available at:

```text
http://localhost:3000/docs
```

The backend Docker Compose file starts:

- PostgreSQL on `localhost:5433`
- SeaweedFS S3-compatible storage on `localhost:8333`

## 2. Start the Flutter App

Open a second terminal at the repository root.

```powershell
cd jalan_aman
flutter pub get
Copy-Item .env.example .env
flutter run
```

Check `jalan_aman/.env` before running. The correct `API_BASE_URL` depends on the device:

```text
Android emulator: http://10.0.2.2:3000
iOS simulator, desktop, or web: http://localhost:3000
```
