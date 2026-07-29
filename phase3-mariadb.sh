#!/bin/bash

set -e

clear

echo "==============================================="
echo " LibreNMS Instalador v2.0"
echo " Fase 3 - MariaDB"
echo "==============================================="

DB_PASSWORD="${DB_PASS}"
DB_USER="${DB_USER:-librenms}"
DB_NAME="${DB_NAME:-librenms}"

echo
echo "Configurando MariaDB..."

cat >/etc/mysql/mariadb.conf.d/99-librenms.cnf <<EOF
[mysqld]
innodb_file_per_table=1
lower_case_table_names=0
EOF

systemctl enable mariadb
systemctl restart mariadb

echo
echo "Criando banco..."

mysql <<EOF

CREATE DATABASE IF NOT EXISTS ${DB_NAME}
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost'
IDENTIFIED BY '${DB_PASSWORD}';

ALTER USER '${DB_USER}'@'localhost'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES
ON ${DB_NAME}.*
TO '${DB_USER}'@'localhost';

FLUSH PRIVILEGES;

EOF

echo
echo "Testando conexão..."

mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -e "USE ${DB_NAME};"

echo
echo "Configurando variáveis de banco no .env..."

INSTALL_DIR="/opt/librenms"

if grep -q "^DB_HOST=" ${INSTALL_DIR}/.env; then
    sed -i "s/^DB_HOST=.*/DB_HOST=localhost/" ${INSTALL_DIR}/.env
else
    echo "DB_HOST=localhost" >> ${INSTALL_DIR}/.env
fi

if grep -q "^DB_DATABASE=" ${INSTALL_DIR}/.env; then
    sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" ${INSTALL_DIR}/.env
else
    echo "DB_DATABASE=${DB_NAME}" >> ${INSTALL_DIR}/.env
fi

if grep -q "^DB_USERNAME=" ${INSTALL_DIR}/.env; then
    sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" ${INSTALL_DIR}/.env
else
    echo "DB_USERNAME=${DB_USER}" >> ${INSTALL_DIR}/.env
fi

if grep -q "^DB_PASSWORD=" ${INSTALL_DIR}/.env; then
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" ${INSTALL_DIR}/.env
else
    echo "DB_PASSWORD=${DB_PASSWORD}" >> ${INSTALL_DIR}/.env
fi

chown librenms:librenms ${INSTALL_DIR}/.env
chmod 640 ${INSTALL_DIR}/.env

echo
echo "Executando migrations do banco..."

sudo -u librenms php ${INSTALL_DIR}/artisan config:clear --no-interaction || true
sudo -u librenms php ${INSTALL_DIR}/artisan migrate --force --no-interaction

echo
echo "==============================================="
echo " MariaDB configurado com sucesso!"
echo "==============================================="

echo
echo "Banco........: librenms"
echo "Usuário......: librenms"
echo "Porta........: 3306"

echo
echo "Próxima etapa:"
echo "./phase4-php-nginx.sh"