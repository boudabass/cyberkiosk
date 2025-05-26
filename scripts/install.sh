#!/bin/bash
set -e

echo "=== [Cyberkiosk] Installation et Configuration ==="

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root (sudo)."
  exit 1
fi

# Installation des prérequis
for pkg in git xorg; do
  if ! dpkg -l | grep -q $pkg; then
    echo "[*] Installation de $pkg..."
    apt update
    apt install -y $pkg
  fi
done

# Détection de la distribution (Debian ou Ubuntu)
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO_ID=$ID
  DISTRO_CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}
else
  echo "Impossible de détecter la distribution (fichier /etc/os-release manquant)."
  exit 1
fi

# Installation officielle de Docker Engine et Docker Compose
if ! command -v docker &> /dev/null; then
  echo "[*] Installation de Docker Engine (méthode officielle pour $DISTRO_ID)..."
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release

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
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Création d'un utilisateur dédié sans mot de passe
if ! id kiosk &>/dev/null; then
  useradd -m -G docker -s /bin/bash kiosk
  passwd -d kiosk
  echo "[*] L'utilisateur 'kiosk' a été créé."
fi

# Clonage du dépôt
if [ ! -d /opt/cyberkiosk ]; then
  git clone https://github.com/boudabass/cyberkiosk.git /opt/cyberkiosk
fi

# Création du dossier asso si absent
if [ ! -d /opt/cyberkiosk/asso ]; then
  mkdir -p /opt/cyberkiosk/asso
  chown kiosk:docker /opt/cyberkiosk/asso
  echo "[*] Dossier /opt/cyberkiosk/asso créé."
fi

# Configuration initiale
cd /opt/cyberkiosk
if [ ! -f .env ]; then
  cp .env.example .env
  echo "[*] Fichier .env créé. Veuillez le configurer avec vos informations."
  
  # Proposer des valeurs par défaut
  read -p "Entrez le serveur SMTP [smtp.example.com] : " smtp_server
  smtp_server=${smtp_server:-smtp.gmail.com}
  sed -i "s|SMTP_SERVER=.*|SMTP_SERVER=$smtp_server|" .env

  read -p "Entrez le port SMTP [587] : " smtp_port
  smtp_port=${smtp_port:-587}
  sed -i "s|SMTP_PORT=.*|SMTP_PORT=$smtp_port|" .env

  read -p "Entrez l'utilisateur SMTP [user@example.com] : " smtp_user
  smtp_user=${smtp_user:-demo@demo.com}
  sed -i "s|SMTP_USER=.*|SMTP_USER=$smtp_user|" .env

  read -p "Entrez le mot de passe SMTP : " smtp_password
  sed -i "s|SMTP_PASSWORD=.*|SMTP_PASSWORD=$smtp_password|" .env
fi

# Autorisation X11
if command -v xhost &> /dev/null; then
  xhost +local:docker
fi

# Ajout du démarrage automatique de la stack dans le profil de l'utilisateur kiosk
KIOSK_PROFILE="/home/kiosk/.bash_profile"
STACK_CMD="docker compose -f /opt/cyberkiosk/docker-compose.yml up -d"
if ! grep -Fxq "$STACK_CMD" "$KIOSK_PROFILE"; then
  echo "" >> "$KIOSK_PROFILE"
  echo "# Démarrage automatique de la stack Cyberkiosk" >> "$KIOSK_PROFILE"
  echo "$STACK_CMD" >> "$KIOSK_PROFILE"
  chown kiosk:kiosk "$KIOSK_PROFILE"
  echo "[*] Ajout du démarrage automatique de la stack dans $KIOSK_PROFILE"
fi

# Redémarrage du système
read -p "Redémarrer le système maintenant pour finaliser l'installation ? [O/n] " reboot_now
if [[ "$reboot_now" =~ ^[Oo]$ || -z "$reboot_now" ]]; then
  echo "[*] Redémarrage du système..."
  reboot
else
  echo "[*] Redémarrage annulé. Pensez à redémarrer manuellement avant d'utiliser la stack."
fi
