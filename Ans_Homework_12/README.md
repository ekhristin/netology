# Домашнее задание к занятию 1 «Введение в Ansible»

## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.
2. Создайте свой публичный репозиторий на GitHub с произвольным именем.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.
![](Pasted%20image%2020250227102114.png)
2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.
![](Pasted%20image%2020250227102729.png)
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
Листинг файла **compose.yml**
```compose
version: '3.8'

services:
  centos:
    image: centos/python-36-centos7
    container_name: centos7         
    hostname: centos7
    command: ["sleep", "infinity"]  # Держит контейнер запущенным
    
  ubuntu:
    image: ubuntu:latest
    container_name: ubuntu          
    hostname: ubuntu
    command: ["bash", "-c", "apt update && apt install -y python3 python3-pip && tail -f /dev/null"]

```
запускаем окружение 
![](Pasted%20image%2020250227222512.png)
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
![](Pasted%20image%2020250227222719.png)
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.
Исправляем файл ./group_vars/deb/examp.yml
![](Pasted%20image%2020250227224501.png)
Исправляем файл ./group_vars/el/examp.yml
![](Pasted%20image%2020250227224623.png)
7.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
![](Pasted%20image%2020250227225006.png)
8. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
Для этого ввожу команды:
```
ansible-vault encrypt group_vars/el/examp.yml
```
```
ansible-vault encrypt group_vars/deb/examp.yml
```

![](Pasted%20image%2020250228094827.png)
![](Pasted%20image%2020250228094904.png)

9. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
```
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```
![](Pasted%20image%2020250228095613.png)
10. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
Для этого воспользуемся командой 
```
ansible-doc -t connection -l
```
![](Pasted%20image%2020250228100137.png)
В рамках выполнения домашнего задания релевантным ответом будет ansible.builtin.local   потомучто выполняется непосредственно на control node также можно соотнести сюда      community.docker.docker   так мы работали с контейнерами     
11. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

![](Pasted%20image%2020250228101823.png)
12. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
![](Pasted%20image%2020250228102107.png)

13. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
14. Предоставьте скриншоты результатов запуска команд.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
для этого использую команды 
```
ansible-vault decrypt group_vars/el/examp.yml
ansible-vault decrypt group_vars/deb/examp.yml
```
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
```
echo PaSSw0rd | ansible-vault encrypt_string --name 'some_fact' --vault-password-file <(echo netology)

```
![](Pasted%20image%2020250228222104.png)

3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
![](Pasted%20image%2020250228223642.png)
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).
листинг файла compose.yml
```
version: '3.8'

services:
  
    
  ubuntu:
    image: python:latest 
    container_name: ubuntu
    hostname: ubuntu
    command: ["sleep", "infinity"]  # Держит контейнер запущенным
  centos:
    image: centos/python-36-centos7
    container_name: centos7
    hostname: centos7
    command: ["sleep", "infinity"]  # Держит контейнер запущенным
    
  fedora:
    image: pycontribs/fedora
    container_name: fedora
    hostname: fedora
    command: ["sleep", "infinity"]  # Держит контейнер запущенным
```

5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
```bash
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

sleep 10

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
```
![](Pasted%20image%2020250301000730.png)
1. Все изменения должны быть зафиксированы и отправлены в ваш личный репозиторий.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
