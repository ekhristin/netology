# Домашнее задание к занятию 3 «Использование Ansible»

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
Для автоматизации процесса создания хостов и сети написал скрипт[terrafor](https://github.com/ekhristin/netology/tree/main/Ans_Homew3/terraform)

2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
```Ansible
- name: Install Nginx

handlers:

- name: Start-nginx

ansible.builtin.service:

name: nginx

state: restarted

become: true

become_method: sudo

- name: Restart-nginx

ansible.builtin.service:

name: nginx

state: reloaded

become: true

become_method: sudo

hosts: lighthouse

tasks:

- name: Nginx | Install epel-release

become: true

ansible.builtin.yum:

name: epel-release

state: present

- name: Nginx | Install Nginx

become: true

ansible.builtin.yum:

name: nginx

state: present

- name: Nginx | Create config

become: true

ansible.builtin.template:

src: templates/nginx.conf.j2

dest: /etc/nginx/nginx.conf

mode: '0644'

notify: Start-nginx

tags: Nginx

  

- name: Install Lighthouse

hosts: lighthouse

handlers:

- name: Restart-nginx

ansible.builtin.service:

name: nginx

state: restarted

become: true

become_method: sudo

pre_tasks:

- name: Lighthouse | Install Dependencies

become: true

ansible.builtin.yum:

name: git

state: present

tasks:

- name: Create Lighthouse directory

become: true

ansible.builtin.file:

path: /var/www/lighthouse

state: directory

recurse: yes

mode: '0755'

owner: nginx

group: nginx

- name: Check if Lighthouse directory exists

ansible.builtin.stat:

path: /var/www/lighthouse/.git

register: lighthouse_repo

- name: Ensure safe.directory is set for /var/www/lighthouse

ansible.builtin.shell:

cmd: "git config --global --add safe.directory /var/www/lighthouse"

args:

creates: /var/www/lighthouse/.git

- name: Lighthouse | Clone from Git

become: true

ansible.builtin.git:

repo: "{{ lighthouse_vcs }}"

version: "master"

dest: "{{ lighthouse_location_dir }}"

update: false

when: not lighthouse_repo.stat.exists

changed_when: false

- name: Lighthouse | Create lighthouse config

become: true

ansible.builtin.template:

src: templates/lighthouse.conf.j2

dest: /etc/nginx/conf.d/default.conf

mode: '0644'

notify: Restart-nginx

tags: Lighthouse
```
1. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
2. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
3. Подготовьте свой inventory-файл `prod.yml`.
![](Pasted%20image%2020250315222425.png)
4. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
5. Попробуйте запустить playbook на этом окружении с флагом `--check`.
![](Pasted%20image%2020250315223445.p
Выполнение playbook завершилось с ошибкой, т.к. этот флаг не вносит изменения в системы, а выполнение playbook требует скачивания и установки пакетов приложений.
6. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
7. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
![](Pasted%20image%2020250315225503.png)
8. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
9. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
