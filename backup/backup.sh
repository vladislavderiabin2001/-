#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Ошибка: Необходимо указать путь к каталогу"
    echo "Использование: $0 /path/to/dir"
    exit 1
fi

SOURCE_DIR="$1"

# Проверка абсолютного пути
if [[ ! "$SOURCE_DIR" = /* ]]; then
    echo "Ошибка: Путь должен быть абсолютным (начинаться с /)"
    exit 1
fi

# Проверка существования каталога
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: '$SOURCE_DIR' не является существующим каталогом"
    exit 1
fi

# Имя каталога без пути
DIRNAME=$(basename "$SOURCE_DIR")

BACKUP_DIR="/tmp/backups"
mkdir -p "$BACKUP_DIR"

# бесконечный цикл раз в 5 минут
while true; do
    DATE=$(date '+%Y-%m-%d')
    TIME=$(date '+%H-%M-%S')

    ARCHIVE_NAME="${DIRNAME}-${DATE}-${TIME}.tgz"
    ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"

    echo "Создание резервной копии каталога: $SOURCE_DIR"
    echo "Архив: $ARCHIVE_PATH"

    if tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$DIRNAME"; then
        echo "✔ Архив создан: $ARCHIVE_PATH"
    else
        echo "✖ Ошибка при создании архива"
    fi

    echo "Ожидание 5 минут..."
    sleep 300
done
