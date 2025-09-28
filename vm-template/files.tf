locals {
  talos = {
    version = "v1.10.4"
  }
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = "venus"
  file_name               = "talos-${local.talos.version}-nocloud-amd64-cluster8.img"
  url                     = "https://factory.talos.dev/image/6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b/${local.talos.version}/nocloud-amd64.iso"
  overwrite               = false
}

