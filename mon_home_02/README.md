# Домашнее задание к занятию "13.Системы мониторинга"

## Обязательные задания

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя 
платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой 
осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
выведите в мониторинг и почему?
Взаимодействие с платформой осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы выведите в мониторинг и почему?

	1. HTTP-метрики :
    - Количество запросов (всех типов — 2xx, 3xx, 4xx, 5xx).
    - Время ответа сервера.
    - Размер передаваемых данных (запросы/ответы).
Позволяет оценить производительность платформы с точки зрения клиентов.

	2. CPU загрузка :
    
    - Средняя загрузка CPU за последние 1, 5 и 15 минут (`load average`).
    - Использование CPU (%) по процессам или общее использование.
  Вычисления сильно нагружают CPU, поэтому его мониторинг критичен для понимания производительности.
  
	3. Дисковые метрики:
    
    - Использованное пространство на диске.
    - Скорость записи/чтения файлов.
    - Количество свободных inode'ов.
Текстовые отчеты сохраняются на диск, поэтому важно отслеживать доступность места и производительность диска.

	4. RAM использование :
    
    - Общий объем RAM.
    - Использованный объем RAM.
    - Доступная память.
Недостаток оперативной памяти может привести к ошибкам или снижению производительности.

2 Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал, 
что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы 
можете ему предложить?

	1. SLA по времени ответа :
    - Процент запросов, которые обрабатываются быстрее определенного порога (например, менее 1 секунды).
	2. Процент успешных запросов :
    - Отношение количества успешных запросов (2xx) ко всем запросам.
	3. Количество клиентских запросов :
    - Общее количество запросов за период времени.
	4. Статистика отказов :
    - Количество ошибок (если они есть) с детализацией по типам кодов ответа (например, 4xx/5xx).
	5. График работы системы :
    - Загрузка CPU, RAM и диска в реальном времени или за период времени.
	6. Информация о времени простоя :
    - Время, когда система не была доступна клиентам.
3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою 
очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, 
чтобы разработчики получали ошибки приложения?

**Самым простым решением будет реализация точечного доступа на чтение к файлам логов на боевых машинах. Пусть разработчики сами просматривают их.**

4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 
70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?
При расчетах не учтены коды 3хх вероятно на них приходиться 29% доли запросов пользователей
Исправленная формула SLA = (summ_2xx_requests + summ_3xx_requests) / summ_all_requests
также при расчетах не учтены и другие показатели которые прямо или косвенно влияют на общую картину.

5. Опишите основные плюсы и минусы pull и push систем мониторинга.
**Pull система**
Сервер сам собирает данные с агентов, можно четко отследить провал в поступление данных, простота настройки, минимальная нагрузка на агент. Требует доступности агентов из вне. Может быть медленным при большом количестве узлов. Требователен к настройке скважности сбора с разных узлов.

**Push система**
Агенты сами отправляют данные на сервер. Оперативная информация о изменениях в метриках. Быстрая доставка данных. Работа за Nat. Риски потери данных при сбоях.
6. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

    - Prometheus  - pull
    - TICK - push
    - Zabbix -push, pull
    - VictoriaMetrics - push, pull
    - Nagios -pull

7. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.

