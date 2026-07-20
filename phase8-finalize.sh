#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNMS Instalador v2.0"
echo " Fase 8 - Finalização"
echo "==============================================="

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

echo
echo "Limpando cache do Laravel..."

sudo -u librenms php /opt/librenms/artisan optimize:clear >/dev/null 2>&1 || true

echo
echo "Executando daily.sh..."

sudo -u librenms /opt/librenms/daily.sh || true

echo
echo "Corrigindo permissões finais..."

chown -R librenms:librenms /opt/librenms

setfacl -R -m u:www-data:rwx \
/opt/librenms/storage \
/opt/librenms/bootstrap/cache

setfacl -dR -m u:www-data:rwx \
/opt/librenms/storage \
/opt/librenms/bootstrap/cache

echo
echo "==============================================="
echo " Verificando serviços"
echo "==============================================="

SERVICOS=(
mariadb
nginx
cron
snmpd
syslog-ng
php${PHP_VERSION}-fpm
)

for svc in "${SERVICOS[@]}"
do

    if systemctl is-active --quiet "$svc"
    then
        printf "%-25s [ OK ]\n" "$svc"
    else
        printf "%-25s [ FAIL ]\n" "$svc"
    fi

done

echo
echo "==============================================="
echo " Validando instalação"
echo "==============================================="

sudo -u librenms php /opt/librenms/validate.php || true

echo
echo "==============================================="
echo " Informações do servidor"
echo "==============================================="

echo "Hostname.............: $(hostname)"
echo "IP...................: $(hostname -I | awk '{print $1}')"
echo "PHP..................: $(php -v | head -1)"
echo "MariaDB..............: $(mysql --version)"
echo "LibreNMS.............: $(sudo -u librenms php /opt/librenms/lnms --version 2>/dev/null | head -1 || echo 'Instalado')"

echo
echo "Banco configurado"

grep "^DB_" /opt/librenms/.env

echo
echo "==============================================="
echo " INSTALAÇÃO CONCLUÍDA!"
echo "==============================================="

IP=$(hostname -I | awk '{print $1}')

echo
echo "Abra o navegador:"
echo

echo "http://${IP}"

echo
echo "Depois do Wizard Web:"
echo
echo "  • Crie o usuário administrador"
echo "  • Faça login"
echo "  • Adicione seus dispositivos SNMP"
echo "  • Execute uma descoberta inicial"

echo
echo "Para validar novamente:"
echo
echo "sudo -u librenms php /opt/librenms/validate.php"

echo
echo "Bom monitoramento! TAMO JUNTO =)"