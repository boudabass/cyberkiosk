# Cyberkiosk

**Solution de kiosque numérique sécurisé et éphémère pour l’association La Cybergrange**

---

## Présentation

Cyberkiosk est une stack Docker Compose conçue pour transformer un PC sous Debian en une borne d’accès Internet sécurisée, simple à utiliser et adaptée aux démarches administratives.  
Chaque session utilisateur est isolée et remise à zéro automatiquement, garantissant la confidentialité et la sécurité des données.

---

## Fonctionnalités clés

- **Session éphémère** : remise à zéro complète après chaque utilisation (fichiers, historique, cache, identifiants).
- **Navigation sécurisée** : accès limité à une liste blanche de sites via un proxy filtrant (Privoxy).
- **Webapp d’accueil** : interface simple pour gérer les fichiers téléchargés, consulter les documents de l’association, et envoyer les fichiers par mail.
- **Administration intégrée** : gestion dynamique de la liste blanche, redémarrage des sessions, accès aux logs.
- **Déploiement facile** : tout est orchestré via Docker Compose avec des images dédiées pour Chromium, Flask et Privoxy.

---

## Structure du projet

cyberkiosk/
│
├── docker-compose.yml # Orchestration des services
├── .env.example # Exemple de variables d’environnement
│
├── chrome/ # Service Chromium
│ ├── Dockerfile
│ └── entrypoint.sh
│
├── webapp/ # Service Flask
│ ├── Dockerfile
│ ├── app/
│ └── requirements.txt
│
├── privoxy/ # Service Privoxy
│ ├── Dockerfile
│ └── config/
│ └── config
│
├── asso/ # Documents de l’association (lecture seule)
│
├── session/ # Volume éphémère pour fichiers utilisateurs
│
├── scripts/ # Scripts d’installation et maintenance
│
└── README.md

text

---

## Prérequis

- PC sous Debian stable (recommandé pour compatibilité et légèreté)
- Docker Engine installé (version récente)
- Accès administrateur pour l’installation initiale
- Compte Gmail dédié avec mot de passe d’application pour l’envoi des mails

---

## Installation rapide

1. Installer Docker sur la machine hôte.
2. Créer un utilisateur dédié (optionnel mais recommandé).
3. Cloner ce dépôt :
git clone https://github.com/boudabass/cyberkiosk.git
cd cyberkiosk

text
4. Copier `.env.example` en `.env` et renseigner les variables (SMTP, ports, etc.).
5. Placer les documents de l’association dans le dossier `asso/`.
6. Lancer la stack :
docker compose up -d

text
7. Le navigateur s’ouvre automatiquement en mode kiosk sur la webapp d’accueil.

---

## Utilisation

- **Pour les usagers** :  
Naviguer uniquement sur les sites autorisés, gérer les fichiers téléchargés, envoyer les documents par mail, puis quitter la session qui sera automatiquement réinitialisée.

- **Pour les administrateurs** :  
Gérer la liste blanche des sites, les documents de l’association, redémarrer les sessions ou la machine, consulter les logs via l’interface d’administration.

---

## Variables d’environnement

Les principales variables à configurer dans `.env` :

- `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD` : pour la configuration de l’envoi mail via Gmail.
- Ports exposés pour chaque service.
- Chemins des volumes (optionnel).

---

## Sécurité

- Isolation complète des sessions via Docker et volumes éphémères.
- Pas de données persistantes utilisateur en dehors de la session active.
- Conteneurs non privilégiés, volumes en lecture seule quand possible.
- Proxy filtrant pour limiter la navigation aux sites autorisés.
- Authentification sur l’interface d’administration.

---

## Maintenance

- Scripts disponibles dans `scripts/` pour installation, reset de session, mises à jour.
- Logs accessibles via Docker Compose.
- Mise à jour des images Docker par simple pull et redémarrage.

---

## Contribution

Contributions, suggestions et rapports de bugs sont les bienvenus !  
Merci de passer par les issues ou pull requests.

---

## Licence

Projet open source sous licence MIT.

---

## Contact

Pour toute question ou support, contactez l’association La Cybergrange.

---

*Merci de contribuer à réduire la fracture numérique avec Cyberkiosk !*
