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
