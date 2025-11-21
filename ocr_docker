1. Инструкция (README.md)
markdown

# Docling Serve с OCR для кириллицы (русский язык)

Этот гайд описывает, как развернуть Docling Serve в Docker с поддержкой OCR и кириллицы.

## Требования

- Docker (проверьте: `docker --version`)
- Базовый образ: `quay.io/docling-project/docling-serve`

## Шаг 1. Создайте рабочую папку

```bash
mkdir docling-ocr-ru && cd docling-ocr-ru

Шаг 2. Создайте Dockerfile

Создайте файл Dockerfile со следующим содержимым:
dockerfile

FROM quay.io/docling-project/docling-serve

# Устанавливаем Tesseract OCR и русский языковой пакет
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-rus && \
    rm -rf /var/lib/apt/lists/*

# Проверка наличия русского языкового пакета
RUN test -f /usr/share/tesseract-ocr/5/tessdata/rus.traineddata || \
    test -f /usr/share/tesseract-ocr/4.0/tessdata/rus.traineddata

Шаг 3. Соберите образ
bash

docker build -t docling-serve-ru .

Проверьте образ:
bash

docker images | grep docling-serve-ru

Шаг 4. Запустите контейнер
bash

docker run -d -p 5001:5001 --name docling-ru docling-serve-ru

Проверка:
bash

docker ps | grep docling-ru

Шаг 5. Проверьте работу сервиса

    Основной эндпоинт:
    http://localhost:5001

    Документация API (Swagger UI):
    http://localhost:5001/docs

Шаг 6. Отправьте файл на обработку

Пример запроса через curl:
bash

curl -X POST "http://localhost:5001/v1/convert" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@./test.pdf" \
  -F "output_format=markdown" \
  -F "ocr=true" \
  -F "ocr_language=rus"

Параметры:

    file — путь к файлу (PDF/изображение).

    output_format — text, markdown, html, json.

    ocr=true — включить OCR.

    ocr_language=rus — язык распознавания.

Шаг 7. Проверьте результат

Вы получите:

    распознанный текст на русском;

    сохранённую структуру документа;

    таблицы (если были).

Шаг 8. Посмотрите логи (при ошибках)
bash

docker logs docling-ru

Управление контейнером

    Остановить:
    bash

docker stop docling-ru

Удалить контейнер:
bash

docker rm docling-ru

Удалить образ:
bash

    docker rmi docling-serve-ru

Частые проблемы и решения

    Порт 5001 занят
    bash

    sudo lsof -i :5001  # Найти процесс
    kill -9 <PID>       # Убить процесс

    OCR не распознаёт кириллицу

        Убедитесь, что в Dockerfile установлен tesseract-ocr-rus.

        Проверьте параметр ocr_language=rus в запросе.

    Ошибка сборки образа

        Проверьте интернет-соединение.

        Убедитесь, что Dockerfile находится в текущей папке.

Дополнительно

    Добавить другие языки:
    В Dockerfile добавьте:
    dockerfile

    RUN apt-get install -y tesseract-ocr-ukr  # украинский

    Настроить Nginx как обратный прокси с HTTPS.

    Использовать docker-compose для удобного управления.


---

## 2. Bash‑скрипт (setup_docling_ocr.sh)

Сохраните в файл `setup_docling_ocr.sh` и запустите:

```bash
#!/bin/bash

echo "=== Шаг 1. Проверка Docker ==="
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Установите Docker и перезапустите скрипт."
    exit 1
fi

echo "Docker установлен. Продолжаем..."

echo "=== Шаг 2. Создание рабочей папки ==="
mkdir -p docling-ocr-ru
cd docling-ocr-ru || exit


echo "=== Шаг 3. Создание Dockerfile ==="
cat > Dockerfile << 'EOF'
FROM quay.io/docling-project/docling-serve

# Установка Tesseract OCR и русского языка
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-rus && \
    rm -rf /var/lib/apt/lists/*

# Проверка русского языкового пакета
RUN test -f /usr/share/tesseract-ocr/5/tessdata/rus.traineddata || \
    test -f /usr/share/tesseract-ocr/4.0/tessdata/rus.traineddata
EOF

echo "Dockerfile создан."

echo "=== Шаг 4. Сборка образа ==="
docker build -t docling-serve-ru .
if [ $? -ne 0 ]; then
    echo "Ошибка сборки образа. Проверьте логи."
    exit 1
fi
echo "Образ собран."

echo "=== Шаг 5. Запуск контейнера ==="
docker run -d -p 5001:5001 --name docling-ru docling-serve-ru
if [ $? -ne 0 ]; then
    echo "Ошибка запуска контейнера. Проверьте, свободен ли порт 5001."
    exit 1
fi
echo "Контейнер запущен."

echo "=== Шаг 6. Проверка статуса ==="
sleep 5  # Ждём инициализации
docker ps | grep docling-ru

echo "=== Готово! ==="
echo "Сервис доступен:"
echo "  - API: http://localhost:5001"
echo "  - Документация: http://localhost:5001/docs"
echo ""
echo "Пример запроса (curl):"
echo "curl -X POST 'http://localhost:5001/v1/convert' \\"
echo "  -F 'file=@./test.pdf' \\"
echo "  -F 'output_format=markdown' \\"
echo "  -F 'ocr=true' \\"
echo "  -F 'ocr_language=rus'"

Как использовать скрипт

    Сохраните код в файл setup_docling_ocr.sh.

    Дайте права на выполнение:
    bash

chmod +x setup_docling_ocr.sh

Запустите:
bash

    ./setup_docling_ocr.sh

Скрипт:

    проверит Docker;

    создаст папку и Dockerfile;

    соберёт образ;

    запустит контейнер;

    выведет инструкции по использованию.

