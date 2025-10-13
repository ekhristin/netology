output "bucket_url" {
  value = "https://${yandex_storage_bucket.netology-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}

output "nlb_ip" {
  value = try(yandex_lb_network_load_balancer.nlb.listener[*].external_address_spec[*].address[0], "NLB not created")
}

output "instance_group_instances" {
  value = yandex_compute_instance_group.lamp-group.instances[*].network_interface[0].nat_ip_address
}

output "alb_dns_name" {
  value = try(
    one([
      for endpoint in yandex_alb_load_balancer.alb.listener[*].endpoint[*].address[*].external_ipv4_address[*].address
      : endpoint
    ]),
    null
  )
}
