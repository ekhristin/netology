resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-instance-group"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.vm-sa.id

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = var.vm_image_id
        size     = 10
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      user-data = <<-EOF
        #!/bin/bash
        echo "<html><body><h1>Hello from LAMP</h1><img src='https://${yandex_storage_bucket.netology-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}'></body></html>" > /var/www/html/index.html
        systemctl restart apache2
      EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yc_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion  = 0
  }

  health_check {
    interval            = 5
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
    http_options {
      port = 80
      path = "/"
    }
  }
}
