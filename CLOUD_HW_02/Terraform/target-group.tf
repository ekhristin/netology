resource "yandex_lb_target_group" "lamp-tg" {
  name      = "lamp-target-group"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp-group.instances
    content {
      subnet_id = yandex_vpc_subnet.public.id
      address   = target.value.network_interface[0].ip_address
    }
  }
}
