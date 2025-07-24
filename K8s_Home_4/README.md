# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
Согласно заданию был подготовлен манифест
```yaml
apiVersion: apps/v1

kind: Deployment

metadata:

name: network-tools

namespace: netology

spec:

selector:

matchLabels:

app: nettools

replicas: 3 # создаем три реплики

template:

metadata:

labels:

app: nettools

spec:

containers:

- name: nginx

image: nginx:1.25.4

ports:

- containerPort: 80

- name: multitool

image: wbitt/network-multitool

ports:

- containerPort: 8080

env:

- name: HTTP_PORT

value: "7880"
```
запускаю под и проверяю что он запустился
![](Pasted%20image%2020250724113334.png)


2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
Согласно заданию формирую требуемый манифест сервиса
```
apiVersion: v1

kind: Service

metadata:

name: network-service

namespace: netology

spec:

selector:

app: nettools

ports:

- protocol: TCP

name: nginx

port: 9001

targetPort: 80

- protocol: TCP

name: multitool

port: 9002

targetPort: 7880
```
запускаю сервис  и проверяю что он запустился
![](Pasted%20image%2020250724113906.png)
2. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
манифест пода с мультитул
```
apiVersion: v1

kind: Pod

metadata:

name: multitool

namespace: netology

spec:

containers:

- name: multitool

image: wbitt/network-multitool

ports:

- containerPort: 8080
```
Запускаю под и проверяю его 
![](Pasted%20image%2020250724114140.png)
после проверяю командой curl доступность nginx и multitool из пункта 1 задания

в сторону nginx
![](Pasted%20image%2020250724114802.png)
в сторону multitool
![](Pasted%20image%2020250724114848.png)

3. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
4. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.
https://github.com/ekhristin/netology/blob/main/K8s_Home_4/deployment.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_4/service.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_4/multitool.yaml

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
Согласно заданию написал следущий манифест сервиса позволяющий осуществить доступ  снаружи кубера.
```
apiVersion: v1

kind: Service

metadata:

name: nodeport-service

namespace: netology

spec:

type: NodePort

selector:

app: nettools

ports:

- port: 80

name: nginx-port

targetPort: 80

nodePort: 30010

- port: 8080

name: multitool-port

targetPort: 7880

nodePort: 30011
```
запускаю сервис. стоит отметить что два сервиса нацеленные на поды не как не конфликтуют между собой и хорошо уживаются.

2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
Проверяю доступ в сторону nginx 
![](Pasted%20image%2020250724120205.png)
В сторону мультитул
![](Pasted%20image%2020250724120253.png)
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.
https://github.com/ekhristin/netology/blob/main/K8s_Home_4/service-nodeport.yaml

------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

