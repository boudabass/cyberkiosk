#!/bin/bash
set -e

cd "$(dirname "$0")/.."

# Vérification que Docker est lancé
if ! systemctl is-active --quiet docker; then
  echo "[!] Le service Docker n'est pas démarré. Veuillez le lancer avec : sudo systemctl start docker"
  exit 1
fi

# Vérification de la présence de .env
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    echo "[*] Fichier .env absent, création depuis .env.example"
    cp .env.example .env
  else
    echo "[!] Fichier .env et .env.example absents. Impossible de continuer."
    exit 1
  fi
fi

# Mise à jour ou ajout de la variable DISPLAY dans .env
if [ -z "$DISPLAY" ]; then
  echo "[!] La variable DISPLAY n'est pas définie dans l'environnement courant."
  echo "    Le navigateur ne pourra pas s'afficher graphiquement."
else
  if grep -q '^DISPLAY=' .env; then
    sed -i "s|^DISPLAY=.*|DISPLAY=$DISPLAY|" .env
    echo "[*] Variable DISPLAY mise à jour dans .env : $DISPLAY"
  else
    echo "DISPLAY=$DISPLAY" >> .env
    echo "[*] Variable DISPLAY ajoutée à .env : $DISPLAY"
  fi
fi

# Autorisation d'accès X11 pour les conteneurs Docker
if command -v xhost &> /dev/null; then
  echo "[*] Autorisation d'accès X11 pour Docker (xhost +local:docker)..."
  xhost +local:docker
else
  echo "[!] La commande xhost n'est pas disponible. L'affichage graphique risque de ne pas fonctionner."
fi

echo "=== [Cyberkiosk] Lancement de la stack ==="
docker compose up -d

echo "La stack Cyberkiosk est démarrée."

