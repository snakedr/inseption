# Работа с SSH-ключами и настройка SSH-сервера

> Полное руководство по генерации, управлению и защите SSH-ключей на Linux

## Содержание

- [Генерация SSH-ключей](#генерация-ssh-ключей)
- [Добавление ключа в ssh-agent](#добавление-ключа-в-ssh-agent)
- [Настройка ~/.ssh/config](#настройка-sshconfig)
- [Настройка SSH-сервера (sshd_config)](#настройка-ssh-сервера-sshd_config)
- [Файлы конфигурации в /etc/ssh/sshd_config.d/](#файлы-конфигурации-в-etcsshsshd_configd)
- [Безопасность](#безопасность)
- [Полезные команды](#полезные-команды)

---

## Генерация SSH-ключей

### 1. Создайте новый SSH-ключ

**Рекомендуется использовать ed25519** (современный и безопасный):

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Для совместимости со старыми системами используйте RSA**:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 2. Укажите путь для сохранения

По умолчанию:
- `~/.ssh/id_ed25519` (для ed25519)
- `~/.ssh/id_rsa` (для RSA)

### 3. Установите парольную фразу (passphrase)

Это дополнительный уровень защиты приватного ключа.

---

## Добавление ключа в ssh-agent

### 1. Запустите ssh-agent (если ещё не запущен)

```bash
eval "$(ssh-agent -s)"
```

### 2. Добавьте ключ

```bash
ssh-add ~/.ssh/id_ed25519
```

### 3. Проверьте, что ключ добавлен

```bash
ssh-add -l
```

---

## Настройка ~/.ssh/config

Файл `~/.ssh/config` позволяет удобно управлять подключениями к нескольким серверам без необходимости помнить все параметры.

### Пример конфигурации

```bash
Host myserver
    HostName example.com
    User username
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host production
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa_prod
    IdentitiesOnly yes

Host github
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_github
    IdentitiesOnly yes
    AddKeysToAgent yes
```

### Описание параметров

| Параметр | Описание |
|----------|---------|
| `Host` | Псевдоним для удобного обращения (используется как `ssh myserver`) |
| `HostName` | IP-адрес или доменное имя сервера |
| `User` | Имя пользователя для подключения |
| `Port` | Порт SSH-сервера (по умолчанию 22) |
| `IdentityFile` | Путь к приватному ключу |
| `IdentitiesOnly yes` | Использовать только указанный ключ, игнорируя остальные |
| `AddKeysToAgent yes` | Автоматически добавлять ключ в ssh-agent |

---

## Настройка SSH-сервера (sshd_config)

Файл `/etc/ssh/sshd_config` управляет поведением SSH-сервера.

### Пример безопасной конфигурации

```bash
# Прослушиваемые порты
Port 22
Port 33333

# Аутентификация по ключу
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Запретить вход под root
PermitRootLogin prohibit-password

# Отключить вход по паролю
PasswordAuthentication no
ChallengeResponseAuthentication no

# Forwarding (по необходимости)
X11Forwarding yes
AllowTcpForwarding yes

# Управление сеансом
ClientAliveInterval 300
ClientAliveCountMax 2

# Логирование
SyslogFacility AUTH
LogLevel VERBOSE
```

### Применение изменений

```bash
sudo systemctl restart sshd
```

### Проверка синтаксиса конфигурации

```bash
sudo sshd -t
```

---

## Файлы конфигурации в /etc/ssh/sshd_config.d/

Современные дистрибутивы (Ubuntu 20.04+, Debian 11+) используют дополнительные конфиги в `/etc/ssh/sshd_config.d/`.

### Важно знать:

**Параметры в `sshd_config.d/*.conf` перезаписывают основной `sshd_config`**

Например, файл `/etc/ssh/sshd_config.d/50-cloud-init.conf` может содержать:

```bash
PasswordAuthentication yes
```

### Проверить все активные параметры

```bash
grep -r "PasswordAuthentication" /etc/ssh/
```

---

## Безопасность

### Установите правильные права доступа

**На клиенте:**

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/config
```

**На сервере:**

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 755 /home/username
```

### Используйте `IdentitiesOnly yes` в конфиге

Это предотвращает перебор всех ключей из ssh-agent:

```bash
Host myserver
    HostName example.com
    User username
    IdentityFile ~/.ssh/id_specific
    IdentitiesOnly yes
```

### Отключите вход под root

```bash
# В sshd_config:
PermitRootLogin prohibit-password
```

Используйте обычного пользователя и `sudo` для привилегированных операций.

### Используйте нестандартный порт

```bash
# Измените Port 22 на другой, например:
Port 2222
```

### Отключите вход по паролю

```bash
PasswordAuthentication no
```

### Регулярно проверяйте лог-файлы

```bash
sudo journalctl -u ssh -f
```

---

## Полезные команды

| Команда | Описание |
|---------|---------|
| `ssh-keygen -t ed25519 -C "email@example.com"` | Создать новый SSH-ключ |
| `ssh-add ~/.ssh/id_ed25519` | Добавить ключ в ssh-agent |
| `ssh-add -l` | Показать все ключи в ssh-agent |
| `ssh-add -D` | Удалить все ключи из ssh-agent |
| `ssh -vvv user@server` | Подробный вывод подключения (отладка) |
| `sudo sshd -t` | Проверить синтаксис sshd_config |
| `sudo systemctl restart sshd` | Перезагрузить SSH-сервер |
| `sudo journalctl -u ssh -f` | Просмотреть логи SSH в реальном времени |
| `sudo ss -tulpn \| grep ssh` | Проверить, на каких портах слушает SSH |
| `ssh-keyscan example.com` | Получить public key сервера |
| `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server` | Скопировать публичный ключ на сервер |

---

## Отладка подключения

Если есть проблемы с подключением, используйте максимальное логирование:

```bash
ssh -vvv user@server
```

Результат подскажет, на каком этапе происходит ошибка.

---

## Дополнительные ресурсы

- [OpenSSH Official Documentation](https://man.openbsd.org/ssh)
- [SSH Best Practices](https://infosec.mozilla.org/guidelines/openssh)
- [GitHub SSH Setup Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

**Последнее обновление:** December 2025

