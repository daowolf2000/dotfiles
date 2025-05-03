#!/bin/bash

# определения цветов для Bash
NC='\033[0m'       # No Color / Сброс
BLACK='\033[0;30m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD_WHITE='\033[1;37m'

tabs 8

# Получаем путь к каталогу, где находится сам скрипт
if [ -n "$1" ]; then
    SOURCE_DIR="$1"
else
    SOURCE_DIR="$(dirname "$(realpath "$0")")"
fi

# Определяем домашний каталог: либо передаётся первым аргументом, либо берём текущий домашний каталог
if [ -n "$2" ]; then
    DEST_DIR="$2"
else
    DEST_DIR="$HOME"
fi

# Каталог для резервного копирования файлов
BACKUP_DIR="$DEST_DIR/.backup"
mkdir -p "$BACKUP_DIR"

# Функция перемещения существующего файла в BACKUP_DIR
backup_file() {
    local src="$1"
    local rel_path="${src#$DEST_DIR/}"  # получаем относительный путь от SOURCE_DIR
    local backup_path="$BACKUP_DIR/$rel_path"
    local backup_dirname=$(dirname "$backup_path")
    
    # Создаем промежуточные директории в BACKUP_DIR, если они отсутствуют
    mkdir -p "$backup_dirname"
    
    mv "$src" "$backup_path"
    echo -e "${BLUE}BACKUP${NC}\t $relative_path"
}

HEADER="|  ${BOLD_WHITE}FROM:${NC} $SOURCE_DIR, ${BOLD_WHITE}TO:${NC} $DEST_DIR, ${BOLD_WHITE}BACKUP:${NC} $BACKUP_DIR)  |"
HEADER_STRIPPED=$(echo -e "$HEADER" | sed -r 's/\x1B\[[0-9;]*[mK]//g')
fillsize=${#HEADER_STRIPPED}
while [[ $fillsize -gt 0 ]]; do FILL="${FILL}-"; fillsize=$(($fillsize-1)); done

echo -e "$FILL"
echo -e "$HEADER"
echo -e "$FILL"

# Обходим рекурсивно директорию SOURCE_DIR
find "$SOURCE_DIR" -type f -iname "*" | grep -Ev "$SOURCE_DIR/(\.git\/|\.gitignore|README\.md|link_dotfiles\.sh)" | while read file_path; do
    # Относительный путь от SOURCE_DIR
    relative_path="${file_path#$SOURCE_DIR/}"
    
    # Путь назначения внутри DEST_DIR
    dest_dir="$DEST_DIR/$relative_path"
    dest_dirname=$(dirname "$dest_dir")
    
    # Перемещаем файл в резервную копию, если он существует и не является ссылкой
    if [[ ! -L "$dest_dir" && -e "$dest_dir" ]]; then
        backup_file "$dest_dir"
    fi
    
    # Создаем промежуточные директории, если они отсутствуют
    mkdir -p "$dest_dirname"
    
    # Проверка существования символической ссылки
    if [[ ! -L "$dest_dir" || $(readlink "$dest_dir") != "$file_path" ]]; then
        # Создание новой символической ссылки
        ln -sf "$file_path" "$dest_dir"
        echo -e "${YELLOW}LINK${NC}\t $relative_path"
    else
        echo -e "${GREEN}PASS${NC}\t $relative_path"
    fi
done
