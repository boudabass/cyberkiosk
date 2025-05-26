#!/bin/bash
set -e

# S'assurer que le script est lancé par l'utilisateur kiosk
if [ "$(whoami)" != "kiosk" ]; then
  echo "Ce script doit être exécuté en tant qu'utilisateur 'kiosk'."
  exit 1
fi

cd /opt/cyberkiosk

# Vérification de la présence du .env
if [ ! -f .env ]; then
  echo "[!] Le fichier .env est absent. Merci de contacter l'administrateur."
  exit 1
fi

# Mise à jour de la variable DISPLAY dans .env si besoin
if [ -n "$DISPLAY" ]; then
  if grep -q '^DISPLAY=' .env; then
    sed -i "s|^DISPLAY=.*|DISPLAY=$DISPLAY|" .env
  else
    echo "DISPLAY=$DISPLAY" >> .env
  fi
fi

# Autorisation d'accès X11 pour Docker
if command -v xhost &> /dev/null; then
  xhost +local:docker
fi

# Lancement de la stack Docker Compose
echo "[*] Lancement de la stack Cyberkiosk..."
docker compose up -d

if [ $? -eq 0 ]; then
  echo "[*] Stack Cyberkiosk démarrée avec succès."
else
  echo "[!] Erreur lors du démarrage de la stack Cyberkiosk."
  exit 1
fi
