# Домашнее задание к занятию «Конфигурация приложений»

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8s).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым GitHub-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/configuration/secret/) Secret.
2. [Описание](https://kubernetes.io/docs/concepts/configuration/configmap/) ConfigMap.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
согласно условию задания создаю манифест, учитываю возникновения ошибки (закрываю решение проблемы из пункта 2 задания) с использованием одно и  того же порта приложениями по умолчанию.Переношу значения порта в ConfigMap
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: nginx-multitool

namespace: netology

spec:

selector:

matchLabels:

app: nmt

replicas: 1

template:

metadata:

labels:

app: nmt

spec:

containers:

- name: nginx

image: nginx:1.25.4

ports:

- containerPort: 80

volumeMounts:

- name: nginx-index-file

mountPath: /usr/share/nginx/html/

- name: multitool

image: wbitt/network-multitool

ports:

- containerPort: 8080

env:

- name: HTTP_PORT

valueFrom:

configMapKeyRef:

name: multitool-maps

key: HTTP_PORT

volumes:

- name: nginx-index-file

configMap:

name: multitool-maps

```
2. Решить возникшую проблему с помощью ConfigMap.
Решено переносом переменной `HTTP_PORT` в ConfigMap
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
Запускаю два манифеста и проверяю что два контейнера запустились
![](Pasted%20image%2020250803075847.png)

4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
Согласно заданию получился простой манифест **config map**
```
apiVersion: v1

kind: ConfigMap

metadata:

name: multitool-maps

namespace: netology

data:

HTTP_PORT: '7880'

index.html: |

<html>

<h1>Welcome</h1>

</br>

<h1>Hi! This is a configmap Index file </h1>

</html>
```
и **service**
```
apiVersion: v1

kind: Service

metadata:

name: nginx-multitool-svc

namespace: netology

spec:

selector:

app: nmt

ports:

- protocol: TCP

name: nginx

port: 80

targetPort: 80

- protocol: TCP

name: multitool

port: 8080

targetPort: 7880
```

После полного запуска всех манифестов 
![](Pasted%20image%2020250803075959.png)
проверяю работу сервиса `kubectl exec -n netology nginx-multitool-7d5cb54649-trgj8 -c multitool -- curl -s http://nginx-multitool-svc`
![](Pasted%20image%2020250803080654.png)

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
https://github.com/ekhristin/netology/blob/main/K8s_home_8/deployment.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/configmap.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/service.yaml
------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.
На основе задания создаю манифест
```
apiVersion: apps/v1

kind: Deployment

metadata:

name: nginx-only

namespace: netology

labels:

app: nginx-frontend

spec:

replicas: 1

selector:

matchLabels:

app: nginx-frontend

template:

metadata:

labels:

app: nginx-frontend

spec:

containers:

- name: nginx

image: nginx:1.25.4

ports:

- containerPort: 80

readinessProbe:

httpGet:

path: /

port: 80

initialDelaySeconds: 5

periodSeconds: 10

livenessProbe:

httpGet:

path: /

port: 80

initialDelaySeconds: 15

periodSeconds: 20

volumeMounts:

- name: nginx-mount

mountPath: /usr/share/nginx/html

volumes:

- name: nginx-mount

configMap:

name: nginx-maps
```
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
Манифест configmap
```
apiVersion: v1

kind: ConfigMap

metadata:

name: nginx-maps

namespace: netology

data:

index.html: |

<!DOCTYPE html>

<html>

<body>

<h1>This is a modified test page!</h1>

</body>

</html>
```
1. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/Документы/netology/K8s_home_8/igress-tls.key -out ~/Документы/netology/K8s_home_8/ingress-tls.crt
![](Pasted%20image%2020250803200241.png)


Манифест Secret  создаю автоматически  командой `kubectl create secret tls ingress-tls-secret   --cert=/home/campas/Документы/netology/K8s_home_8/ingress-tls.crt   --key=/home/campas/Документы/netology/K8s_home_8/ingress-tls.key   --dry-run=client -o yaml > nginx_secret.yaml`

```
apiVersion: v1

data:

tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURxVENDQXBHZ0F3SUJBZ0lVQkt1VFJGQjhQM2I2VmVsa0pzc2ticDZmWmxNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1pERUxNQWtHQTFVRUJoTUNVbFV4Q3pBSkJnTlZCQWdNQWsxUE1ROHdEUVlEVlFRSERBWk5iM05qYjNjeApFVEFQQmdOVkJBb01DRTVsZEc5c2IyZDVNUXd3Q2dZRFZRUUxEQU5qYjIweEZqQVVCZ05WQkFNTURXMTVhVzVuCmNtVnpjeTVqYjIwd0hoY05NalV3T0RBek1UY3dNRE00V2hjTk1qWXdPREF6TVRjd01ETTRXakJrTVFzd0NRWUQKVlFRR0V3SlNWVEVMTUFrR0ExVUVDQXdDVFU4eER6QU5CZ05WQkFjTUJrMXZjMk52ZHpFUk1BOEdBMVVFQ2d3SQpUbVYwYjJ4dloza3hEREFLQmdOVkJBc01BMk52YlRFV01CUUdBMVVFQXd3TmJYbHBibWR5WlhOekxtTnZiVENDCkFTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTU5nR2c1MkZZdkUrUjB2Rnc5bXFTMzIKWURYNS9MUk45WkJ2dDVvK2FCaVU2RUFpczJFcE51RmRhZEtGWEV5Z295aE9HVVRCQVhmYWlSK1Q5Z2lnY0pIRwo3aHkwbnNFeXNwVkI1dmtXTnBIbVdWSlJ2S3E1WTRyNFU3L0NLSndManU4aXdDSTNjeHlyRmhXYjZzb1dYTFBkCldieEtnSVhFOW5IdE1mTjJpTGhnQ0tTRlB0M3FDSy9KL0xDbmV0ZE9MV3pBSSs2YTlUZGpPbU1iNW16M1Zuek8Kb3BsV1FQRHhVOWlxNHdZS1VqQTdQc01DRmN3UitsdC9xc2wxZVVIOEk3Tmx0Z3Z5d0pHL2l0Tm1TeHltakZ3ZAozb1p6MXMxN2hLSDAvNmZiSTUrUlJGMmNlZFdRYUZTa2VucVE5OHRnV1VtRVNUY0hjdWkrSkwveVQ5V0ozRWtDCkF3RUFBYU5UTUZFd0hRWURWUjBPQkJZRUZFQjFySzdlRmtzVTRFTzExcmtOLzgxQnYxV1lNQjhHQTFVZEl3UVkKTUJhQUZFQjFySzdlRmtzVTRFTzExcmtOLzgxQnYxV1lNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEUVlKS29aSQpodmNOQVFFTEJRQURnZ0VCQUl2K0FTVXB1dnp5SnlxdjJEQkNESm1NdEFvOGNjT2ZQaW1qTGhsRzVOWllHSjVBCndaR1Boa1R1QWduZHJHY0tuYWI3UGRWWFhVUnd4cmtlRDFVSTBnRi96d3E4V0pHb0ZGMm90SVgyc1NHM0hmVHIKMTdPMGErUk9Ob0dMV2dVbmprS3h3V1JPNGJHSXJyRlU2T1VVZ29KeEx1WHFuTVNiR1hIWTZiRHpQbGFucHR3TwpDZlB2TndjQmNvbmtXelk0bTMrT3VWd2orbWc4czI4VmxnR0VCbHJCK0dTSTFCTVA5dU43ZXJFZ282dkEwN1J4CjJOdHhXVWhQaGNQdHI3RDhYekFTeHlVTDVud2FVUzl6K0JFdkNPaUVsZjhDME9lQTdLT2VYc3piL3JYeGN2VGYKNDgvUTl5UWtBeDdhd0tCNWNQWWdaZFI1NGVWSis4Q3RvZHFuM3lFPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==

tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRRERZQm9PZGhXTHhQa2QKTHhjUFpxa3Q5bUExK2Z5MFRmV1FiN2VhUG1nWWxPaEFJck5oS1RiaFhXblNoVnhNb0tNb1RobEV3UUYzMm9rZgprL1lJb0hDUnh1NGN0SjdCTXJLVlFlYjVGamFSNWxsU1VieXF1V09LK0ZPL3dpaWNDNDd2SXNBaU4zTWNxeFlWCm0rcktGbHl6M1ZtOFNvQ0Z4UFp4N1RIemRvaTRZQWlraFQ3ZDZnaXZ5Znl3cDNyWFRpMXN3Q1B1bXZVM1l6cGoKRytaczkxWjh6cUtaVmtEdzhWUFlxdU1HQ2xJd096N0RBaFhNRWZwYmY2ckpkWGxCL0NPelpiWUw4c0NSdjRyVApaa3NjcG94Y0hkNkdjOWJOZTRTaDlQK24yeU9ma1VSZG5IblZrR2hVcEhwNmtQZkxZRmxKaEVrM0IzTG92aVMvCjhrL1ZpZHhKQWdNQkFBRUNnZ0VBRDlSemlBUnRUbnZSSzFvclppWU5ReG9aUllaUndWSW51V0l6NEIxNlZiT0sKOWRkWjdWOW5nTzhPcWU0QVFuMHBleFNJMjVjL3hUUkJzL3RMRGZ2aDR3M1pNUjQ1VnJJQzRqRUt3OWZXNkE5Zgo0Vm1hRGNNam01anZRRFE5RWhlbHB4Nkxycm9MYTZFNUV0c2xOT2FHOEZQWTkzYVozenpNTXdMaTd6VUZjdHJBCmtlWlZuV0lCbCtORy81YmVTajFvaEdYVlRMYk9pdnJBY3pxcmp6Sm01TEZBeXplYWFlTGtUSVZNbDRTVzZZMVIKL0ZnTXAzTGJPR0RGaVI2VHpWQnlxTzE0T0dHUDYreHV6ZWlzMDB1UWZqOHNoUXdPV3ozbVF0VDdxa1psa2pLVQp3VXdRZ2o0MmVnT29OQ1pzejlUNTRaMFA1QUtURjVYZGpCcTJ2ckJKMlFLQmdRRDlmNU9TVXY1ZEpuc09QcFlUClk2ODJ2bkZsMDYyMTd5dWZZTk16K3FLdEhTUXJITTNxbFRUcng5WUthUFdLU0tXZlNQcmhkVTRoNXNxd1NCbDcKYzUwdlNtOTBrRzdUc1pUZ09IZzdTNTFUZktXbE1xTXpyck5paVRxWmN1ZVFFT3VEcnYwNUN1eG1oRFlkMkEybwoxOUlWU01zYjhoYi82MkwwYkhXb09ZaUpkd0tCZ1FERlRhL1hYaHBLaW9VVDZYSFU3dldEa0FPbEFsV0QyU3hhCkJZSWdYN2tnK3Y2U1JPREdJc2k5Vkx0V1R1d3FvajcyUmNRTDlsM2xPSEdWZGVFenRnK0JIcDFNckxOeVdTaXoKOFE5S3UxS0RVZGVNVmdGRE50LzVMYkFua1lOeCtVaGUwZDk2dWV6RldNUGdwVWRpVWQzVDFmYUdhR1pxbDkvUApoU0d3SDVJNFB3S0JnQlBscDVlY25BcURzclR6aEtRUTl2ZTlDdm1MRzk5ajNuQ3NFT2ZMakdrNkdGU3A5aCtyCmhuUGJRNW1kazJnL080QzlJYlFBbVJsZ0hCaXFFQlg0aFNYcEdjWjBiNzU5K2NsL3BUQkNSeDcrY2FIOXo0R0cKL04ySEYrcGpjbm1FV25nRGpDeW1CdGdsR0hwUE13TkZyVit1VHdMcWhaT2d6aXVSTjhyMGVSc1JBb0dBRmdOawo2eEtFdkd4WURMQ3ZFcUxXb2FjZndQbFJzVFE1enBGdXcwM3F5ZE0zTS9xYldYL29CYmUrYnhLL0pzS1RZOGJFCjZOREVDUjhURFNucHhtczVyNTVLenBNMk1qdmdYck0ya1kvMDFOSDh5cHVONklIbTIxWk5vUnlMSGR4Q1J0SUQKclIyeFhSTmFSMllwWUw3aGtSRCtRR0RGakg4RmFaSGhBRldGYXVFQ2dZRUFoRXFHSkxoRHpnVndBQjdmVG1KSgpiVUZTaVBHYnJRTVFDWGlTSkE1OXFpekozZDdZcitLeDVvSDh3eEhSK3docitkRDQ3VVY0TURFZjdSYnBZYU1CCmQ1UEFUOVJ3K0RWWFdxYkhGN1Q1blk0dUROSmdONUN1Q2dUcmZQa0E1enI1cDNrNnZxVzB4QWhJekJDNjFaY3kKbnJSUG9xSm8yTVFtMlprbG5yREdib009Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K

kind: Secret

metadata:

creationTimestamp: null

name: ingress-tls-secret

namespace: netology

type: kubernetes.io/tls
```

1. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
Манифест ingress
```
apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

name: web-ingress

namespace: netology

annotations:

nginx.ingress.kubernetes.io/rewrite-target: /

kubernetes.io/ingress.class: nginx

spec:

ingressClassName: nginx

tls:

- hosts:

- myingress.com

secretName: ingress-cert

rules:

- host: myingress.com

http:

paths:

- path: /

pathType: Prefix

backend:

service:

name: nginx-service

port:

number: 80
```
Манифест service
```
apiVersion: v1

kind: Service

metadata:

name: nginx-service

namespace: netology

spec:

type: ClusterIP

selector:

app: nginx-frontend

ports:

- name: http

protocol: TCP

port: 80

targetPort: 80
```
Запускаю последовательно манифесты и проверяю работу сайта.

![](Pasted%20image%2020250803204038.png)
![](Pasted%20image%2020250803204413.png)
![](Pasted%20image%2020250803204749.png)
![](Pasted%20image%2020250803204528.png)

2. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
https://github.com/ekhristin/netology/blob/main/K8s_home_8/nginx_deployment.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/nginx_configmap.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/nginx_secret.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/nginx_service.yaml
https://github.com/ekhristin/netology/blob/main/K8s_home_8/nginx_ingress.yaml
------

### Правила приёма работы

1. Домашняя работа оформляется в своём GitHub-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------
