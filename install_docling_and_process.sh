#!/bin/bash

# === НАСТРОЙКИ ===
# Путь к папке с входными документами (PDF, изображения)
INPUT_DIR="./input_docs"
# Путь к папке для результатов
OUTPUT_DIR="./output_docs"
# Язык OCR (для кириллицы — "rus")
OCR_LANGUAGE="rus"
# Формат вывода (txt, md, html, json)
OUTPUT_FORMAT="md"

# === ПРОВЕРКА И УСТАНОВКА ЗАВИСИМОСТЕЙ ===
echo "1. Проверка и установка зависимостей..."

# Проверка наличия Python 3.9+
if ! command -v python3 &> /dev/null; then
    echo "Ошибка: Python 3 не установлен. Установите Python 3.9+."
    exit 1
fi

python3 -c "import sys; exit(1 if sys.version_info < (3,9) else 0)"
if [ $? -ne 0 ]; then
    echo "Ошибка: Требуется Python 3.9 или выше."
    exit 1
fi

# Установка pip (если нет)
if ! command -v pip3 &> /dev/null; then
    sudo apt install python3-pip -y || \
    sudo dnf install python3-pip -y || \
    echo "Установите pip3 вручную для вашего дистрибутива."
fi

# Установка Docling и зависимостей
pip3 install --upgrade pip
pip3 install docling[ocr]  # Включает поддержку OCR (Tesseract + EasyOCR)

# Установка Tesseract OCR и языковых пакетов
echo "Установка Tesseract OCR и русского языка..."
sudo apt install tesseract-ocr tesseract-ocr-rus -y || \
sudo dnf install tesseract tesseract-langpack-rus -y || \
echo "Установите Tesseract вручную для вашего дистрибутива."

# Создание папок
mkdir -p "$INPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "2. Настройка завершена. Готов к обработке документов."

# === ОБРАБОТКА ДОКУМЕНТОВ ===
echo "3. Обработка файлов из $INPUT_DIR..."

# Перебираем все файлы в папке input_docs
for file in "$INPUT_DIR"/*; do
    if [[ -f "$file" ]]; then
        echo "Обработка: $file"

        # Генерируем имя выходного файла
        filename=$(basename "$file")
        output_name="${filename%.*}.$OUTPUT_FORMAT"
        output_path="$OUTPUT_DIR/$output_name"

        # Python-скрипт для обработки (встраиваем в bash)
        python3 - <<EOF
from docling.document_converter import DocumentConverter
from docling.datamodel.pipeline_options import PdfPipelineOptions, TesseractOcrOptions

# Настройки OCR для кириллицы
ocr_options = TesseractOcrOptions(languages=["$OCR_LANGUAGE"])
pipeline_options = PdfPipelineOptions()
pipeline_options.do_ocr = True  # Включить OCR для сканов
pipeline_options.ocr_options = ocr_options

converter = DocumentConverter(pipeline_options=pipeline_options)

try:
    result = converter.convert("$file")
    
    # Экспорт в выбранный формат
    if "$OUTPUT_FORMAT" == "txt":
        text = result.document.export_to_text()
    elif "$OUTPUT_FORMAT" == "md":
        text = result.document.export_to_markdown()
    elif "$OUTPUT_FORMAT" == "html":
        text = result.document.export_to_html()
    elif "$OUTPUT_FORMAT" == "json":
        import json
        text = json.dumps(result.document.to_dict(), ensure_ascii=False, indent=2)
    else:
        text = result.document.export_to_text()

    # Сохранение результата
    with open("$output_path", "w", encoding="utf-8") as f:
        f.write(text)
    print(f"Сохранено: {output_path}")
except Exception as e:
    print(f"Ошибка при обработке {file}: {e}")
EOF

    else
        echo "Пропущен каталог: $file"
    fi
done

echo "Готово! Результаты в папке: $OUTPUT_DIR"

