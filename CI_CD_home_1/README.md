# Домашнее задание к занятию 7 «Жизненный цикл ПО»

## Подготовка к выполнению

1. Получить бесплатную версию Jira - https://www.atlassian.com/ru/software/jira/work-management/free (скопируйте ссылку в адресную строку). Вы можете воспользоваться любым(в том числе бесплатным vpn сервисом) если сайт у вас недоступен. Кроме того вы можете скачать [docker образ](https://hub.docker.com/r/atlassian/jira-software/#) и запустить на своем хосте self-managed версию jira.
2. Настроить её для своей команды разработки.
3. Создать доски Kanban и Scrum.
4. [Дополнительные инструкции от разработчика Jira](https://support.atlassian.com/jira-cloud-administration/docs/import-and-export-issue-workflows/).

## Основная часть

Необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить жизненный цикл:

1. Open -> On reproduce.
2. On reproduce -> Open, Done reproduce.
3. Done reproduce -> On fix.
4. On fix -> On reproduce, Done fix.
5. Done fix -> On test.
6. On test -> On fix, Done.
7. Done -> Closed, Open.

Для решения поставленной задачи:
создаем статусы указанные в задании по пути `settings > issues >issues atributes > statuses > add status`
![](Pasted%20image%2020250322084937.png)
В зависимости от статуса выбираем категорию.
создаем новый workflow по пути `settings > issues > workflows > add workflow > bug`:
Добавляю статусы созданные на предыдущем шаге в диаграмму с помощью кнопки `Add status`
![](Pasted%20image%2020250322085736.png)
Соединяем статусы согласно заданию и как итог получаем требуемый workflow ![](Pasted%20image%2020250322091738.png)

Остальные задачи должны проходить по упрощённому workflow:

1. Open -> On develop.
2. On develop -> Open, Done develop.
3. Done develop -> On test.
4. On test -> On develop, Done.
5. Done -> Closed, Open.
![](Pasted%20image%2020250322093101.png)
После подготовил канбан доску 
![](Pasted%20image%2020250322095354.png)
**Что нужно сделать**

6. Создайте задачу с типом bug, попытайтесь провести его по всему workflow до Done. 
![](Pasted%20image%2020250322095925.png)
7. Создайте задачу с типом epic, к ней привяжите несколько задач с типом task, проведите их по всему workflow до Done. 
![](Pasted%20image%2020250322103459.png)
![](Pasted%20image%2020250322103743.png)
8. При проведении обеих задач по статусам используйте kanban. 
Повторил те же операции только через канбан 
9. Верните задачи в статус Open.
![](Pasted%20image%2020250322104438.png)
10. Перейдите в Scrum, запланируйте новый спринт, состоящий из задач эпика и одного бага, стартуйте спринт, проведите задачи до состояния Closed. Закройте спринт.
Для этого переходим в SCRUM доску и берем задачи в спринт(закладка backlog)
![](Pasted%20image%2020250322104922.png)
и нажимаем кнопку grate sprint после переносим наши задачи в спринт
назначаем исполнителя 
![](Pasted%20image%2020250322105452.png)
и жмем кнопку `start sprint`
Выбираем продолжительность спринта и дату начала 
И получаем спринт 
![](Pasted%20image%2020250322105724.png)
Скриншот промежуточного этапа работы с доской. Чтобы было проще работать с доской лучше сделать столбцы на каждый статус, тогда будет удобно перетаскивать задачу между колонками. Сейчас доска выглядит более информативной, скажем так  отчетной для владельца продукта.
11. Если всё отработалось в рамках ожидания — выгрузите схемы workflow для импорта в XML. Файлы с workflow и скриншоты workflow приложите к решению задания.
Экспортирую workflow в XML для этого в окне workflow нажимаю кнопку Export и выбираю в формате XML
![](Pasted%20image%2020250322111020.png)

---
Ссылки на файлы:

[another workflow.xml](https://github.com/ekhristin/netology/blob/main/CI_CD_home_1/another%20workflow.xml)
[bug's.xml](https://github.com/ekhristin/netology/blob/main/CI_CD_home_1/bug's.xml)
### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
