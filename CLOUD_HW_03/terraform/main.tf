resource "yandex_kms_symmetric_key" "s3_key" {
  name              = var.kms_key_name
  description       = "Encryption key for S3 bucket"
  default_algorithm = "AES_256"
  rotation_period   = "600h"
}

resource "yandex_storage_bucket" "bucket" {
  bucket    = var.bucket_name
  folder_id = var.yc_folder_id
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.s3_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_object" "image" {
  bucket = yandex_storage_bucket.bucket.bucket
  key    = basename(var.image_path)
  source = var.image_path
}
