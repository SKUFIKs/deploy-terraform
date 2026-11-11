
variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  type        = string
  description = "API Token"
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  description = "Check SSL"
  default     = false
}

variable "proxmox_agent" {
  type    = bool
  default = false
}

variable "proxmox_user" {
  type    = string
  default = "root"
}

variable "private_key" {
  type = string
}

variable "vm_id_template" {
  type = string
}

variable "node_name" {
  type = string
}

variable "node_address" {
  type    = string
  default = "localhost"
}

variable "node_port" {
  type    = number
  default = 22
}

variable "datastore_id" {
  type        = string
  description = "ID storage"
}

variable "interface" {
  type    = string
  default = "virtio0"
}

variable "iso_datastore_id" {
  type        = string
  description = "ISO/Cloud images"
  default     = "local"
}

variable "default_cpu_cores" {
  type    = number
  default = 2
}

variable "default_memory_mb" {
  type        = number
  description = "RAM in mb"
  default     = 2048
}

variable "disk_size_gb" {
  type    = number
  default = 3
}

variable "default_address" {
  type    = string
  default = "dhcp"
}

variable "default_network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "vm_dns_list" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}

variable "vm_id_1" {
  type = number
}

variable "tags_vm1" {
  type    = list(string)
  default = []
}

variable "vm_id_1_name" {
  type = string
}

variable "vm_id_1_cpu" {
  type = number
}

variable "vm_id_1_memory" {
  type = number
}

variable "vm_id_1_datastore_id" {
  type = string
}

variable "vm_id_1_disksize" {
  type = number
}

variable "vm_id_1_address" {
  type = string
}

variable "vm_id_1_gateway" {
  type = string
}

variable "vm_user_account" {
  type = string
}

variable "vm_user_key" {
  type = string
}

variable "tags_vm2" {
  type = list(string)
}


variable "vm_id_2" {
  type = number
}

variable "vm_id_2_name" {
  type = string
}

variable "vm_id_2_cpu" {
  type = number
}

variable "vm_id_2_memory" {
  type = number
}

variable "vm_id_2_floating" {
  type = number
}


variable "vm_id_2_datastore_id" {
  type = string
}

variable "vm_id_2_disksize" {
  type = number
}

variable "vm_id_2_address" {
  type = string
}

variable "vm_id_2_gateway" {
  type = string
}

variable "vm_id_3" {
  type = string
}

variable "tags_vm3" {
  type = list(string)
}

variable "vm_id_3_name" {
  type = string
}

variable "vm_id_3_cpu" {
  type = number
}

variable "vm_id_3_memory" {
  type = number
}

variable "vm_id_3_floating" {
  type = number
}


variable "vm_id_3_datastore_id" {
  type = string
}

variable "vm_id_3_disksize" {
  type = number
}

variable "vm_id_3_address" {
  type = string
}

variable "vm_id_3_gateway" {
  type = string
}

variable "vm_id_4" {
  type = number
}

variable "tags_vm4" {
  type = list(string)
}

variable "vm_id_4_name" {
  type = string
}

variable "vm_id_4_cpu" {
  type = number
}

variable "vm_id_4_memory" {
  type = number
}

variable "vm_id_4_floating" {
  type = number
}

variable "vm_id_4_datastore_id" {
  type = string
}

variable "vm_id_4_disksize" {
  type = number
}

variable "vm_id_4_address" {
  type = string
}

variable "vm_id_4_gateway" {
  type = string
}

variable "vm_id_5" {
  type = number
}

variable "tags_vm5" {
  type = list(string)
}

variable "vm_id_5_name" {
  type = string
}

variable "vm_id_5_cpu" {
  type = number
}

variable "vm_id_5_memory" {
  type = number
}

variable "vm_id_5_floating" {
  type = number
}

variable "vm_id_5_datastore_id" {
  type = string
}

variable "vm_id_5_disksize" {
  type = number
}

variable "vm_id_5_address" {
  type = string
}

variable "vm_id_5_gateway" {
  type = string
}
