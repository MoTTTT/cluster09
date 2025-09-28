resource "proxmox_virtual_environment_vm" "talos-template" {
  name        = "talos-template"
  description = "Talos Cluster API Template"
  tags        = ["terraform","talos","template","clusterapi"]
  node_name   = "venus"
  on_boot     = false
  cpu {
    cores = 2
    type = "x86-64-v2-AES"
  }
  memory {
    dedicated = 10000
  }
  agent {
    enabled = true
  }
  network_device {
    bridge = "vmbr0"
  }
  disk {
    datastore_id = "pool1"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 40
  }
  operating_system {
    type = "l26"
  }
  initialization {
    datastore_id = "pool1"
    ip_config {
      ipv4 {
        address = "192.168.4.101/24"
        gateway = "192.168.4.1"
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}
