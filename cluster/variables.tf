variable "ssh_public_key" {
  description = "SSH public key to inject into LXC containers"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key for remote-exec provisioning"
  type        = string
  sensitive   = true
}
