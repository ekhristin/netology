# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

### Цели задания

1. Отработать основные принципы и методы работы с управляющими конструкциями Terraform.
2. Освоить работу с шаблонизатором Terraform (Interpolation Syntax).

------

### Чек-лист готовности к домашнему заданию

1. Зарегистрирован аккаунт в Yandex Cloud. Использован промокод на грант.
2. Установлен инструмент Yandex CLI.
3. Доступен исходный код для выполнения задания в директории [**03/src**](https://github.com/netology-code/ter-homeworks/tree/main/03/src).
4. Любые ВМ, использованные при выполнении задания, должны быть прерываемыми, для экономии средств.

------

### Внимание!! Обязательно предоставляем на проверку получившийся код в виде ссылки на ваш github-репозиторий!
Убедитесь что ваша версия **Terraform** ~>1.8.4
Теперь пишем красивый код, хардкод значения не допустимы!
------

### Задание 1

1. Изучите проект.
2. Инициализируйте проект, выполните код. 
Чтобы проект смог инициализироваться пришлось поправить файл провайдера 
![](Pasted%20image%2020250211214640.png)
и немного файл провайдера для безовасного хранения токена
![](Pasted%20image%2020250211220708.png)
инициализируем и запускаем проект.

Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud .
![](Pasted%20image%2020250211221456.png)
------

### Задание 2

1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.(как это сделать узнайте в документации провайдера yandex/compute_instance )
Листинг файла **count-vm.tf**
```
variable "each_vm" {
  type = list(object({ vm_name = string, cpu = number, ram = number, disk_volume = number, disk_type = string, core_fraction = number, platform_id = string, preemptible = bool }))
  default = [{
    core_fraction = 20
    cpu           = 4
    disk_volume   = 15
    disk_type     = "network-hdd"
    platform_id   = "standard-v3"
    ram           = 4
    vm_name       = "main"
    preemptible   = true
  },
  {
    core_fraction = 20
    cpu           = 2
    disk_volume   = 10
    disk_type     = "network-hdd"
    platform_id   = "standard-v3"
    ram           = 2
    vm_name       = "replica"
    preemptible   = true
  }]
}

resource "yandex_compute_instance" "db" {
  for_each = {
    for index, vm in var.each_vm :
    vm.vm_name => vm
  }

  name        = each.value.vm_name
  hostname    = each.value.vm_name
  platform_id = each.value.platform_id

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = each.value.disk_type
      size     = each.value.disk_volume
    }
  }

    metadata = local.metadata

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = toset([yandex_vpc_security_group.example.id])
  }

}
```
3. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk_volume , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну общую переменную типа:
```
variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, disk_volume=number }))
}
```
Листинг файла **for_each-vm.tf**
```
variable "web_settings" {
  type = object({
    platform_id   = string,
    core_count    = number,
    core_fraction = number,
    memory_count  = number,
    hdd_size      = number,
    hdd_type      = string,
    preemptible   = bool,
    nat           = bool
  })
  default = {
    core_count    = 2,
    core_fraction = 20,
    memory_count  = 2,
    hdd_size      = 10,
    hdd_type      = "network-hdd",
    platform_id   = "standard-v3",
    preemptible   = true,
    nat           = true
  }
}

resource "yandex_compute_instance" "web" {
  count = 2
  depends_on = [ yandex_compute_instance.db ]

  name        = "web-${count.index + 1}"
  hostname    = "web-${count.index + 1}"
  platform_id = var.web_settings.platform_id

  resources {
    core_fraction = var.web_settings.core_fraction
    cores         = var.web_settings.core_count
    memory        = var.web_settings.memory_count
  }
  scheduling_policy {
    preemptible = var.web_settings.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.web_settings.hdd_type
      size     = var.web_settings.hdd_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = toset([yandex_vpc_security_group.example.id]) #прикручиваем политику
    nat                = var.web_settings.nat
  }

  metadata = local.metadata
}
```
При желании внесите в переменную все возможные параметры.

	1. ВМ из пункта 2.1 должны создаваться после создания ВМ из пункта 2.2.
1. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.
```

variable "cloud_id" {
  type        = string
  default = "b1gl1mia19itahjudhdr"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default = "b1gb7eigrg8f1c85cu89"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}
variable "vm_web_user" {
  type        = string
  default     = "ubuntu"
  description = "user"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts" 
}
variable "path_ssh_key" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  description = "Path to the SSH key file"
}
locals {
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "${var.vm_web_user}:${file(var.path_ssh_key)}"
  }
}
```
3. Инициализируйте проект, выполните код.
![](Pasted%20image%2020250214095715.png)
![](Pasted%20image%2020250214095855.png)
![](Pasted%20image%2020250214095941.png)
![](Pasted%20image%2020250214100021.png)
	

------

### Задание 3

1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле **одиночную**(использовать count или for_each запрещено из-за задания №4) ВМ c именем "storage"  . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.
Листинг файла **disk_vm.tf**
```
variable "vm_settings_disk" {
  type = object({
    name = string
    size = number
    type = string
  })
  default = {
    name = "vm-disk"
    size = 1
    type = "network-hdd"
  }
}

variable "vm_settings_storage" {
  type = object({
    platform_id   = string,
    core_count    = number,
    core_fraction = number,
    memory_count  = number,
    hdd_type      = string,
    hdd_size      = number,
    preemptible   = bool
    name          = string
  })
  default = {
    core_count    = 2,
    core_fraction = 20,
    memory_count  = 2,
    hdd_size      = 10,
    hdd_type      = "network-hdd",
    platform_id   = "standard-v3",
    preemptible   = true,
    name          = "storage"
  }
}

resource "yandex_compute_disk" "v_disk" {
  count = 3

  name = "${var.vm_settings_disk.name}-${count.index + 1}"
  type = var.vm_settings_disk.type
  size = var.vm_settings_disk.size
  zone = var.default_zone
}

resource "yandex_compute_instance" "storage" {
  name        = var.vm_settings_storage.name
  hostname    = var.vm_settings_storage.name
  platform_id = var.vm_settings_storage.platform_id

  resources {
    core_fraction = var.vm_settings_storage.core_fraction
    cores         = var.vm_settings_storage.core_count
    memory        = var.vm_settings_storage.memory_count
  }

  scheduling_policy {
    preemptible = var.vm_settings_storage.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.vm_settings_storage.hdd_type
      size     = var.vm_settings_storage.hdd_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = toset([yandex_vpc_security_group.example.id])
    nat = true
  }

  dynamic "secondary_disk" {
    for_each = toset(yandex_compute_disk.v_disk.*.id)
    content {
      disk_id = secondary_disk.key
    }
  }

  metadata = local.metadata
}
```

------
![](Pasted%20image%2020250214203327.png)
![](Pasted%20image%2020250214203406.png)
### Задание 4

1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demo).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
2. Инвентарь должен содержать 3 группы и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
3. Добавьте в инвентарь переменную  [**fqdn**](https://cloud.yandex.ru/docs/compute/concepts/network#hostname).
``` 
[webservers]
web-1 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
web-2 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[databases]
main ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
replica ansible_host<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[storage]
storage ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
```
Пример fqdn: ```web1.ru-central1.internal```(в случае указания переменной hostname(не путать с переменной name)); ```fhm8k1oojmm5lie8i22a.auto.internal```(в случае отсутвия перменной hostname - автоматическая генерация имени,  зона изменяется на auto). нужную вам переменную найдите в документации провайдера или terraform console.
```
resource "local_file" "hosts_templatefile"{
 
    content = templatefile("${path.module}/hosts.tftpl",
    { webservers = yandex_compute_instance.web
      databases = yandex_compute_instance.db
      storage = [yandex_compute_instance.storage]
    })

   filename = "${abspath(path.module)}/hosts.cfg"
}
```
4. Выполните код. Приложите скриншот получившегося файла. 
![](Pasted%20image%2020250214225346.png)
![](Pasted%20image%2020250214225510.png)
Для общего зачёта создайте в вашем GitHub-репозитории новую ветку terraform-03. Закоммитьте в эту ветку свой финальный код проекта, пришлите ссылку на коммит.   
**Удалите все созданные ресурсы**.

------

## Дополнительные задания (со звездочкой*)

**Настоятельно рекомендуем выполнять все задания со звёздочкой.** Они помогут глубже разобраться в материале.   
Задания со звёздочкой дополнительные, не обязательные к выполнению и никак не повлияют на получение вами зачёта по этому домашнему заданию. 

### Задание 5* (необязательное)
1. Напишите output, который отобразит ВМ из ваших ресурсов count и for_each в виде списка словарей :
``` 
[
 {
  "name" = 'имя ВМ1'
  "id"   = 'идентификатор ВМ1'
  "fqdn" = 'Внутренний FQDN ВМ1'
 },
 {
  "name" = 'имя ВМ2'
  "id"   = 'идентификатор ВМ2'
  "fqdn" = 'Внутренний FQDN ВМ2'
 },
 ....
...итд любое количество ВМ в ресурсе(те требуется итерация по ресурсам, а не хардкод) !!!!!!!!!!!!!!!!!!!!!
]
```
Приложите скриншот вывода команды ```terrafrom output```.

------

### Задание 6* (необязательное)

1. Используя null_resource и local-exec, примените ansible-playbook к ВМ из ansible inventory-файла.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demo).
3. Модифицируйте файл-шаблон hosts.tftpl. Необходимо отредактировать переменную ```ansible_host="<внешний IP-address или внутренний IP-address если у ВМ отсутвует внешний адрес>```.

