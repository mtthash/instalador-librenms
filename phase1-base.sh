#!/usr/bin/env bash

################################################################################
# LibreNMS Instalação
# Phase 1 - Base System
################################################################################

set -euo pipefail

echo
echo "=================================================="
echo " Phase 1 - Preparing Ubuntu"
echo "=================================================="
echo

################################################################################
# Checagem de root
################################################################################

if [[ $EUID -ne 0 ]]; then
    echo "Execute as root."
    exit 1
fi

################################################################################
# Atualizando repositórios
################################################################################

echo
echo "[1/9] Updating repositories..."
echo

apt update

################################################################################
# Atualizr pacotes instalados
################################################################################

echo
echo "[2/9] Upatualizando pacotes instalados..."
echo

DEBIAN_FRONTEND=noninteractive apt upgrade -y

################################################################################
# Instalar pacotes base / dependências
################################################################################

echo
echo "[3/9] Instalando pacotes base / dependências..."
echo

DEBIAN_FRONTEND=noninteractive apt install -y \
acl \
bash-completion \
ca-certificates \
composer \
cron \
curl \
dnsutils \
fping \
git \
graphviz \
imagemagick \
iputils-ping \
mariadb-client \
mariadb-server \
mtr-tiny \
nginx-full \
nmap \
python3 \
python3-command-runner \
python3-dotenv \
python3-pip \
python3-psutil \
python3-pymysql \
python3-redis \
python3-setuptools \
python3-systemd \
rrdtool \
snmp \
snmpd \
sudo \
tcpdump \
traceroute \
unzip \
vim \
wget \
whois

################################################################################
# Instalar pacotes PHP
################################################################################

echo
echo "[4/9] Instalando pacotes PHP..."
echo

DEBIAN_FRONTEND=noninteractive apt install -y \
php-cli \
php-common \
php-curl \
php-fpm \
php-gd \
php-gmp \
php-mbstring \
php-mysql \
php-snmp \
php-xml \
php-zip \
php-bcmath

################################################################################
# Detectar versão do PHP
################################################################################

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

echo
echo "Versão do PHP: ${PHP_VERSION}"
echo

################################################################################
# Configurar timezone
################################################################################

echo
echo "[5/9] Configurando timezone..."
echo

timedatectl set-timezone "${TIMEZONE}"

sed -i "s#;date.timezone =#date.timezone = ${TIMEZONE}#g" \
/etc/php/${PHP_VERSION}/cli/php.ini

sed -i "s#;date.timezone =#date.timezone = ${TIMEZONE}#g" \
/etc/php/${PHP_VERSION}/fpm/php.ini

################################################################################
# Habilitar serviços
################################################################################

echo
echo "[6/9] Habilitando serviços..."
echo

systemctl enable mariadb
systemctl enable nginx
systemctl enable php${PHP_VERSION}-fpm
systemctl enable cron
systemctl enable snmpd

################################################################################
# Restartar serviços
################################################################################

echo
echo "[7/9] Restartando serviços..."
echo

systemctl restart mariadb
systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl restart cron
systemctl restart snmpd

################################################################################
# Verificar binários instalados
################################################################################

echo
echo "[8/9] Verificando binários instalados..."
echo

for cmd in \
git \
php \
composer \
mysql \
nginx \
rrdtool \
snmpwalk \
python3
do

    if command -v "$cmd" >/dev/null; then
        printf "%-15s OK\n" "$cmd"
    else
        printf "%-15s FAILED\n" "$cmd"
        exit 1
    fi

done

################################################################################
# Mostar versões instaladas
################################################################################

echo
echo "[9/9] Instalando versões dos pacotes..."
echo

echo "Ubuntu : $(lsb_release -ds)"
echo "PHP    : $(php -v | head -1)"
echo "MariaDB: $(mysql --version)"
echo "Python : $(python3 --version)"
echo "Nginx  : $(nginx -v 2>&1)"
echo "Git    : $(git --version)"
echo "RRDTool: $(rrdtool --version)"

echo
echo "=================================================="
echo " Fase 1 - Preparação concluída!"
echo "=================================================="
echo