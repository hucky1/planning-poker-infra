# Planning Poker Infra

Local infrastructure repo for the Planning Poker project.

## Expected Layout

Clone frontend and backend repos inside this infra repo as sibling folders:

```text
planning-poker-infra/
  planning-poker-frontend/
  planning-poker-backend/
  compose.yaml
  .env.example
  docker/
  README.md
  .gitignore
```

## First-Time Setup

```bash
git clone git@github.com:hucky1/planning-poker-infra.git planning-poker-infra
cd planning-poker-infra

git clone git@github.com:hucky1/planning-poker-frontend.git planning-poker-frontend
git clone git@github.com:hucky1/planning-poker-backend.git planning-poker-backend

cp .env.example .env
```

## Version Configuration

All runtime versions are controlled from `.env`:

- `PHP_VERSION` (backend base image, example `8.5-fpm`)
- `COMPOSER_VERSION` (Composer image used to copy composer binary)
- `NGINX_VERSION` (Symfony web gateway)
- `NODE_VERSION` (frontend runtime)
- `XDEBUG_*` (debugger mode and IDE connection settings)

## Bootstrap Latest Symfony

Initialize backend with latest Symfony skeleton and common setup packages:

```bash
docker compose run --rm backend sh -lc '
  set -eu
  if [ -f /workspace/composer.json ]; then
    echo "composer.json already exists in planning-poker-backend. Skipping bootstrap."
    exit 0
  fi
  rm -rf /tmp/symfony
  composer create-project symfony/skeleton:"*" /tmp/symfony
  cp -a /tmp/symfony/. /workspace/
  cd /workspace
  composer require symfony/webapp-pack symfony/orm-pack
  composer require --dev symfony/maker-bundle
'
```

## Local Development

Start all services (frontend, PHP-FPM backend, Nginx gateway):

```bash
docker compose up --build
```

Stop and remove containers:

```bash
docker compose down
```