В виде решения на это упражнение приведите скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 
Для работы в новых реалиях скрипт запуска **sandbox** необходимо адаптировать под работу нового docker
**Листинг sanbox**
```bash
#!/usr/bin/env bash

set -eo pipefail

IFS=$'\n\t'

  

# Проверяем наличие docker

if ! [ -x "$(command -v docker)" ]; then

echo 'Error: docker is not installed.' >&2

exit 1

fi

  

# Проверяем новый формат docker compose

if ! [ -x "$(command -v docker)" ] || ! docker compose version > /dev/null 2>&1; then

echo 'Error: docker compose is not installed or not working.' >&2

exit 1

fi

  

sandbox () {

# Если используется nightly-версия, очищаем старые образы и пересобираем контейнеры

if [ "$2" == "-nightly" ]; then

source .env-nightlies

echo "Using nightlies...removing old ones."

# Если существуют nightly-образы, останавливаем и пересобираем контейнеры

if [ $(docker images | grep nightly | tr -s ' ' | cut -d ' ' -f 3 | wc -l) -gt 0 ]; then

docker compose down

docker compose rm -f

docker compose build --pull

fi

else

source .env-latest

echo "Using latest, stable releases"

fi

  

# Функция для входа в контейнеры

enter () {

case $2 in

influxdb)

echo "Entering /bin/bash session in the influxdb container..."

docker compose exec influxdb /bin/bash

;;

chronograf)

echo "Entering /bin/sh session in the chronograf container..."

docker compose exec chronograf /bin/sh

;;

kapacitor)

echo "Entering /bin/bash session in the kapacitor container..."

docker compose exec kapacitor /bin/bash

;;

telegraf)

echo "Entering /bin/bash session in the telegraf container..."

docker compose exec telegraf /bin/bash

;;

*)

echo "sandbox enter (influxdb||chronograf||kapacitor||telegraf)"

;;

esac

}

  

# Функция для просмотра логов контейнеров

logs () {

case $2 in

influxdb)

echo "Following the logs from the influxdb container..."

docker compose logs -f influxdb

;;

chronograf)

echo "Following the logs from the chronograf container..."

docker compose logs -f chronograf

;;

kapacitor)

echo "Following the logs from the kapacitor container..."

docker compose logs -f kapacitor

;;

telegraf)

echo "Following the logs from the telegraf container..."

docker compose logs -f telegraf

;;

*)

echo "sandbox logs (influxdb||chronograf||kapacitor||telegraf)"

;;

esac

}

  

# Обработка команд

case $1 in

up)

echo "Spinning up Docker Images..."

echo "If this is your first time starting sandbox this might take a minute..."

docker compose up -d --build

echo "Opening tabs in browser..."

sleep 3

if [ $(uname) == "Darwin" ]; then

open http://localhost:3010

open http://localhost:8888

elif [ $(uname) == "Linux" ]; then

xdg-open http://localhost:8888

xdg-open http://localhost:3010

else

echo "no browser detected..."

fi

;;

down)

echo "Stopping sandbox containers..."

docker compose down

;;

restart)

echo "Stopping all sandbox processes..."

docker compose down > /dev/null 2>&1

echo "Starting all sandbox processes..."

docker compose up -d --build > /dev/null 2>&1

echo "Services available!"

;;

delete-data)

echo "Deleting all influxdb, kapacitor and chronograf data..."

rm -rf kapacitor/data influxdb/data chronograf/data

;;

docker-clean)

echo "Stopping and removing running sandbox containers and images..."

docker compose down > /dev/null 2>&1

echo "Removing TICK stack images..."

docker rmi sandbox_documentation influxdb:latest telegraf:latest kapacitor:latest chronograf:latest chrono_config:latest quay.io/influxdb/influxdb:nightly quay.io/influxdb/chronograf:nightly > /dev/null 2>&1

docker rmi $(docker images -f "dangling=true" -q)

;;

influxdb)

echo "Entering the influx cli..."

docker compose exec influxdb /usr/bin/influx

;;

flux)

echo "Entering the flux REPL..."

docker compose exec influxdb /usr/bin/influx -type flux

;;

rebuild-docs)

echo "Rebuilding documentation container..."

docker build -t sandbox_documentation documentation/ > /dev/null 2>&1

echo "Restarting..."

docker compose down > /dev/null 2>&1

docker compose up -d --build > /dev/null 2>&1

;;

enter)

enter $@

;;

logs)

logs $@

;;

*)

cat <<-EOF

sandbox commands:

up (-nightly) -> spin up the sandbox environment (latest or nightlies specified in the companion file)

down -> tear down the sandbox environment (latest or nightlies specified in the companion file)

restart (-nightly) -> restart the sandbox

influxdb -> attach to the influx cli

flux -> attach to the flux REPL

  

enter (influxdb||kapacitor||chronograf||telegraf) -> enter the specified container

logs (influxdb||kapacitor||chronograf||telegraf) -> stream logs for the specified container

  

delete-data -> delete all data created by the TICK Stack

docker-clean -> stop and remove all running docker containers and images

rebuild-docs -> rebuild the documentation image

EOF

;;

esac

}

  

# Переходим в директорию скрипта

pushd "$(dirname "$0")" > /dev/null

sandbox $@

popd > /dev/null

```
P.S.: если при запуске некоторые контейнеры будут падать с ошибкой - проставьте им режим `Z`, например
`./data:/var/lib:Z`

