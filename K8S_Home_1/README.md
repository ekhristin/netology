# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Чеклист готовности к домашнему заданию

1. Личный компьютер с ОС Linux или MacOS 

или

2. ВМ c ОС Linux в облаке либо ВМ на локальной машине для установки MicroK8S  

------



### Задание 1. Установка MicroK8S
    - sudo apt update,
    - sudo apt install snapd,
    - sudo snap install microk8s --classic,
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`,
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`.
для применения настроек группы в установленной терминальной сессии выполнил команду `newgrp microk8s`
**Скрин выполнения команд**
![](Pasted%20image%2020250522211103.png)
1. Полезные команды:
    - проверить статус `microk8s status --wait-ready`;
**Скрин выполнения команды**
![](Pasted%20image%2020250522211837.png)
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`;
    - включить addon можно через команду `microk8s enable`; 
**Скрин выполнения команды**
![](Pasted%20image%2020250522212129.png)
    - список addon `microk8s status`;
**Скрин выполнения команды**
![](Pasted%20image%2020250522212403.png)
    - вывод конфигурации `microk8s config`;
**Скрин выполнения команды**
![](Pasted%20image%2020250522212539.png)
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`.
**Скрин выполнения команды**
![](Pasted%20image%2020250522212636.png)
1. Настройка внешнего подключения:
    - отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89

```
Добавляем адрес для подключения 

![](Pasted%20image%2020250522213357.png)
	- обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`.

![](Pasted%20image%2020250522213449.png)
### 2. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl;
    - chmod +x ./kubectl;
    - sudo mv ./kubectl /usr/local/bin/kubectl;
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`;
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`.
### Устанавливаю kubectl на локальную машину

Для этого выполняем следующие команды на локальной машине 
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```
**Скрин выполнения**
![](Pasted%20image%2020250522214451.png)

генерирую на сервере конфиг 

![](Pasted%20image%2020250522214931.png)
Создаю директорию ~/.kube 
mkdir ~/.kube
Копирую полученные настройки в файл на локальную машину в ~/.kube/config 

Проверяю подключение.
Для этого ввожу команду **kubectl version**
![](Pasted%20image%2020250522215748.png)
и смотрю статус запущенных нод возвращает одну ноду
![](Pasted%20image%2020250522220016.png)



------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.

------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.
 Подключаюсь к dashboard при помощи port-forward для этого ввожу в командной строке
 ```
 ubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
```
![](Pasted%20image%2020250522221429.png)
Для подключения кубер запрашивает токен его необходимо сгенерировать на сервере командой 
```
microk8s kubectl create token default
```
в браузе обязательно пишем https://localhost:10443 если написать без https:// сервер не откроется
![](Pasted%20image%2020250522221251.png)

копируем токен в поле токен и жмем на кнопку войти.
Результатом будет открывшаяся консоль управления кубером.
![](Pasted%20image%2020250522222050.png)

 
------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get nodes` и скриншот дашборда.

