# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
На основе задания подготовил следующий манифест
```
piVersion: apps/v1

kind: Deployment

metadata:

name: volumes-test2

namespace: netology

spec:

selector:

matchLabels:

app: vol

replicas: 1

template:

metadata:

labels:

app: vol

spec:

nodeSelector:

kubernetes.io/hostname: micro-k8s # имя ноды на которой запускается

containers:

- name: busybox

image: busybox:1.28

command: ['sh', '-c', 'mkdir -p /out/logs && while true; do echo "$(date) - Test message" >> /out/logs/success.txt; sleep 5; done']

volumeMounts:

- name: volume

mountPath: /out/logs

- name: multitool

image: wbitt/network-multitool

command: ['sh', '-c', 'tail -f /out/logs/success.txt']

volumeMounts:

- name: volume

mountPath: /out/logs

volumes:

- name: volume

persistentVolumeClaim:

claimName: pvc-vol
```
манифест PV
```
apiVersion: v1

kind: PersistentVolume

metadata:

name: local-volume

spec:

capacity:

storage: 1Gi

accessModes:

- ReadWriteOnce

persistentVolumeReclaimPolicy: Delete

storageClassName: local-storage

hostPath:

path: /data/pvc-first
```
манифест PVC
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

name: pvc-vol

namespace: netology

spec:

storageClassName: local-storage

accessModes:

- ReadWriteOnce

resources:

requests:

storage: 1Gi
```
1. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
![](Pasted%20image%2020250729120901.png)
2. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
Проверка работы busybox
![](Pasted%20image%2020250729121516.png)
Для проверки чтения воспользуемся командой просмотра логов

![](Pasted%20image%2020250729121708.png)
Все работает.
Ремарка. Создание каталога /data/pvc-first на ноде вручную не требуется так в этой версии микрокубера предусмотрено автоматическое создание каталогов при их отсутствии.

3. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
Удаляю Deployment и PVC 
![](Pasted%20image%2020250729122918.png)
При удалении Deployment и PVC - PV перешел в состояние Failed, т.к. контроллер PV не сумел удалить данные по пути `/data/pvc-first`. 

Если PVC не удалять, а удалить только Deployment, то PV будет в статусе "Bound"
3. Продемонстрировать, что файл сохранился на локальном диске ноды.
![](Pasted%20image%2020250729123011.png)
4. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
![](Pasted%20image%2020250729143045.png)
![](Pasted%20image%2020250729143004.png)
После удаления PV, файл в директории `/data/pvc-first` остался на месте из-за особенностей работы контроллера PV с hostPath.

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
https://github.com/ekhristin/netology/blob/main/K8s_Home_7/deployment_nfs.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_7/pvc.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_7/pv.yaml
------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
так плагина nfs нет в коровском репозитарии подключаем community 
microk8s enable community
далее активируем nfs
![](Pasted%20image%2020250729143927.png)


2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
Согласно заданию создаю манифесты
Deployment
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: multool

namespace: netology

labels:

app: multool

spec:

selector:

matchLabels:

app: multool

replicas: 1

template:

metadata:

labels:

app: multool

spec:

containers:

- name: multitool

image: wbitt/network-multitool

ports:

- containerPort: 8080

env:

- name: HTTP_PORT

value: "7880"

volumeMounts:

- name: nfs-storage

mountPath: "/data"

volumes:

- name: nfs-storage

persistentVolumeClaim:

claimName: nfs-pvc
```
Так как PV для NFS  у нас поднят автоматически дописываю
PVC
```
apiVersion: v1

kind: PersistentVolumeClaim

metadata:

name: nfs-pvc

namespace: netology

spec:

accessModes:

- ReadWriteMany

resources:

requests:

storage: 1Gi
```
Запускаем манифесты последовательно, после применения PVC под с мультитулом стартует.
![](Pasted%20image%2020250729144908.png)
![](Pasted%20image%2020250729144934.png)
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
Для этого подключусь к мультитулу 
Делаю запись в файл и чтение из него в мультитул
![](Pasted%20image%2020250729150118.png)
Чтобы посмотреть файл на ноде необходимо уточнить где он примонтирован, для этого с помощью команды `kubectl describe pv` путь размещения файла
![](Pasted%20image%2020250729202341.png)
Проверяю файл по пути /var/snap/microk8s/common/default-storage/netology-nfs-pvc-pvc-8b0dfc74-a1d3-48b0-9efc-30d759da4310
![](Pasted%20image%2020250729202535.png)
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
https://github.com/ekhristin/netology/blob/main/K8s_Home_7/deployment_nfs.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_7/pvc_nfs.yaml
------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
