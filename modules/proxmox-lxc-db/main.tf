terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.61.0"
    }
  }
}

resource "proxmox_virtual_environment_container" "this" {
  node_name    = var.node_name
  vm_id        = var.vmid
  unprivileged = true

  initialization {
    hostname = var.name

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = "192.168.50.254"
      }
    }

    # Allow us to connect via SSH to provision
    user_account {
      keys = [var.ssh_public_key]
    }
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name        = "eth0"
    bridge      = "vmbr0"
    mac_address = var.mac_address
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  features {
    nesting = true
  }
}

# Add Proxmox HA Group resource to ensure HA for the database containers
resource "proxmox_virtual_environment_haresource" "db_ha" {
  depends_on = [proxmox_virtual_environment_container.this]

  resource_id = "ct:${var.vmid}"
  state       = "started"
}

# Provisioning using remote-exec (similar to the bootstrap agent LXC)
resource "null_resource" "deploy_db" {
  depends_on = [proxmox_virtual_environment_container.this]

  triggers = {
    container_id      = proxmox_virtual_environment_container.this.id
    postgres_password = var.postgres_password
    redis_password    = var.redis_password
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = split("/", var.ipv4_address)[0]
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "echo '=== 1. Wait for DNS and Network ==='",
      "for i in {1..30}; do if ping -c 1 debian.org &> /dev/null; then break; fi; echo 'Waiting for network...'; sleep 2; done",

      "echo '=== 2. Update and Install PostgreSQL & Redis ==='",
      "apt-get update",
      "apt-get install -y postgresql postgresql-contrib redis-server",

      "echo '=== 3. Configure PostgreSQL ==='",
      "sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/g\" /etc/postgresql/15/main/postgresql.conf",
      "echo 'host all all 192.168.50.0/23 md5' >> /etc/postgresql/15/main/pg_hba.conf",
      "sudo -u postgres psql -c \"ALTER USER postgres PASSWORD '${var.postgres_password}';\"",

      "echo '=== 4. Configure Redis (if password provided) ==='",
      "if [ -n \"${var.redis_password}\" ]; then",
      "  sed -i \"s/bind 127.0.0.1 -::1/bind 0.0.0.0/g\" /etc/redis/redis.conf",
      "  sed -i 's/# requirepass foobared/requirepass ${var.redis_password}/g' /etc/redis/redis.conf",
      "fi",

      "echo '=== 5. Restart Services ==='",
      "systemctl restart postgresql redis-server",
      "systemctl enable postgresql redis-server"
    ]
  }
}
