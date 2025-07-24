 # Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
Листинг манифеста deploy.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 8080

```
запускаем манефест командой 
```
kubectl apply -f deployment.yaml
```
после чего проверяем выполнения манефеста
```
kubectl get pods -A
kubectl logs pods/multitool-6d7bd49559-6clc4
```
Видим ошибку 
![](Pasted%20image%2020250718103158.png)
Смотрим глубже в контейнер

Ошибка возникает из-за того что порт 80 порт занят

исправляем манифест
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool:latest
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          value: "7080"
```
перезапускаем и видим результат работы - под запустился
![](Pasted%20image%2020250718134040.png)
2. После запуска увеличить количество реплик работающего приложения до 2.
меняем  реплики с одной на две в строчке replicas: 
![](Pasted%20image%2020250718134846.png)
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
манифест файла service.yaml
```
apiVersion: v1

kind: Service

metadata:

name: nginx-multitool-svc

namespace: netology

spec:

selector:

app: multitool

ports:

- protocol: TCP

name: nginx

port: 80

targetPort: 80

- protocol: TCP

name: multitool

port: 8080

targetPort: 7080

```
Запускаем его и проверяем что он функционирует
![](Pasted%20image%2020250723103747.png)

2. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.
Манифест отдельного пода для проверки
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

- containerPort: 9080
```
Запускаем под и проверяем работу сервиса из запущенного контейнера
в сторону nginx 
![](Pasted%20image%2020250723105428.png)
в сторону multitool
![](Pasted%20image%2020250723105856.png)


------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
Манифест для запуска деплоя с отложенным стартом.
```yaml
apiVersion: apps/v1

kind: Deployment

metadata:

name: nginx-init-deploy

namespace: netology

spec:

selector:

matchLabels:

app: nginx-init

replicas: 1

template:

metadata:

labels:

app: nginx-init

spec:

containers:

- name: nginx

image: nginx:1.25.4

ports:

- containerPort: 80

initContainers:

- name: delay

image: busybox

command: ['sh', '-c', "until nslookup nginx-init-svc.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for nginx-init-svc; sleep 2; done"]

```

1. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.

Запускаю манифест и проверяю старт пода
![](Pasted%20image%2020250723111123.png)
Под ждет запуска сервиса



1. Создать и запустить Service. Убедиться, что Init запустился.
Манифест сервиса 
```yaml
apiVersion: v1

kind: Service

metadata:

name: nginx-init-svc

namespace: netology

spec:

ports:

- name: nginx-init

port: 80

selector:

app: nginx-init
```

Запускаю манифест сервиса и проверяю состояние пода
![](Pasted%20image%2020250723120044.png)
жду несколько секунд и перепроверяю
![](Pasted%20image%2020250723120144.png)
Под запустился!
1. Продемонстрировать состояние пода до и после запуска сервиса.
### Манифесты
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/deployment.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/deployment_bag_fix.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/deployment_2_replics.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/service.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/multitool.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/nginx-init-deploy.yaml
https://github.com/ekhristin/netology/blob/main/K8S_Home_3/nginx-init-svc.yaml


------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------
