# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

### Цели задания

1. Создать свои ресурсы в облаке Yandex Cloud с помощью Terraform.
2. Освоить работу с переменными Terraform.


### Чек-лист готовности к домашнему заданию

1. Зарегистрирован аккаунт в Yandex Cloud. Использован промокод на грант.
2. Установлен инструмент Yandex CLI.
3. Исходный код для выполнения задания расположен в директории [**02/src**](https://github.com/netology-code/ter-homeworks/tree/main/02/src).


### Задание 0

1. Ознакомьтесь с [документацией к security-groups в Yandex Cloud](https://cloud.yandex.ru/docs/vpc/concepts/security-groups?from=int-console-help-center-or-nav). 
Этот функционал понадобится к следующей лекции.

------
### Внимание!! Обязательно предоставляем на проверку получившийся код в виде ссылки на ваш github-репозиторий!
------

### Задание 1
В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.
Убедитесь что ваша версия **Terraform** ~>1.8.4

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Создайте сервисный аккаунт и ключ. [service_account_key_file](https://terraform-provider.yandexcloud.net).
```
С помощью инструмента YANDEX.CLOUD iam https://console.yandex.cloud/folders/b1gb7eigrg8f1c85cu89/iam создаем сервисный акаунт.
```
```
Получаем токен согласно инструкции https://yandex.cloud/ru/docs/iam/operations/iam-token/create-for-sa .
```
3. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную **vms_ssh_public_root_key**.
4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
![](Pasted%20image%2020250203232030.png)
Эта ошибка связана с использованием неверного аргумента platform_id = "standart-v4" платформы standart-v4 нет есть standard-v3 - исправляем platform_id = "standard-v3".
![](Pasted%20image%2020250203232652.png)
Эта ошибка говорит о том что выбрано неправильное значение использования ядра процессора для resource "yandex_compute_instance" исправляем "platform"  
core_fraction = 20
![](Pasted%20image%2020250203233039.png)
Эта ошибка говорит о том что выбрано неправильное значение ядер исправляем 
cores = 2
![](Pasted%20image%2020250203233620.png)

5. Подключитесь к консоли ВМ через ssh и выполните команду ``` curl ifconfig.me```.
Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем ubuntu: ```"ssh ubuntu@vm_ip_address"```. Предварительно убедитесь, что ваш ключ добавлен в ssh-агент: ```eval $(ssh-agent) && ssh-add``` Вы познакомитесь с тем как при создании ВМ создать своего пользователя в блоке metadata в следующей лекции.;
![](Pasted%20image%2020250203234151.png)
6. Ответьте, как в процессе обучения могут пригодиться параметры ```preemptible = true``` и ```core_fraction=20``` в параметрах ВМ.
Виртуальные машины с функцией прерывания (preemptible = true) являются отличным выбором для тестовых задач.
При использовании этой опции, виртуальная машина может быть остановлена системой через 24 часа, выбор того значения позволяет значительно снизить расходы на виртулизацию.

Параметр Core Fraction даёт возможность установить ограничение на долю мощности виртуального процессора, которая будет выделяться  ВМ. Если нагрузка на машину небольшая, можно задать значение 20% от одного ядра, чтобы избежать лишних затрат на вычислительные ресурсы
В качестве решения приложите:

- скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;
- скриншот консоли, curl должен отобразить тот же внешний ip-адрес;
- ответы на вопросы.


### Задание 2

1. Замените все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
```
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
```
variable "vm_web_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "image"
}

variable "vm_web_user" {
  type        = string
  default     = "ubuntu"
  description = "user"
}

variable "vm_web_name" {
  type        = string
  description = "Name"
  default     = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  description = "platform ID"
  default     = "standard-v3"
}

variable "vm_web_cores" {
  type        = number
  description = "CPU"
  default     = 2
}

variable "vm_web_memory" {
  type        = number
  description = "RAM"
  default     = 1
}

variable "vm_web_core_fraction" {
  type        = number
  description = "CPU%"
  default     = 20
}
variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "nat"
}
```
3. Проверьте terraform plan. Изменений быть не должно. 
![](Pasted%20image%2020250204211455.png)

### Задание 3

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  ```cores  = 2, memory = 2, core_fraction = 20```. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').  ВМ должна работать в зоне "ru-central1-b"
```
#сеть для первой машины
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
#сеть для второй машины в зоне b
resource "yandex_vpc_network" "db" {
  name = var.vpc_db
}

resource "yandex_vpc_subnet" "db" {
  name           = var.vpc_db
  zone           = var.b-zone
  network_id     = yandex_vpc_network.db.id
  v4_cidr_blocks = var.b-zone_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
resource "yandex_compute_instance" "db" {
  name        = var.vm_db_name
  zone        = var.vm_db_zone
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_preemptible
  } 
  network_interface {
    subnet_id = yandex_vpc_subnet.db.id
    nat       = var.vm_db_nat
  }
  
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
```

Листинг файла vms_platform.tf
```
# web
variable "vm_web_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "image"
}

variable "vm_web_user" {
  type        = string
  default     = "ubuntu"
  description = "user"
}

variable "vm_web_name" {
  type        = string
  description = "Name"
  default     = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  description = "platform ID"
  default     = "standard-v3"
}

variable "vm_web_cores" {
  type        = number
  description = "CPU"
  default     = 2
}

variable "vm_web_memory" {
  type        = number
  description = "RAM"
  default     = 1
}

variable "vm_web_core_fraction" {
  type        = number
  description = "CPU%"
  default     = 20
}
variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "nat"
}
variable "vm_db_name" {
  type        = string
  description = "Name"
  default     = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type        = string
  description = "platform ID"
  default     = "standard-v3"
}

