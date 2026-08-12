# tflint-ignore: terraform_unused_declarations
variable "HOMELAB_CICD_SSH_PRIVATE_KEY" {
  type        = string
  description = "SSH private key for CICD and provisioning"
  sensitive   = true
  default     = ""
}

# tflint-ignore: terraform_unused_declarations
variable "HOMELAB_CICD_SSH_PUBLIC_KEY" {
  type        = string
  description = "SSH public key for CICD and provisioning"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "Talos Cluster Name"
  default     = "homelab-talos"
}

variable "cluster_endpoint" {
  type        = string
  description = "Talos Cluster Endpoint"
  default     = "https://192.168.50.110:6443"
}
