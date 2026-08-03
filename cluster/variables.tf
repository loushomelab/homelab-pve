variable "HOMELAB_CICD_SSH_PUBLIC_KEY" {
  description = "SSH public key to inject into LXC containers"
  type        = string
}

variable "HOMELAB_CICD_SSH_PRIVATE_KEY" {
  description = "SSH private key for remote-exec provisioning"
  type        = string
  sensitive   = true
}
