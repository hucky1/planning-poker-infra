#!/bin/sh
set -eu

cd /workspace

if [ ! -f package.json ]; then
  echo "planning-poker-frontend is empty (or missing package.json). Add frontend files, then restart compose."
  sleep infinity
fi

npm install

exec npm run dev -- --host 0.0.0.0 --port "${FRONTEND_PORT:-5173}"
