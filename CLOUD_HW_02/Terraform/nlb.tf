resource "yandex_lb_network_load_balancer" "nlb" {
  name = "netology-nlb"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp-tg.id

    healthcheck {
      name                = "http-healthcheck"
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
}
