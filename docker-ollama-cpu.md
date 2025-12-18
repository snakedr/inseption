#1. Установка Docker на Debian 13.2
##1.1 Обновляем систему и ставим зависимости

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

##1.2 Добавляем официальный GPG-ключ Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings

```bash
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

##1.3 Добавляем репозиторий Docker

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

##1.4 Устанавливаем Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

##1.5 Проверяем

```bash
docker --version
docker compose version

1.6 (Рекомендуется) запуск Docker без sudo

```bash
sudo usermod -aG docker $USER
newgrp docker

2. Проверка Docker

```bash
docker run hello-world

Если контейнер отработал — Docker установлен корректно.

3. Установка Ollama в Docker через docker-compose
3.1 Создаём рабочую директорию

```bash
mkdir -p ~/ollama
cd ~/ollama

3.2 docker-compose.yml (CPU версия)

```bash
sudo nano docker-composer.yml

```bash
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_KEEP_ALIVE=24h

volumes:
  ollama_data:



Порт 11434 — HTTP API Ollama

Все модели сохраняются в volume ollama_data

3.3 Запуск Ollama

```bash
docker compose up -d


Проверка:

```bash
docker ps

4. Проверка работы Ollama
4.1 Проверка API

```bash
curl http://localhost:11434


Ожидаемый ответ:

"Ollama is running"

4.2 Загрузка модели (пример: llama3)

```bash
docker exec -it ollama ollama pull llama3


Запуск модели:

```bash
docker exec -it ollama ollama run llama3

5. Использование Ollama с хоста

Пример запроса:

curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Привет! Кто ты?"
}'

6. (Опционально) Версия с GPU (NVIDIA)

Если нужен GPU, скажи — дам:

настройку nvidia-container-toolkit

docker-compose.yml с deploy.resources.reservations.devices

7. Полезные команды

Остановка:

```bash
docker compose down

Обновление Ollama:

```bash
docker compose pull
docker compose up -d


Логи:

```bash
docker logs -f ollama
