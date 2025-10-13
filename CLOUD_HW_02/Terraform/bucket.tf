resource "yandex_storage_bucket" "netology-bucket" {
  bucket     = var.bucket_name
  folder_id  = var.yc_folder_id
  acl        = "public-read"
  force_destroy = true
}

resource "yandex_storage_object" "image" {
  bucket     = yandex_storage_bucket.netology-bucket.bucket
  key        = "image.jpg"
  source     = var.image_path
  acl        = "public-read"
}
