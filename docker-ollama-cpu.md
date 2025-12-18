# Docker + Ollama на Debian 13.2

Полная автоматизированная установка Docker CE и Ollama через docker-compose.

---

## 1. Установка Docker на Debian 13.2

### 1.1 Обновляем систему и ставим зависимости

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

### 1.2 Добавляем официальный GPG-ключ Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### 1.3 Добавляем репозиторий Docker

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 1.4 Устанавливаем Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```

### 1.5 Проверяем версии

```bash
docker --version
docker compose version
```

### 1.6 Запуск Docker без sudo (рекомендуется)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 2. Проверка Docker

```bash
docker run hello-world
```

Если контейнер отработал — Docker установлен корректно.

---

## 3. Установка Ollama в Docker через docker-compose

### 3.1 Создаём рабочую директорию

```bash
mkdir -p ~/ollama
cd ~/ollama
```

### 3.2 Создаём файл docker-compose.yml (CPU версия)

```bash
cat > docker-compose.yml << 'EOF'
version: "3.9"

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
EOF
```

**Что означает:**
- 🔌 Порт `11434` — HTTP API Ollama
- 💾 Volume `ollama_data` — сохранение всех моделей
- ⏱️ `OLLAMA_KEEP_ALIVE=24h` — модель в памяти 24 часа

### 3.3 Запуск Ollama

```bash
docker compose up -d
```

**Проверка статуса:**

```bash
docker ps
```

---

## 4. Проверка работы Ollama

### 4.1 Проверка API

```bash
curl http://localhost:11434
```

**Ожидаемый ответ:**
```
Ollama is running
```

### 4.2 Загрузка модели

```bash
docker exec -it ollama ollama pull llama3
```

### 4.3 Запуск модели в интерактивном режиме

```bash
docker exec -it ollama ollama run llama3
```

---

## 5. Использование Ollama с хоста

### Пример API запроса

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Привет! Кто ты?"
}'
```

### Пример с потоком ответа

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Напиши мне рассказ о котике",
  "stream": false
}' | jq .response
```

---

## 6. Полезные команды

### Просмотр статуса

| Команда | Описание |
|---------|---------|
| `docker ps` | Список активных контейнеров |
| `docker logs -f ollama` | Логи в реальном времени |
| `docker exec -it ollama ollama list` | Список загруженных моделей |

### Управление контейнером

| Команда | Описание |
|---------|---------|
| `docker compose up -d` | Запустить Ollama |
| `docker compose down` | Остановить Ollama |
| `docker compose pull` | Обновить образ |
| `docker compose up -d` | Перезапустить |

### Работа с моделями

| Команда | Описание |
|---------|---------|
| `docker exec -it ollama ollama pull llama3` | Загрузить модель llama3 |
| `docker exec -it ollama ollama pull mistral` | Загрузить модель mistral |
| `docker exec -it ollama ollama list` | Показать загруженные модели |

### Очистка

| Команда | Описание |
|---------|---------|
| `docker system prune -a` | Удалить неиспользуемые образы |
| `docker volume rm ollama_data` | ⚠️ Удалить все модели (осторожно!) |

---

## 7. Популярные модели Ollama

```bash
# Быстрые и лёгкие
docker exec -it ollama ollama pull orca-mini
docker exec -it ollama ollama pull neural-chat

# Мощные
docker exec -it ollama ollama pull llama3
docker exec -it ollama ollama pull mistral

# Специализированные
docker exec -it ollama ollama pull neural-chat     # Чат
docker exec -it ollama ollama pull codegemma       # Программирование
```

---

## 8. GPU поддержка (NVIDIA)

Если у вас есть NVIDIA GPU, установите поддержку:

### 8.1 Установка nvidia-container-toolkit

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 8.2 docker-compose.yml с GPU

```yaml
version: "3.9"

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
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

volumes:
  ollama_data:
```

---

## 9. Автоматизированный скрипт

Используйте готовый скрипт для полной установки:

```bash
chmod +x install-docker-ollama.sh
./install-docker-ollama.sh
```

---

## Возможные проблемы

### Docker требует sudo
Выполните:
```bash
sudo usermod -aG docker $USER
# Переоткройте терминал или выполните:
newgrp docker
```

### Ollama не отвечает на localhost:11434
Проверьте, запущен контейнер:
```bash
docker ps | grep ollama
```

Если контейнер упал, проверьте логи:
```bash
docker logs ollama
```

### Недостаточно памяти
Модели требуют RAM. Проверьте:
```bash
free -h
```

Уменьшите `OLLAMA_KEEP_ALIVE` в docker-compose.yml или используйте более лёгкие модели.

---

## Дополнительные ресурсы

- [Официальный сайт Docker](https://www.docker.com/)
- [Официальный сайт Ollama](https://ollama.ai/)
- [Ollama на GitHub](https://github.com/jmorganca/ollama)
- [Ollama Models](https://ollama.ai/library)

---

**Статус:** Протестировано на Debian 13.2

**Последнее обновление:** 2025-12-18
