# privoxy/Dockerfile

FROM debian:bookworm-slim

LABEL maintainer="La Cybergrange <contact@cybergrange.fr>"
LABEL description="Image Privoxy personnalisée pour Cyberkiosk"

RUN apt-get update && \
    apt-get install -y --no-install-recommends privoxy && \
    rm -rf /var/lib/apt/lists/*

# Copie la configuration personnalisée
COPY config/config /etc/privoxy/config
COPY config/user.action /etc/privoxy/user.action

# Utilisateur non-root pour la sécurité
RUN useradd -m privoxyuser
USER privoxyuser

EXPOSE 8118

CMD ["privoxy", "--no-daemon", "/etc/privoxy/config"]
