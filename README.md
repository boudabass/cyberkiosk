Cyberkiosk – La Cybergrange
Cyberkiosk est une stack Docker clé en main pour créer un kiosque numérique sécurisé, éphémère et facile à déployer, pensée pour les associations d’inclusion numérique.
Le projet garantit la confidentialité des usagers, l’isolation des sessions, et la simplicité d’utilisation même sur du matériel ancien.

🚀 Fonctionnalités principales
Session utilisateur éphémère : aucune trace ni fichier personnel conservé après usage.

Navigation web sécurisée : accès uniquement aux sites autorisés (liste blanche).

Webapp d’accueil : gestion simple des fichiers de session, envoi par mail, accès aux documents de l’association.

Administration intégrée : gestion dynamique de la liste blanche, reboot session/machine, logs techniques.

Déploiement ultra-simple : script d’installation minimal, stack Docker Compose unique.

📦 Structure de la stack
chromium-kiosk : navigateur Chromium en mode kiosk, session privée, affichage X11/Xvfb.

webapp-flask : page d’accueil, gestion fichiers, envoi mail, interface admin.

proxy-privoxy : proxy filtrant, configuration dynamique via l’admin web.

Volumes Docker :

session (tmpfs, éphémère) : fichiers utilisateur.

asso (lecture seule) : documents de l’association.

🖥️ Prérequis
PC sous Debian stable (préconisé)

Docker Engine (version récente)

X11 fonctionnel (ou Xvfb pour fallback)

Accès root pour l’installation initiale

⚡ Installation rapide
bash
# 1. Cloner le dépôt
git clone https://github.com/cybergrange/cyberkiosk.git
cd cyberkiosk

# 2. Lancer le script d’installation (création user, config X11, etc.)
sudo ./setup-kiosk.sh

# 3. Lancer la stack Docker
sudo -u kiosk-user docker compose up -d
Voir le guide complet dans docs/INSTALL.md

🔑 Configuration
Liste blanche des sites : modifiable depuis l’interface admin (webapp).

Documents asso : placer les fichiers dans /opt/kiosk/asso sur l’hôte.

SMTP (envoi mail) : renseigner les variables dans le fichier .env (voir docs/MAIL.md).

🛠️ Utilisation
Démarrage : le navigateur s’ouvre automatiquement en mode kiosk sur la webapp d’accueil.

Fin de session : après envoi du mail, toutes les données de la session sont effacées.

Administration : accès à l’interface admin via la webapp (authentification requise).

🔒 Sécurité
Sessions totalement isolées et non persistantes

Aucun accès root dans les conteneurs

Volumes éphémères pour les données utilisateurs

Administration sécurisée par mot de passe

🧑‍💻 Contribution
Les contributions (code, documentation, tests sur d’autres configs matérielles) sont les bienvenues !
Merci de lire le guide CONTRIBUTING.md avant de proposer une PR.

📄 Licence
Projet open source sous licence MIT.

🤝 Remerciements
Merci à tous les bénévoles et toute l'équipe de La Cybergrange et à la communauté du libre pour leur soutien et leurs retours !
