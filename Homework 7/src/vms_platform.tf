# web
variable "vm_web_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "image"
}

#variable "vm_web_user" {
#  type        = string
#  default     = "ubuntu"
#  description = "user"
#}

variable "vm_web_name" {
  type        = string
  description = "Name"
  default     = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  description = "platform ID"
  default     = "standard-v3"
}

#variable "vm_web_cores" {
#  type        = number
#  description = "CPU"
#  default     = 2
#}

#variable "vm_web_memory" {
#  type        = number
#  description = "RAM"
#  default     = 1
#}

#variable "vm_web_core_fraction" {
#  type        = number
#  description = "CPU%"
#  default     = 20
#}
variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "nat"
}
variable "vm_db_name" {
  type        = string
  description = "Name"
  default     = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type        = string
  description = "platform ID"
  default     = "standard-v3"
}

#variable "vm_db_cores" {
#  type        = number
# description = "CPU"
#  default     = 2
#}

#variable "vm_db_memory" {
#  type        = number
#  description = "RAM"
#  default     = 2
#}

#variable "vm_db_core_fraction" {
#  type        = number
#  description = "CPU%"
#  default     = 20
#S}
variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "preemptible"
}

variable "vm_db_nat" {
  type        = bool
  default     = true
  description = "nat"
}
variable "vms_resources" {
  description = "единая map-переменная"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
        cores        = 2
        memory       = 1
        core_fraction = 20
    },
    db = {
        cores        = 2
        memory       = 2
        core_fraction = 20
    }
  }
}


variable "metadata" {
  type = map(string)
  description = "Metadata"
}

variable "test" {
  type = list(map(list(string)))
}
