terraform {

  # 1.7+ нужен для terraform test с mock_provider (см. tests/).
  required_version = ">= 1.7.0"

  backend "local" {
    path = "/home/skuf/terraform-state/terraform.tfstate"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.118.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ssh {
    agent       = var.proxmox_agent
    username    = var.proxmox_user
    private_key = file(pathexpand(var.private_key))
    node {
      name    = var.node_name
      address = var.node_address
      port    = var.node_port
    }
  }

}

resource "proxmox_download_file" "debian_cloud_image" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.node_name

  url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"

  file_name = "debian-13-genericcloud-amd64.img"
}

resource "proxmox_virtual_environment_vm" "debian_template" {
  vm_id     = var.vm_id_template
  name      = "debian-13-genericcloud"
  node_name = var.node_name

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = var.default_cpu_cores
  }

  memory {
    dedicated = var.default_memory_mb
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_download_file.debian_cloud_image.id
    interface    = var.interface
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.default_address
      }
    }
  }

  network_device {
    bridge = var.default_network_bridge
  }

}

resource "proxmox_virtual_environment_vm" "debian_clone" {

  vm_id     = var.vm_id_1
  name      = var.vm_id_1_name
  node_name = var.node_name
  tags      = var.tags_vm1
  clone {
    vm_id = var.vm_id_template
    full  = false
  }

  agent {
    enabled = var.proxmox_agent
    timeout = "2m"
  }

  cpu {
    cores = var.vm_id_1_cpu
  }


  memory {
    dedicated = var.vm_id_1_memory
  }

  disk {
    datastore_id = var.vm_id_1_datastore_id
    interface    = var.interface
    size         = var.vm_id_1_disksize
  }


  initialization {
    dns {
      servers = var.vm_dns_list
    }
    ip_config {
      ipv4 {
        address = var.vm_id_1_address
        gateway = var.vm_id_1_gateway
      }
    }

    vendor_data_file_id = "local:snippets/install-qemu.yaml"

    user_account {
      username = var.vm_user_account
      keys     = [trimspace(file(pathexpand(var.vm_user_key)))]
    }
  }
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.debian_clone.ipv4_addresses[1][0]
}



resource "proxmox_virtual_environment_vm" "whings_server" {

  vm_id = var.vm_id_2

  name      = var.vm_id_2_name
  node_name = var.node_name
  tags      = var.tags_vm2

  clone {
    vm_id = var.vm_id_template
    full  = true
  }

  agent {
    enabled = var.proxmox_agent
    timeout = "2m"
  }

  cpu {
    cores = var.vm_id_2_cpu
  }

  memory {
    dedicated = var.vm_id_2_memory
    floating  = var.vm_id_2_floating
  }

  disk {
    datastore_id = var.vm_id_2_datastore_id
    interface    = var.interface
    size         = var.vm_id_2_disksize
  }


  initialization {
    dns {
      servers = var.vm_dns_list
    }
    ip_config {
      ipv4 {
        address = var.vm_id_2_address
        gateway = var.vm_id_2_gateway
      }
    }

    vendor_data_file_id = "local:snippets/install-qemu.yaml"

    user_account {
      username = var.vm_user_account
      keys     = [trimspace(file(pathexpand(var.vm_user_key)))]
    }
  }
}


output "whings_ipv4_address" {
  value = try(proxmox_virtual_environment_vm.whings_server.ipv4_addresses[1][0], "IP не получен")
}


resource "proxmox_virtual_environment_vm" "dev_server" {

  vm_id = var.vm_id_3

  name      = var.vm_id_3_name
  node_name = var.node_name
  tags      = var.tags_vm3

  clone {
    vm_id = var.vm_id_template
    full  = true
  }

  agent {
    enabled = var.proxmox_agent
    timeout = "2m"
  }

  cpu {
    cores = var.vm_id_3_cpu
  }

  memory {
    dedicated = var.vm_id_3_memory
    floating  = var.vm_id_3_floating
  }

  disk {
    datastore_id = var.vm_id_3_datastore_id
    interface    = var.interface
    size         = var.vm_id_3_disksize
  }


  initialization {
    dns {
      servers = var.vm_dns_list
    }
    ip_config {
      ipv4 {
        address = var.vm_id_3_address
        gateway = var.vm_id_3_gateway
      }
    }

    vendor_data_file_id = "local:snippets/install-qemu.yaml"

    user_account {
      username = var.vm_user_account
      keys     = [trimspace(file(pathexpand(var.vm_user_key)))]
    }
  }
}


output "dev__ipv4_address" {
  value = try(proxmox_virtual_environment_vm.dev_server.ipv4_addresses[1][0])
}
