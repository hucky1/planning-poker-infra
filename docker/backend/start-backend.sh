#!/bin/sh
set -eu

cd /workspace

if [ ! -f composer.json ]; then
  echo "planning-poker-backend is empty (or missing composer.json). Add Symfony files, then restart compose."
  while true; do sleep 3600; done
fi

if [ ! -d vendor ]; then
  composer install --no-interaction
fi

# Optional auto-migration for local development after Symfony/Doctrine is installed.
if [ "${RUN_MIGRATIONS:-0}" = "1" ] && [ -f bin/console ]; then
  if php bin/console list --raw 2>/dev/null | grep -q '^doctrine:migrations:migrate$'; then
    php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
  fi
fi

exec php-fpm -F
