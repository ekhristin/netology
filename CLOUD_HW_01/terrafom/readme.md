# Домашнее задание к занятию «Организация сети» - Сильчин Сергей

### Задание 1. Yandex Cloud 

1. Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.


### Решение  
1. После применения командой ```terraform apply``` создаются VPC, route table, и 3 VM (public-vm, private-vm, nat-instance):  
![image1](https://github.com/user-attachments/assets/e4951410-0e1d-41cb-bab9-bed82c8f15ac)  
![image2](https://github.com/user-attachments/assets/bdae5f8e-afbe-469d-89b2-05750837c042)  
![image3](https://github.com/user-attachments/assets/1fee90b9-19b4-4af2-a12c-ab0960acb0c8)  
![image4](https://github.com/user-attachments/assets/ce78410e-539a-4333-aff8-277043a77149)  


3. Проверяем подключение к public-vm ```ssh ubuntu@89.169.131.121``` и проверяем доступ в интернет:
![image5](https://github.com/user-attachments/assets/fc5fb3e4-5019-44a4-9e5f-01c196154123)  
4. Для того чтобы с public-vm подключиться к private-vm по ее локальному IP используем ssh agent forwarding, подключаемся к public-vm с форвардингом агента (ключ -A), далее подключаемся с public-vm к private-vm и проверяем с нее доступ в интернет:  
![image6](https://github.com/user-attachments/assets/bf075110-d0f6-451e-b89a-f607c4c6c79c)  
Также можно убедиться по трассировке, что трафик идет через NAT-инстанс с IP 192.168.10.254:  
![image7](https://github.com/user-attachments/assets/ff06134d-28ab-4b45-9e67-d23ef89efcf0)
И проверим, что у private-vm внешний IP соответствует NAT-инстансу:  
![image](https://github.com/user-attachments/assets/94216bb9-e0e6-49e8-8437-c32532199626)
5. Файлы *.tf закоммичены, кроме terraform.tfvars, где содержатся переменные для подключения yc_token, ус_cloud_id, ус_folder_id и yc_zone.
