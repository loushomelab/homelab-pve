output "vm_id" {
  description = "Proxmox VM ID for the private host"
  value       = module.private.vm_id
}

output "mac_address" {
  description = "Primary NIC MAC address for the private host"
  value       = module.private.mac_address
}
