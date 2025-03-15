# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»


### Инструкция к выполению


1. Для выполнения заданий обязательно ознакомьтесь с [инструкцией](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD) по экономии облачных ресурсов. Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.
2. Практические задачи выполняйте на личной рабочей станции или созданной вами ранее ВМ в облаке.
3. Своё решение к задачам оформите в вашем GitHub репозитории в формате markdown!!!
4. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

## Задача 1


Сценарий выполнения задачи:

- Установите docker и docker compose plugin на свою linux рабочую станцию или ВМ.
- Если dockerhub недоступен создайте файл /etc/docker/daemon.json с содержимым: `{"registry-mirrors": ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]}`
- Зарегистрируйтесь и создайте публичный репозиторий с именем "custom-nginx" на [https://hub.docker.com](https://hub.docker.com/) (ТОЛЬКО ЕСЛИ У ВАС ЕСТЬ ДОСТУП);
![](Pasted%20image%2020250123222333.png)
- скачайте образ nginx:1.21.1;
Для того чтобы скачать воспользуемся командой 
```
sudo docker pull nginx:1.21.1
```
- Создайте Dockerfile и реализуйте в нем замену дефолтной индекс-страницы(/usr/share/nginx/html/index.html), на файл index.html с содержимым:

```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```
**Выполнение** 
1. Создаем файл index.html с нужным содержимым с помощью редактора nano:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```
2. Подгатавливаем файл **Dockerfile**
```
FROM nginx:1.21.1

COPY index.html /usr/share/nginx/html/index.html
```

- Соберите и отправьте созданный образ в свой dockerhub-репозитории c tag 1.0.0 (ТОЛЬКО ЕСЛИ ЕСТЬ ДОСТУП).
3. Собираем и отправляем
```
docker build -t custom-nginx:1.0.0 .
sudo docker login
docker tag custom-nginx:1.0.0 campas/custom-nginx:1.0.0
docker tag custom-nginx:1.0.0 campas/custom-nginx:general
sudo docker push campas/custom-nginx:1.0.0
sudo docker push campas/custom-nginx:general




```
- Предоставьте ответ в виде ссылки на [https://hub.docker.com/](https://hub.docker.com/)<username_repo>/custom-nginx/general .
```
https://hub.docker.com/repository/docker/campas/custom-nginx/general
```
[https://hub.docker.com/repository/docker/campas/custom-nginx/general](https://hub.docker.com/repository/docker/campas/custom-nginx/general)

## Задача 2

1. Запустите ваш образ custom-nginx:1.0.0 командой docker run в соответвии с требованиями:

- имя контейнера "ФИО-custom-nginx-t2"
- контейнер работает в фоне
- контейнер опубликован на порту хост системы 127.0.0.1:8080
```
docker run -d --name khea-custom-nginx-t2 -p 127.0.0.1:8080:80 custom-nginx:1.0.0
```
2. Не удаляя, переименуйте контейнер в "custom-nginx-t2"
```
docker rename khea-custom-nginx-t2 custom-nginx-t2
```
3. Выполните команду `date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html`
5. Убедитесь с помощью curl или веб браузера, что индекс-страница доступна.
```
curl http://127.0.0.1:8080
```
![](Снимок%20экрана%20от%202025-01-24%2021-57-00.png)
В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.
![](Снимок%20экрана%20от%202025-01-24%2021-57-41.png)
## Задача 3


1. Воспользуйтесь docker help или google, чтобы узнать как подключиться к стандартному потоку ввода/вывода/ошибок контейнера "custom-nginx-t2".
Чтобы подключиться к стандартному потоку ввода/вывода/ошибок контейнера вводим
```
docker attach custom-nginx-t2
```
2. Подключитесь к контейнеру и нажмите комбинацию Ctrl-C.
![](Pasted%20image%2020250124230535.png)
3. Выполните `docker ps -a` и объясните своими словами почему контейнер остановился.

```
После выполнения команды `docker attach` и нажатия `Ctrl-C`, контейнер остановится, потому что команда `Ctrl-C` посылает сигнал `SIGINT` процессу Nginx внутри контейнера,который является основным процессом для запуска контейнера.Как он завершиться сразу остановиться контейнер.
```
4. Перезапустите контейнер
```
docker start custom-nginx-t2
```
5. Зайдите в интерактивный терминал контейнера "custom-nginx-t2" с оболочкой bash.
```
docker exec -it custom-nginx-t2 bash
```
6. Установите любимый текстовый редактор(vim, nano итд) с помощью apt-get.
```
apt-get update
apt-get install -y nano
```
7. Отредактируйте файл "/etc/nginx/conf.d/default.conf", заменив порт "listen 80" на "listen 81".
```
nano /etc/nginx/conf.d/default.conf
```
![](Pasted%20image%2020250124231315.png)
8. Запомните(!) и выполните команду `nginx -s reload`, а затем внутри контейнера `curl http://127.0.0.1:80 ; curl http://127.0.0.1:81`.
```
nginx -s reload
```
```
curl http://127.0.0.1:80
curl http://127.0.0.1:81
```
![](Pasted%20image%2020250124231442.png)
9. Выйдите из контейнера, набрав в консоли `exit` или Ctrl-D.
10. Проверьте вывод команд: `ss -tlpn | grep 127.0.0.1:8080` , `docker port custom-nginx-t2`, `curl http://127.0.0.1:8080`. Кратко объясните суть возникшей проблемы.
![](Pasted%20image%2020250124231945.png)
```
Так как в докере работает правило проброса с хостового порта 8080 на 80 порт контейнера, то мы получаем ошибку, так как контейнер после изменения слушает 81 порт.
```
11. - Это дополнительное, необязательное задание. Попробуйте 
самостоятельно исправить конфигурацию контейнера, используя доступные источники в интернете. Не изменяйте конфигурацию nginx и не удаляйте контейнер. Останавливать контейнер можно. [пример источника](https://www.baeldung.com/linux/assign-port-docker-container)
 
 Для того чтобы исправить эту проблему нужно остановить контейнер  плюс сам докер и отредактировать файлы конфигурации
![](Pasted%20image%2020250125000308.png)
редактируем файлы
![](Pasted%20image%2020250125000400.png)
Запускаем докер и контейнер
![](Pasted%20image%2020250125000600.png)
проверяем работу
![](Pasted%20image%2020250125000850.png)

12. Удалите запущенный контейнер "custom-nginx-t2", не останавливая его.(воспользуйтесь --help или google)
```
docker rm --force custom-nginx-t2
docker ps -a
```
![](Снимок%20экрана%20от%202025-01-25%2000-15-01.png)
В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

## Задача 4

- Запустите первый контейнер из образа _**centos**_ c любым тегом в фоновом режиме, подключив папку текущий рабочий каталог `$(pwd)` на хостовой машине в `/data` контейнера, используя ключ -v.
```
docker run -d --name centos-container -v $(pwd):/data centos:latest /bin/bash -c "sleep inf"

```
![](Pasted%20image%2020250125003043.png)

- Запустите второй контейнер из образа _**debian**_ в фоновом режиме, подключив текущий рабочий каталог `$(pwd)` в `/data` контейнера.
```
docker run -d --name centos-container -v $(pwd):/data centos:latest /bin/bash -c "sleep inf"
```
![](Pasted%20image%2020250125002832.png)
- Подключитесь к первому контейнеру с помощью `docker exec` и создайте текстовый файл любого содержания в `/data`.
```
docker exec -it centos-container bash
echo 1234 > /data/test
cat /data/test
```
![](Pasted%20image%2020250125003541.png)
- Добавьте ещё один файл в текущий каталог `$(pwd)` на хостовой машине.
```
echo 4321 > /$(pwd)/test_host
cat /$(pwd)/test_host
```
![](Pasted%20image%2020250125003819.png)
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в `/data` контейнера.
```
docker exec -it debian-container bash 
ls /data
cat /data/test
cat /data/test_host
```
![](Pasted%20image%2020250125004130.png)
В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

## Задача 5

1. Создайте отдельную директорию(например /tmp/netology/docker/task5) и 2 файла внутри него. "compose.yaml" с содержимым:

```
version: "3"
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

"nanon" с содержимым:

```
version: "3"
services:
  registry:
    image: registry:2

    ports:
    - "5000:5000"
```
![](Pasted%20image%2020250125092105.png)
И выполните команду "docker compose up -d". Какой из файлов был запущен и почему? (подсказка: [https://docs.docker.com/compose/compose-application-model/#the-compose-file](https://docs.docker.com/compose/compose-application-model/#the-compose-file) )
![](Pasted%20image%2020250125101121.png)
2. Отредактируйте файл compose.yaml так, чтобы были запущенны оба файла. (подсказка: [https://docs.docker.com/compose/compose-file/14-include/](https://docs.docker.com/compose/compose-file/14-include/))
```
version: "3"
include:
  - docker-compose.yaml
services:
  portainer:
    network_mode: host
    image: portainer/portainer-ce:latest
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock

```
![](Pasted%20image%2020250125104222.png)
3. Выполните в консоли вашей хостовой ОС необходимые команды чтобы залить образ custom-nginx как custom-nginx:latest в запущенное вами, локальное registry. Дополнительная документация: [https://distribution.github.io/distribution/about/deploying/](https://distribution.github.io/distribution/about/deploying/)
```
 docker tag custom-nginx:1.0.0 127.0.0.1:5000/custom-nginx:latest
 docker push 127.0.0.1:5000/custom-nginx:latest
```
![](Pasted%20image%2020250126101321.png)
4. Откройте страницу "[https://127.0.0.1:9000](https://127.0.0.1:9000/)" и произведите начальную настройку portainer.(логин и пароль адмнистратора)
    
5. Откройте страницу "[http://127.0.0.1:9000/#!/home](http://127.0.0.1:9000/#!/home)", выберите ваше local окружение. Перейдите на вкладку "stacks" и в "web editor" задеплойте следующий компоуз:
    

```
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```
![](Pasted%20image%2020250126103935.png)
![](Pasted%20image%2020250126104219.png)
6. Перейдите на страницу "[http://127.0.0.1:9000/#!/2/docker/containers](http://127.0.0.1:9000/#!/2/docker/containers)", выберите контейнер с nginx и нажмите на кнопку "inspect". В представлении <> Tree разверните поле "Config" и сделайте скриншот от поля "AppArmorProfile" до "Driver".
![](Pasted%20image%2020250126104630.png)
7. Удалите любой из манифестов компоуза(например compose.yaml). Выполните команду "docker compose up -d". Прочитайте warning, объясните суть предупреждения и выполните предложенное действие. Погасите compose-проект ОДНОЙ(обязательно!!) командой.
![](Pasted%20image%2020250126105300.png)
Сompose выдал предупреждение о том, что в проекте найдены потерянные контейнеры, в данном случае **docker-portainer-1**. Compose предлгает запустить команду с флагом --remove-orphans, для удаления контейнеров которые не имеют манифеста.
Выполнил предложенное действие.
![](Pasted%20image%2020250126105956.png)
Погасил проект одной командой 
![](Pasted%20image%2020250126110216.png)

---

### Правила приема

Домашнее задание выполните в файле readme.md в GitHub-репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.