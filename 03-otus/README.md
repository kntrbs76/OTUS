## lab-02
otus | nginx - setting up web application balancing

### Домашнее задание
Настраиваем балансировку веб-приложения

#### Цель:
научиться использовать Nginx в качестве балансировщика
В результате получаем рабочий пример Nginx в качестве балансировщика, и базовую отказоустойчивость бекенда.

- развернуть 4 виртуалки терраформом в яндекс облаке
- 1 виртуалка - Nginx - с публичным IP адресом
- 2 виртуалки - бэкенд на выбор студента (любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java) + nginx со статикой
- 1 виртуалкой с БД на выбор mysql/mongodb/postgres/redis.
- репозиторий в github: README, схема, манифесты терраформ и ансибл
- стенд должен разворачиваться с помощью terraform и ansible
- при отказе (выключение) виртуалки с бекендом система должна продолжать работать

#### Описание/Пошаговая инструкция выполнения домашнего задания:
В работе должны применяться:
- terraform
- ansible
- nginx;
- uwsgi/unicorn/php-fpm;
- некластеризованная бд mysql/mongodb/postgres/redis.-

### Выполнение домашнего задания

#### Создание стенда

Получаем OAUTH токен:
```
https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
```
Настраиваем аутентификации в консоли:
```
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_yc_token=$YC_TOKEN
```

Сервер loadbalancer-1 будет служить балансировщиком для распределения пакетов между серверами backend-1 и backend-2. 
Для балансировки на сервере loadbalancer-1 будет использоватья приложение Nginx. 
Балансировку настроим в режиме Robin Round, с максимальном количеством ошибок - 2, и timeout - 10 секунд:
```
upstream backend {
        server {{ ip_address['backend-1'] }}:80 max_fails=2 fail_timeout=10s;
        server {{ ip_address['backend-2'] }}:80 max_fails=2 fail_timeout=10s;
}
```
Для проверки работы балансировщика loadbalancer-1 воспользуемся отображением в браузере веб-страниц, размещённых на серверах backend-1 и backend-2, где установлены php-fpm. 
Для хранения баз данных будет использоваться сервер database-1, но котором установлено приложение Percona server для MySQL.

На всех серверах будут использоваться ОС Debian 11.