variable "vm_db_cores" {
  type        = number
  description = "CPU"
  default     = 2
}

variable "vm_db_memory" {
  type        = number
  description = "RAM"
  default     = 2
}

variable "vm_db_core_fraction" {
  type        = number
  description = "CPU%"
  default     = 20
}
variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_db_nat" {
  type        = bool
  default     = true
  description = "nat"
}

variable "b-zone" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "b-zone_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vpc_db" {
  type        = string
  default     = "db"
  description = "VPC network & subnet db"
}
```
3. Примените изменения.
![](Pasted%20image%2020250204215931.png)

### Задание 4

1. Объявите в файле outputs.tf **один** output , содержащий: instance_name, external_ip, fqdn для каждой из ВМ в удобном лично для вас формате.(без хардкода!!!)
```
output "instances" {
  value = {
    web = {
      instance_name = yandex_compute_instance.platform.name
      external_ip   = yandex_compute_instance.platform.network_interface[0].nat_ip_address
    }
    db = {
      instance_name = yandex_compute_instance.db.name
      external_ip   = yandex_compute_instance.db.network_interface[0].nat_ip_address
    }
  }
}
```
2. Примените изменения.

В качестве решения приложите вывод значений ip-адресов команды ```terraform output```.
![](Pasted%20image%2020250204222105.png)

### Задание 5

1. В файле locals.tf опишите в **одном** local-блоке имя каждой ВМ, используйте интерполяцию ${..} с НЕСКОЛЬКИМИ переменными по примеру из лекции.
```
locals {
  vm_web_f_name = "${var.vpc_name}-${var.vm_web_name}"
  vm_db_f_name  = "${var.vpc_db}-${var.vm_db_name}"
}
```
2. Замените переменные внутри ресурса ВМ на созданные вами local-переменные.
![](Pasted%20image%2020250204222810.png)
![](Pasted%20image%2020250204222739.png)
3. Примените изменения.
![](Pasted%20image%2020250204222909.png)
![](Pasted%20image%2020250204223229.png)
### Задание 6

1. Вместо использования трёх переменных  ".._cores",".._memory",".._core_fraction" в блоке  resources {...}, объедините их в единую map-переменную **vms_resources** и  внутри неё конфиги обеих ВМ в виде вложенного map(object).  
   ```
   пример из terraform.tfvars:
   vms_resources = {
     web={
       cores=2
       memory=2
       core_fraction=5
       hdd_size=10
       hdd_type="network-hdd"
       ...
     },
     db= {
       cores=2
       memory=4
       core_fraction=20
       hdd_size=10
       hdd_type="network-ssd"
       ...
     }
   }
   ```
```
variable "vms_resources" {
  description = "единая map-переменная"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
        cores        = 2
        memory       = 1
        core_fraction = 20
    },
    db = {
        cores        = 2
        memory       = 2
        core_fraction = 20
    }
  }
}
```
2. Создайте и используйте отдельную map(object) переменную для блока metadata, она должна быть общая для всех ваших ВМ.
   ```
   пример из terraform.tfvars:
   metadata = {
     serial-port-enable = 1
     ssh-keys           = "ubuntu:ssh-ed25519 AAAAC..."
   }
   ```  
```
variable "metadata" {
  type = map(string)
  description = "Metadata"
}
metadata = {
  serial-port-enable = "1",
  ssh-keys = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiZjyQiMYyn9ZJrggVSncksTiG+2NMFf2TVZmROmb6O ssilchin-deb"
}

