# Домашнее задание к занятию 5. «Практическое применение Docker»


### Инструкция по выполнению

1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это необходимо, чтобы не расходовать средства, полученные в результате использования промокода.
2. **Свое решение проблемы оформите в репозиториях GitHub.**
3. В личном кабинете отправьте ссылку проверки на .md-файл в вашей репозитории.
4. Сообщите ответ с помощью скриншотов.

---

## Примечание: показана со схемой виртуального стенда [по ссылке](https://github.com/netology-code/shvirtd-example-python/blob/main/schema.pdf)


---

## Задача 0

1. Убедитесь, что у вас НЕ(!) установлен флажок `docker-compose`, для этого вы получите эту ошибку от команды.`docker-compose --version`

```
Command 'docker-compose' not found, but can be installed with:

sudo snap install docker          # version 24.0.5, or
sudo apt  install docker-compose  # version 1.25.0-1

See 'snap info docker' for additional versions.
```


![](Pasted%20image%2020250126195211.png)
В случае применения установленного в системе `docker-compose`- удалите его.  
2. Убедитесь, что у вас УСТАНОВЛЕН `docker compose`(без шины) версия не ниже v2.24.X, для этого выполните команду`docker compose version`
![](Pasted%20image%2020250126194920.png)
### **Свое решение проблемы оформите в своих репозиториях на GitHub!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**

---

## Задача 1

