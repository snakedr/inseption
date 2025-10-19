# Полная базовая настройка нового Linux-сервера

Эта инструкция описывает последовательную настройку нового сервера для безопасной и удобной работы.  
Подходит для любых Linux-дистрибутивов, с подключением по SSH и настройкой UTF-8.

---

## Создание SSH-ключей и подключение без пароля

**Зачем:** безопасное подключение без пароля, возможность автоматизации команд.  

На локальной машине (Mac/Linux):

```bash
# Генерация пары ключей
ssh-keygen -t ed25519 -C "your_email@example.com"

# Копирование публичного ключа на сервер
ssh-copy-id user@server_ip

# Проверка подключения
ssh user@server_ip
```

После этого можно подключаться к серверу без ввода пароля.

---

## Настройка локали UTF-8

**Зачем:** корректная работа терминала, редакторов, логов и скриптов.

На сервере:

```bash
# Добавляем переменные локали
echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
echo "export LC_CTYPE=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc

# Применяем изменения
source ~/.bashrc

# Генерируем локаль
sudo locale-gen en_US.UTF-8
sudo update-locale

# Проверка
locale
```

После этого все поля должны показывать `en_US.UTF-8`.

---

## Смена порта SSH

**Зачем:** повышает безопасность.

Выберите порт в диапазоне 1024–65535, который не занят другими сервисами.

```bash
sudo nano /etc/ssh/sshd_config
```

```
# Измените строку:
# Port 22
Port 2222
```

```bash
# Перезапуск сервиса
sudo systemctl restart sshd
```

После этого подключение по стандартному порту 22 будет закрыто, используйте новый порт для SSH.

---

## Создание нового пользователя с правами sudo

**Зачем:** работа под root напрямую небезопасна.

```bash
sudo adduser newuser
sudo usermod -aG sudo newuser

# Подключение через нового пользователя
ssh newuser@server_ip -p 2222
```

`newuser` — новый администратор сервера.

---

## Отключение root

**Зачем:** повышает безопасность, исключая прямой root-доступ.

```bash
sudo nano /etc/ssh/sshd_config
```

```
# Изменяем:
PermitRootLogin no
```

```bash
# Перезапуск ssh
sudo systemctl restart sshd
```

Root больше не сможет заходить по SSH напрямую.

---

## Обновление системы

**Зачем:** актуальные пакеты и исправления безопасности.

```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y

# Fedora
sudo dnf update -y
```

---

## Установка базовых пакетов

```bash
# Debian/Ubuntu
sudo apt install -y git curl wget vim htop ufw fail2ban

# CentOS/RHEL
sudo yum install -y git curl wget vim htop firewalld fail2ban
```

Можно добавить любые пакеты для проектов (docker, python, nodejs и т.д.).

---

## Настройка Firewall и базовая безопасность

### Для Debian/Ubuntu с UFW:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp         # SSH порт
sudo ufw enable
sudo ufw status
sudo ufw logging off           # это выключение логов, делается на выключенном ufw
```

### Для CentOS/RHEL с firewalld:

```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

---

## Резюме

Сервер настроен для:

- Безопасного подключения через SSH ключи на нестандартном порту
- Работы через пользователя с sudo, root отключён
- Корректной UTF-8 локали
- Обновлённой системы и установленных базовых пакетов
- Защищённого firewall

---

## Дополнительные рекомендации

После базовой настройки рекомендуется:

1. **Настроить автоматические обновления безопасности**
2. **Установить fail2ban для защиты от брутфорса**
3. **Настроить мониторинг логов**
4. **Создать резервное копирование конфигураций**

---

## Лицензия

MIT License - свободное использование и модификация.
