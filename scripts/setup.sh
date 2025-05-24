#!/bin/bash
set -e

echo "=== [Cyberkiosk] Installation initiale ==="

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root (sudo)."
  exit 1
fi

# Vérification de la présence de git
if ! command -v git &> /dev/null; then
  echo "[*] Installation de git..."
  apt update
  apt install -y git
fi

# Installation de Docker si absent
if ! command -v docker &> /dev/null; then
  echo "[*] Installation de Docker..."
  apt update
  apt install -y docker.io
  systemctl enable --now docker
fi

# Création d'un utilisateur dédié (optionnel mais recommandé)
read -p "Créer un utilisateur dédié 'kiosk' ? [O/n] " create_user
if [[ "$create_user" =~ ^[Oo]$ || -z "$create_user" ]]; then
  id kiosk &>/dev/null || useradd -m -G docker -s /bin/bash kiosk
  passwd kiosk
  echo "[*] L'utilisateur 'kiosk' a été ajouté au groupe docker."
  echo "    Déconnectez-vous puis reconnectez-vous pour appliquer les droits."
fi

# Installation de X11 (si nécessaire)
if ! dpkg -l | grep -q xorg; then
  echo "[*] Installation de X11..."
  apt install -y xorg
fi

echo "=== [Cyberkiosk] Clonage du dépôt ==="
if [ ! -d /opt/cyberkiosk ]; then
  git clone https://github.com/boudabass/cyberkiosk.git /opt/cyberkiosk
fi

echo "=== [Cyberkiosk] Préparation des dossiers ==="
mkdir -p /opt/cyberkiosk/asso
chown -R kiosk:kiosk /opt/cyberkiosk

echo "=== Installation terminée ==="
echo "Connectez-vous avec l'utilisateur 'kiosk' pour lancer la stack."

# Demande de confirmation avant redémarrage
read -p "Redémarrer le système maintenant pour finaliser l'installation ? [O/n] " reboot_now
if [[ "$reboot_now" =~ ^[Oo]$ || -z "$reboot_now" ]]; then
  echo "[*] Redémarrage du système..."
  reboot
else
  echo "[*] Redémarrage annulé. Pensez à redémarrer manuellement avant d'utiliser la stack."
fi

