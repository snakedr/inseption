1. Markdown‑версия (docling-guide.md)
markdown

# Руководство: Docling Serve с OCR для кириллицы


## Введение

Это полное руководство по развёртыванию Docling Serve в Docker с поддержкой OCR и кириллицы. Описаны:
- сборка образа;
- запуск сервиса;
- работа с API;
- решение типичных проблем при конвертации PDF.

## Подготовка окружения

### Требования
- Docker (проверьте: `docker --version`);
- базовый образ: `quay.io/docling-project/docling-serve`.

### Проверка Docker

Выполните в терминале:

```bash
docker --version
docker compose version  # или docker-compose --version

Если Docker Compose не установлен (на Linux):
bash

sudo apt install docker-compose -y

Развёртывание через Docker Compose
Файл docker-compose.yml

Создайте файл docker-compose.yml со следующим содержимым:
yaml

services:
  docling:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5001:5001"
    container_name: docling-ru
    restart: unless-stopped

Файл Dockerfile

Создайте файл Dockerfile в той же папке:
dockerfile

FROM quay.io/docling-project/docling-serve

# Установка Tesseract OCR и русского языкового пакета
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-rus && \
    rm -rf /var/lib/apt/lists/*

# Проверка наличия русского языкового пакета
RUN test -f /usr/share/tesseract-ocr/5/tessdata/rus.traineddata || \
    test -f /usr/share/tesseract-ocr/4.0/tessdata/rus.traineddata

Запуск сервиса

    Поместите оба файла (docker-compose.yml и Dockerfile) в одну папку.

    Откройте терминал в этой папке и выполните:
    bash

    docker compose up -d --build

    Флаг -d запускает контейнер в фоновом режиме, --build пересоберёт образ при изменениях.

Проверка статуса

Убедитесь, что контейнер запущен:
bash

docker compose ps

Вы должны увидеть строку с docling-ru и статусом Up.
Остановка сервиса

Чтобы остановить контейнер:
bash

docker compose stop

Чтобы удалить контейнеры и сети:
bash

docker compose down

Работа с API
Основные эндпоинты

    API: http://<IP>:5001

    Документация (Swagger UI): http://<IP>:5001/docs

    Проверка статуса: http://<IP>:5001/health

    Замените <IP> на IP вашего сервера (например, 192.168.0.186).

Пример запроса через curl

Отправьте PDF на конвертацию:
bash

curl -X POST "http://<IP>:5001/v1/convert" \
  -F "file=@./test.pdf" \
  -F "output_format=markdown" \
  -F "ocr=true" \
  -F "ocr_language=rus" \
  -F "ocr_config=--psm 6 --oem 3"

Параметры:

    file — путь к файлу на диске;

    output_format — формат вывода: text, markdown, html, json;

    ocr=true — включить OCR;

    ocr_language=rus — язык распознавания;

    ocr_config — дополнительные настройки Tesseract (здесь: --psm 6 для таблиц, --oem 3 — современный движок).

Использование Swagger UI

    Откройте в браузере: http://<IP>:5001/docs.

    Найдите эндпоинт POST /v1/convert.

    Заполните поля:

        file: выберите файл с диска;

        output_format: markdown;

        ocr: true;

        ocr_language: rus.

    Нажмите «Execute».

    Результат будет в разделе «Responses».

Решение типичных проблем
Проблема 1: «Каша» из кириллицы и цифр вместо таблицы

Причины:

    PDF — скан без текстового слоя.

    Сложная вёрстка (таблицы, колонки).

    Низкое качество скана.

    Неправильные настройки OCR.

Решения:

    Проверьте текстовый слой в PDF

        Откройте PDF в Adobe Acrobat Reader.

        Попробуйте выделить текст мышью.

            Если выделяется → документ содержит текст.

            Если не выделяется → это скан (нужен OCR).

    Улучшите качество изображения
    Используйте ImageMagick для повышения контрастности:
    bash

convert scanned.pdf -density 300 -contrast-stretch 10%x10%+0% output.pdf

Настройте Tesseract

    В запросе укажите: --psm 6 (режим «единый блок текста/таблица»), --oem 3 (движок LSTM).

    Убедитесь, что в Dockerfile установлен tesseract-ocr-rus.

Используйте альтернативные инструменты для таблиц

    Tabula (извлекает таблицы):
    bash

java -jar tabula-1.0.5-jar-with-dependencies.jar -p all -o output.csv input.pdf

Camelot (Python‑библиотека):
python

        import camelot
        tables = camelot.read_pdf('input.pdf', flavor='stream')
        tables.export('output.csv', f='csv')

    Конвертируйте через DOCX

        Откройте PDF в Microsoft Word или LibreOffice Writer.

        Сохраните как .docx.

        Экспортируйте в .txt.

    Проверьте кодировку выходного файла

        Откройте TXT в VS Code или Notepad++.

        Убедитесь, что кодировка — UTF‑8.

        Если текст нечитаем, пересохраните файл в UTF‑8.

Проблема 2: Соединение отклонено (Connection refused)

    Проверьте, запущен ли контейнер: docker compose ps.

    Убедитесь, что порт 5001 проброшен в docker-compose.yml.

    Проверьте IP сервера (на сервере: ip a или ifconfig).

Проблема 3: Страница не найдена (404)

    Используйте полный путь: /v1/convert, а не /v1.

    Перезапустите контейнер: docker compose down && docker compose up -d.

Проблема 4: Ошибка CORS в браузере

    Если делаете AJAX‑запросы из фронтенда, добавьте CORS‑заголовки в бэкенд.

    Для тестирования используйте curl или Swagger UI.

Дополнительные настройки
Добавление healthcheck

Добавьте в docker-compose.yml:
yaml

healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
  interval: 30s
  timeout: 10s
  retries: 3

Настройка HTTPS

    Добавьте Nginx/Caddy как обратный прокси.

    Настройте SSL‑сертификат (например, через Let’s Encrypt).

    В docker-compose.yml измените порты:
    yaml

    ports:
      - "443:5001"

    Тогда URL будет: https://<IP>/v1/convert.

Полезные команды

    Логи контейнера: docker compose logs -f

    Пересобрать и перезапустить: docker compose up -d --build

    Удалить контейнеры: docker compose down

    Проверить IP сервера: ip a (или ifconfig)

    Проверить открытые порты: sudo ss -tulnp | grep 5001
