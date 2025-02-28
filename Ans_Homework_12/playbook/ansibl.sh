#!/bin/bash

# Путь к compose.yml
COMPOSE_FILE="compose.yml"

# Путь к inventory Ansible
INVENTORY="inventory/prod.yml"

# Путь к playbook Ansible
PLAYBOOK="site.yml"

# Функция для вывода сообщений
log() {
  echo "[INFO] $1"
}

# Функция для ошибок
error() {
  echo "[ERROR] $1"
  exit 1
}
# Проверка готовности контейнеров
wait_for_containers() {
  log "Waiting for containers to be ready..."
  while ! docker ps | grep -q "running"; do
    sleep 5
    log "Containers are not ready yet. Retrying..."
  done
  log "All containers are now ready."
}
# Шаг 1: Запрос пароля для Ansible Vault
log "Please enter the Ansible Vault password:"
read -s -p "Vault Password: " VAULT_PASSWORD
echo

if [ -z "$VAULT_PASSWORD" ]; then
  error "Vault password cannot be empty."
fi

# Сохраняем пароль во временный файл
VAULT_PASSWORD_FILE=$(mktemp)
echo "$VAULT_PASSWORD" > "$VAULT_PASSWORD_FILE"

# Удаляем временный файл при выходе из скрипта
trap 'rm -f "$VAULT_PASSWORD_FILE"' EXIT

# Шаг 2: Запуск контейнеров
log "Starting containers..."
docker compose -f $COMPOSE_FILE up -d
if [ $? -ne 0 ]; then
  error "Failed to start containers."
fi
#wait_for_containers # запускаем функцию ожидания описанную ранее
sleep 30


# Шаг 3: Запуск Ansible playbook
log "Running Ansible playbook..."
ansible-playbook -i $INVENTORY $PLAYBOOK \
  --vault-password-file="$VAULT_PASSWORD_FILE"
if [ $? -ne 0 ];then
  error "Ansible playbook failed."
fi

# Шаг 4: Остановка контейнеров
log "Stopping containers..."
docker compose down
if [ $? -ne 0 ]; then
  error "Failed to stop containers."
fi

log "All tasks completed successfully!"
