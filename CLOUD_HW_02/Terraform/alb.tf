resource "yandex_alb_target_group" "alb-tg" {
  name = "alb-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp-group.instances
    content {
      subnet_id  = yandex_vpc_subnet.public.id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "lamp-http-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "lamp-virtual-host"
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = "lamp-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.lamp-backend-group.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "lamp-backend-group" {
  name = "lamp-backend-group"

  http_backend {
    name             = "lamp-http-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.alb-tg.id]
    
    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name = "lamp-application-lb"

  network_id = yandex_vpc_network.network.id

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}
