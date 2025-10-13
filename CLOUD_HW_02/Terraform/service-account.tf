resource "yandex_iam_service_account" "vm-sa" {
  name        = "vm-service-account"
  description = "SA for managing computer instances"
  folder_id   = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_binding" "vm-permissions" {
  folder_id = var.yc_folder_id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.vm-sa.id}"
  ]
}

resource "yandex_iam_service_account_static_access_key" "vm-sa-key" {
  service_account_id = yandex_iam_service_account.vm-sa.id
  description        = "Static key for VM management"
}
