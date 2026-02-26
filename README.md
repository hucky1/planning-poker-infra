# Planning Poker Infra

Infrastructure repository for Planning Poker with explicit local-development and production modes.

## Expected Layout (Local Dev)

```text
planning-poker-infra/
  planning-poker-frontend/
  planning-poker-backend/
  compose.yaml              # production baseline (prebuilt images)
  compose.dev.yaml          # local development stack (bind mounts)
  .env.example
  .env.production.example
  docker/
  README.md
  .gitignore
```

## First-Time Setup (Local Dev)

```bash
git clone git@github.com:hucky1/planning-poker-infra.git planning-poker-infra
cd planning-poker-infra

git clone git@github.com:hucky1/planning-poker-frontend.git planning-poker-frontend
git clone git@github.com:hucky1/planning-poker-backend.git planning-poker-backend

cp .env.example .env
```

## Local Development (compose.dev.yaml)

Start the full local stack (frontend, php-fpm backend + nginx gateway, postgres, redis):

```bash
docker compose -f compose.dev.yaml --env-file .env up --build
```

Stop and remove containers:

```bash
docker compose -f compose.dev.yaml --env-file .env down
```

## Production Baseline (compose.yaml)

`compose.yaml` is production-oriented and expects prebuilt app images:

- `BACKEND_IMAGE`
- `FRONTEND_IMAGE`
- external `DATABASE_URL`
- external `REDIS_URL`

Example run:

```bash
cp .env.production.example .env.production
# update values with real images/secrets first
docker compose -f compose.yaml --env-file .env.production up -d
```

## Dev Runtime Notes

- `backend` only runs `composer install` when `vendor/` is missing.
- `frontend` uses `npm ci` when `package-lock.json` exists and `node_modules/` is missing.
- Optional auto-migration is enabled with `RUN_MIGRATIONS=1` (fail-fast on migration errors).
- `INSTALL_XDEBUG=0` by default for reliable PHP 8.5 builds; set `INSTALL_XDEBUG=1` only when needed.

## Secrets Strategy

- Keep local defaults in `.env` (from `.env.example`).
- Keep non-local settings in `.env.production` (from `.env.production.example`).
- Do not commit real secrets; inject them via CI or secret manager.

## CI Validation

GitHub Actions validates:

- `docker compose -f compose.dev.yaml --env-file .env.example config`
- `docker compose -f compose.yaml --env-file .env.production.example config`
- `docker compose -f compose.dev.yaml --env-file .env.example build backend frontend`
