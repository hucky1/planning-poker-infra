#!/bin/sh
set -eu

cd /workspace

if [ ! -f package.json ]; then
  echo "planning-poker-frontend is empty (or missing package.json). Add frontend files, then restart compose."
  while true; do sleep 3600; done
fi

if [ ! -d node_modules ]; then
  if [ -f package-lock.json ]; then
    npm ci
  else
    npm install
  fi
fi

exec npm run dev -- --host 0.0.0.0 --port "${FRONTEND_PORT:-5173}"
