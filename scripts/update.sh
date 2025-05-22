#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "=== [Cyberkiosk] Mise à jour des images ==="
docker compose pull
docker compose up -d

echo "Stack mise à jour."
