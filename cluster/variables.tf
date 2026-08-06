variable "HOMELAB_CICD_SSH_PRIVATE_KEY" {
  type        = string
  description = "SSH private key for CICD and provisioning"
  sensitive   = true
  default     = ""
}

variable "HOMELAB_CICD_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for CICD and provisioning"
  default     = ""
}

variable "PBS_HOST" {
  type        = string
  description = "IP address of the Proxmox Backup Server"
}

variable "PBS_DATASTORE" {
  type        = string
  description = "Datastore name on the Proxmox Backup Server"
}

variable "PBS_FINGERPRINT" {
  type        = string
  description = "Certificate fingerprint of the Proxmox Backup Server"
}

variable "PBS_TOKEN_ID" {
  type        = string
  description = "API Token ID for PBS in format 'user@realm!token'"
}

variable "PBS_TOKEN_SECRET" {
  type        = string
  description = "API Token Secret for PBS"
  sensitive   = true
}

variable "HOMELAB_EMAIL" {
  type        = string
  description = "Email address for notifications"
}
