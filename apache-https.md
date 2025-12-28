#!/bin/bash

# ==========================================
# Debian Web Server Setup (Apache + SSL)
# ==========================================

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}      DEBIAN APACHE SETUP AUTOMATION     ${NC}"
echo -e "${BLUE}=========================================${NC}"

# 1. Проверка прав root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED} Запустите скрипт от имени root (sudo ./install.sh)${NC}"
  exit 1
fi

# 2. Обновление системы
echo -e "${GREEN} Обновляем пакеты (apt update & upgrade)...${NC}"
apt update && apt upgrade -y

# 3. Установка Apache и UFW
echo -e "${GREEN}  Устанавливаем Apache2 и Firewall...${NC}"
apt install apache2 ufw -y

# Настройка Firewall
ufw allow 'Apache'
ufw allow 22/tcp  # Важно: не блокируем SSH
ufw --force enable

# 4. Создание index.html
echo -e "${GREEN}  Генерируем красивый index.html...${NC}"
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Мой сервер</title>
  <style>
    body { font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #f4f4f4; }
    h1 { color: #333; }
    .status { color: #28a745; font-weight: bold; }
    .card { background: white; padding: 20px; border-radius: 8px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
  </style>
</head>
<body>
  <div class="card">
    <h1>Apache работает </h1>
    <p>Система: Debian + Apache</p>
    <p class="status">● Status: Active</p>
  </div>
</body>
</html>
EOF

# 5. Права доступа
echo -e "${GREEN} Настраиваем права (chown/chmod)...${NC}"
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Проверка статуса Apache
if systemctl is-active --quiet apache2; then
    echo -e "${GREEN}✔ Apache успешно запущен!${NC}"
else
    echo -e "${RED} Ошибка запуска Apache!${NC}"
    exit 1
fi

# 6. Блок HTTPS (Certbot)
echo -e "${BLUE}=========================================${NC}"
read -p " Хотите настроить HTTPS (Let's Encrypt)? (y/n): " SETUP_SSL

if [[ "$SETUP_SSL" =~ ^[Yy]$ ]]; then
    read -p "Введите ваш домен (например, example.com): " DOMAIN_NAME

    if [ -z "$DOMAIN_NAME" ]; then
        echo -e "${RED} Домен не введен. Пропускаем SSL.${NC}"
    else
        echo -e "${GREEN}  Установка Certbot...${NC}"
        apt install certbot python3-certbot-apache -y

        # Создание VirtualHost конфига
        echo -e "${GREEN}  Создание VirtualHost для $DOMAIN_NAME...${NC}"
        VHOST_CONF="/etc/apache2/sites-available/$DOMAIN_NAME.conf"

        cat <<EOF > $VHOST_CONF
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

        a2ensite "$DOMAIN_NAME.conf"
        systemctl reload apache2

        echo -e "${GREEN}  Получение сертификата...${NC}"
        certbot --apache -d "$DOMAIN_NAME" -d "www.$DOMAIN_NAME" --non-interactive --agree-tos -m admin@$DOMAIN_NAME --redirect

        echo -e "${GREEN}✔ SSL настроен! Проверьте: https://$DOMAIN_NAME${NC}"
    fi
else
    echo -e "${BLUE}  Пропускаем настройку SSL. Сайт доступен по HTTP.${NC}"
fi

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN} Готово! Сервер настроен.${NC}"
echo -e "${BLUE}=========================================${NC}"
