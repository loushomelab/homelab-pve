variable "name" {
  description = "The name of the LXC container"
  type        = string
}

variable "node_name" {
  description = "The Proxmox node to deploy the container on"
  type        = string
}

variable "vmid" {
  description = "The ID of the virtual machine"
  type        = number
}

variable "ipv4_address" {
  description = "The static IPv4 address (e.g., 192.168.50.151/23)"
  type        = string
}

variable "mac_address" {
  description = "The static MAC address for the primary network interface"
  type        = string
}

variable "datastore_id" {
  description = "The Proxmox datastore ID for disks"
  type        = string
  default     = "SSD"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "template_file_id" {
  description = "The file ID of the LXC template in Proxmox"
  type        = string
}

variable "postgres_password" {
  description = "Root password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Password for Redis (leave empty to skip Redis external access configuration)"
  type        = string
  default     = ""
  sensitive   = true
}
