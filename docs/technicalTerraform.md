# Proxmox Talos Provider Evaluation: Terraform  

## Tallos Terraform provider

### Provider

- Terraform provider: <https://registry.terraform.io/providers/siderolabs/talos/latest/docs>
- Tallos Boostrap: <https://github.com/siderolabs/terraform-provider-talos/blob/main/docs/resources/machine_bootstrap.md>

### Evaluation

- Chosen approach: <https://github.com/rgl/terraform-proxmox-talos/tree/main>
- Docs: <https://developer.hashicorp.com/terraform/tutorials>
- Using terraform with proxmox: <https://austinsnerdythings.com/2021/09/01/how-to-deploy-vms-in-proxmox-with-terraform/>
- Using terraform with proxmox: <https://tcude.net/using-terraform-with-proxmox/>
- Proxmox Provider: <https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/clone-vm>
- Proxmox Provider: <https://registry.terraform.io/providers/Telmate/proxmox/latest/docs>
- Tallos Provider: <https://github.com/siderolabs/terraform-provider-talos/blob/main/docs/index.md>

BGP provider:

```yaml
provider "proxmox" {
  endpoint = "https://10.0.0.2:8006/"

  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_USERNAME environment variable
  username = "root@pam"
  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_PASSWORD environment variable
  password = "the-password-set-during-installation-of-proxmox-ve"

  # because self-signed TLS certificate is in use
  insecure = true
  # uncomment (unless on Windows...)
  # tmp_dir  = "/var/tmp"

  ssh {
    agent = true
    # TODO: uncomment and configure if using api_token instead of password
    # username = "root"
  }
}
```

- VM Template:

```yaml
resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-template"
  node_name = "pve"
  template = true
  started  = false
  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"
  cpu {
    cores = 2
  }
  memory {
    dedicated = 2048
  }
  efi_disk {
    datastore_id = "local"
    type         = "4m"
  }
  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}
```

Clone MV from template:

```yaml
resource "proxmox_virtual_environment_vm" "ubuntu_clone" {
  name      = "ubuntu-clone"
  node_name = "pve"
  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }
  agent {
    enabled = true
  }
  memory {
    dedicated = 768
  }
  initialization {
    dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.ubuntu_clone.ipv4_addresses[1][0]
}
```

## Provisioning References

- <https://github.com/christensenjairus/ClusterCreator>
- <https://cyber-engine.com/blog/2024/06/25/k8s-on-proxmox-using-clustercreator/>
- <https://github.com/DushanthaS/kubernetes-the-hard-way-on-proxmox>
- <https://github.com/siderolabs/image-factory>
- <https://blog.stonegarden.dev/articles/2024/08/talos-proxmox-tofu/>
- <https://github.com/rgl/terraform-proxmox-talos>
- <https://olav.ninja/talos-cluster-on-proxmox-with-terraform>
- <https://github.com/kubernetes-sigs/kubespray>
- <https://kubespray.io/>
- <https://blog.andreasm.io/2024/01/15/proxmox-with-opentofu-kubespray-and-kubernetes/>
- <https://medium.com/@abhigyan.dwivedi_58961/creating-a-kvm-kubernetes-cluster-with-vagrant-kubespray-and-ansible-a-idiot-resistant-guide-2f3727ce7039>
