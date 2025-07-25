# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.

Согласно заданию был подготовлен следующий манифест
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: volumes

namespace: netology

spec:

selector:

matchLabels:

app: volumes

replicas: 1

template:

metadata:

labels:

app: volumes

spec:

containers:

- name: busybox

image: busybox:1.28

command: ['sh', '-c', 'mkdir -p /testvolume && while true; do echo "Good time $(date)" >> /testvolume/date-time.txt; sleep 5; done']

volumeMounts:

- name: volume

mountPath: /testvolume

- name: multitool

image: wbitt/network-multitool

command: ['sh', '-c', 'while true; do if [ -f "/testvolume/date-time.txt" ]; then echo "[$(date)] $(tail -n 1 /testvolume/date-time.txt)" >> /testvolume/work.txt; else echo "Ожидание файла /testvolume/date-time.txt..."; fi; sleep 5; done' ]

volumeMounts:

- name: volume

mountPath: /testvolume

volumes:

- name: volume

emptyDir: {}
```

4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
Для демонстрации подключимся к контейнерам и внутри их проверим работу скриптов.
`kubectl -n netology exec -it volumes-6f75869bbb-zjgml -c busybox -- sh`
![](Pasted%20image%2020250725094522.png)
`kubectl -n netology exec -it volumes-6f75869bbb-zjgml -c multitool -- sh`
![](Pasted%20image%2020250725094542.png)
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.
https://github.com/ekhristin/netology/blob/main/K8s_Home_6/deployment.yaml
------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
Согласно заданию был подготовлен следующий манифест
```
apiVersion: apps/v1

kind: DaemonSet

metadata:

name: daemonset

namespace: netology

labels:

app: multitool

spec:

selector:

matchLabels:

name: daemonset

template:

metadata:

labels:

name: daemonset

spec:

containers:

- name: multitool

image: wbitt/network-multitool

volumeMounts:

- name: logdir

mountPath: /nodes-logs/syslog

subPath: syslog

- name: varlog

mountPath: /var/log/syslog

readOnly: true

terminationGracePeriodSeconds: 30

volumes:

- name: logdir

hostPath:

path: /var/log

- name: varlog

hostPath:

path: /var/log
```
3. Продемонстрировать возможность чтения файла изнутри пода.
Для этого подключаюсь к pod с контейнером multitool читая файл по пути **/nodes-logs/syslog**
![](Pasted%20image%2020250725095614.png)

4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.
https://github.com/ekhristin/netology/blob/main/K8s_Home_6/daemonset.yaml
------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------
