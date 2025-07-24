# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Service.
3. [Описание](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress.
4. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
Согласно заданию был подготовлен манифест фронтенда
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: frontend

namespace: netology

labels:

app: front

spec:

selector:

matchLabels:

app: front

replicas: 3

template:

metadata:

labels:

app: front

component: net #метка для выбора

spec:

containers:

- name: nginx

image: nginx:1.25.4

ports:

- containerPort: 80
```
2. Создать Deployment приложения _backend_ из образа multitool. 
Согласно заданию был подготовлен манифест бекнеда
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: backend

namespace: netology

labels:

app: back

spec:

selector:

matchLabels:

app: back

replicas: 1

template:

metadata:

labels:

app: back

component: net #метка для выбора

spec:

containers:

- name: multitool

image: wbitt/network-multitool

ports:

- containerPort: 8080

env:

- name: HTTP_PORT

value: "7880"
```
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
Согласно заданию был подготовлен манифест сервиса обеспечивающий сетевую связанность до подов
```
apiVersion: v1

kind: Service

metadata:

name: frontback-service

namespace: netology

labels:

component: net

spec:

selector:

component: net #Метка выбора подов

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

Запускаю три манифеста подряд,  проверяю состояния 
![](Pasted%20image%2020250724211326.png)
3. Продемонстрировать, что приложения видят друг друга с помощью Service.
Для тестирования воспользуюсь подом бекэнда 
![](Pasted%20image%2020250724211947.png)
4. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

https://github.com/ekhristin/netology/blob/main/K8s_Home_5/deploy_front.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_5/deploy_back.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_5/service.yaml
------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
выполняю команду `microk8s enable ingress`
![](Pasted%20image%2020250724213019.png)
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
Согласно заданию был подготовлен манифест
```
apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

name: web-ingress

namespace: netology

annotations:

nginx.ingress.kubernetes.io/rewrite-target: /

spec:

rules:

- host: myingress.com

http:

paths:

- path: /

pathType: Prefix

backend:

service:

name: frontback-service

port:

number: 9001

- path: /api

pathType: Prefix

backend:

service:

name: frontback-service

port:

number: 9002
```
запускаю манифест и проверяю применимость правил на ингрессе
![](Pasted%20image%2020250724213730.png)
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
Так как ингресс работает с днс именами по входу, необходимо прописать в файле hosts запись 192.168.3.3 myingress.com
после проверяем ответы подов.
![](Pasted%20image%2020250724214651.png)

4. Предоставить манифесты и скриншоты или вывод команды п.2.
https://github.com/ekhristin/netology/blob/main/K8s_Home_5/ingress.yaml
------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------
