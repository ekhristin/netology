# ClickHouse  Vector  Installation Playbook

[[License](https://img.shields.io/badge/license-MIT-green.svg)

# **Документация к Ansible Playbook**

## **Описание**

Этот плейбук Ansible предназначен для автоматизации развертывания и настройки инфраструктуры, состоящей из трех компонентов:

1. **ClickHouse** — распределенная система управления базами данных.
2. **Vector** — инструмент для сбора, обработки и отправки логов и метрик.
3. **Lighthouse** — приложение для мониторинга и анализа данных.

Плейбук выполняет следующие задачи:

- Создает необходимые директории.
- Клонирует репозитории с исходным кодом.
- Настрояет службы и конфигурационные файлы.
- Убеждается в корректной работе всех компонентов.

---

## **Требования**

### **Общие требования**

- **Ansible версии 2.9 или выше** .
- **Python 3.x** установлен на контролирующем узле.
- Доступ к управляемым хостам через SSH.
- Управляемые хосты должны иметь установленный пакет `git`.

### **Требования к операционной системе**

- Поддерживаемые ОС: CentOS Stream 9.
- Необходимые порты:
    - ClickHouse: TCP 9000 (клиентский доступ), TCP 8123 (HTTP).
    - Vector: зависит от настроек конфигурации.
    - Lighthouse: зависит от приложения.

---

## **Переменные**

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

### **Шаг 1: Установка Ansible**

Убедитесь, что Ansible установлен на вашем контролирующем узле. Для установки выполните следующую команду:

#### Ubuntu/Debian:

bash

Копировать

1

sudo apt update && sudo apt install ansible

#### CentOS/RHEL:

bash

Копировать

1

sudo yum install epel-release && sudo yum install ansible

### **Шаг 2: Клонирование репозитория**

Клонируйте репозиторий с плейбуком:

bash

Копировать

1

2

git clone https://github.com/ekhristin/netology.git

cd netology/Ans_Homew3/playbook

### **Шаг 3: Настройка инвентаря**

## Создайте файл инвентаря (`inventory/prod.yaml`) со списком хостов. Пример: ```yaml

all: children: clickhouse: hosts: centos9-1: ansible_host: 192.168.1.10 ansible_user: user1 vector: hosts: centos9-2: ansible_host: 192.168.1.11 ansible_user: user2 lighthouse: hosts: centos9-3: ansible_host: 192.168.1.12 ansible_user: user3

Копировать

1

2

3

4

5

6

7

8

9

  

---

  

## **Запуск плейбука**

  

### **Шаг 1: Проверка синтаксиса**

Перед запуском убедитесь, что плейбук корректен:

```bash

ansible-playbook -i inventory/prod.yaml site.yml --syntax-check

### **Шаг 2: Запуск плейбука**

Запустите плейбук с указанием инвентаря:

bash

Копировать

1

ansible-playbook -i inventory/prod.yaml site.yml

### **Шаг 3: Просмотр детального вывода**

Если возникают проблемы, используйте флаг `-vvv` для получения подробного вывода:

bash

Копировать

1

ansible-playbook -i inventory/prod.yaml site.yml -vvv

---

## **Структура проекта**

Проект имеет следующую структуру:

Копировать

1

2

3

4

5

6

7

8

9

10

11

12

13

14

/playbook

├── group_vars/

│ ├── all.yaml

│ ├── clickhouse.yaml

│ ├── vector.yaml

│ └── lighthouse.yaml

├── inventory/

│ └── prod.yaml

├── roles/

│ ├── clickhouse/

│ ├── vector/

│ └── lighthouse/

├── site.yml

└── README.md

- **`group_vars/`** : Содержит общие переменные для групп хостов.
- **`inventory/`** : Файлы инвентаря для разных сред (например, `prod.yaml` для production).
- **`roles/`** : Роли для каждого компонента (ClickHouse, Vector, Lighthouse).
- **`site.yml`** : Основной плейбук, который оркестрирует выполнение ролей.
- **`README.md`** : Данная документация.

---

## **Настройка переменных**

Переменные можно настраивать в файлах `group_vars/` или передавать через параметр `-e` при запуске плейбука.

## Пример настройки переменных в `group_vars/all.yaml`: ```yaml

clickhouse_vcs: "[https://github.com/ClickHouse/ClickHouse.git](https://github.com/ClickHouse/ClickHouse.git) " vector_vcs: "[https://github.com/vectordotdev/vector.git](https://github.com/vectordotdev/vector.git) " lighthouse_vcs: "[https://github.com/VKCOM/lighthouse.git](https://github.com/VKCOM/lighthouse.git) "

clickhouse_location_dir: "/var/lib/clickhouse" vector_location_dir: "/var/lib/vector" lighthouse_location_dir: "/var/www/lighthouse"

Копировать

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

  

---

  

## **Результат работы**

  

После успешного выполнения плейбука вы получите:

1. Развернутый экземпляр ClickHouse с базой данных `vec_logs_db`.

2. Настроенную службу Vector для сбора логов.

3. Развернутое приложение Lighthouse в указанной директории.

  

---

  

## **Тестирование**

  

Для проверки корректности работы компонентов выполните следующие команды:

  

### **ClickHouse**

Подключитесь к ClickHouse и проверьте создание базы данных:

```bash

clickhouse-client -q "SHOW DATABASES;"

### **Vector**

Проверьте статус службы Vector:

bash

Копировать

1

systemctl status vector

### **Lighthouse**

Проверьте доступность приложения Lighthouse:

bash

Копировать

1

curl http://<lighthouse_host>:<port>

---

## **Частые вопросы**

### **Q: Как добавить новые хосты?**

A: Добавьте их в файл инвентаря (`inventory/prod.yaml`) и перезапустите плейбук.

### **Q: Что делать, если возникла ошибка с правами доступа?**

A: Убедитесь, что все необходимые директории имеют правильные права доступа. Например:

bash

Копировать

1

2

chmod -R 755 /var/lib/clickhouse

chown -R user:group /var/lib/clickhouse

### **Q: Как обновить конфигурацию после изменений?**

A: Перезапустите плейбук:

bash

Копировать

1

ansible-playbook -i inventory/prod.yaml site.yml

---

## **Лицензия**

Этот плейбук распространяется под лицензией MIT. Подробнее см. файл `LICENSE`.

---

## **Контакты**

Если у вас есть вопросы или предложения по улучшению плейбука, свяжитесь с автором:

- Email: [example@example.com](mailto:example@example.com)
- GitHub: [https://github.com/ekhristin](https://github.com/ekhristin)

---

Эта документация поможет вам успешно развернуть и настроить инфраструктуру с использованием данного плейбука. Если у вас возникнут дополнительные вопросы, обратитесь к разделу "Частые вопросы" или свяжитесь с автором.