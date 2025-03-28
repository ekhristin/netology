# Домашнее задание к занятию 4 «Работа с roles»

## Подготовка к выполнению

1. * Необязательно. Познакомьтесь с [LightHouse](https://youtu.be/ymlrNlaHzIY?t=929).
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю на GitHub.

## Основная часть

Ваша цель — разбить ваш playbook на отдельные roles. 

Задача — сделать roles для ClickHouse, Vector и LightHouse и написать playbook для использования этих ролей. 

Ожидаемый результат — существуют три ваших репозитория: два с roles и один с playbook.

**Что нужно сделать**

1. Создайте в старой версии playbook файл `requirements.yml` и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```
![](Pasted%20image%2020250322200206.png)
2. При помощи `ansible-galaxy` скачайте себе эту роль.
Выполняем команду 
```
ansible-galaxy install -r requirements.yml -p roles
```
Результат выполнения команды приведен на  скриншоте 
![](Pasted%20image%2020250322202154.png)
по его успешному выполнению скопировались все необходимые директории и файлы.
![](Pasted%20image%2020250322202359.png)
3. Создайте новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 
[**vars**](https://github.com/ekhristin/vector-role/blob/0.42.0/vars/main.yml)[**default**](https://github.com/ekhristin/vector-role/blob/0.42.0/defaults/main.yml)
5. Перенести нужные шаблоны конфигов в `templates`.
В [**template**](https://github.com/ekhristin/vector-role/tree/0.42.0/templates)положил файл конфига вектора **vector.yaml.j2**
6. Опишите в `README.md` обе роли и их параметры. Пример качественной документации ansible role [по ссылке](https://github.com/cloudalchemy/ansible-prometheus).
[**vector readme**](https://github.com/ekhristin/vector-role/blob/0.42.0/README.md) [**lighthouse readme**](https://github.com/ekhristin/lighthouse-role/blob/main/README.md)
7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.
[**vars**](https://github.com/ekhristin/lighthouse-role/blob/main/vars/main.yml)[**default**](https://github.com/ekhristin/lighthouse-role/blob/main/defaults/main.yml)
В [**template**](https://github.com/ekhristin/lighthouse-role/tree/main/templates)положил файлы конфигов nginx и lighthouse  nginx.conf.j2 lighthouse.conf.j2 
8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в `requirements.yml` в playbook.
[**vector-role**](https://github.com/ekhristin/vector-role) [**lighthouse-role**](https://github.com/ekhristin/lighthouse-role) [**requirements.yml**](https://github.com/ekhristin/netology/blob/main/Ans_home_4/playbook/requirements.yml)
9. Переработайте playbook на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.
[**playbook/site.yml**](https://github.com/ekhristin/netology/blob/main/Ans_home_4/playbook/site.yml)
10. Выложите playbook в репозиторий.
[**playbook**](https://github.com/ekhristin/netology/tree/main/Ans_home_4/playbook)
11. В ответе дайте ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.
[**vector-role**](https://github.com/ekhristin/vector-role) [**lighthouse-role**](https://github.com/ekhristin/lighthouse-role)[**playbook**](https://github.com/ekhristin/netology/tree/main/Ans_home_4/playbook)
---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
