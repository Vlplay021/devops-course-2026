#!/usr/bin/env bash

# Доставка статического ресурса на devops-vm
# Использование: scripts/deploy.sh [--dry-run]

set -euo pipefail

REMOTE="devops"
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

# 1. Разбор аргумента --dry-run
DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi

# 2. Проверка: существует ли файл index.html (Требование 4)
if [[ ! -f "${LOCAL_DIR}index.html" ]]; then
    echo "Ошибка: Файл site/index.html не найден!" >&2
    exit 1
fi

# 3. Проверка: есть ли незафиксированные изменения в git (Требование 5)
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Ошибка: В репозитории есть незафиксированные изменения. Сделайте коммит!" >&2
    exit 1
fi

# 4. Вывод короткого хеша коммита
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "Деплой коммита: ${COMMIT_HASH}"

# 5. Синхронизация (используем scp, так как rsync нет в Windows Git Bash)
if [[ $DRY_RUN -eq 1 ]]; then
    echo "[DRY-RUN] Будет скопировано:"
    echo " - ${LOCAL_DIR}index.html -> ${REMOTE}:${REMOTE_DIR}/"
    if [[ -f "${LOCAL_DIR}404.html" ]]; then
        echo " - ${LOCAL_DIR}404.html -> ${REMOTE}:${REMOTE_DIR}/"
    fi
    echo "[DRY-RUN] Завершено. Файлы не изменены."
    exit 0
fi

echo "Копирование файлов на сервер..."
# Копируем html файлы
scp "${LOCAL_DIR}"*.html "${REMOTE}:${REMOTE_DIR}/"

echo "Установка прав доступа..."
# Приводим права в соответствие с моделью (Требование 3)
ssh "${REMOTE}" "chmod 644 ${REMOTE_DIR}/*.html && chmod 755 ${REMOTE_DIR}"

# 6. Проверка доступности (Требование 6 и 9)
echo "Проверка доступности ${SITE_URL}..."
# -f отключает вывод тела ответа при ошибках, -s отключает прогресс-бар
# --cacert проверяет сертификат (без -k)
if ! curl -f -s --cacert "${CA_CERT}" "${SITE_URL}" > /dev/null; then
    echo "Ошибка: Ресурс ${SITE_URL} недоступен!" >&2
    exit 1
fi

echo "Успешный деплой коммита ${COMMIT_HASH}!"
exit 0
