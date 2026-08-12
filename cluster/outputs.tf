output "talos_control_plane_ips" {
  description = "IPv4 addresses of Talos Control Plane nodes"
  value = {
    for name, node in module.talos_cp : name => try(node.ipv4_addresses[1][0], "IP not reported yet")
  }
}

output "talos_worker_ips" {
  description = "IPv4 addresses of Talos Worker nodes"
  value = {
    for name, node in module.talos_worker : name => try(node.ipv4_addresses[1][0], "IP not reported yet")
  }
}

output "talos_control_plane_macs" {
  description = "MAC addresses of Talos Control Plane nodes"
  value = {
    for name, node in module.talos_cp : name => node.mac_address
  }
}

output "talos_worker_macs" {
  description = "MAC addresses of Talos Worker nodes"
  value = {
    for name, node in module.talos_worker : name => node.mac_address
  }
}

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

