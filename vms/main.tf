locals {
  talos_version = "v1.13.7"
  schematic_id  = "6ebbfe35c8225645c05d4d19eaad385bd1ec795954932d0ada671388272fec19"
  talos_iso_url = "https://factory.talos.dev/image/${local.schematic_id}/${local.talos_version}/nocloud-amd64.iso"

  target_nodes = ["r720", "1920x", "3960x"]
}

# 1. 在所有目标节点的 local 存储上下载 Talos ISO
resource "proxmox_download_file" "talos_iso" {
  for_each     = toset(local.target_nodes)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  url       = local.talos_iso_url
  file_name = "talos-${local.talos_version}-nocloud-qga-amd64.iso"
  overwrite = false
}

# 2. 部署 Control Plane 节点 (3台)
module "talos_cp" {
  source = "../modules/proxmox-vm"

  for_each = {
    "cp-01" = { node = "r720", id = 110, mac = "BC:24:11:00:00:01" }
    "cp-02" = { node = "1920x", id = 112, mac = "BC:24:11:00:00:02" }
    "cp-03" = { node = "3960x", id = 114, mac = "BC:24:11:00:00:03" }
  }

  name         = "talos-${each.key}"
  node_name    = each.value.node
  vm_id        = each.value.id
  mac_address  = each.value.mac
  datastore_id = "SSD"
  cores        = 4
  memory       = 4096
  iso_file_id  = proxmox_download_file.talos_iso[each.value.node].id
}

# 3. 部署 Worker 节点 (3台)
module "talos_worker" {
  source = "../modules/proxmox-vm"

  for_each = {
    "worker-01" = { node = "r720", id = 111, mac = "BC:24:11:00:01:01" }
    "worker-02" = { node = "1920x", id = 113, mac = "BC:24:11:00:01:02" }
    "worker-03" = { node = "3960x", id = 115, mac = "BC:24:11:00:01:03" }
  }

  name         = "talos-${each.key}"
  node_name    = each.value.node
  vm_id        = each.value.id
  mac_address  = each.value.mac
  datastore_id = "SSD"
  disk_size    = 100
  cores        = 8
  memory       = 16384
  iso_file_id  = proxmox_download_file.talos_iso[each.value.node].id
}