Чтобы развернуть данную инфраструктуры запустим следующую команду:
```
terraform apply -auto-approve 
------------------------------------------------
(base) kntrbs@kntrbs-ThinkPad-T490:~/my_proj/OTUS/03-otus$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.group_vars_all_file will be created
  + resource "local_file" "group_vars_all_file" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./group_vars/all/main.yml"
      + id                   = (known after apply)
    }

  # local_file.inventory_file will be created
  + resource "local_file" "inventory_file" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./inventory.ini"
      + id                   = (known after apply)
    }

  # yandex_vpc_network.vpc will be created
  + resource "yandex_vpc_network" "vpc" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "my_vpc_network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet will be created
  + resource "yandex_vpc_subnet" "subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "my_vpc_subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.10.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # module.backends[0].yandex_compute_instance.instances will be created
  + resource "yandex_compute_instance" "instances" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "backend-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru
            EOT
        }
      + name                      = "backend-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83u9thmahrv9lgedrk"
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

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy (known after apply)
    }

  # module.backends[1].yandex_compute_instance.instances will be created
  + resource "yandex_compute_instance" "instances" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "backend-2"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru
            EOT
        }
      + name                      = "backend-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83u9thmahrv9lgedrk"
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

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy (known after apply)
    }

  # module.databases[0].yandex_compute_instance.instances will be created
  + resource "yandex_compute_instance" "instances" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "database-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru
            EOT
        }
      + name                      = "database-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83u9thmahrv9lgedrk"
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

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy (known after apply)
    }

  # module.loadbalancers[0].yandex_compute_instance.instances will be created
  + resource "yandex_compute_instance" "instances" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "loadbalancer-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                debian:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDp9D/mW8jUYiG7eFHjESAdX+R6Oc5R6ls6t0JV67w9Oj3tiBXYPMN7NE/eJ/pK6kmXd0ofNsbu4BaBqcm8XW0dhVb6KdbtWzzvFvR/jQSa6BlBOWs2cKpm370PApa7hB/U6urRBYmCvl5nny1ItQyypK+r2xwPWZgNn5un0LrkSGIM2yqnZPczWazCKUwA56og8YePnfuJmLZR5jt44lpvjHEMiXp+Jh8L7/Hh7uOhR/U8sKfCyA8oOQ8c7vsCRD6L9OEvZ12oKRBa2WyeJBlVfckSHwHlEr/NzqT5a9lQA18SKfHdgfclDoQHRA9KbAUP+axi+iJ4tZYjTbCGu3+3w5vY5PzS2N10KKzyBq6EeNH53kCudttp3XS77jQJTC6q396xL8HJh4ss3CKKIkBX0O3wSo2mk6RccyDz9pDeS9LHm4PlEWBPV3cnNk3n/uwZFuQampCvEdVie9qynkN+UScyCmJjNynP/tNQZUDv+XJxwXHkh9FpxHd24H2gEao0iqtmf5mje7kasIYKz4SOcPjsXQPIeciJoORRcUiRs9kUJGkQi8Gx8DGFOd26LRwouFkRWVTGGSbCgW+7Ou51k0epBBG9E6ywPmWyioidcNwwAaE/d71V5wei5bCQerqtCSMgcnMf6zPqPL+Y9J7pYqMjnYZ4y5ClyxqtpCQHRw== kntrbs@yandex.ru
            EOT
        }
      + name                      = "loadbalancer-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-b"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd83u9thmahrv9lgedrk"
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

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 4
        }

      + scheduling_policy (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + backends_info      = [
      + {
          + ip_address     = (known after apply)
          + name           = "backend-1"
          + nat_ip_address = (known after apply)
        },
      + {
          + ip_address     = (known after apply)
          + name           = "backend-2"
          + nat_ip_address = (known after apply)
        },
    ]
  + databases_info     = [
      + {
          + ip_address     = (known after apply)
          + name           = "database-1"
          + nat_ip_address = (known after apply)
        },
    ]
  + loadbalancers_info = [
      + {
          + ip_address     = (known after apply)
          + name           = "loadbalancer-1"
          + nat_ip_address = (known after apply)
        },
    ]
yandex_vpc_network.vpc: Creating...
yandex_vpc_network.vpc: Creation complete after 3s [id=enpqlfhgqduohi7ba021]
yandex_vpc_subnet.subnet: Creating...
yandex_vpc_subnet.subnet: Creation complete after 0s [id=e2lf7bnn7bjncu9dng48]
module.backends[0].yandex_compute_instance.instances: Creating...
module.backends[1].yandex_compute_instance.instances: Creating...
module.loadbalancers[0].yandex_compute_instance.instances: Creating...
module.databases[0].yandex_compute_instance.instances: Creating...
module.backends[0].yandex_compute_instance.instances: Still creating... [10s elapsed]
module.databases[0].yandex_compute_instance.instances: Still creating... [10s elapsed]
module.backends[1].yandex_compute_instance.instances: Still creating... [10s elapsed]
module.loadbalancers[0].yandex_compute_instance.instances: Still creating... [10s elapsed]
module.loadbalancers[0].yandex_compute_instance.instances: Still creating... [20s elapsed]
module.backends[1].yandex_compute_instance.instances: Still creating... [20s elapsed]
module.databases[0].yandex_compute_instance.instances: Still creating... [20s elapsed]
module.backends[0].yandex_compute_instance.instances: Still creating... [20s elapsed]
module.backends[0].yandex_compute_instance.instances: Still creating... [30s elapsed]
module.loadbalancers[0].yandex_compute_instance.instances: Still creating... [30s elapsed]
module.databases[0].yandex_compute_instance.instances: Still creating... [30s elapsed]
module.backends[1].yandex_compute_instance.instances: Still creating... [30s elapsed]
module.backends[1].yandex_compute_instance.instances: Still creating... [40s elapsed]
module.databases[0].yandex_compute_instance.instances: Still creating... [40s elapsed]
module.loadbalancers[0].yandex_compute_instance.instances: Still creating... [40s elapsed]
module.backends[0].yandex_compute_instance.instances: Still creating... [40s elapsed]
module.databases[0].yandex_compute_instance.instances: Creation complete after 41s [id=epdltmmf7hjpovgtv6k4]
module.backends[0].yandex_compute_instance.instances: Creation complete after 45s [id=epda1rvsmmst5ug5k944]
module.loadbalancers[0].yandex_compute_instance.instances: Creation complete after 46s [id=epdch03fka4uk2be7fn9]
module.backends[1].yandex_compute_instance.instances: Creation complete after 46s [id=epdqirj00261i1vvh43m]
local_file.group_vars_all_file: Creating...
local_file.inventory_file: Creating...
local_file.inventory_file: Creation complete after 0s [id=a6988a36558a70bc1ec06f13ac39f9b6abd0a2bb]
local_file.group_vars_all_file: Creation complete after 0s [id=bb6a8c644e0ed58c2e53325fc972fd286e4e568a]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

backends_info = [
  {
    "ip_address" = "10.10.20.31"
    "name" = "backend-1"
    "nat_ip_address" = "89.169.160.80"
  },
  {
    "ip_address" = "10.10.20.28"
    "name" = "backend-2"
    "nat_ip_address" = "89.169.168.207"
  },
]
databases_info = [
  {
    "ip_address" = "10.10.20.26"
    "name" = "database-1"
    "nat_ip_address" = "84.201.155.23"
  },
]
loadbalancers_info = [
  {
    "ip_address" = "10.10.20.7"
    "name" = "loadbalancer-1"
    "nat_ip_address" = "62.84.122.213"
  },
]
---------------------------------------------------------------------------
После запуска предыдущей команды terraform автоматически сгенерировал inventory файл, 
который понадобится для последующего запуска команды ansible
Ждем какое то время - потому как мгновенно все не поднимается, а для отладки  sleep не нравится, 
поэтому ручками...```
Далее для настройки этих виртуальных машин запустим ansible-playbook :


```
ansible-playbook -u debian --private-key ~/.ssh/id_rsa -b ./provision.yml

```

Дл проверки работы балансировщика воспользуемся отображением простой страницы  созданного добрым человеком сайта на PHP, 
имитирующий продажу новых и подержанных автомобилей:

При напонении сайта данные будут размещаться на сервере database-1. На данном сервере установлено приложение MySQL от Percona.
Заранее создана база данных 'cars', в котором созданы таблицы 'new' и 'used', имитирующие списки соответственно новых и подержанных автомобилей.

Убеждаемся, что балансировщик loadbalancer-1 корректно выполняет свою функцию при отключении одного из backend-серверов.
Поочередности выключаем бэкенды при этом продолжая наполнять сайт данными. Балансир работает - база наполняется - даже при отключении любого из двух бэкендрв.
### Удаление стенда

Удалить развернутый стенд командой:
```
terraform destroy -auto-approve
```
