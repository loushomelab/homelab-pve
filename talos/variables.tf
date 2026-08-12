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
