# Домашнее задание к занятию «Управление доступом»

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Чеклист готовности к домашнему заданию

1. Установлено k8s-решение, например MicroK8S.
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым github-репозиторием.

------

### Инструменты / дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) RBAC.
2. [Пользователи и авторизация RBAC в Kubernetes](https://habr.com/ru/company/flant/blog/470503/).
3. [RBAC with Kubernetes in Minikube](https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b).

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
Создаем сертификат.
`openssl genrsa -out user.key 2048`
персонализирую сертификат
`openssl req -new -key user.key -out user.csr -subj "/CN=dev/O=dev-group"`
Где 
- `CN=dev` — имя пользователя.
- `O=dev-group` — группа (для RBAC).
Создаю манифест CSR с привязкой пользователю
```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: dev-csr
spec:
  request: $(cat user.csr | base64 -w0)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 7776000  # срок жизни 3 месяца  
  usages:
  - client auth
```
Создаю переменную 
export BASE64_CSR=$(cat user.csr | base64 | tr -d '\n')
собираю манифест 
envsubst < csr.yaml >final_csr.yaml
применяем манифест `kubectl apply -f final_csr.yaml`
Одобряем CSR
kubectl certificate approve dev-csr
Проверяем подписанный сертификат 
kubectl get csr dev-csr -o wide
![](Pasted%20image%2020250830225940.png)
Получаем подписанный сертификат
kubectl get csr dev-csr -o jsonpath='{.status.certificate}' | base64 -d > user1.crt
Проверяем полученный сертификат
openssl x509 -in user1.crt -text -noout 
2. Настройте конфигурационный файл kubectl для подключения.
в результате работы был подготовлен следующий манифест
```
apiVersion: v1

clusters:

- cluster:

certificate-authority-data: ${CA_DATA}

server: https://192.168.3.3:16443

name: microk8s-cluster

contexts:

- context:

cluster: microk8s-cluster

user: dev-user

name: dev-user-context

current-context: dev-user-context

kind: Config

preferences: {}

users:

- name: dev-user

user:

client-certificate-data: ${CERT_DATA}
client-key-data: ${KEY_DATA}
```
Собираем манифест наполняя  по его актуальным значениям.
```
CA_DATA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}') \
CERT_DATA=$(cat user1.crt | base64 -w 0) \
KEY_DATA=$(cat user.key | base64 -w 0) \
envsubst < dev-user-kubeconfig.yaml > du-config.yaml
```
Копируем полученный конфигурационный файл в каталог .kube
cp dev-user-kubeconfig.yaml ~/.kube/config-dev-user (необязательная часть нужна в случае переключения конфигурационных файлов через переменную, мы же будем подтягивать с помощью)
проверяем подключение 
kubectl --kubeconfig du-config.yaml auth whoami
![](Pasted%20image%2020250831133914.png)

2. Создайте роли и все необходимые настройки для пользователя.
перед началом создания манифеста активирую контроллер RBAC без него всем пользователям будет доступно все.
![](Pasted%20image%2020250831170424.png)
3. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
на основе задания подготовил два манифеста с правами и привязкой к пользователю
```
piVersion: rbac.authorization.k8s.io/v1

kind: Role

metadata:

name: pod-reader

namespace: netology

rules:

- apiGroups: [""] # core API group

resources: ["pods"] # доступ к pods

verbs: ["get", "list", "watch"]

- apiGroups: [""] # core API group

resources: ["pods/log"] # доступ к логам pods

verbs: ["get", "list"]

- apiGroups: [""] # core API group

resources: ["pods/status"] # доступ к статусу pods (для describe)

verbs: ["get"]
```

```
apiVersion: rbac.authorization.k8s.io/v1

kind: RoleBinding

metadata:

name: dev-pod-access

namespace: netology

subjects:

# Для пользователя dev (из CN сертификата)

- kind: User

name: dev # ← ДОЛЖНО БЫТЬ "dev" (CN из сертификата)

apiGroup: rbac.authorization.k8s.io

# Для группы dev-group (из O сертификата) - опционально

- kind: Group

name: dev-group # ← Группа "dev-group" (O из сертификата)

apiGroup: rbac.authorization.k8s.io

roleRef:

kind: Role

name: pod-reader # ← Ссылается на Role выше

apiGroup: rbac.authorization.k8s.io
```
Применяю манифесты после проверяю доступы.
к дефолтному 
![](Pasted%20image%2020250831171740.png)
и неймспейсу нетология![](Pasted%20image%2020250831171804.png)

чтение информации о подах
![](Pasted%20image%2020250831171938.png)
запускаем тестовый под в неймспейсе netology
  
kubectl run test-pod --image=nginx --restart=Never -n netology
проверяем доступ к  логам пода
![](Pasted%20image%2020250831172937.png)
проверяю описание пода
![](Pasted%20image%2020250831173155.png)
проверяю недоступные действия
удаление 
![](Pasted%20image%2020250831173426.png)
2. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.
https://github.com/ekhristin/netology/blob/main/K8s_Home_9/csr.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_9/du-config.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_9/rbac.yaml
https://github.com/ekhristin/netology/blob/main/K8s_Home_9/rbac_binding.yaml


------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------