Помимо исправлений файла компос потребуется еще назначить права на папки 
```
sudo chmod 777 kapacitor/data  
sudo chmod 777 chronograf/data/
```
![](Pasted%20image%2020250412211951.png)
8. Перейдите в веб-интерфейс Chronograf (http://localhost:8888) и откройте вкладку Data explorer.
        
    - Нажмите на кнопку Add a query
    - Изучите вывод интерфейса и выберите БД telegraf.autogen
    - В `measurments` выберите cpu->host->telegraf-getting-started, а в `fields` выберите usage_system. Внизу появится график утилизации cpu.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.

Для выполнения задания приведите скриншот с отображением метрик утилизации cpu из веб-интерфейса.
![](Pasted%20image%2020250412213553.png)
9. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs). 
Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```
Открываем конфигурационный файл Telegraf ( `./telegraf/telegraf.conf`) и добавляем:

```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"  # Подключение к Docker API
  timeout = "5s"                            # Таймаут запросов
  perdevice = true                          # Сбор метрик для каждого контейнера отдельно
  total = false                             # Не включать общие метрики
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:
```
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройке перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.
чтоб это заработало пришлось дать права к файлу `sudo chmod -R 777 /var/run/docker.sock`

![](Pasted%20image%2020250412223459.png)
Факультативно можете изучить какие метрики собирает telegraf после выполнения данного задания.

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

1. Вы устроились на работу в стартап. На данный момент у вас нет возможности развернуть полноценную систему 
мониторинга, и вы решили самостоятельно написать простой python3-скрипт для сбора основных метрик сервера. Вы, как 
опытный системный-администратор, знаете, что системная информация сервера лежит в директории `/proc`. 
Также, вы знаете, что в системе Linux есть  планировщик задач cron, который может запускать задачи по расписанию.

Суммировав все, вы спроектировали приложение, которое:
- является python3 скриптом
- собирает метрики из папки `/proc`
- складывает метрики в файл 'YY-MM-DD-awesome-monitoring.log' в директорию /var/log 
(YY - год, MM - месяц, DD - день)
- каждый сбор метрик складывается в виде json-строки, в виде:
  + timestamp (временная метка, int, unixtimestamp)
  + metric_1 (метрика 1)
  + metric_2 (метрика 2)
  
     ...
     
  + metric_N (метрика N)
  
- сбор метрик происходит каждую 1 минуту по cron-расписанию

Для успешного выполнения задания нужно привести:

а) работающий код python3-скрипта,

б) конфигурацию cron-расписания,

в) пример верно сформированного 'YY-MM-DD-awesome-monitoring.log', имеющий не менее 5 записей,

P.S.: количество собираемых метрик должно быть не менее 4-х.
P.P.S.: по желанию можно себя не ограничивать только сбором метрик из `/proc`.

2. В веб-интерфейсе откройте вкладку `Dashboards`. Попробуйте создать свой dashboard с отображением:

    - утилизации ЦПУ
    - количества использованного RAM
    - утилизации пространства на дисках
    - количество поднятых контейнеров
    - аптайм
    - ...
    - фантазируйте)
    
    ---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

