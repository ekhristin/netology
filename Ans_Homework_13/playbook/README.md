# ClickHouse and Vector Installation Playbook

[![Ansible Role](https://img.shields.io/badge/ansible-playbook-v2.9+-blue.svg)](https://github.com/yourusername/clickhouse-vector-playbook) [![License](https://img.shields.io/badge/license-MIT-green.svg)](https://chat.qwen.ai/c/LICENSE)

Этот плейбук Ansible устанавливает и настраивает **ClickHouse** (сервер базы данных) и **Vector** (инструмент для сбора логов) на серверах Linux. Он автоматизирует процесс загрузки пакетов, их установки, настройки служб и создания необходимых баз данных.

---

## Содержание

- [Требования](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D1%82%D1%80%D0%B5%D0%B1%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F)
- [Установка](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0)
- [Использование](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5)
- [Переменные](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%BF%D0%B5%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%BD%D1%8B%D0%B5)
- [Пример inventory](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80-inventory)
- [Проверка работы](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B)
- [Лицензия](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D1%8F)

---

## Требования

- **Ansible** : версия 2.9 или выше.
- **Операционная система удаленного сервера**: поддерживается только семейство Linux (CentOS, Fedora).
- **Доступ к интернету** : требуется для загрузки пакетов ClickHouse и Vector.

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

    bash
    
    Копировать
    
    1
    
    2
    
    git clone https://github.com/yourusername/clickhouse-vector-playbook.git
    
    cd clickhouse-vector-playbook
    
2. **Создайте файл inventory:**
    
    Создайте файл `inventory` или используйте существующий. Пример файла находится в разделе [Пример inventory](https://chat.qwen.ai/c/9ca3f550-8a2f-476e-8acb-e9021ff6dc10#%D0%BF%D1%80%D0%B8%D0%BC%D0%B5%D1%80-inventory) .
    
3. **Настройте переменные:**
    
    Отредактируйте файл `group_vars/all.yml` (или создайте его), чтобы указать версии ClickHouse и Vector:
    
    yaml
    
    Копировать
    
    1
    
    2
    
    3
    
    clickhouse_version: "23.3.15.1"
    
    vector_version: "0.24.0"
    
    vector_architecture: "x86_64"
    

---

## Использование

### Запуск плейбука

Чтобы запустить плейбук, выполните следующую команду:

bash

Копировать

1

ansible-playbook -i inventory playbook.yml

### Выбор тегов

Вы можете использовать теги для выборочного выполнения задач:

- `install_clickhouse`: установка и настройка ClickHouse.
- `install_vector`: установка и настройка Vector.

Пример:

bash

Копировать

1

ansible-playbook -i inventory playbook.yml --tags "install_clickhouse"

---

## Переменные

|Переменная|Описание|По умолчанию|
|---|---|---|
|`clickhouse_version`|Версия ClickHouse|`"23.3.15.1"`|
|`vector_version`|Версия Vector|`"0.24.0"`|
|`vector_architecture`|Архитектура системы для Vector|`"x86_64"`|

Вы можете переопределить эти переменные в файле `group_vars/all.yml` или передать их через CLI:

bash

Копировать

1

ansible-playbook -i inventory playbook.yml -e "clickhouse_version=23.3.15.1 vector_version=0.24.0"

---

## Пример inventory

Пример файла `inventory`:

ini

Копировать

1

2

3

4

5

6

7

[clickhouse]

server1.example.com

server2.example.com

  

[clickhouse:vars]

ansible_user=root

ansible_become=true

Замените `server1.example.com` и `server2.example.com` на реальные адреса ваших серверов.

---

## Проверка работы

После выполнения плейбука вы можете проверить работу ClickHouse и Vector следующими способами:

### Проверка ClickHouse

1. **Статус службы:**
    
    bash
    
    Копировать
    
    1
    
    systemctl status clickhouse-server
    
2. **Тестовый запрос:**
    
    bash
    
    Копировать
    
    1
    
    clickhouse-client --query="SELECT 1"
    
3. **HTTP-интерфейс:**
    
    bash
    
    Копировать
    
    1
    
    curl -s "http://localhost:8123/?query=SELECT+1"
    

### Проверка Vector

1. **Статус службы:**
    
    bash
    
    Копировать
    
    1
    
    systemctl status vector
    
2. **Просмотр логов:**
    
    bash
    
    Копировать
    
    1
    
    journalctl -u vector -f
    

---

## Лицензия

Этот проект распространяется под лицензией MIT. Подробнее см. файл [LICENSE](https://chat.qwen.ai/c/LICENSE) .

---

## Контакты

Если у вас есть вопросы или предложения, свяжитесь с нами:

- Email: [your-email@example.com](mailto:your-email@example.com)
- GitHub: [@yourusername](https://github.com/yourusername)

---

Этот плейбук постоянно развивается. Если вы хотите предложить улучшения или исправления, пожалуйста, создайте pull request!