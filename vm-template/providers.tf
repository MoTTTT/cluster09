terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.4.50:8006/"
  username = "root@pam"
  password = "XX"
  insecure = true
  tmp_dir  = "/var/tmp"
  ssh {
    agent = true
  }
}