```

3. Найдите и закоментируйте все, более не используемые переменные проекта.
Для поиска не используемых переменных воспользовался TFLINT
![](Pasted%20image%2020250205224657.png)
Закоментировал неиспользуемые переменные пример 
![](Pasted%20image%2020250205224840.png)

4. Проверьте terraform plan. Изменений быть не должно.
![](Pasted%20image%2020250204232105.png)
------

## Дополнительное задание (со звёздочкой*)

**Настоятельно рекомендуем выполнять все задания со звёздочкой.**   
Они помогут глубже разобраться в материале. Задания со звёздочкой дополнительные, не обязательные к выполнению и никак не повлияют на получение вами зачёта по этому домашнему заданию. 


------
### Задание 7*

Изучите содержимое файла console.tf. Откройте terraform console, выполните следующие задания: 

1. Напишите, какой командой можно отобразить **второй** элемент списка test_list.
```
local.test_list[1]
```
![](Pasted%20image%2020250204233050.png)
2. Найдите длину списка test_list с помощью функции length(<имя переменной>).
```
	length(local.test_list)
```
![](Pasted%20image%2020250204233250.png)
3. Напишите, какой командой можно отобразить значение ключа admin из map test_map.
```
local.test_map["admin"]
```
![](Pasted%20image%2020250204233542.png)
4. Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.

```
"${local.test_map["admin"]} is ${keys(local.test_map)[0]} for ${local.test_list[2]} server based on OS ${local.servers["production"]["image"]} with ${local.servers["production"]["cpu"]} vcpu ${local.servers["production"]["ram"]} ram and ${length(local.servers["production"]["disks"])} virtual disks"
 ```
 ![](Pasted%20image%2020250204235702.png)
**Примечание**: если не догадаетесь как вычленить слово "admin", погуглите: "terraform get keys of map"

В качестве решения предоставьте необходимые команды и их вывод.

------

### Задание 8*
1. Напишите и проверьте переменную test и полное описание ее type в соответствии со значением из terraform.tfvars:
```
test = [
  {
    "dev1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117",
      "10.0.1.7",
    ]
  },
  {
    "dev2" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@84.252.140.88",
      "10.0.2.29",
    ]
  },
  {
    "prod1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@51.250.2.101",
      "10.0.1.30",
    ]
  },
]
```
2. Напишите выражение в terraform console, которое позволит вычленить строку "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117" из этой переменной.
------

------

### Задание 9*

Используя инструкцию https://cloud.yandex.ru/ru/docs/vpc/operations/create-nat-gateway#tf_1, настройте для ваших ВМ nat_gateway. Для проверки уберите внешний IP адрес (nat=false) у ваших ВМ и проверьте доступ в интернет с ВМ, подключившись к ней через serial console. Для подключения предварительно через ssh измените пароль пользователя: ```sudo passwd ubuntu```

### Правила приёма работыДля подключения предварительно через ssh измените пароль пользователя: sudo passwd ubuntu
В качестве результата прикрепите ссылку на MD файл с описанием выполненой работы в вашем репозитории. Так же в репозитории должен присутсвовать ваш финальный код проекта.

**Важно. Удалите все созданные ресурсы**.


### Критерии оценки

Зачёт ставится, если:

* выполнены все задания,
* ответы даны в развёрнутой форме,
* приложены соответствующие скриншоты и файлы проекта,
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку работу отправят, если:

* задание выполнено частично или не выполнено вообще,
* в логике выполнения заданий есть противоречия и существенные недостатки. 

