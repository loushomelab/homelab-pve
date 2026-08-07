resource "proxmox_storage_nfs" "pbstorage" {
  id      = "pbstorage"
  server  = "192.168.50.76"
  export  = "/mnt/tank/pbstorage"
  content = ["iso", "backup", "rootdir", "images", "vztmpl", "snippets"]
}
