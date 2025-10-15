# variable "yc_token" {
#   description = "Yandex Cloud OAuth token"
#   type        = string
#   sensitive   = true
# }

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default = "b1gl1mia19itahjudhdr"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default = "b1gb7eigrg8f1c85cu89"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "khristin-151025"
}

variable "image_path" {
  description = "Path to local image file"
  type        = string
  default     = "image.jpg"
}

variable "kms_key_name" {
  description = "Name of the KMS key"
  type        = string
  default     = "s3-encryption-key"
}
variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}