#variable "folder_id" {
#  type = string
#}

variable "vpc_name" {
  type = string
  description = "VPC name"
}

variable "zone" {
  type = string
  default = "ru-central1-b"
  description = "zone"
}

variable "network_interface" {
  description = "Additional network interface to attach to the instance"
  type        = map(map(string))
  default     = {}
}

#variable "subnet_name" {
#  type = string
#  description = "subnet name"
#}

#variable "subnet_id" {
#  type = string
#  description = "subnet id"
#}

#variable "subnet_cidrs" {
#  type = list(string)
#  description = "CIDRs"
#}
/*
variable "subnet_cidrs" {}
*/
## VM parameters
variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "cpu" {
  description = "VM CPU count"
  default     = 2
  type        = number
}

variable "memory" {
  description = "VM RAM size"
  default     = 4
  type        = number
}

variable "core_fraction" {
  description = "Core fraction, default 100%"
  default     = 100
  type        = number
}

variable "disk" {
  description = "VM Disk size"
  default     = 10
  type        = number
}

variable "disk_type" {
  description = "Disk type"
  type        = string
  default     = "network-ssd"
}
variable "secondary_disk" {
  description = "Additional secondary disk to attach to the instance"
  type        = map(map(string))
  default     = {}
}
variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance in order to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail."
  type        = bool
  default     = true
}

# yc compute image list --folder-id standard-images
variable "image_id" {
  description = "Default image ID AlmaLinux 9"
  default     = "fd86hnivlvsk0gth3p4l" # almalinux-9-v20240923
  type        = string
}

variable "nat" {
  type    = bool
  default = true
}

variable "platform_id" {
  type    = string
  default = "standard-v3"
}

variable "internal_ip_address" {
  type    = string
  default = null
}

variable "nat_ip_address" {
  type    = string
  default = null
}

variable "vm_user" {
  type        = string
  description = "vm user"
  default = ""
}

variable "ssh_public_key" {
  type        = string
  description = "cloud-config ssh public key"
  default = ""
}

variable "ssh_private_key" {
  type        = string
  description = "cloud-config ssh private key"
  default = ""
}

variable "user-data" {
  type        = string
  description = "user data"
  default = ""
}
