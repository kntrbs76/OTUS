Домашнее задание
Реализация GFS2 хранилища на виртуалках под виртуалбокс

Цель:
развернуть в Yandex Cloud следующую конфигурацию с помощью terraform

1 виртуалка с iscsi
3 виртуальные машины с разделяемой файловой системой GFS2 поверх cLVM


Привести к рабочему виду файл variables.tf, внеся в него данные от своего аккаунта Yandex Cloud, а также изменить имя пользователя
Привести к необходимому виду файл cloud-init.yml, внеся в него ваш открытый ssh ключ, а также имя вашего пользователя
Добавить пользователя в файл ansible.cfg

terraform apply -auto-approve
------------------------------------------
terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.hosts_ini will be created
  + resource "local_file" "hosts_ini" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./ansible/hosts.ini"
      + id                   = (known after apply)
    }

  # null_resource.ansible-install-pcs-servers will be created
  + resource "null_resource" "ansible-install-pcs-servers" {
      + id       = (known after apply)
      + triggers = {
          + "always_run" = (known after apply)
        }
    }

  # yandex_compute_disk.iscsi-secondary-data-disk will be created
  + resource "yandex_compute_disk" "iscsi-secondary-data-disk" {
      + block_size  = 4096
      + created_at  = (known after apply)
      + folder_id   = (known after apply)
      + id          = (known after apply)
      + name        = "iscsi-secondary-data-disk-01"
      + product_ids = (known after apply)
      + size        = 1
      + status      = (known after apply)
      + type        = "network-hdd"
      + zone        = "ru-central1-b"

      + disk_placement_policy (known after apply)
    }

  # yandex_compute_instance.iscsi-servers[0] will be created
  + resource "yandex_compute_instance" "iscsi-servers" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "iscsi-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "user-data" = <<-EOT
                #cloud-config
                ssh_pwauth: no
                users:
                  - name: kntrbs
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    ssh-authorized-keys:
                      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru"
            EOT
        }
      + name                      = "iscsi-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8p7vi5c5bbs2s5i67s"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.1.204"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.2.204"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy (known after apply)

      + secondary_disk {
          + auto_delete = false
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = "READ_WRITE"
        }
    }

  # yandex_compute_instance.pcs-servers[0] will be created
  + resource "yandex_compute_instance" "pcs-servers" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "pcs-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "user-data" = <<-EOT
                #cloud-config
                ssh_pwauth: no
                users:
                  - name: kntrbs
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    ssh-authorized-keys:
                      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru"
            EOT
        }
      + name                      = "pcs-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8p7vi5c5bbs2s5i67s"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.1.201"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.2.201"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.3.201"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy (known after apply)
    }

  # yandex_compute_instance.pcs-servers[1] will be created
  + resource "yandex_compute_instance" "pcs-servers" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "pcs-2"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "user-data" = <<-EOT
                #cloud-config
                ssh_pwauth: no
                users:
                  - name: kntrbs
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    ssh-authorized-keys:
                      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru"
            EOT
        }
      + name                      = "pcs-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8p7vi5c5bbs2s5i67s"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.1.202"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.2.202"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.3.202"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy (known after apply)
    }

  # yandex_compute_instance.pcs-servers[2] will be created
  + resource "yandex_compute_instance" "pcs-servers" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "pcs-3"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "user-data" = <<-EOT
                #cloud-config
                ssh_pwauth: no
                users:
                  - name: kntrbs
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    ssh-authorized-keys:
                      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru"
            EOT
        }
      + name                      = "pcs-3"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8p7vi5c5bbs2s5i67s"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.1.203"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.2.203"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }
      + network_interface {
          + index              = (known after apply)
          + ip_address         = "10.180.3.203"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy (known after apply)
    }

  # yandex_vpc_network.ru-central1-a-servers-network-01 will be created
  + resource "yandex_vpc_network" "ru-central1-a-servers-network-01" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "pcs-servers-network-01"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.iscsi-servers-subnet-01 will be created
  + resource "yandex_vpc_subnet" "iscsi-servers-subnet-01" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "iscsi-servers-subnet-01"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.180.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.iscsi-servers-subnet-02 will be created
  + resource "yandex_vpc_subnet" "iscsi-servers-subnet-02" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "iscsi-servers-subnet-02"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.180.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.iscsi-servers-subnet-03 will be created
  + resource "yandex_vpc_subnet" "iscsi-servers-subnet-03" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "iscsi-servers-subnet-03"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.180.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.pcs-servers-subnet-01 will be created
  + resource "yandex_vpc_subnet" "pcs-servers-subnet-01" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "pcs-servers-subnet-01"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.160.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # yandex_vpc_subnet.pcs-servers-subnet-02 will be created
  + resource "yandex_vpc_subnet" "pcs-servers-subnet-02" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "pcs-servers-subnet-02"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.180.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_iscsi-servers = [
      + [
          + "iscsi-1",
        ],
      + [
          + (known after apply),
        ],
    ]
  + external_ip_address_pcs-servers   = [
      + [
          + "pcs-1",
          + "pcs-2",
          + "pcs-3",
        ],
      + [
          + (known after apply),
          + (known after apply),
          + (known after apply),
        ],
    ]
  + internal_ip_address_iscsi-servers = [
      + [
          + "iscsi-1",
        ],
      + [
          + (known after apply),
        ],
    ]
  + internal_ip_address_pcs-servers   = [
      + [
          + "pcs-1",
          + "pcs-2",
          + "pcs-3",
        ],
      + [
          + (known after apply),
          + (known after apply),
          + (known after apply),
        ],
    ]
