#!/bin/bash
# Финальный авто-почтовый сервер Debian 12
# Postfix + Dovecot + DKIM + TLS + Maildir + проверка DNS/SPF/DKIM/MX/PTR + тест SMTP

set -e

DOMAIN=$1
MAILUSER="postmaster"
HOSTNAME="mail.$DOMAIN"

if [ -z "$DOMAIN" ]; then
  echo "Использование: $0 example.com"
  exit 1
fi

echo "=== Проверка DNS ==="
A_RECORD=$(dig +short "$HOSTNAME")
[ -z "$A_RECORD" ] && { echo "❌ A-запись для $HOSTNAME не найдена!"; exit 1; }
echo "A-запись: $A_RECORD"

MX_RECORD=$(dig +short MX "$DOMAIN")
[ -z "$MX_RECORD" ] && { echo "❌ MX-запись для $DOMAIN не найдена!"; exit 1; }
echo "MX-запись: $MX_RECORD"

SPF_RECORD=$(dig +short TXT "$DOMAIN" | grep "v=spf1")
[ -z "$SPF_RECORD" ] && { echo "❌ SPF-запись для $DOMAIN не найдена!"; exit 1; }
echo "SPF-запись: $SPF_RECORD"

PTR=$(dig +short -x "$A_RECORD")
[ -z "$PTR" ] && { echo "❌ PTR-запись для $A_RECORD не найдена!"; exit 1; }
echo "PTR для $A_RECORD → $PTR"
[ "$PTR" != "$HOSTNAME." ] && { echo "❌ PTR-запись не совпадает с $HOSTNAME!"; exit 1; }

echo "=== Проверка портов ==="
for port in 25 587 143 993; do
  if ss -tuln | grep -q ":$port "; then
    echo "❌ Порт $port занят процессом: $(ss -tulnp | grep ":$port ")"
    exit 1
  else
    echo "✅ Порт $port свободен"
  fi
done

echo "=== Обновление системы ==="
apt update && apt upgrade -y

echo "=== Установка пакетов ==="
DEBIAN_FRONTEND=noninteractive apt install -y \
  postfix dovecot-core dovecot-imapd opendkim opendkim-tools certbot dnsutils swaks

echo "=== Настройка Postfix ==="
debconf-set-selections <<< "postfix postfix/mailname string $DOMAIN"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

postconf -e "myhostname = $HOSTNAME"
postconf -e "mydomain = $DOMAIN"
postconf -e "myorigin = /etc/mailname"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"
postconf -e "mydestination = localhost, $DOMAIN, $HOSTNAME"
postconf -e "home_mailbox = Maildir/"
postconf -e "smtpd_banner = \$myhostname ESMTP"
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination"
postconf -e "smtpd_tls_security_level = encrypt"
postconf -e "smtpd_tls_cert_file = /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
postconf -e "smtpd_tls_key_file = /etc/letsencrypt/live/$DOMAIN/privkey.pem"

echo "=== Настройка Dovecot ==="
cat > /etc/dovecot/dovecot.conf <<EOF
disable_plaintext_auth = yes
mail_location = maildir:~/Maildir
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
protocols = imap
ssl = required
ssl_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
ssl_ciphers = HIGH:!aNULL:!MD5
ssl_cert = </etc/letsencrypt/live/$DOMAIN/fullchain.pem
ssl_key = </etc/letsencrypt/live/$DOMAIN/privkey.pem
EOF

echo "=== Настройка DKIM ==="
mkdir -p "/etc/opendkim/keys/$DOMAIN"
opendkim-genkey -D "/etc/opendkim/keys/$DOMAIN/" -d "$DOMAIN" -s mail
chown -R opendkim:opendkim "/etc/opendkim/keys/$DOMAIN"
[ ! -f "/etc/opendkim/keys/$DOMAIN/mail.private" ] && { echo "❌ DKIM-ключи не созданы!"; exit 1; }

echo "Публичный DKIM-ключ:"
cat "/etc/opendkim/keys/$DOMAIN/mail.txt"

echo "mail._domainkey.$DOMAIN $DOMAIN:mail:/etc/opendkim/keys/$DOMAIN/mail.private" >> /etc/opendkim/KeyTable
echo "*@$DOMAIN mail._domainkey.$DOMAIN" >> /etc/opendkim/SigningTable
echo "127.0.0.1" >> /etc/opendkim/TrustedHosts
sed -i 's/^SOCKET.*/SOCKET="inet:12301@localhost"/' /etc/default/opendkim

postconf -e "milter_default_action = accept"
postconf -e "milter_protocol = 6"
postconf -e "smtpd_milters = inet:localhost:12301"
postconf -e "non_smtpd_milters = inet:localhost:12301"

echo "=== Создание почтового пользователя и Maildir ==="
read -sp "Введите пароль для пользователя $MAILUSER: " MAILPASS
echo
useradd -m "$MAILUSER"
echo "$MAILUSER:$MAILPASS" | chpasswd
sudo -u "$MAILUSER" maildirmake.dovecot "/home/$MAILUSER/Maildir" || { echo "❌ Не удалось создать Maildir!"; exit 1; }
sudo chown -R "$MAILUSER:$MAILUSER" "/home/$MAILUSER/Maildir"

echo "=== Получение TLS-сертификата ==="
systemctl stop nginx apache2 2>/dev/null || true
certbot certonly --standalone -d "$HOSTNAME" --non-interactive --agree-tos -m "$MAILUSER@$DOMAIN"
[ ! -d "/etc/letsencrypt/live/$HOSTNAME" ] && { echo "❌ Не удалось получить TLS-сертификат!"; exit 1; }

echo "=== Запуск сервисов ==="
systemctl enable postfix dovecot opendkim
systemctl restart postfix dovecot opendkim

echo "=== Тест DKIM ==="
opendkim-testkey -d "$DOMAIN" -s mail -vvv

echo "=== Тест отправки письма через swaks ==="
read -p "Введите email для теста доставки: " TESTMAIL
if ! swaks --to "$TESTMAIL" --from "$MAILUSER@$DOMAIN" --server "$HOSTNAME" --auth LOGIN --auth-user "$MAILUSER@$DOMAIN" --auth-password "$MAILPASS" --tls; then
  echo "❌ Тест отправки письма не удался!"
  exit 1
fi

echo "======================================="
echo "📬 Почтовый сервер установлен!"
echo " Домен: $DOMAIN"
echo " Пользователь: $MAILUSER"
echo "======================================="
echo "➡️ DNS-записи для добавления:"
echo " MX   10 $HOSTNAME"
echo " A        $HOSTNAME → $A_RECORD"
echo " TXT SPF  $SPF_RECORD"
echo " TXT DKIM  см. /etc/opendkim/keys/$DOMAIN/mail.txt"
echo "⚠️ Не забудьте добавить DMARC-запись: _dmarc.$DOMAIN  v=DMARC1; p=none; rua=mailto:$MAILUSER@$DOMAIN"
echo "======================================="
