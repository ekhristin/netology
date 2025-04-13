# Домашнее задание к занятию 14 «Средство визуализации Grafana»

## Задание повышенной сложности

**При решении задания 1** не используйте директорию [help](./help) для сборки проекта. Самостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных будет node-exporter:

- grafana;
- prometheus-server;
- prometheus node-exporter.

За дополнительными материалами можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию также приведите все конфигурации, скрипты, манифесты, которые вы 
использовали в процессе решения задания.

**При решении задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например, Telegram или email, и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1

1. Используя директорию [help](./help) внутри этого домашнего задания, запустите связку prometheus-grafana.
Запустил сервисы 
```
docker-compose up -d
```
2. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
Открыл Grafana:
[http://localhost:3000](http://localhost:3000/)
- Логин: admin
- Пароль: admin
![](Pasted%20image%2020250413100526.png)
3. Подключите поднятый вами prometheus, как источник данных.
Для подключения Prometheus как источник данных выполняем следующие действия:
- Configuration → Data Sources → Add data source
![](Pasted%20image%2020250413100801.png)
- Выбираем Prometheus
![](Pasted%20image%2020250413100820.png)
- Вводим в настройках URL: [http://prometheus:9090](http://prometheus:9090/)
![](Pasted%20image%2020250413100931.png)
- Нажимаем Save & Test
![](Pasted%20image%2020250413101007.png)
2. Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.
![](Pasted%20image%2020250413101247.png)
## Задание 2

Изучите самостоятельно ресурсы:

1. [PromQL tutorial for beginners and humans](https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085).
1. [Understanding Machine CPU usage](https://www.robustperception.io/understanding-machine-cpu-usage).
1. [Introduction to PromQL, the Prometheus query language](https://grafana.com/blog/2020/02/04/introduction-to-promql-the-prometheus-query-language/).

Создайте Dashboard и в ней создайте Panels:
Для создание Dashboard пройдем по пути **`+` (Create) → Dashboard**.
![](Pasted%20image%2020250413101815.png)
Далее создаем для каждой метрики отдельную панель и заполняем **PromQL-запрос** в поле **`Metrics browser`** и настраиваем необходимые характеристики.

- Настройка утилизации CPU для nodeexporter (в процентах, 100-idle);
**PromQL-запрос**: 100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
**Settings**
- **Title:** `CPU Utilization (%)`
![](Pasted%20image%2020250413103046.png)
- **Unit:** `Percent (0-100)`
![](Pasted%20image%2020250413103135.png)
Общий вид настроенной панели CPU
![](Pasted%20image%2020250413103247.png)
- CPULA 1/5/15;
Пример шага создания темплейта для значения 1мин
**PromQL-запрос** node_load1
**Settings**
- **Title:** CPU Load Average 1min
- **Visualization** Gauge
![](Pasted%20image%2020250413105423.png)
- **Unit** shot
![](Pasted%20image%2020250413105452.png)
Повторить шаги для значений **PromQL-запрос**
```
node_load5
node_load15
```

- количество свободной оперативной памяти;
**PromQL-запрос**: node_memory_MemFree_bytes / 1024 / 1024  # в МБ
**Settings**
- **Title:** Free Memory (MB)
![](Pasted%20image%2020250413111030.png)
- **Unit:** - megabytes
-
![](Pasted%20image%2020250413110723.png)
- количество места на файловой системе.
**PromQL-запрос**: node_filesystem_avail_bytes{mountpoint="/"}
**Settings**
- **Title:** Free Disk Space (GB)
![](Pasted%20image%2020250413111813.png)
**Unit:** bytes
Для решения этого задания приведите promql-запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.
![](Pasted%20image%2020250413112408.png)
## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
Пример создания  **`Alert`** для панели  **CPU Utilization
Выбираем панели и  Нажимаем кнопку **`Edit`** (карандаш вверху).
![](Pasted%20image%2020250413113006.png)

2. Переходим во вкладку **`Alert`** и создаем правило нажав на  **`Create alert`**.
![](Pasted%20image%2020250413113246.png)
3. Заполняем параметры:

- **Name**: CPU Utilization (%) alert
- **Condition:** `awg() > 80` (если значение > 80%)
- **Evaluate every:** 1m` (проверять каждую 1 минуту)
- **For:** `5m` (алерт сработает, если условие выполняется 5 минут)
![](Pasted%20image%2020250413113609.png)
Для памяти 
![](Pasted%20image%2020250413114830.png)
Для свободного места на диске 
![](Pasted%20image%2020250413114943.png)
2. В качестве решения задания приведите скриншот вашей итоговой Dashboard.
![](Pasted%20image%2020250413115613.png)
## Задание 4

1. Сохраните ваш Dashboard.Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его. https://github.com/ekhristin/netology/blob/main/mon_home_03/help/grafana.json
2. В качестве решения задания приведите листинг этого файла.
```json
{

"annotations": {

"list": [

{

"builtIn": 1,

"datasource": "-- Grafana --",

"enable": true,

"hide": true,

"iconColor": "rgba(0, 211, 255, 1)",

"name": "Annotations & Alerts",

"type": "dashboard"

}

]

},

"editable": true,

"gnetId": null,

"graphTooltip": 0,

"id": 1,

"links": [],

"panels": [

{

"datasource": null,

"fieldConfig": {

"defaults": {

"color": {

"mode": "thresholds"

},

"custom": {},

"mappings": [],

"thresholds": {

"mode": "absolute",

"steps": [

{

"color": "green",

"value": null

},

{

"color": "red",

"value": 80

}

]

},

"unit": "short"

},

"overrides": []

},

"gridPos": {

"h": 5,

"w": 6,

"x": 0,

"y": 0

},

"id": 4,

"options": {

"reduceOptions": {

"calcs": [

"lastNotNull"

],

"fields": "",

"values": false

},

"showThresholdLabels": false,

"showThresholdMarkers": true,

"text": {}

},

"pluginVersion": "7.4.0",

"targets": [

{

"expr": "node_load1",

"interval": "",

"legendFormat": "1m",

"refId": "`"

},

{

"expr": "node_load5",

"hide": false,

"interval": "",

"legendFormat": "5m",

"refId": "B"

},

{

"expr": "node_load15",

"hide": false,

"interval": "",

"legendFormat": "15m",

"refId": "C"

}

],

"title": "CPU Load Average",

"type": "gauge"

},

{

"alert": {

"alertRuleTags": {},

"conditions": [

{

"evaluator": {

"params": [

80

],

"type": "gt"

},

"operator": {

"type": "and"

},

"query": {

"params": [

"A",

"5m",

"now"

]

},

"reducer": {

"params": [],

"type": "avg"

},

"type": "query"

}

],

"executionErrorState": "alerting",

"for": "5m",

"frequency": "1m",

"handler": 1,

"name": "CPU Utilization (%) alert",

"noDataState": "no_data",

"notifications": []

},

"aliasColors": {},

"bars": false,

"dashLength": 10,

"dashes": false,

"datasource": null,

"description": "",

"fieldConfig": {

"defaults": {

"custom": {},

"unit": "percent"

},

"overrides": []

},

"fill": 1,

"fillGradient": 0,

"gridPos": {

"h": 5,

"w": 18,

"x": 6,

"y": 0

},

"hiddenSeries": false,

"id": 2,

"legend": {

"avg": false,

"current": false,

"max": false,

"min": false,

"show": true,

"total": false,

"values": false

},

"lines": true,

"linewidth": 1,

"nullPointMode": "null",

"options": {

"alertThreshold": true

},

"percentage": false,

"pluginVersion": "7.4.0",

"pointradius": 2,

"points": false,

"renderer": "flot",

"seriesOverrides": [],

"spaceLength": 10,

"stack": false,

"steppedLine": false,

"targets": [

{

"expr": "100 - (avg by(instance)(rate(node_cpu_seconds_total{mode=\"idle\"}[1m])) * 100)",

"interval": "",

"legendFormat": "",

"refId": "A"

}

],

"thresholds": [

{

"colorMode": "critical",

"fill": true,

"line": true,

"op": "gt",

"value": 80,

"visible": true

}

],

"timeFrom": null,

"timeRegions": [],

"timeShift": null,

"title": "CPU Utilization (%)",

"tooltip": {

"shared": true,

"sort": 0,

"value_type": "individual"

},

"type": "graph",

"xaxis": {

"buckets": null,

"mode": "time",

"name": null,

"show": true,

"values": []

},

"yaxes": [

{

"format": "percent",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

},

{

"format": "short",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

}

],

"yaxis": {

"align": false,

"alignLevel": null

}

},

{

"alert": {

"alertRuleTags": {},

"conditions": [

{

"evaluator": {

"params": [

1200

],

"type": "gt"

},

"operator": {

"type": "and"

},

"query": {

"params": [

"A",

"5m",

"now"

]

},

"reducer": {

"params": [],

"type": "avg"

},

"type": "query"

}

],

"executionErrorState": "alerting",

"for": "5m",

"frequency": "1m",

"handler": 1,

"name": "Free Memory (MB) alert",

"noDataState": "no_data",

"notifications": []

},

"aliasColors": {},

"bars": false,

"dashLength": 10,

"dashes": false,

"datasource": null,

"fieldConfig": {

"defaults": {

"custom": {},

"unit": "decmbytes"

},

"overrides": []

},

"fill": 1,

"fillGradient": 0,

"gridPos": {

"h": 4,

"w": 24,

"x": 0,

"y": 5

},

"hiddenSeries": false,

"id": 10,

"legend": {

"avg": false,

"current": false,

"max": false,

"min": false,

"show": true,

"total": false,

"values": false

},

"lines": true,

"linewidth": 1,

"nullPointMode": "null",

"options": {

"alertThreshold": true

},

"percentage": false,

"pluginVersion": "7.4.0",

"pointradius": 2,

"points": false,

"renderer": "flot",

"seriesOverrides": [],

"spaceLength": 10,

"stack": false,

"steppedLine": false,

"targets": [

{

"expr": "node_memory_MemFree_bytes / 1024 / 1024 # в МБ",

"interval": "",

"legendFormat": "",

"refId": "A"

}

],

"thresholds": [

{

"colorMode": "critical",

"fill": true,

"line": true,

"op": "gt",

"value": 1200,

"visible": true

}

],

"timeFrom": null,

"timeRegions": [],

"timeShift": null,

"title": "Free Memory (MB)",

"tooltip": {

"shared": true,

"sort": 0,

"value_type": "individual"

},

"type": "graph",

"xaxis": {

"buckets": null,

"mode": "time",

"name": null,

"show": true,

"values": []

},

"yaxes": [

{

"format": "decmbytes",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

},

{

"format": "short",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

}

],

"yaxis": {

"align": false,

"alignLevel": null

}

},

{

"alert": {

"alertRuleTags": {},

"conditions": [

{

"evaluator": {

"params": [

419000000000

],

"type": "gt"

},

"operator": {

"type": "and"

},

"query": {

"params": [

"A",

"5m",

"now"

]

},

"reducer": {

"params": [],

"type": "avg"

},

"type": "query"

}

],

"executionErrorState": "alerting",

"for": "5m",

"frequency": "1m",

"handler": 1,

"name": "Free Disk Space (GB) alert",

"noDataState": "no_data",

"notifications": []

},

"aliasColors": {},

"bars": false,

"dashLength": 10,

"dashes": false,

"datasource": null,

"fieldConfig": {

"defaults": {

"custom": {},

"unit": "decbytes"

},

"overrides": []

},

"fill": 1,

"fillGradient": 0,

"gridPos": {

"h": 5,

"w": 24,

"x": 0,

"y": 9

},

"hiddenSeries": false,

"id": 12,

"legend": {

"avg": false,

"current": false,

"max": false,

"min": false,

"show": true,

"total": false,

"values": false

},

"lines": true,

"linewidth": 1,

"nullPointMode": "null",

"options": {

"alertThreshold": true

},

"percentage": false,

"pluginVersion": "7.4.0",

"pointradius": 2,

"points": false,

"renderer": "flot",

"seriesOverrides": [],

"spaceLength": 10,

"stack": false,

"steppedLine": false,

"targets": [

{

"expr": "node_filesystem_avail_bytes{mountpoint=\"/\"}",

"interval": "",

"legendFormat": "",

"refId": "A"

}

],

"thresholds": [

{

"colorMode": "critical",

"fill": true,

"line": true,

"op": "gt",

"value": 419000000000,

"visible": true

}

],

"timeFrom": null,

"timeRegions": [],

"timeShift": null,

"title": "Free Disk Space (GB)",

"tooltip": {

"shared": true,

"sort": 0,

"value_type": "individual"

},

"type": "graph",

"xaxis": {

"buckets": null,

"mode": "time",

"name": null,

"show": true,

"values": []

},

"yaxes": [

{

"format": "decbytes",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

},

{

"format": "short",

"label": null,

"logBase": 1,

"max": null,

"min": null,

"show": true

}

],

"yaxis": {

"align": false,

"alignLevel": null

}

}

],

"refresh": false,

"schemaVersion": 27,

"style": "dark",

"tags": [],

"templating": {

"list": []

},

"time": {

"from": "2025-04-12T18:52:16.999Z",

"to": "2025-04-13T17:06:19.463Z"

},

"timepicker": {},

"timezone": "",

"title": "Netology",

"uid": "YUVDrw0Hz",

"version": 3

}
```

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
