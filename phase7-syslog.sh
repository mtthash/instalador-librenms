#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNMS Instalador v2.0"
echo " Fase 7 - Syslog-ng"
echo "==============================================="

echo
echo "Instalando syslog-ng..."

apt update
apt install -y syslog-ng-core

echo
echo "Criando configuração..."

cp templates/syslog-ng.conf /etc/syslog-ng/conf.d/librenms.conf

echo
echo "Configurando permissões..."

chown librenms:librenms /opt/librenms/syslog.php
chmod +x /opt/librenms/syslog.php

echo
echo "Habilitando serviço..."

systemctl enable syslog-ng
systemctl restart syslog-ng

echo
echo "Habilitando Syslog no LibreNMS..."

sudo -u librenms lnms config:set enable_syslog true || true

echo
echo "Validando configuração..."

syslog-ng --syntax-only

echo
echo "==============================================="
echo " Syslog configurado!"
echo "==============================================="

echo
echo "Portas utilizadas"

echo "UDP 514"

echo "TCP 514"

echo
echo "Próxima etapa:"
echo "./phase8-final.sh"