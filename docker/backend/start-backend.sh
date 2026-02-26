#!/bin/sh
set -eu

cd /workspace

if [ ! -f composer.json ]; then
  echo "planning-poker-backend is empty (or missing composer.json). Add Symfony files, then restart compose."
  sleep infinity
fi

composer install --no-interaction

exec php-fpm -F
