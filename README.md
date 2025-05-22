# Cyberkiosk

**Projet de kiosque numérique sécurisé, éphémère et accessible, conçu pour l’association La Cybergrange.**

---

## Présentation

Cyberkiosk est une solution clé-en-main pour transformer n’importe quel PC sous Debian en borne d’accès Internet sécurisée, idéale pour les démarches administratives et l’accompagnement numérique.  
Chaque session utilisateur est isolée, aucune donnée n’est conservée, et la navigation est strictement contrôlée.

---

## Fonctionnalités principales

- **Session éphémère** : remise à zéro complète après chaque utilisation (fichiers, historique, identifiants…)
- **Navigation sécurisée** : accès uniquement à une liste blanche de sites autorisés via un proxy filtrant
- **Webapp d’accueil** : gestion simple des fichiers téléchargés, documents de l’association, et envoi par mail
- **Administration intégrée** : gestion de la liste blanche, redémarrage de session/machine, logs techniques
- **Déploiement ultra-simple** : tout est orchestré via Docker Compose

---

## Prérequis

- PC sous **Debian stable** (préconisé : version minimale, sans interface graphique lourde)
- **Docker Engine** installé (version récente recommandée)
- Accès administrateur pour l’installation initiale
- Compte Gmail dédié pour l’envoi des mails (avec mot de passe d’application)

---

## Installation rapide

1. **Préparation de l’hôte**
   - Installez Docker :
     ```
     sudo apt update
     sudo apt install docker.io
     sudo systemctl enable --now docker
     ```
   - (Optionnel) Installez X11 ou Xvfb si besoin d’un affichage virtuel.

2. **Création de l’utilisateur dédié**
   - (optionnel mais recommandé)
     ```
     sudo useradd -m -G docker -s /bin/bash kiosk
     sudo passwd kiosk
     ```

3. **Clonage du dépôt**
git clone https://github.com/votre-asso/cyberkiosk.git
cd cyberkiosk



4. **Configuration**
- Copiez et éditez le fichier `.env.example` en `.env` pour renseigner les paramètres SMTP et autres variables.
- Placez les documents de l’association dans le dossier `asso/`.

5. **Lancement de la stack**
docker compose up -d



6. **Accès**
- Le navigateur Chromium s’ouvre en mode kiosk sur la webapp d’accueil.
- Interface d’administration : http://localhost:5000/admin

---

## Utilisation

- **Pour les usagers**
- Naviguez sur les sites autorisés depuis la page d’accueil
- Téléchargez les documents nécessaires, ajoutez ceux de l’association
- Envoyez-vous vos fichiers par mail en fin de session
- À la fin, toutes les données sont effacées automatiquement

- **Pour les administrateurs**
- Gérez la liste blanche des sites accessibles
- Ajoutez/supprimez des documents de l’association
- Redémarrez une session ou la machine depuis l’interface admin
- Accédez aux logs techniques pour le support

---

## Structure du projet

cyberkiosk/
│
├── docker-compose.yml # Orchestration des services
├── Dockerfile.chrome # Image du navigateur Chromium
├── Dockerfile.webapp # Image de la webapp Flask
├── Dockerfile.privoxy # Image du proxy filtrant
├── asso/ # Documents de l’association (lecture seule)
├── session/ # Volume éphémère pour les fichiers utilisateurs
├── webapp/ # Code source de la webapp Flask
├── privoxy/ # Configurations du proxy
├── .env.example # Exemple de configuration SMTP et variables
└── README.md



---

## Sécurité & bonnes pratiques

- Isolation stricte des sessions utilisateur
- Aucun accès root dans les conteneurs
- Volumes Docker éphémères (aucune persistance de données sensibles)
- Accès administrateur limité par authentification
- Liste blanche dynamique et configurable
- Conformité RGPD : aucune donnée personnelle conservée

---

## Dépannage

- **Redémarrer la stack** :  
docker compose down && docker compose up -d


- **Consulter les logs** :  
docker compose logs


- **Réinitialiser la configuration** :  
Supprimez le dossier `session/` et relancez la stack.

---

## Contribution

Toute aide est la bienvenue !  
Merci de proposer vos améliorations via des issues ou pull requests.

---

## Licence

Projet open source sous licence MIT.

---

🤝 Remerciements
Merci à tous les bénévoles et toute l'équipe de La Cybergrange et à la communauté du libre pour leur soutien et leurs retours !
