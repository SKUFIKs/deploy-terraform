# Проверки плана без реального Proxmox и без секретов.
#
# mock_provider подменяет провайдер bpg/proxmox: Terraform не подключается
# к API, но строит план и проверяет выражения в конфигурации. Это позволяет
# ловить опечатки в переменных и случайные изменения параметров ВМ.
#
# Запуск (из каталога terraform/):
#   terraform init -backend=false
#   terraform test

mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_vm" {
    # Нужно для output'ов: в main.tf берётся ipv4_addresses[1][0].
    defaults = {
      ipv4_addresses = [["127.0.0.1"], ["192.168.10.210"]]
    }
  }

  mock_resource "proxmox_download_file" {
    # Провайдер проверяет формат file_id даже при mock-провайдере.
    # В main.tf этот id передаётся в диск шаблона.
    defaults = {
      id = "local:iso/debian-13-genericcloud-amd64.img"
    }
  }
}

variables {
  # Достаточно фиктивных значений: к API никто не ходит.
  proxmox_endpoint  = "https://pve.example.com:8006/"
  proxmox_api_token = "root@pam!test=00000000-0000-0000-0000-000000000000"
  proxmox_agent     = true

  private_key  = "tests/fixtures/test_private_key"
  node_name    = "pve"
  node_address = "192.168.1.100"
  node_port    = 22
  datastore_id = "local-lvm"

  vm_dns_list     = ["1.1.1.1", "8.8.8.8"]
  vm_user_account = "ubuntu"
  vm_user_key     = "tests/fixtures/vm_user_key.pub"

  vm_id_template    = "9000"
  default_cpu_cores = 2
  default_memory_mb = 2048
  disk_size_gb      = 5

  vm_id_1              = 101
  vm_id_1_name         = "test-web"
  tags_vm1             = ["test", "web"]
  vm_id_1_cpu          = 2
  vm_id_1_memory       = 2048
  vm_id_1_datastore_id = "local-lvm"
  vm_id_1_disksize     = 10
  vm_id_1_address      = "192.168.10.101/24"
  vm_id_1_gateway      = "192.168.10.1"

  vm_id_2              = 102
  vm_id_2_name         = "test-db"
  tags_vm2             = ["test", "db"]
  vm_id_2_cpu          = 4
  vm_id_2_memory       = 4096
  vm_id_2_floating     = 1024
  vm_id_2_datastore_id = "local-lvm"
  vm_id_2_disksize     = 20
  vm_id_2_address      = "192.168.10.102/24"
  vm_id_2_gateway      = "192.168.10.1"

  vm_id_3              = "103"
  vm_id_3_name         = "test-dev"
  tags_vm3             = ["test", "dev"]
  vm_id_3_cpu          = 2
  vm_id_3_memory       = 2048
  vm_id_3_floating     = 0
  vm_id_3_datastore_id = "local-lvm"
  vm_id_3_disksize     = 10
  vm_id_3_address      = "192.168.10.103/24"
  vm_id_3_gateway      = "192.168.10.1"

  vm_id_4              = 104
  vm_id_4_name         = "test-ru"
  tags_vm4             = ["test", "ru"]
  vm_id_4_cpu          = 2
  vm_id_4_memory       = 2048
  vm_id_4_floating     = 512
  vm_id_4_datastore_id = "local-lvm"
  vm_id_4_disksize     = 10
  vm_id_4_address      = "192.168.10.104/24"
  vm_id_4_gateway      = "192.168.10.1"

  vm_id_5              = 105
  vm_id_5_name         = "test-ai"
  tags_vm5             = ["test", "ai"]
  vm_id_5_cpu          = 4
  vm_id_5_memory       = 4096
  vm_id_5_floating     = 1024
  vm_id_5_datastore_id = "local-lvm"
  vm_id_5_disksize     = 20
  vm_id_5_address      = "192.168.10.105/24"
  vm_id_5_gateway      = "192.168.10.1"
}

run "template_uses_defaults" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.template == true
    error_message = "Шаблон должен создаваться с template = true."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.started == false
    error_message = "Шаблон не должен запускаться."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.cpu[0].cores == 2
    error_message = "У шаблона должно быть 2 ядра (default_cpu_cores)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.memory[0].dedicated == 2048
    error_message = "У шаблона должно быть 2048 МБ RAM (default_memory_mb)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.disk[0].size == 5
    error_message = "Размер диска шаблона должен совпадать с disk_size_gb."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_template.efi_disk[0].type == "4m"
    error_message = "У шаблона должен быть EFI-диск типа 4m."
  }
}

run "nginx_clone_keeps_settings" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.debian_clone.clone[0].full == false
    error_message = "nginx-нода должна быть linked clone (full = false)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_clone.vm_id == 101
    error_message = "У nginx-ноды должен быть vm_id_1."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_clone.memory[0].dedicated == 2048
    error_message = "У nginx-ноды должно быть 2048 МБ RAM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.debian_clone.initialization[0].ip_config[0].ipv4[0].address == "192.168.10.101/24"
    error_message = "У nginx-ноды должен быть адрес из vm_id_1_address."
  }

  assert {
    condition     = contains(proxmox_virtual_environment_vm.debian_clone.tags, "web")
    error_message = "У nginx-ноды должен быть тег web."
  }
}

run "whings_clone_keeps_settings" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.whings_server.clone[0].full == true
    error_message = "Хост whings должен быть полным клоном (full = true)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.whings_server.vm_id == 102
    error_message = "У хоста whings должен быть vm_id_2."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.whings_server.memory[0].dedicated == 4096
    error_message = "У хоста whings должно быть 4096 МБ RAM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.whings_server.memory[0].floating == 1024
    error_message = "У хоста whings должен быть ballooning 1024 МБ."
  }

  assert {
    condition     = contains(proxmox_virtual_environment_vm.whings_server.tags, "db")
    error_message = "У хоста whings должен быть тег db."
  }
}

run "dev_clone_keeps_settings" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.dev_server.clone[0].full == true
    error_message = "dev-сервер должен быть полным клоном (full = true)."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.dev_server.vm_id == 103
    error_message = "У dev-сервера должен быть vm_id_3."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.dev_server.initialization[0].ip_config[0].ipv4[0].address == "192.168.10.103/24"
    error_message = "У dev-сервера должен быть адрес из vm_id_3_address."
  }
}

run "outputs_are_exported" {
  command = apply

  assert {
    condition     = output.vm_ipv4_address == "192.168.10.210"
    error_message = "output.vm_ipv4_address должен брать адрес из ipv4_addresses."
  }

  assert {
    condition     = output.whings_ipv4_address == "192.168.10.210"
    error_message = "output.whings_ipv4_address должен брать адрес из ipv4_addresses."
  }

  assert {
    condition     = output.dev__ipv4_address == "192.168.10.210"
    error_message = "output.dev__ipv4_address должен брать адрес из ipv4_addresses."
  }
}
