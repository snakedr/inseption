```bash
# Установка Debian 13.2 + Open WebUI + Gemini API (1 ГБ ОЗУ)

## 0. Обновление системы

sudo apt update
sudo apt upgrade -y

# 1. Установка пакетов, необходимых для HTTPS
sudo apt install ca-certificates curl gnupg lsb-release -y

# 2. Добавление официального GPG ключа Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Добавление репозитория Docker
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Установка Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


# 5.Рекомендуется создать файл подкачки размером 2 ГБ:

#Создание файла подкачки (2 ГБ):
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

#Чтобы включить подкачку постоянно, добавьте строку в /etc/fstab:
sudo nano /etc/fstab

#Добавьте в конец файла следующую строку, сохраните (Ctrl+O) и выйдите (Ctrl+X):
/swapfile none swap sw 0 0

#Проверить запуск и работу памяти:
free -h

#Развертывание Open WebUI через Docker Compose

Шаг 1: Создайте папку проекта и перейдите в нее Для порядка создадим отдельную папку для Open WebUI.

mkdir open-webui-project
cd open-webui-project

Шаг 2: Создайте файл docker-compose.yml

sudo nano docker-compose.yml
=======================
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    volumes:
      - open-webui:/app/backend/data
volumes:
  open-webui:
=======================

#Запустите контейнер в фоновом режиме, используя команду docker compose:
sudo docker compose up -d

#Проверка статуса:
sudo docker compose ps

#Доступ к интерфейсу
#Откройте браузер и перейдите по адресу: 

http://ваш_IP_server:3000

#Настройка доступа к языковой модели:

URL: https://generativelanguage.googleapis.com/v1beta/openai
API: #ваш API ключ
IDs: gemini-2.5-flash

# p.s.
# Быстрые команды администрирования
# Остановить
docker compose down

# Перезапустить
docker compose restart

# Просмотреть логи
docker compose logs -f
