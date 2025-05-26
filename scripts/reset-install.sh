#!/bin/bash
set -e

echo "=== [Cyberkiosk] Réinitialisation complète ==="

# 1. Arrêt et suppression des conteneurs Docker liés à cyberkiosk
if [ -d /opt/cyberkiosk ]; then
  cd /opt/cyberkiosk
  echo "[*] Arrêt des conteneurs Docker..."
  docker compose down || true
fi

# 2. Suppression des images Docker liées à cyberkiosk
echo "[*] Suppression des images Docker cyberkiosk..."
docker images | grep cyberkiosk | awk '{print $3}' | xargs -r docker rmi -f

# 3. Suppression du dossier d'installation
if [ -d /opt/cyberkiosk ]; then
  echo "[*] Suppression du dossier /opt/cyberkiosk..."
  rm -rf /opt/cyberkiosk
fi

# 4. Suppression de l'utilisateur kiosk et de son home
if id kiosk &>/dev/null; then
  echo "[*] Suppression de l'utilisateur kiosk et de son répertoire personnel..."
  userdel -r kiosk || true
fi

# 5. Nettoyage du .bashrc de l'utilisateur kiosk (si jamais il reste)
if [ -f /home/kiosk/.bashrc ]; then
  echo "[*] Nettoyage du .bashrc de l'utilisateur kiosk..."
  sed -i '/cyberkiosk/d' /home/kiosk/.bashrc
  sed -i '/chromium-browser/d' /home/kiosk/.bashrc
fi

# 6. (Optionnel) Suppression des volumes et réseaux Docker inutilisés
echo "[*] Nettoyage des volumes et réseaux Docker non utilisés..."
docker system prune -f --volumes

echo "=== Réinitialisation terminée. Vous pouvez relancer le script d'installation. ==="