yandex_vpc_network.ru-central1-a-servers-network-01: Creating...
yandex_compute_disk.iscsi-secondary-data-disk: Creating...
yandex_vpc_network.ru-central1-a-servers-network-01: Creation complete after 1s [id=enp4f45p79cc1oaotbij]
yandex_vpc_subnet.pcs-servers-subnet-02: Creating...
yandex_vpc_subnet.iscsi-servers-subnet-03: Creating...
yandex_vpc_subnet.iscsi-servers-subnet-01: Creating...
yandex_vpc_subnet.pcs-servers-subnet-01: Creating...
yandex_vpc_subnet.iscsi-servers-subnet-02: Creating...
yandex_vpc_subnet.iscsi-servers-subnet-03: Creation complete after 0s [id=e2l37bbg8u0hsrgkgg62]
yandex_vpc_subnet.iscsi-servers-subnet-02: Creation complete after 1s [id=e2le0hfs37mppl2bn4j6]
yandex_vpc_subnet.iscsi-servers-subnet-01: Creation complete after 1s [id=e2l5vjlj9jgtjc2gp0ej]
yandex_vpc_subnet.pcs-servers-subnet-01: Creation complete after 2s [id=e2lq2jvdfv888vucna48]
yandex_vpc_subnet.pcs-servers-subnet-02: Creation complete after 3s [id=e2l7lvkqcon1aul3c3es]
yandex_compute_disk.iscsi-secondary-data-disk: Creation complete after 8s [id=epdsr784ti4i2l028vi8]
yandex_compute_instance.iscsi-servers[0]: Creating...
yandex_compute_instance.iscsi-servers[0]: Still creating... [10s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [20s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [30s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [40s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [50s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [1m0s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [1m10s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [1m20s elapsed]
yandex_compute_instance.iscsi-servers[0]: Still creating... [1m30s elapsed]
yandex_compute_instance.iscsi-servers[0]: Creation complete after 1m34s [id=epd2vj9nndr84ift2rq7]
yandex_compute_instance.pcs-servers[0]: Creating...
yandex_compute_instance.pcs-servers[1]: Creating...
yandex_compute_instance.pcs-servers[2]: Creating...
yandex_compute_instance.pcs-servers[0]: Still creating... [10s elapsed]
yandex_compute_instance.pcs-servers[1]: Still creating... [10s elapsed]
yandex_compute_instance.pcs-servers[2]: Still creating... [10s elapsed]
yandex_compute_instance.pcs-servers[1]: Still creating... [20s elapsed]
yandex_compute_instance.pcs-servers[0]: Still creating... [20s elapsed]
yandex_compute_instance.pcs-servers[2]: Still creating... [20s elapsed]
yandex_compute_instance.pcs-servers[1]: Still creating... [30s elapsed]
yandex_compute_instance.pcs-servers[0]: Still creating... [30s elapsed]
yandex_compute_instance.pcs-servers[2]: Still creating... [30s elapsed]
yandex_compute_instance.pcs-servers[1]: Still creating... [40s elapsed]
yandex_compute_instance.pcs-servers[0]: Still creating... [40s elapsed]
yandex_compute_instance.pcs-servers[2]: Still creating... [40s elapsed]
yandex_compute_instance.pcs-servers[2]: Creation complete after 44s [id=epdilbou3vv0e5c8uest]
yandex_compute_instance.pcs-servers[1]: Creation complete after 45s [id=epdbqeshno3s1qji8s8e]
yandex_compute_instance.pcs-servers[0]: Creation complete after 48s [id=epdgl8s57ej96ksuvhde]
null_resource.ansible-install-pcs-servers: Creating...
null_resource.ansible-install-pcs-servers: Provisioning with 'local-exec'...
null_resource.ansible-install-pcs-servers (local-exec): Executing: ["/bin/sh" "-c" "sleep 20 && ansible-playbook -D -i 89.169.163.148\",\"89.169.170.44\",\"84.201.140.123\",\"89.169.168.167, -u kntrbs ./ansible/accessebility.yml"]
local_file.hosts_ini: Creating...
local_file.hosts_ini: Creation complete after 0s [id=40bfe33511e37976707c40a80cf65d6b906dbf33]
null_resource.ansible-install-pcs-servers: Still creating... [10s elapsed]
null_resource.ansible-install-pcs-servers: Still creating... [20s elapsed]

null_resource.ansible-install-pcs-servers (local-exec): PLAY [all] *********************************************************************

null_resource.ansible-install-pcs-servers (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.168.167]
null_resource.ansible-install-pcs-servers (local-exec): ok: [84.201.140.123]
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.170.44]
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.163.148]

null_resource.ansible-install-pcs-servers (local-exec): TASK [Check SSL connection] ****************************************************
null_resource.ansible-install-pcs-servers (local-exec): changed: [89.169.168.167 -> localhost]
null_resource.ansible-install-pcs-servers (local-exec): changed: [84.201.140.123 -> localhost]
null_resource.ansible-install-pcs-servers (local-exec): changed: [89.169.163.148 -> localhost]
null_resource.ansible-install-pcs-servers (local-exec): changed: [89.169.170.44 -> localhost]

null_resource.ansible-install-pcs-servers (local-exec): RUNNING HANDLER [Print message] ************************************************
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.168.167] => {
null_resource.ansible-install-pcs-servers (local-exec):     "msg": "You can run Ansible Playbook"
null_resource.ansible-install-pcs-servers (local-exec): }
null_resource.ansible-install-pcs-servers (local-exec): ok: [84.201.140.123] => {
null_resource.ansible-install-pcs-servers (local-exec):     "msg": "You can run Ansible Playbook"
null_resource.ansible-install-pcs-servers (local-exec): }
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.163.148] => {
null_resource.ansible-install-pcs-servers (local-exec):     "msg": "You can run Ansible Playbook"
null_resource.ansible-install-pcs-servers (local-exec): }
null_resource.ansible-install-pcs-servers (local-exec): ok: [89.169.170.44] => {
null_resource.ansible-install-pcs-servers (local-exec):     "msg": "You can run Ansible Playbook"
null_resource.ansible-install-pcs-servers (local-exec): }

null_resource.ansible-install-pcs-servers (local-exec): PLAY RECAP *********************************************************************
null_resource.ansible-install-pcs-servers (local-exec): 84.201.140.123             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.ansible-install-pcs-servers (local-exec): 89.169.163.148             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.ansible-install-pcs-servers (local-exec): 89.169.168.167             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.ansible-install-pcs-servers (local-exec): 89.169.170.44              : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

null_resource.ansible-install-pcs-servers: Creation complete after 26s [id=7995493719645921974]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_iscsi-servers = [
  [
    "iscsi-1",
  ],
  [
    "89.169.168.167",
  ],
]
external_ip_address_pcs-servers = [
  [
    "pcs-1",
    "pcs-2",
    "pcs-3",
  ],
  [
    "89.169.163.148",
    "89.169.170.44",
    "84.201.140.123",
  ],
]
internal_ip_address_iscsi-servers = [
  [
    "iscsi-1",
  ],
  [
    "10.180.0.6",
  ],
]
internal_ip_address_pcs-servers = [
  [
    "pcs-1",
    "pcs-2",
    "pcs-3",
  ],
  [
    "10.160.0.33",
    "10.160.0.22",
    "10.160.0.35",
  ],
]
-------------------------------------------------------------------------
![07.png](screens/07.png)
Переходим в папку ansible  и запускаем плейбук
ansible-playbook main.yml -e ntp_timezone=Europe/Moscow -e "newpassword=qwerty12345"
------------------------------------------------------------------------
После успешной настройки можно увидить состояние кластера:
![01.png](screens/01.png)
![02.png](screens/02.png)
Здесь мы видим что успешно примонтирована файловая система GFS2:
![03.png](screens/03.png)
Далее мы можем посмотреть что у нас есть связь с ISCSI хостом, на котором располагается хранилище:
![04.png](screens/04.png)
Можем увидеть структуру наших блочных устройств:
![06.png](screens/06.png)
