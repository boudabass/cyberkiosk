#!/bin/bash
set -e

echo "=== [Cyberkiosk] RESET TOTAL DOCKER & SYSTEME ==="

# 1. Arrêter le service Docker
echo "[*] Arrêt du service Docker..."
sudo systemctl stop docker || true

# 2. Arrêter et supprimer tous les conteneurs
echo "[*] Suppression de tous les conteneurs..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# 3. Suppression de toutes les images
echo "[*] Suppression de toutes les images Docker..."
docker rmi -f $(docker images -aq) 2>/dev/null || true

# 4. Suppression de tous les volumes
echo "[*] Suppression de tous les volumes Docker..."
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# 5. Suppression de tous les réseaux non par défaut
echo "[*] Suppression de tous les réseaux Docker..."
docker network rm $(docker network ls | grep -v "bridge\|host\|none" | awk '{print $1}') 2>/dev/null || true

# 6. Suppression des fichiers de configuration et data Docker
echo "[*] Suppression des fichiers de configuration et data Docker..."
sudo rm -rf /var/lib/docker /etc/docker /var/run/docker.sock /var/run/docker /usr/local/bin/docker-compose

# 7. Suppression du groupe docker
sudo groupdel docker || true

# 8. Suppression de tous les fichiers et dossiers liés à Docker dans le système
sudo find / -name "*docker*" -exec rm -rf {} \; 2>/dev/null || true

# 9. Suppression du projet et de l'utilisateur kiosk
echo "[*] Suppression du dossier /opt/cyberkiosk..."
sudo rm -rf /opt/cyberkiosk

if id kiosk &>/dev/null; then
  echo "[*] Suppression de l'utilisateur kiosk et de son home..."
  sudo userdel -r kiosk || true
fi

# 10. Nettoyage des fichiers temporaires X11 et SHM
echo "[*] Nettoyage des fichiers temporaires X11 et SHM..."
sudo rm -rf /tmp/.X11-unix/* /dev/shm/*

# 11. Désinstallation des paquets Docker
echo "[*] Désinstallation des paquets Docker..."
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-ce-cli

# 12. Nettoyage final
echo "[*] Nettoyage final..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "=== RESET COMPLET TERMINÉ. Le système est vierge de tout Docker et Cyberkiosk ==="
