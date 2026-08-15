variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "node_name" {
  description = "The Proxmox node to deploy the VM on"
  type        = string
}

variable "vm_id" {
  description = "The ID of the virtual machine"
  type        = number
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Dedicated memory in MB"
  type        = number
  default     = 4096
}

variable "datastore_id" {
  description = "The Proxmox datastore ID for disks"
  type        = string
  default     = "SSD"
}

variable "iso_file_id" {
  description = "The file ID of the Talos ISO in Proxmox"
  type        = string
}

variable "mac_address" {
  description = "The static MAC address for the primary network interface"
  type        = string
}
