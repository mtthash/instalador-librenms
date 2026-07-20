# LibreNMS Instalador v2.0

Script automatizado para instalação do LibreNMS em servidores Linux (Debian/Ubuntu).

## Requisitos

- Sistema Linux baseado em Debian (Debian 12+, Ubuntu 22.04+)
- Acesso root ou sudo
- Conexão com internet
- Mínimo 2 cores de CPU e 2GB de RAM

## Estrutura de Instalação

O instalador é dividido em 8 fases:

### Phase 1 - Base
`./phase1-base.sh`

Prepara o sistema operacional:
- Atualiza pacotes e repositórios
- Instala dependências básicas
- Cria usuário `librenms`
- Configura variáveis de ambiente

### Phase 2 - LibreNMS
`./phase2-librenms.sh`

Clona e prepara a aplicação LibreNMS:
- Clona repositório oficial do LibreNMS
- Instala dependências PHP via Composer
- Configura arquivo .env
- Define permissões de diretórios

### Phase 3 - MariaDB
`./phase3-mariadb.sh`

Instala e configura o banco de dados:
- Instala servidor MariaDB
- Cria usuário e banco de dados para LibreNMS
- Executa migrações iniciais
- Configura backup automático

### Phase 4 - PHP-FPM + Nginx
`./phase4-php-nginx.sh`

Configura o servidor web e PHP:
- Instala e configura PHP-FPM
- Instala e configura Nginx
- Define timezone para America/Sao_Paulo
- Ativa suporte a reescrita de URLs

**Configurações disponíveis:**
- Arquivo template: `templates/nginx-librenms.conf`
- Configuração PHP-FPM: `templates/php-fpm-librenms.conf`

### Phase 5 - SNMP
`./phase5-snmp.sh`

Configura o agente SNMP:
- Instala snmpd
- Configura community strings
- Habilita monitoramento local

### Phase 6 - Cron
`./phase6-cron.sh`

Configura tarefas agendadas:
- Daily: Executa rotinas diárias
- Poller: Coleta dados dos dispositivos
- Discoverer: Descobre novos dispositivos
- Alerts: Processa alertas

### Phase 7 - Syslog-ng
`./phase7-syslog.sh`

Instala e configura receptor de syslog:
- Instala syslog-ng-core
- Configura recepção TCP/UDP na porta 514
- Encaminha logs para LibreNMS

**Configurações disponíveis:**
- Arquivo template: `templates/syslog-ng.conf`

### Phase 8 - Finalização
`./phase8-finalize.sh`

Completa a instalação:
- Limpa cache da aplicação
- Executa scripts finais do LibreNMS
- Corrige permissões de diretórios
- Valida status de todos os serviços
- Exibe informações da instalação

## Como Usar

### Instalação Completa Automática

```bash
chmod +x install.sh
./install.sh
```

O script `install.sh` executará automaticamente todas as 8 fases.

### Instalação Fase por Fase (Manual)

```bash
chmod +x phase*.sh

# Executar uma fase de cada vez
./phase1-base.sh
./phase2-librenms.sh
./phase3-mariadb.sh
./phase4-php-nginx.sh
./phase5-snmp.sh
./phase6-cron.sh
./phase7-syslog.sh
./phase8-finalize.sh
```

## Variáveis de Configuração

Durante a instalação, o script pedirá as seguintes informações:

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `LIBRENMS_VERSION` | Versão do LibreNMS | master |
| `DB_HOST` | Host do banco de dados | localhost |
| `DB_USER` | Usuário do banco | librenms |
| `DB_NAME` | Nome do banco | librenms |
| `SNMP_COMMUNITY` | String de comunidade SNMP | public |
| `HOSTNAME_WEB` | Nome de host para acessar web | localhost |
| `TIMEZONE` | Timezone do servidor | America/Sao_Paulo |

## Configurações de Template

Os arquivos de configuração template estão localizados em `templates/`:

- `nginx-librenms.conf` - Configuração do Nginx
- `php-fpm-librenms.conf` - Configuração do PHP-FPM
- `syslog-ng.conf` - Configuração do Syslog-ng

Você pode personalizar estes arquivos antes de executar as respectivas fases.

## Acessando LibreNMS

Após a conclusão da instalação:

1. Acesse: `http://<IP_DO_SERVIDOR>`
2. Siga o wizard de configuração
3. Crie o usuário administrador
4. Faça login
5. Comece a adicionar dispositivos para monitoramento

## Validação da Instalação

```bash
# Validar instalação do LibreNMS
sudo -u librenms php /opt/librenms/validate.php

# Verificar status dos serviços
systemctl status mariadb
systemctl status nginx
systemctl status php8.X-fpm
systemctl status snmpd
systemctl status syslog-ng
systemctl status cron
```

## Estrutura de Diretórios

```
/opt/librenms/              # Aplicação principal
├── html/                   # Arquivos web (Nginx root)
├── storage/                # Armazenamento de dados
├── bootstrap/cache/        # Cache da aplicação
├── database/               # Migrations
├── .env                    # Variáveis de ambiente
└── syslog.php             # Handler de syslog

/etc/nginx/conf.d/
└── librenms.conf          # Configuração do Nginx

/etc/php/8.X/fpm/pool.d/
└── librenms.conf          # Configuração PHP-FPM

/etc/syslog-ng/conf.d/
└── librenms.conf          # Configuração Syslog-ng
```

## Troubleshooting

### 1. Erro ao acessar a web
```bash
# Verificar permissões
ls -la /opt/librenms/html

# Verificar Nginx
nginx -t
systemctl restart nginx
```

### 2. Banco de dados não conecta
```bash
# Testar conexão
mysql -u librenms -p librenms

# Verificar status
systemctl status mariadb
```

### 3. Syslog-ng não funciona
```bash
# Testar sintaxe
syslog-ng --syntax-only

# Ver logs
journalctl -u syslog-ng -f
```

### 4. SNMP não coleta dados
```bash
# Testar SNMP local
snmpget -v2c -c public localhost sysUpTime.0

# Ver status
systemctl status snmpd
```

## Logs

Verificar logs de instalação:

```bash
# Nginx
tail -f /var/log/nginx/error.log

# PHP-FPM
tail -f /var/log/php8.X-fpm.log

# MariaDB
tail -f /var/log/mysql/error.log

# Syslog-ng
journalctl -u syslog-ng -f

# LibreNMS
tail -f /opt/librenms/storage/logs/laravel.log
```

## Suporte

Para dúvidas ou problemas:
1. Consulte a documentação oficial: https://docs.librenms.org
2. Visite o fórum: https://community.librenms.org
3. Abra uma issue: https://github.com/librenms/librenms/issues

## Licença

LibreNMS é licenciado sob AGPLv3. Veja LICENSE.txt

---

**Bom monitoramento! TAMO JUNTO =)**
