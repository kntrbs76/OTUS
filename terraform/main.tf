terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

resource "yandex_compute_disk" "boot-disk" {
  name     = "boot-disk"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd81fcau7ut6fv7uptar"
}

resource "yandex_compute_instance" "vm-1" {
  name        = "linux-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("cloud-init.yml")}"
  }
   provisioner "local-exec" {
    command     = "until nc -zv ${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} 22; do echo 'Waiting for SSH to be available...'; sleep 5; done"
    working_dir = path.module
  }
  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address},' -u kntrbs --private-key ~/.ssh/id_rsa ./ansible/playbooks/nginx_install.yaml"
    working_dir = path.module
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.network-1.id
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
