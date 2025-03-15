# ClickHouse and Vector Installation Playbook

[![Ansible Role](https://img.shields.io/badge/ansible-playbook_v2.9+-blue.svg)](https://github.com/ekhristin/netology/tree/main/Ans_Homew3/playbook) [![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/ekhristin/netology/tree/main/Ans_Homew3/playbook)

Этот плейбук Ansible устанавливает и настраивает **ClickHouse** (сервер базы данных)  **Vector** (инструмент для сбора логов) и **Lighthouse**(приложение для мониторинга и анализа данных) на серверах Linux. Он автоматизирует процесс загрузки пакетов, их установки, настройки служб и создания необходимых баз данных.

---

## Содержание

- [Требования](#Требования)
- [Установка](#Установка)
- [Использование](#Использование)
- [Переменные](#Переменные)
- [Пример inventory](#Пример inventory)
- [Проверка работы](#Проверка работы)
- [Контакты](#Контакты)

---

## Требования

- **Ansible** : версия 2.9 или выше.
- **Операционная система удаленного сервера**: поддерживается только семейство Linux (CentOS9, Fedora).
- **Доступ к интернету** : требуется для загрузки пакетов ClickHouse,Lighthouse и Vector.

Убедитесь, что Ansible установлен на вашем компьютере:

```bash
ansible --version
```

Если Ansible не установлен, выполните следующую команду:
```bash
pip install ansible
```

---

## Установка

1. Скопируйте себе папку воспользовавшись сервисом  https://downgit.github.io/#/home

Ссылка на репу https://github.com/ekhristin/netology/tree/main/Ans_Homew3/playbook
Ссылка на скачивание https://downgit.github.io/#/home?url=https://github.com/ekhristin/netology/tree/main/Ans_Homework_13/playbook


2. **Создайте файл inventory:**
    
    Создайте файл `inventory` или используйте существующий. Пример файла находится в разделе [Пример inventory](https://github.com/ekhristin/netology/blob/main/Ans_Homew3/playbook/inventory/prod.yml)
    
3. **Настройте переменные:**

Отредактируйте файлы group_vars/clickhouse/vars.yml, чтобы указать версии ClickHouse, Vector, Lighthouse :

```
clickhouse_version: "22.3.3.44"

clickhouse_packages:

- clickhouse-client

- clickhouse-server

- clickhouse-common-static

  

vector_version: "0.42.0"

vector_architecture: "x86_64"
```
---

## Использование

### Запуск плейбука

Чтобы запустить плейбук, выполните следующую команду:
```
ansible-playbook -i inventory/prod.yml site.yml
```


## Переменные
Все переменные находятся в файлах `group_vars` или определены непосредственно в плейбуке. Ниже представлены основные переменные:

### **Обязательные переменные**

|Переменная|Описание|Пример значения|
|---|---|---|
|`clickhouse_vcs`|URL репозитория ClickHouse|`https://github.com/ClickHouse/ClickHouse.git`|
|`vector_vcs`|URL репозитория Vector|`https://github.com/vectordotdev/vector.git`|
|`lighthouse_vcs`|URL репозитория Lighthouse|`https://github.com/VKCOM/lighthouse.git`|
|`clickhouse_location_dir`|Путь для установки ClickHouse|`/var/lib/clickhouse`|
|`vector_location_dir`|Путь для установки Vector|`/var/lib/vector`|
|`lighthouse_location_dir`|Путь для установки Lighthouse|`/var/www/lighthouse`|

### **Необязательные переменные**

|Переменная|Описание|Пример значения|
|---|---|---|
|`vector_data_dir`|Директория для хранения данных Vector|`/var/lib/vector/data`|
|`lighthouse_repo`|Использовать ли репозиторий для Lighthouse|`true`или`false`|

---

## **Установка**

| Переменная            | Описание                       | По умолчанию  |
| --------------------- | ------------------------------ | ------------- |
| `clickhouse_version`  | Версия ClickHouse              | `"22.3.3.44"` |
| `vector_version`      | Версия Vector                  | `"0.42.0"`    |
| `vector_architecture` | Архитектура системы для Vector | `"x86_64"`    |

Вы можете переопределить эти переменные в файле `group_vars/clickhouse/vars.yml` или передать их через CLI:

```
ansible-playbook -i inventory/prod.yml site.yml -e "clickhouse_version=22.3.3.4 vector_version=0.42.0"
```
Пакеты участвующие в инсталляции 
```
https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.x86_64.rpm
https://packages.clickhouse.com/rpm/stable/clickhouse-client-22.3.3.44.noarch.rpm
https://packages.clickhouse.com/rpm/stable/clickhouse-server-22.3.3.44.x86_64.rpm

```

---

## Пример inventory

Пример файла `inventory`:
```
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: ssh
      ansible_ssh_user: user
      ansible_host: erver1.example.com`
      ansible_private_key_file: ~/.ssh/id_ed25519
```


Замените `server1.example.com` и поле user на реальные значения.

---
## **Структура проекта**

Проект имеет следующую структуру:

## Проверка работы
```
/playbook
├── group_vars/
│   ├── all.yaml
│   ├── clickhouse.yaml
│   ├── vector.yaml
│   └── lighthouse.yaml
├── inventory/
│   └── prod.yaml
├── roles/
│   ├── clickhouse/
│   ├── vector/
│   └── lighthouse/
├── site.yml
└── README.md
```
- **`group_vars/`** : Содержит общие переменные для групп хостов.
- **`inventory/`** : Файлы инвентаря для разных сред (например, `prod.yaml` для production).
- **`roles/`** : Роли для каждого компонента (ClickHouse, Vector, Lighthouse).
- **`site.yml`** : Основной плейбук, который оркестрирует выполнение ролей.
- **`README.md`** : Данная документация.
### Проверка работы
После выполнения плейбука вы можете проверить работу ClickHouse и Vector следующими способами:


## Проверка ClickHouse

1. **Статус службы:**
```
systemctl status clickhouse-server
```

2. **Тестовый запрос:**
```
clickhouse-client --query="SELECT 1"
```
3. **HTTP-интерфейс:**
```
curl -s "http://localhost:8123/?query=SELECT+1"
```


## Проверка Vector

1. **Статус службы:**

```
systemctl status vector
```

2. **Просмотр логов:**
  
```
journalctl -u vector -f
```




---

Этот плейбук постоянно развивается. Если вы хотите предложить улучшения или исправления, пожалуйста, создайте pull request!