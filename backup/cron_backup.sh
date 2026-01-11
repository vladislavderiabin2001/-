#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Ошибка: Необходимо указать путь к каталогу"
    echo "Использование: $0 /path/to/dir"
    exit 1
fi

SOURCE_DIR="$1"

if [[ ! "$SOURCE_DIR" = /* ]]; then
    echo "Ошибка: Путь должен быть абсолютным"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: '$SOURCE_DIR' не каталог"
    exit 1
fi

DIRNAME=$(basename "$SOURCE_DIR")
BACKUP_DIR="/tmp/backups"
mkdir -p "$BACKUP_DIR"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H-%M-%S')

ARCHIVE_NAME="${DIRNAME}-${DATE}-${TIME}.tgz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$DIRNAME"

# В crontab -e добавить строку */5 * * * * /path/to/dir/cron_backup.sh /path/to/dir
