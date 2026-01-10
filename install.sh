#!/bin/sh

# ==============================================================================
# Script d'Installation ROBUSTE - Open WebUI
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { printf "${BLUE}[INFO]${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# --- Configuration ---
APP_NAME="open-webui"
INSTALL_DIR="/opt/${APP_NAME}"
SYSTEMD_UNIT="/etc/systemd/system/${APP_NAME}.service"
COMPOSE_FILE="docker-compose.yaml"

if [ "$(id -u)" -ne 0 ]; then
    log_warn "Passage en mode sudo..."
    exec sudo "$0" "$@"
fi

log_info "Début de la mise à jour système de ${APP_NAME}..."

# 1. Résolution des conflits de conteneurs (La partie robuste)
log_info "Nettoyage des anciens conteneurs conflictuels..."
if [ "$(docker ps -aq -f name=^/${APP_NAME}$)" ]; then
    log_warn "Un conteneur nommé '${APP_NAME}' existe déjà. Suppression en cours..."
    docker rm -f "${APP_NAME}" > /dev/null 2>&1 || true
    log_success "Ancien conteneur supprimé."
fi

# 2. Configuration Ollama & Pare-feu (Idempotent)
log_info "Vérification configuration Ollama & UFW..."
mkdir -p /etc/systemd/system/ollama.service.d
cat <<OLLAMA_EOF > /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
OLLAMA_EOF

systemctl daemon-reload
systemctl restart ollama

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "active"; then
    ufw allow from 172.16.0.0/12 to any port 11434 comment 'Allow Docker to Ollama' > /dev/null
fi

# 3. Déploiement des fichiers
log_info "Mise à jour des fichiers dans ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"
cp "$(dirname "$(readlink -f "$0")")/${COMPOSE_FILE}" "${INSTALL_DIR}/"

# 4. Création du service Systemd ROBUSTE
# Note : on force le nom du projet avec -p pour éviter les conflits de répertoires
log_info "Configuration du service systemd..."
cat <<SERVICE_EOF > "${SYSTEMD_UNIT}"
[Unit]
Description=Docker Compose Open WebUI Service
Requires=docker.service
After=docker.service ollama.service

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
# Nettoyage forcé au démarrage au cas où Docker aurait crashé
ExecStartPre=-/usr/bin/docker compose -p ${APP_NAME} down
ExecStartPre=-/usr/bin/docker rm -f ${APP_NAME}
# Lancement
ExecStart=/usr/bin/docker compose -p ${APP_NAME} up --remove-orphans
# Arrêt propre
ExecStop=/usr/bin/docker compose -p ${APP_NAME} down
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 5. Lancement final
log_info "Démarrage du service..."
systemctl daemon-reload
systemctl enable "${APP_NAME}.service"
systemctl restart "${APP_NAME}.service"

log_success "Installation ROBUSTE terminée !"
log_info "Logs : journalctl -u ${APP_NAME}.service -f"
