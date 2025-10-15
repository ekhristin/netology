output "bucket_url" {
  value = "https://${yandex_storage_bucket.bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"
}