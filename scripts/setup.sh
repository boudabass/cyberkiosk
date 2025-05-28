#!/bin/bash
set -e
set -o pipefail

echo "=== [Cyberkiosk] Installation et Configuration ==="

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root (sudo)."
  exit 1
fi

# Détection de la distribution (Debian ou Ubuntu)
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO_ID=$ID
  DISTRO_CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}
else
  echo "Impossible de détecter la distribution (fichier /etc/os-release manquant)."
  exit 1
fi

# Mise à jour et installation des prérequis
apt update
apt install -y git xorg ca-certificates curl gnupg lsb-release gnome-terminal

# Installation officielle de Docker Engine et Docker Compose V2
if ! command -v docker &> /dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  if [ "$DISTRO_ID" = "ubuntu" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $DISTRO_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  elif [ "$DISTRO_ID" = "debian" ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $DISTRO_CODENAME stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    echo "Distribution non supportée : $DISTRO_ID"
    exit 1
  fi
  chmod a+r /etc/apt/keyrings/docker.asc
  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
fi

# Installation ou mise à jour explicite du plugin Docker Compose V2
apt install -y docker-compose-plugin

if ! id kiosk &>/dev/null; then
  useradd -m -G docker -s /bin/bash kiosk
  passwd -d kiosk
  echo "[*] L'utilisateur 'kiosk' a été créé."
else
  usermod -aG docker kiosk
fi

# Clonage du dépôt Cyberkiosk
if [ ! -d /opt/cyberkiosk ]; then
  git clone https://github.com/boudabass/cyberkiosk.git /opt/cyberkiosk
  chown -R kiosk:kiosk /opt/cyberkiosk
fi

# Préparation des dossiers (si besoin)
mkdir -p /opt/cyberkiosk/asso
chown -R kiosk:kiosk /opt/cyberkiosk

# === Configuration initiale du .env ===
cd /opt/cyberkiosk
if [ ! -f .env ]; then
  cp .env.example .env
  chown kiosk:kiosk .env
  echo "[*] Fichier .env créé. Veuillez le configurer avec vos informations."

  # Proposer des valeurs par défaut
  read -p "Entrez le serveur SMTP [smtp.gmail.com] : " smtp_server
  smtp_server=${smtp_server:-smtp.gmail.com}
  sed -i "s|SMTP_SERVER=.*|SMTP_SERVER=$smtp_server|" .env

  read -p "Entrez le port SMTP [587] : " smtp_port
  smtp_port=${smtp_port:-587}
  sed -i "s|SMTP_PORT=.*|SMTP_PORT=$smtp_port|" .env

  read -p "Entrez l'utilisateur SMTP [demo@demo.com] : " smtp_user
  smtp_user=${smtp_user:-demo@demo.com}
  sed -i "s|SMTP_USER=.*|SMTP_USER=$smtp_user|" .env

  read -p "Entrez le mot de passe SMTP : " smtp_password
  sed -i "s|SMTP_PASSWORD=.*|SMTP_PASSWORD=$smtp_password|" .env
fi

# Création du dossier autostart si inexistant
sudo -u kiosk mkdir -p /home/kiosk/.config/autostart

# Création du fichier .desktop pour lancer start.sh dans un terminal graphique au login
cat << 'EOF' > /home/kiosk/.config/autostart/cyberkiosk-start.desktop
[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c "/opt/cyberkiosk/scripts/start.sh; exec bash"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Cyberkiosk Start
Comment=Lance la stack Cyberkiosk au démarrage de la session dans un terminal
EOF

chown kiosk:kiosk /home/kiosk/.config/autostart/cyberkiosk-start.desktop
chmod +x /opt/cyberkiosk/scripts/start.sh

# Ajout de la redirection des logs au début de start.sh si absent
START_SH="/opt/cyberkiosk/scripts/start.sh"
if ! grep -q "exec > /tmp/cyberkiosk.log 2>&1" "$START_SH"; then
  sed -i '1iexec > /tmp/cyberkiosk.log 2>&1' "$START_SH"
fi

echo "=== Installation terminée ==="
echo "Redémarrez et connectez-vous en tant que 'kiosk' : la stack Cyberkiosk démarrera automatiquement dans un terminal, et les logs seront disponibles dans /tmp/cyberkiosk.log."
echo "ATTENTION : Ne jamais ouvrir de session graphique root !"
echo "Connectez-vous uniquement en tant que 'kiosk' pour utiliser Cyberkiosk."

read -p "Redémarrer le système maintenant ? [O/n] " reboot_now
if [[ "$reboot_now" =~ ^[Oo]$ || -z "$reboot_now" ]]; then
  reboot
fi