1. Добавьте в свою вилку GitHub пространство [репозитория](https://github.com/netology-code/shvirtd-example-python/blob/main/README.md) . Примечание: В связи с доработкой кода приложения Python. Если вы уверены, что задание выполнено вами, код приложения Python работает с ошибкой, воспользуйтесь вместо файла main.py not_tested_main.py (просто заменить CMD)
2. Создайте файл с именем `Dockerfile.python`для сборки данного проекта (для 3-х заданий изучите [https://docs.docker.com/compose/compose-file/build/](https://docs.docker.com/compose/compose-file/build/) ). Используйте базовый образ `python:3.9-slim`. Обязательно зажгите `COPY . .`Dockerfile. Не забывайте о возможных рисках, ненужных в изображении файлов с помощью dockerignore. Протестируйте корректность сборки.
**Dockerfile.python**
```
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY haproxy ./
COPY nginx ./
COPY . .
CMD ["python", "main.py"]
```
**.dockerignore**
```
.git
.gitignore
README.md
*.pyc
__pycache__
LICENSE
README.MD
schema.pdf
```
Тестирую сборку
![](Pasted%20image%2020250126202451.png)
3. (Необязательная часть, *) Изучите инструкцию в проекте и запустите веб-приложение без использования Docker в venv. (Mysql БД можно запустить в Docker Run).
4. (Необязательная часть, *) По изображению предоставленного кода Python внесите в него исправления для управления названной пользовательской таблицей через переменную ENV.

---

### ВНИМАНИЕ!
## !!! В процессе выполнения ДЗ НЕ изменяйте традиционные файлы в fork-репозитории! Ваша задача ДОБАВИТЬ 5 файлов: `Dockerfile.python`, `compose.yaml`, `.gitignore`, `.dockerignore`, `bash-скрипт`. Если вам удалось внести и внести изменения в проект - вы что-то сделаете неправильно!

## Задача 2 (*)

1. Создайте в облачном реестре контейнеров Яндекса с именем «test» с помощью «yctool». [Инструкция](https://cloud.yandex.ru/ru/docs/container-registry/quickstart/?from=int-console-help)
2. Настройте аутентификацию вашего локального докера в реестре контейнеров Яндекса.
3. Соберите и залейте в него образ с приложением Python из задания №1.
```
docker build  -t test:1.0.0 . -f Dockerfile.python 
yc container registry list
docker tag test:1.0.0 cr.yandex/crptiubv5fur1160hams/test:1.0.0
docker push \ cr.yandex/crptiubv5fur1160hams/test:1.0.0
```
![](Pasted%20image%2020250126222713.png)
![](Pasted%20image%2020250126223105.png)
4. Просканируйте образ уязвимостей.
```

```

5. В качестве ответа приложите отчет.
![](Pasted%20image%2020250126223942.png)
## Задача 3


1. Изучите файл "proxy.yaml"
2. создать в репозитории с проектным файлом `compose.yaml`. С помощью директивы "include" подключите к нему файл "proxy.yaml".
3. Запишите в файл `compose.yaml`следующие сервисы:

- `web`. Образец приложения должен ИЛИ собрать при запуске создать из файла `Dockerfile.python`ИЛИ скачать из реестра контейнеров облака yandex (из задания №2 со *). Контейнер должен работать в сети Bridge с именем `backend`и иметь фиксированный ipv4-адрес `172.20.0.5`. Сервис должен всегда перезапускаться в случае ошибок. Передайте необходимые ENV-переменные для подключения к базе данных Mysql по сетевому имени сервиса`web`

- `db`. изображение = mysql:8. Контейнер должен работать в сети Bridge с именем `backend`и иметь фиксированный ipv4-адрес `172.20.0.10`. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пользователя root, создания базы данных, пользователя и пароля для веб-приложений.
**Листинг файла compose.yaml**
```
version: '3.7'
include:
  - proxy.yaml

services:

  db:
    image: mysql:8
    restart: on-failure
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - MYSQL_ROOT_HOST="%"
    volumes:
      - ./docker_volumes/mysql:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      backend:
        ipv4_address: 172.20.0.10

  web:
    build:
      context: .
      dockerfile: Dockerfile.python
    ports:
      - "5000:5000"
    restart: on-failure
    environment:
      DB_HOST: "db"
      DB_TABLE: ${MY_DB_TABLE}
      DB_USER: ${MYSQL_USER}
      DB_NAME: ${MYSQL_DATABASE}
      DB_PASSWORD: ${MYSQL_PASSWORD}
    depends_on:
      - db
    networks:
      backend:
        ipv4_address: 172.20.0.5
networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
```
3. Запустите проект локально с помощью docker Compose,
![](Pasted%20image%2020250129092705.png)
добитесь его стабильной работы: команда `curl -L http://127.0.0.1:8090`должна вернуть в качестве ответа время и локальный IP-адрес. Если сервисы не запускаются, используйте команды: `docker ps -a` и `docker logs <container_name>`. Если вместо IP-адреса вы увидите `NULL`--убедитесь, что вы шлете запрос на порт `8090`, а не 5000.
![](Pasted%20image%2020250130091501.png)

4. Подключитесь к БД mysql с помощью команды `docker exec -ti <имя_контейнера> mysql -uroot -p<пароль root-пользователя>`(обратите внимание, что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем). 
```
docker exec -ti shvirtd-example-python-db-1 mysql -uroot -pYtReWq4321
```
![](Pasted%20image%2020250130102014.png)

Введите команду последовательно (не забываем в конце символа ; ): `show databases; use <имя вашей базы данных(по-умолчанию example)>; show tables; SELECT * from requests LIMIT 10;`.
![](Pasted%20image%2020250130102055.png)

5. Остановите проект. В качестве ответа приложите скриншот sql-запроса.
![](Pasted%20image%2020250130102628.png)

## Задача 4

1. Запустите в Яндекс Облако ВМ (вам хватит 2 Гб оперативной памяти).
2. Подключитесь к ВМ по ssh и установите докер.

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
```

3. Напишите bash-скрипт, который скачает ваш форк-репозиторий в каталог /opt и запустите проект.
**Листинг файл docker_git.sh**
```bash
##!/bin/bash

REPO_URL="https://github.com/ekhristin/shvirtd-example-python.git"
TARGET_DIR="/opt/"

if [ ! -d $TARGET_DIR ]; then
  echo "Каталог не существует. Создаю его..."
  sudo mkdir -p  $TARGET_DIR 
fi

cd $TARGET_DIR || { echo "Не удалось перейти в каталог  $TARGET_DIR"; exit 1; }

if [ ! -d "$TARGET_DIR/shvirtd-example-python" ]; then
    echo "Клонирование репозитория..."
    sudo git clone "$REPO_URL"
fi
cd $TARGET_DIR/shvirtd-example-python || { echo "Не удалось перейти в каталог  $TARGET_DIR/shvirtd-example-python"; exit 1; }
if [ -f "compose.yaml" ]; then
  echo "Запуск проекта с помощью Docker Compose..."
  docker compose up -d --build
else
  echo "Файл compose.yaml не найден в каталоге проекта."
fi


# Запускаем проект с помощью Docker Compose
sudo docdocker compose -f compose.yaml up -d
```

```bash
chmod +x docker_git.sh
```
4. Зайдите на сайт проверки http подключений, например(или аналогичный): `https://check-host.net/check-http`и запустите проверку вашего сервиса `http://<внешний_IP-адрес_вашей_ВМ>:8090`. Таким образом трафик будет направлен во входящий прокси. ПРИМЕЧАНИЕ: приложение main.py (в отличие от not_tested_main.py) весьма вероятно упадет под оформление, но успеет обработать часть запроса - этого достаточно. Обновленная версия (main.py) не прошла достаточного времени тестирования, но ее необходимо сохранить с помощью приложения.
5. (Необязательная часть) Дополнительно настройте удаленный контекст ssh к вашему серверу. Отобразите список контекстов и удаленного результата выполнения.`docker ps -a`
6. В качестве ответа повторите sql-запрос и приложите скриншот с данного сервера, bash-скрипт и ссылку на fork-репозиторий.
![](Pasted%20image%2020250130234215.png)
## Задача 5 (*)

1. Напишите и задеплойте в вашу облачную ВМ bash-скрипт, который производит резервное копирование БД mysql в каталог "/opt/backup" с помощью запуска в сети контейнера "backend" из образа `schnitzler/mysqldump`с помощью `docker run ...`команды. Подсказка: «Документация образа».
**Листинг файла backup_db.sh**
```bash
#!/bin/bash

BACKUP_DIR="/opt/backup"
CONTAINER_NAME="db"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/mysql_backup_$DATE.sql"

mkdir -p $BACKUP_DIR

docker run --rm --network backend -v $BACKUP_DIR:/backup schnitzler/mysqldump \
  mysqldump -h db -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} > $BACKUP_FILE
```

```
chmod +x /opt/backup_db.sh
crontab -e
* * * * * /opt/backup_db.sh
```
2. Протестируйте ручной запуск
3. Настроить выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Подумайте, как не светить логин/пароль в git!!
4. Предоставьте скрипт, задачу cron и скриншот с несколькими резервными копиями в "/opt/backup"

## Задача 6
Загрузите образ docker `hashicorp/terraform:latest`и скопируйте бинарный файл `/bin/terraform`на свою локальную машину с помощью погружения и сохранения в docker. Предоставьте скриншоты действий.
```
#Для погружения будем использовать утилиту dive 
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -OL https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb
sudo apt install ./dive_${DIVE_VERSION}_linux_amd64.deb
```
изучаем образ с помощью dive и находим нас интересующий слой
![](Pasted%20image%2020250131100826.png)
запоминаем его номер
архивируем образ и извлекаем из него файлы
```
docker save hashicorp/terraform:latest -o terraform_image.tar
ar -xf terraform_image.tar -C layers/

```
извлекаем из образа файл
```
cd layers/blobs/sha256/
tar -xf da25c3c268493bc8d1313c7698a81a97a99c917ae09a248795e969d82cb53f65
cd bin
cp terraform ~/test/lab-4-5/shvirtd-example-python/
```
![](Pasted%20image%2020250131101249.png)
## Задача 6.1

Добейтесь необычного результата с помощью docker cp.  
Предоставьте скриншоты действий.

![](Pasted%20image%2020250131110833.png)
## Задача 6.2 (**)

Предложите способ извлечения файла из контейнера, используя только команду docker build и любой Dockerfile.  
Предоставьте скриншоты действий.

## Задача 7 (***)

Запустите ваше приложение Python с помощью runC, а не с помощью Docker илиContainerd.  
Предоставьте скриншоты действий.

Мой форк https://github.com/ekhristin/shvirtd-example-python
