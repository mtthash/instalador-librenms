#!/usr/bin/env bash

################################################################################
# LibreNMS Instalação
# Phase 2 - Install LibreNMS
################################################################################

set -euo pipefail

echo
echo "=================================================="
echo " Fase 2 - Instalando LibreNMS"
echo "=================================================="
echo

################################################################################
# Variaveis
################################################################################

INSTALL_DIR="/opt/librenms"
GIT_BRANCH="master"

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

################################################################################
# Criar usuário librenms
################################################################################

echo "[1/9] Criando usuário librenms..."

if ! id librenms >/dev/null 2>&1; then
    useradd \
        -r \
        -M \
        -d ${INSTALL_DIR} \
        -s /bin/bash \
        librenms

    echo "Usuário librenms criado com sucesso."
else
    echo "Usuário librenms já existe."
fi

################################################################################
# Clonar repositório LibreNMS
################################################################################

echo
echo "[2/9] Clonando repositório LibreNMS..."

if [[ ! -d ${INSTALL_DIR} ]]; then

    git clone \
        --depth 1 \
        --branch ${GIT_BRANCH} \
        https://github.com/librenms/librenms.git \
        ${INSTALL_DIR}

else
    echo "Repositório já existe."
fi

################################################################################
# Permissões
################################################################################

echo
echo "[3/9] Configurando permissões..."

chown -R librenms:librenms ${INSTALL_DIR}

chmod 771 ${INSTALL_DIR}

################################################################################
# Diretórios Laravel
################################################################################

mkdir -p \
${INSTALL_DIR}/storage/framework/cache \
${INSTALL_DIR}/storage/framework/cache/data \
${INSTALL_DIR}/storage/framework/sessions \
${INSTALL_DIR}/storage/framework/views \
${INSTALL_DIR}/storage/logs \
${INSTALL_DIR}/bootstrap/cache \
${INSTALL_DIR}/rrd

################################################################################
# ACL
################################################################################

echo
echo "[4/9] Aplicando ACL..."

setfacl -R -m u:www-data:rwx ${INSTALL_DIR}/storage
setfacl -R -m u:www-data:rwx ${INSTALL_DIR}/bootstrap/cache
setfacl -R -m u:www-data:rwx ${INSTALL_DIR}/rrd

setfacl -dR -m u:www-data:rwx ${INSTALL_DIR}/storage
setfacl -dR -m u:www-data:rwx ${INSTALL_DIR}/bootstrap/cache
setfacl -dR -m u:www-data:rwx ${INSTALL_DIR}/rrd

################################################################################
# Composer
################################################################################

echo
echo "[5/9] Instalando dependências do Composer..."

sudo -u librenms \
php ${INSTALL_DIR}/scripts/composer_wrapper.php install --no-dev

################################################################################
# .env
################################################################################

echo
echo "[6/9] Preparando arquivo .env..."

if [[ ! -f ${INSTALL_DIR}/.env ]]; then

    sudo -u librenms cp \
        ${INSTALL_DIR}/.env.example \
        ${INSTALL_DIR}/.env

fi

################################################################################
# Laravel key
################################################################################

echo
echo "[7/9] Gerando chave do Laravel..."

sudo -u librenms php ${INSTALL_DIR}/artisan key:generate --force

################################################################################
# Comando LNMS
################################################################################

echo
echo "[8/9] Instalando comando lnms..."

ln -sf ${INSTALL_DIR}/lnms /usr/local/bin/lnms

cp \
${INSTALL_DIR}/misc/lnms-completion.bash \
/etc/bash_completion.d/

################################################################################
# Validação
################################################################################

echo
echo "[9/9] Validando instalação..."

sudo -u librenms php ${INSTALL_DIR}/validate.php || true

echo
echo "=================================================="
echo " Fase 2 - LibreNMS instalado com sucesso!"
echo "=================================================="
echo