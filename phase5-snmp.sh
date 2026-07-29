#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNMS Instalador v2.0"
echo " Fase 5 - SNMP"
echo "==============================================="

SNMP_COMMUNITY="public"

echo
echo "Configurando SNMP..."

cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf

sed -i "s/RANDOMSTRINGGOESHERE/${SNMP_COMMUNITY}/" \
/etc/snmp/snmpd.conf

echo
echo "Instalando script distro..."

curl -fsSL \
https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro \
-o /usr/bin/distro

chmod +x /usr/bin/distro

echo
echo "Habilitando SNMP..."

systemctl enable snmpd
systemctl restart snmpd

echo
echo "Testando SNMP..."

sleep 2

if snmpwalk -v2c -c ${SNMP_COMMUNITY} localhost \
1.3.6.1.2.1.1 >/dev/null 2>&1
then

    echo
    echo "✓ SNMP funcionando."

else

    echo
    echo "ERRO: SNMP não respondeu."
    exit 1

fi

echo
echo "==============================================="
echo " SNMP configurado com sucesso!"
echo "==============================================="

echo
echo "Community......: ${SNMP_COMMUNITY}"

echo
echo "Próxima etapa:"
echo "./phase6-cron.sh"