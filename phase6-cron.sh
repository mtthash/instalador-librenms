#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNms Instalador v2.0"
echo " Phase 6 - LibreNMS Services"
echo "==============================================="

echo
echo "Configurando Cron..."

cp /opt/librenms/dist/librenms.cron \
/etc/cron.d/librenms

chmod 644 /etc/cron.d/librenms
chown root:root /etc/cron.d/librenms

echo
echo "Configurando Scheduler..."

cp /opt/librenms/dist/librenms-scheduler.service \
/etc/systemd/system/

cp /opt/librenms/dist/librenms-scheduler.timer \
/etc/systemd/system/

systemctl daemon-reload

systemctl enable librenms-scheduler.timer
systemctl start librenms-scheduler.timer

echo
echo "Configurando Logrotate..."

cp /opt/librenms/misc/librenms.logrotate \
/etc/logrotate.d/librenms

chmod 644 /etc/logrotate.d/librenms

echo
echo "Instalando comando lnms..."

ln -sf /opt/librenms/lnms /usr/local/bin/lnms

echo
echo "Instalando Bash Completion..."

cp /opt/librenms/misc/lnms-completion.bash \
/etc/bash_completion.d/

echo
echo "Corrigindo permissões..."

chown -R librenms:librenms /opt/librenms

setfacl -R -m u:www-data:rwx \
/opt/librenms/storage \
/opt/librenms/bootstrap/cache

setfacl -dR -m u:www-data:rwx \
/opt/librenms/storage \
/opt/librenms/bootstrap/cache

echo
echo "Recarregando Cron..."

systemctl restart cron

echo
echo "Validando instalação..."

sudo -u librenms php /opt/librenms/validate.php || true

echo
echo "==============================================="
echo " Serviços configurados!"
echo "==============================================="

echo
echo "Resumo"

echo "Cron............. OK"
echo "Scheduler........ OK"
echo "Logrotate........ OK"
echo "lnms............. $(command -v lnms)"
echo "Cron file........ /etc/cron.d/librenms"

echo
echo "Próxima etapa:"
echo "./phase7-final.sh"