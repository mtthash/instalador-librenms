#!/usr/bin/env bash

################################################################################
# LibreNMS Installer v2.0
# Ubuntu Server 24.04 LTS
# LibreNMS 26.7.x
################################################################################

set -euo pipefail

clear

################################################################################
# Colors
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

################################################################################
# Banner
################################################################################

echo -e "${BLUE}"
echo "============================================================"
echo "            Testoni - LibreNMS Installer v2.0"
echo "             Ubuntu Server 24.04 LTS Edition"
echo "============================================================"
echo -e "${NC}"

################################################################################
# Root check
################################################################################

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This installer must be executed as root.${NC}"
    exit 1
fi

################################################################################
# Files check
################################################################################

FILES=(
phase1-base.sh
phase2-librenms.sh
phase3-mariadb.sh
phase4-php-nginx.sh
phase5-snmp.sh
phase6-cron.sh
phase7-syslog.sh
phase8-finalize.sh
)

for FILE in "${FILES[@]}"; do
    if [[ ! -f "$FILE" ]]; then
        echo
        echo -e "${RED}Missing file:${NC} $FILE"
        exit 1
    fi
done

################################################################################
# Collect information
################################################################################

echo

read -rp "Server hostname (FQDN or IP): " SERVER_NAME

echo

read -rp "Timezone [America/Sao_Paulo]: " TIMEZONE

TIMEZONE=${TIMEZONE:-America/Sao_Paulo}

echo

read -rp "LibreNMS database name [librenms]: " DB_NAME
DB_NAME=${DB_NAME:-librenms}

read -rp "LibreNMS database user [librenms]: " DB_USER
DB_USER=${DB_USER:-librenms}

read -sp "LibreNMS database password: " DB_PASS
echo

################################################################################
# Export variables
################################################################################

export SERVER_NAME
export TIMEZONE
export DB_NAME
export DB_USER
export DB_PASS

################################################################################
# Phase runner
################################################################################

run_phase() {

    echo
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Running $1${NC}"
    echo -e "${BLUE}============================================================${NC}"

    bash "$1"

    echo
    echo -e "${GREEN}$1 completed successfully.${NC}"
}

################################################################################
# Execute phases
################################################################################

run_phase phase1-base.sh
run_phase phase2-librenms.sh
run_phase phase3-mariadb.sh
run_phase phase4-php-nginx.sh
run_phase phase5-snmp.sh
run_phase phase6-cron.sh
run_phase phase7-syslog.sh
run_phase phase8-finalize.sh

################################################################################
# Finish
################################################################################

clear

echo

echo -e "${GREEN}"
echo "============================================================"
echo "          LibreNMS Installation Completed"
echo "============================================================"
echo -e "${NC}"

echo

echo "Web Interface:"
echo "http://$SERVER_NAME"

echo
echo "Database"

echo " Host     : localhost"
echo " Port     : 3306"
echo " Database : $DB_NAME"
echo " User     : $DB_USER"

echo
echo "Próximos passos"

echo "1) Abra a interface WEB"

echo "2) Crie o usuário administrador"

echo "3) Adicione seu primeiro dispositivo"

echo "4) Execute a validação"

echo
echo "sudo -u librenms php /opt/librenms/validate.php"

echo