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
- **Операционная система удаленного сервера**: поддерживается только семейство Linux (CentOS9, Fedora).
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

Ссылка на репу https://github.com/ekhristin/netology/tree/main/Ans_Homework_13/playbook
Ссылка на скачивание https://downgit.github.io/#/home?url=https://github.com/ekhristin/netology/tree/main/Ans_Homework_13/playbook


2. **Создайте файл inventory:**
    
    Создайте файл `inventory` или используйте существующий. Пример файла находится в разделе [Пример inventory](https://github.com/ekhristin/netology/blob/main/Ans_Homework_13/playbook/inventory/prod.yml)
    
3. **Настройте переменные:**

Отредактируйте файл group_vars/clickhouse/vars.yml, чтобы указать версии ClickHouse и Vector:

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

| Переменная            | Описание                       | По умолчанию  |
| --------------------- | ------------------------------ | ------------- |
| `clickhouse_version`  | Версия ClickHouse              | `"22.3.3.44"` |
| `vector_version`      | Версия Vector                  | `"0.42.0"`    |
| `vector_architecture` | Архитектура системы для Vector | `"x86_64"`    |

Вы можете переопределить эти переменные в файле `group_vars/clickhouse/vars.yml` или передать их через CLI:

```
ansible-playbook -i inventory/prod.yml site.yml -e "clickhouse_version=22.3.3.4 vector_version=0.42.0"
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

## Проверка работы

После выполнения плейбука вы можете проверить работу ClickHouse и Vector следующими способами:

### Проверка ClickHouse

1. **Статус службы:**
```
systemctl status clickhouse-server
```

1. **Тестовый запрос:**
```
clickhouse-client --query="SELECT 1"
```
2. **HTTP-интерфейс:**
```
curl -s "http://localhost:8123/?query=SELECT+1"
```


### Проверка Vector

1. **Статус службы:**

```
systemctl status vector
```

2. **Просмотр логов:**
  
```
journalctl -u vector -f
```



---

## Контакты

Если у вас есть вопросы или предложения, свяжитесь с нами:

- Email: [your-email@example.com](mailto:your-email@example.com)
- GitHub: [@yourusername](https://github.com/yourusername)

---

Этот плейбук постоянно развивается. Если вы хотите предложить улучшения или исправления, пожалуйста, создайте pull request!