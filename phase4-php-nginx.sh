#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNMS Instalador v2.0"
echo " Fase 4 - PHP-FPM + Nginx"
echo "==============================================="

HOSTNAME_WEB="${SERVER_NAME}"

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

echo
echo "Versão do PHP detectada: ${PHP_VERSION}"

echo
echo "Configurando timezone..."

timedatectl set-timezone America/Sao_Paulo

for INI in \
/etc/php/${PHP_VERSION}/fpm/php.ini \
/etc/php/${PHP_VERSION}/cli/php.ini
do

sed -i \
's#^;*date.timezone *=.*#date.timezone = America/Sao_Paulo#' \
$INI

done

echo
echo "Configurando PHP-FPM..."

cp /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
   /etc/php/${PHP_VERSION}/fpm/pool.d/librenms.conf

sed -i 's/\[www\]/\[librenms\]/' \
/etc/php/${PHP_VERSION}/fpm/pool.d/librenms.conf

sed -i 's/user = www-data/user = librenms/' \
/etc/php/${PHP_VERSION}/fpm/pool.d/librenms.conf

sed -i 's/group = www-data/group = librenms/' \
/etc/php/${PHP_VERSION}/fpm/pool.d/librenms.conf

sed -i \
"s|listen = /run/php/php${PHP_VERSION}-fpm.sock|listen = /run/php-fpm-librenms.sock|" \
/etc/php/${PHP_VERSION}/fpm/pool.d/librenms.conf

systemctl enable php${PHP_VERSION}-fpm
systemctl restart php${PHP_VERSION}-fpm

echo
echo "Configurando Nginx..."

cp templates/nginx-librenms.conf /etc/nginx/conf.d/librenms.conf

sed -i "s|server_name _;|server_name ${HOSTNAME_WEB};|" \
/etc/nginx/conf.d/librenms.conf

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

echo
echo "Validando configuração do Nginx..."

nginx -t

systemctl enable nginx
systemctl restart nginx

echo
echo "==============================================="
echo " PHP-FPM e Nginx configurados!"
echo "==============================================="

echo
echo "PHP...............: ${PHP_VERSION}"
echo "Timezone..........: America/Sao_Paulo"
echo "PHP-FPM Socket....: /run/php-fpm-librenms.sock"

echo
echo "Próxima etapa:"
echo "./phase5-snmp.sh"