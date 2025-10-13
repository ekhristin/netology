# variable "yc_token" {
#  description = "Yandex Cloud OAuth token"
#  type        = string
#  sensitive   = true
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

variable "yc_zone" {
  description = "Yandex Cloud default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "bucket_name" {
  description = "Name for the storage bucket"
  type        = string
  default     = "khristin-111025"
}

variable "image_path" {
  description = "Path to local image file"
  type        = string
  default     = "image.jpg"
}

variable "vm_image_id" {
  description = "ID of the LAMP image"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}

variable "subnet_cidr" {
  description = "block for public subnet"
  type        = string
  default     = "192.168.10.0/24"
}
