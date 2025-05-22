FROM python:3.11-slim

# Variables d'environnement de base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Installation des dépendances système nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        libmagic1 \
        && rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-root
RUN useradd -m -d /home/webappuser -s /bin/bash webappuser

WORKDIR /app

# Copie des dépendances Python
COPY requirements.txt .

# Installation des dépendances Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copie du code source de l’application
COPY app/ /app/app/
COPY entrypoint.sh /entrypoint.sh

# Droits d'exécution sur l'entrypoint
RUN chmod +x /entrypoint.sh

# Propriété des fichiers à l'utilisateur non-root
RUN chown -R webappuser:webappuser /app /entrypoint.sh

USER webappuser

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
