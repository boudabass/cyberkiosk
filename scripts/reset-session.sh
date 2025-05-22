#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "=== [Cyberkiosk] Réinitialisation de la session ==="

# Arrêt de la stack
docker compose down

# Nettoyage du dossier session (volume local)
if [ -d session ]; then
  rm -rf session/*
  touch session/.keep
fi

# Redémarrage de la stack
docker compose up -d

echo "Session utilisateur réinitialisée."
