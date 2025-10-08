# variable "yc_token" {
#  description = "Yandex Cloud OAuth token"
#  type        = string
#  sensitive   = true
# }

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  sensitive   = true
  default = "b1gl1mia19itahjudhdr"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  sensitive   = true
  default = "b1gb7eigrg8f1c85cu89"
}

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}
