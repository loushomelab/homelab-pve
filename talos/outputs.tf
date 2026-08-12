output "talosconfig" {
  description = "Talos client configuration (talosconfig)"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes client configuration (kubeconfig)"
  value       = resource.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}
