# Домашнее задание к занятию «Базовые объекты K8S»

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

------
### Решение задания 1. Создать Pod с именем hello-world

1. Подготовил манифест для запуска пода.
![](Pasted%20image%2020250527070223.png)
2. Указал имя пода hello-world, указал образ gcr.io/kubernetes-e2e-test-images/echoserver:2.2:

3. Создал под и запустил его:
Для этого ввел команду.
```
kubectl apply -f pod.yaml
```
ответом на нее было сообщение об успешном создании пода
![](Pasted%20image%2020250527074013.png)

4. С помощью port-forward пробрасываю порт пода в локальную сеть, после чего могу подключиться к поду:
```
kubectl port-forward -n default pod/hello-world 8080:8080 --address='0.0.0.0'
```
#### Разбор команды:

- **`kubectl port-forward`** – проброс портов из пода в локальную сеть.
    
- **`-n kube-system`** – указывает namespace, где находится под.
    
- **`pod/hello-world`** – имя пода, к которому применяется проброс.
    
- **`8080:8080`** – локальный порт `8080` пробрасывается на порт `8080` в поде.
    
- **`--address='0.0.0.0'`** – разрешает подключения не только с `localhost`, но и с других хостов (полезно для внешнего доступа).
Результат выполнения 
![](Pasted%20image%2020250527095634.png)
С помощью curl проверил ответ от POD на GET запрос:
```
curl -G http://127.0.0.1:8080
```
![](Pasted%20image%2020250527095805.png)


### Решение задания 2. Создать Service и подключить его к Pod

1 - 3. Пишу манифест для создания пода и сервиса, связываю их с помощью label и selector, использую образ gcr.io/kubernetes-e2e-test-images/echoserver:2.2:

![](Pasted%20image%2020250527100212.png)

Запускаю под и сервис:
```
kubectl apply -f service.yaml
```
![](Pasted%20image%2020250527100427.png)

4. Подключаюсь локально к Service с помощью kubectl port-forward:

```
kubectl port-forward -n default service/netolgy-svc 8085:80 
```
![](Pasted%20image%2020250527100734.png)

С помощью curl смотрю ответ от пода на GET запрос:
```
curl -G http://127.0.0.1:8085
```
![](Pasted%20image%2020250527100903.png)

При обращении к сервису netolgy-svc по проброшенному порту 8085 вижу ответ от пода netology-web, а значит, связь пода с сервисом работает.

Ссылки на манифесты:

Pod - https://github.com/

Service - https://github.com/
