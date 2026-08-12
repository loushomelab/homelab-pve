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
