#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "=== [Cyberkiosk] Lancement de la stack ==="
docker compose up -d

echo "La stack Cyberkiosk est démarrée."
