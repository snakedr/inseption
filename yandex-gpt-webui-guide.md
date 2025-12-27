# Интеграция Yandex GPT с Open WebUI: Полное руководство

## Оглавление
1. [Введение](#введение)
2. [Способ 1: Прокси-адаптер OpenAI](#способ-1-прокси-адаптер-openai)
3. [Способ 2: Прямая интеграция в Open WebUI](#способ-2-прямая-интеграция-в-open-webui)
4. [API Yandex GPT: Справочник](#api-yandex-gpt-справочник)
5. [Альтернативные WebUI](#альтернативные-webui)
6. [Безопасность и доступ](#безопасность-и-доступ)
7. [Часто встречающиеся ошибки](#часто-встречающиеся-ошибки)

---

## Введение

Yandex GPT не имеет открытого веб-интерфейса, но есть несколько способов для его использования:

- **Прокси-адаптер** — преобразует OpenAI API формат в Yandex GPT API
- **Прямая интеграция** — через конфигурацию Open WebUI с modelUri
- **Альтернативные интерфейсы** — Gradio, Text Generation WebUI и другие

---

## Способ 1: Прокси-адаптер OpenAI

### Шаг 1. Сборка адаптера

**1.1. Клонируйте репозиторий:**

```bash
git clone https://github.com/ai-cookbook/openai-yandexgpt-adapter
cd openai-yandexgpt-adapter
```

**1.2. Настройте переменные окружения:**

Создайте файл `.env` в корне проекта:

```env
YC_FOLDER_ID=<ваш_идентификатор_каталога>
YC_IAM_TOKEN=<ваш_IAM_токен>
```

Где найти эти значения:
- **YC_FOLDER_ID**: В консоли Yandex Cloud → левое меню → выберите каталог → ID отображается рядом с именем
- **YC_IAM_TOKEN**: Получается через `yc iam create-token` (требует установленного Yandex Cloud CLI)

**1.3. Соберите Docker-контейнер:**

```bash
docker build -t openai-ygpt-adapter:local .
```

**1.4. Запустите контейнер:**

```bash
docker run -d -p 9041:9041 --name ygpt-adapter openai-ygpt-adapter:local
```

Флаги:
- `-d` — запуск в фоне
- `-p 9041:9041` — пробросить порт 9041
- `--name ygpt-adapter` — имя контейнера

### Шаг 2. Проверка адаптера

**Отправьте тестовый запрос через curl:**

```bash
curl -X POST http://<ваш_сервер>:9041/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "yandexgpt",
    "messages": [
      {
        "role": "user",
        "content": "Привет!"
      }
    ]
  }'
```

**Ожидаемый ответ:**

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "Привет! Чем я могу вам помочь?"
      }
    }
  ]
}
```

### Шаг 3. Подключение к Open WebUI

Откройте Open WebUI и перейдите в **Admin Panel** → **Settings** → **Connections** → **OpenAI**:

| Параметр | Значение |
|----------|----------|
| API URL | `http://<ваш_сервер>:9041/v1` |
| API Key | `any` (адаптер не требует аутентификации) |
| Model Name | `yandexgpt` |

Сохраните и протестируйте подключение.

---

## Способ 2: Прямая интеграция в Open WebUI

### Предварительные требования

- Учётная запись в Yandex Cloud
- API-ключ или IAM-токен
- ID каталога в Yandex Cloud

### Шаг 1. Получение учётных данных

**1.1. Получите API-ключ:**

```bash
# Через консоль Yandex Cloud
# Перейдите в "Сервисные аккаунты" → создайте новый → сгенерируйте API-ключ
```

**1.2. Найдите ID каталога:**

- В браузере откройте https://console.cloud.yandex.ru/folders/[id_здесь]
- ID отображается в URL после `/folders/`

**1.3. Убедитесь в роли сервисного аккаунта:**

Сервисный аккаунт должен иметь роль **`ai.languageModels.user`** для доступа к нейросетям.

### Шаг 2. Конфигурация в Open WebUI

Откройте **Settings** → **Models** и добавьте новую модель:

```json
{
  "name": "yandexgpt-lite",
  "modelUri": "gpt://<ID_каталога>/yandexgpt-lite/latest",
  "apiUrl": "https://llm.api.cloud.yandex.net/foundationModels/v1/completion",
  "apiKey": "<ваш_API_ключ>",
  "folderId": "<ID_каталога>"
}
```

### Доступные модели Yandex GPT

| Модель | modelUri | Характеристики |
|--------|----------|-----------------|
| Yandex GPT Lite | `gpt://<ID>/yandexgpt-lite/latest` | Быстрая, экономичная |
| Yandex GPT Pro | `gpt://<ID>/yandexgpt/latest` | Продвинутая, точнее |

---

## API Yandex GPT: Справочник

### Базовые эндпоинты

| Тип | URL |
|-----|-----|
| Синхронный запрос | `https://llm.api.cloud.yandex.net/foundationModels/v1/completion` |
| Асинхронный запрос | `https://llm.api.cloud.yandex.net/foundationModels/v1/completionAsync` |

### Обязательные заголовки

```http
Authorization: Api-Key <ваш_API_ключ>
x-folder-id: <ваш_ID_каталога>
Content-Type: application/json
```

### Структура тела запроса (синхронный)

```json
{
  "modelUri": "gpt://<ID_каталога>/yandexgpt-lite/latest",
  "completionOptions": {
    "temperature": 0.6,
    "maxTokens": "2000"
  },
  "messages": [
    {
      "role": "system",
      "text": "Ты — помощник, отвечающий на вопросы кратко и по делу."
    },
    {
      "role": "user",
      "text": "Объясни, как работает API Yandex GPT."
    }
  ]
}
```

### Параметры запроса

| Параметр | Описание | Тип | Диапазон |
|----------|---------|------|----------|
| `modelUri` | Идентификатор модели | string | — |
| `temperature` | Креативность ответа (0=детерминированный, 1=творческий) | float | 0.0–1.0 |
| `maxTokens` | Максимальная длина ответа | integer | до 4096 (Lite) / 10000 (Pro) |
| `role` | Роль в диалоге (system/user/assistant) | string | — |

### Примеры curl-запросов

**Простой синхронный запрос:**

```bash
curl -X POST \
  https://llm.api.cloud.yandex.net/foundationModels/v1/completion \
  -H "Authorization: Api-Key <ваш_API_ключ>" \
  -H "x-folder-id: <ID_каталога>" \
  -H "Content-Type: application/json" \
  -d '{
    "modelUri": "gpt://<ID_каталога>/yandexgpt-lite/latest",
    "completionOptions": {
      "temperature": 0.5,
      "maxTokens": "1000"
    },
    "messages": [
      {
        "role": "user",
        "text": "Как включить API Yandex GPT?"
      }
    ]
  }'
```

**С историей диалога:**

```bash
curl -X POST \
  https://llm.api.cloud.yandex.net/foundationModels/v1/completion \
  -H "Authorization: Api-Key <ваш_API_ключ>" \
  -H "x-folder-id: <ID_каталога>" \
  -H "Content-Type: application/json" \
  -d '{
    "modelUri": "gpt://<ID_каталога>/yandexgpt/latest",
    "completionOptions": {
      "temperature": 0.7,
      "maxTokens": "2000"
    },
    "messages": [
      {
        "role": "system",
        "text": "Ты — опытный программист."
      },
      {
        "role": "user",
        "text": "Как написать функцию на Python?"
      },
      {
        "role": "assistant",
        "text": "Функция в Python создаётся с помощью ключевого слова def..."
      },
      {
        "role": "user",
        "text": "А как обработать исключения?"
      }
    ]
  }'
```

### Структура ответа

**Успешный ответ (HTTP 200):**

```json
{
  "result": {
    "message": {
      "role": "assistant",
      "text": "Текст ответа модели..."
    },
    "usage": {
      "inputTokens": "50",
      "outputTokens": "150"
    }
  }
}
```

**Ошибка:**

```json
{
  "error": {
    "code": 400,
    "message": "Invalid folder ID"
  }
}
```

---

## Альтернативные WebUI

### Gradio (быстрый способ)

**Установка:**

```bash
pip install gradio ollama
```

**Код для простого чата (save_file.py):**

```python
import requests
import gradio as gr
import json

API_URL = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion"
API_KEY = "<ваш_API_ключ>"
FOLDER_ID = "<ID_каталога>"

def respond(message, history):
    """Отправляет запрос к Yandex GPT"""
    
    # Конвертируем историю в формат Yandex GPT
    messages = []
    for user_msg, assistant_msg in history:
        messages.append({"role": "user", "text": user_msg})
        if assistant_msg:
            messages.append({"role": "assistant", "text": assistant_msg})
    
    # Добавляем текущее сообщение
    messages.append({"role": "user", "text": message})
    
    headers = {
        "Authorization": f"Api-Key {API_KEY}",
        "x-folder-id": FOLDER_ID,
        "Content-Type": "application/json"
    }
    
    payload = {
        "modelUri": f"gpt://{FOLDER_ID}/yandexgpt-lite/latest",
        "completionOptions": {
            "temperature": 0.6,
            "maxTokens": "2000"
        },
        "messages": messages
    }
    
    try:
        response = requests.post(API_URL, json=payload, headers=headers)
        response.raise_for_status()
        result = response.json()
        return result["result"]["message"]["text"]
    except Exception as e:
        return f"Ошибка: {str(e)}"

# Запуск интерфейса
demo = gr.ChatInterface(
    respond,
    examples=["Привет!", "Расскажи о себе", "Как использовать API?"],
    title="Yandex GPT Chat",
    description="Чат с использованием Yandex GPT API"
)

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)
```

**Запуск:**

```bash
python save_file.py
```

Откройте http://localhost:7860

### Text Generation WebUI (Oobabooga)

Установка и настройка более сложная, но предоставляет больше функций:

```bash
git clone https://github.com/oobabooga/text-generation-webui
cd text-generation-webui
pip install -r requirements.txt
python server.py
```

Подробнее: https://github.com/oobabooga/text-generation-webui

---

## Безопасность и доступ

### Для локального использования

```bash
# Запустите адаптер только на localhost
docker run -d -p 127.0.0.1:9041:9041 --name ygpt-adapter openai-ygpt-adapter:local
```

**Правила:**
- Не открывайте порты в интернет
- Используйте приватную сеть
- Не коммитьте `.env` файл с учётными данными

### Для публичного доступа

**1. Настройте HTTPS (Nginx + Let's Encrypt):**

```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:9041;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**2. Добавьте аутентификацию (basic auth):**

```bash
# Установите htpasswd (Linux)
sudo apt-get install apache2-utils

# Создайте пароль
htpasswd -c /etc/nginx/.htpasswd username
```

```nginx
location / {
    auth_basic "API Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    proxy_pass http://127.0.0.1:9041;
}
```

**3. Ограничьте доступ по IP:**

```nginx
location / {
    allow 192.168.1.0/24;
    allow 203.0.113.0/24;
    deny all;
    
    proxy_pass http://127.0.0.1:9041;
}
```

### Переменные окружения (лучшие практики)

Используйте файл `.env` и `docker-compose.yml`:

```yaml
version: '3.8'

services:
  ygpt-adapter:
    build: .
    ports:
      - "127.0.0.1:9041:9041"
    environment:
      - YC_FOLDER_ID=${YC_FOLDER_ID}
      - YC_IAM_TOKEN=${YC_IAM_TOKEN}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9041/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```bash
# Запуск
docker-compose up -d
```

---

## Часто встречающиеся ошибки

### 1. "Invalid folder ID"

**Причина:** ID каталога неправильный или неправильно указан в заголовках.

**Решение:**
```bash
# Проверьте ID в консоли Yandex Cloud
# В заголовке x-folder-id должно быть только числовое значение
-H "x-folder-id: 123456789"
```

### 2. "Unauthorized"

**Причина:** API-ключ неверный или истёк.

**Решение:**
```bash
# Сгенерируйте новый API-ключ в консоли Yandex Cloud
# Убедитесь, что используете формат:
-H "Authorization: Api-Key abc123xyz..."
# или
-H "Authorization: Bearer your-iam-token..."
```

### 3. "Service account doesn't have permission"

**Причина:** Сервисному аккаунту не назначена роль `ai.languageModels.user`.

**Решение:**
```bash
# В консоли Yandex Cloud:
# 1. Выберите сервисный аккаунт
# 2. Нажмите "Добавить роль"
# 3. Выберите "ai.languageModels.user"
```

### 4. "maxTokens exceeds limit"

**Причина:** Запрошено больше токенов, чем позволяет модель.

**Решение:**
```json
{
  "completionOptions": {
    "maxTokens": "2000"  // Yandex GPT Lite: max 4096
  }
}
```

### 5. Docker контейнер не запускается

**Причина:** Порт уже занят или отсутствуют переменные окружения.

**Решение:**
```bash
# Проверьте занятость порта
lsof -i :9041

# Остановите процесс или используйте другой порт
docker run -d -p 9042:9041 --name ygpt-adapter openai-ygpt-adapter:local

# Проверьте логи
docker logs ygpt-adapter
```

### 6. "Connection refused" при подключении к Open WebUI

**Причина:** Open WebUI не может достучаться до адаптера.

**Решение:**
```bash
# Если Open WebUI в контейнере, используйте имя сервиса Docker
# или --network для связи контейнеров

docker network create ai-network

docker run -d -p 9041:9041 --network ai-network --name ygpt-adapter openai-ygpt-adapter:local

docker run -d -p 3000:8080 --network ai-network -e OPENAI_API_BASE_URL=http://ygpt-adapter:9041/v1 --name webui ghcr.io/open-webui/open-webui:latest
```

---

## Лимиты и квоты

### Yandex GPT API

| Параметр | Ограничение |
|----------|-------------|
| Макс. токенов на запрос (Lite) | 4,096 |
| Макс. токенов на запрос (Pro) | 10,000 |
| Макс. размер истории | 20,000 токенов |
| Запросы в секунду | зависит от тарифа |
| Время обработки | 5–30 сек в зависимости от нагрузки |

### Тарификация

Проверьте актуальные цены в [документации Yandex Cloud](https://cloud.yandex.ru/docs/foundation-models/pricing).

### Мониторинг

```bash
# Логирование в Yandex Cloud Logs
gcloud logging read "resource.type=api" --limit 50

# Метрики использования
# Доступны в консоли Yandex Cloud → Monitoring
```

---

## Итоговые рекомендации

| Сценарий | Решение |
|----------|---------|
| Локальное развёртывание с удобным UI | **Ollama + Open WebUI** |
| Облачная модель через OpenAI API | **Прокси-адаптер Yandex GPT** |
| Быстрое тестирование | **Gradio** |
| Максимум настроек и контроля | **Text Generation WebUI** |
| Прямая интеграция (нужны учётные данные) | **Open WebUI + modelUri** |

---

## Дополнительные ресурсы

- [Официальная документация Yandex Cloud](https://cloud.yandex.ru/docs/foundation-models/)
- [Репозиторий Open WebUI](https://github.com/open-webui/open-webui)
- [Yandex GPT Adapter](https://github.com/ai-cookbook/openai-yandexgpt-adapter)
- [Gradio Documentation](https://gradio.app/docs/)

---

**Последнее обновление:** Декабрь 2025  
**Версия API:** v1