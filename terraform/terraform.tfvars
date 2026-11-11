# proxmox agent
proxmox_agent = true

#default settings template
vm_id_template         = 102
default_cpu_cores      = 2
default_memory_mb      = 2048
disk_size_gb           = 3
interface              = "virtio0"
default_address        = "dhcp"
default_network_bridge = "vmbr0"

#vm settings 1
vm_id_1              = 103
vm_id_1_name         = "nginx-node"
tags_vm1             = ["Web", "Proxy"]
vm_id_1_cpu          = 1
vm_id_1_memory       = 1024
vm_id_1_datastore_id = "local-lvm"
vm_id_1_disksize     = 5
vm_id_1_address      = "192.168.10.210/24"
vm_id_1_gateway      = "192.168.10.1"

#vm settings 2
vm_id_2              = 101
vm_id_2_name         = "nwhings-node-2"
tags_vm2             = ["Pterodactyl", "Whings"]
vm_id_2_cpu          = 6
vm_id_2_memory       = 16384
vm_id_2_floating     = 5120
vm_id_2_datastore_id = "local-lvm2"
vm_id_2_disksize     = 60
vm_id_2_address      = "192.168.10.220/24"
vm_id_2_gateway      = "192.168.10.1"

#vm settings 3
vm_id_3              = 200
vm_id_3_name         = "dev-server"
tags_vm3             = ["dev"]
vm_id_3_cpu          = 4
vm_id_3_memory       = 4096
vm_id_3_floating     = 1024
vm_id_3_datastore_id = "local-lvm"
vm_id_3_disksize     = 15
vm_id_3_address      = "192.168.10.100/24"
vm_id_3_gateway      = "192.168.10.1"

#vm settings 4
vm_id_4              = 202
vm_id_4_name         = "ru-server"
tags_vm4             = ["ru"]
vm_id_4_cpu          = 2
vm_id_4_memory       = 2048
vm_id_4_floating     = 1024
vm_id_4_datastore_id = "local-lvm"
vm_id_4_disksize     = 15
vm_id_4_address      = "192.168.10.102/24"
vm_id_4_gateway      = "192.168.10.1"

#vm settings 5
vm_id_5              = 201
vm_id_5_name         = "llama-server"
tags_vm5             = ["ai", "llama"]
vm_id_5_cpu          = 4
vm_id_5_memory       = 4096
vm_id_5_floating     = 1024
vm_id_5_datastore_id = "local-lvm"
vm_id_5_disksize     = 30
vm_id_5_address      = "192.168.10.103/24"
vm_id_5_gateway      = "192.168.10.1"