Для проверки работы уберите у ВМ внешние адреса(nat=false). Этот вариант используется при работе через bastion-сервер.
Для зачёта предоставьте код вместе с основной частью задания.

### Правила приёма работы

В своём git-репозитории создайте новую ветку terraform-03, закоммитьте в эту ветку свой финальный код проекта. Ответы на задания и необходимые скриншоты оформите в md-файле в ветке terraform-03.

В качестве результата прикрепите ссылку на ветку terraform-03 в вашем репозитории.

Важно. Удалите все созданные ресурсы.

### Задание 7* (необязательное)
Ваш код возвращает вам следущий набор данных: 
```
> local.vpc
{
  "network_id" = "enp7i560tb28nageq0cc"
  "subnet_ids" = [
    "e9b0le401619ngf4h68n",
    "e2lbar6u8b2ftd7f5hia",
    "b0ca48coorjjq93u36pl",
    "fl8ner8rjsio6rcpcf0h",
  ]
  "subnet_zones" = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c",
    "ru-central1-d",
  ]
}
```
Предложите выражение в terraform console, которое удалит из данной переменной 3 элемент из: subnet_ids и subnet_zones.(значения могут быть любыми) Образец конечного результата:
```
> <некое выражение>
{
  "network_id" = "enp7i560tb28nageq0cc"
  "subnet_ids" = [
    "e9b0le401619ngf4h68n",
    "e2lbar6u8b2ftd7f5hia",
    "fl8ner8rjsio6rcpcf0h",
  ]
  "subnet_zones" = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-d",
  ]
}
```
Пример выражения
```
{
  "network_id" = local.vpc.network_id,
  "subnet_ids" = splice(local.vpc.subnet_ids, 2, 1), # Удаляем 1 элемент, начиная с индекса 2 (третий элемент)
  "subnet_zones" = splice(local.vpc.subnet_zones, 2, 1) # То же самое для subnet_zones
}
```
### Задание 8* (необязательное)
Идентифицируйте и устраните намеренно допущенную в tpl-шаблоне ошибку. Обратите внимание, что terraform сам сообщит на какой строке и в какой позиции ошибка!
```
[webservers]
%{~ for i in webservers ~}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"] platform_id=${i["platform_id "]}}
%{~ endfor ~}
```
Ошибка пропущена фигурная закрывающая скобка } и после platform_id есть пробел. 
Код с исправлениями
```
[webservers]
%{~ for i in webservers ~}
${i["name"]} ansible_host=${i["network_interface"][0]["nat_ip_address"]} platform_id=${i["platform_id"]}
%{~ endfor ~}
```
### Задание 9* (необязательное)
Напишите  terraform выражения, которые сформируют списки:
1. ["rc01","rc02","rc03","rc04",rc05","rc06",rc07","rc08","rc09","rc10....."rc99"] те список от "rc01" до "rc99"
`formatlist("rc%02d", range(1, 100))`
3. ["rc01","rc02","rc03","rc04",rc05","rc06","rc11","rc12","rc13","rc14",rc15","rc16","rc19"....."rc96"] те список от "rc01" до "rc96", пропуская все номера, заканчивающиеся на "0","7", "8", "9", за исключением "rc19"
`[for i in range(1, 96) : format("rc%02d", i) if !contains([0, 7, 8, 9], i % 10) || i == 19]`
### Критерии оценки

Зачёт ставится, если:

* выполнены все задания,
* ответы даны в развёрнутой форме,
* приложены соответствующие скриншоты и файлы проекта,
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку работу отправят, если:

* задание выполнено частично или не выполнено вообще,
* в логике выполнения заданий есть противоречия и существенные недостатки. 


