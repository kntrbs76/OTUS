locals {
  vm_user         = "almalinux"
  ssh_public_key  = "~/.ssh/id_rsa.pub"
  ssh_private_key = "~/.ssh/id_rsa"
  #vm_name         = "instance"
  vpc_name        = "my_vpc_network"

  folders = {
    "lab-folder" = {}
    #"loadbalancer-folder" = {}
    #"nginx_folder" = {}
    #"backend_folder" = {}
  }

  subnets = {
    "lab-subnet" = {
      v4_cidr_blocks = ["10.10.10.0/24"]
    }
    /*
    "loadbalancer-subnet" = {
      v4_cidr_blocks = ["10.10.10.0/24"]
    }
    "nginx-subnet" = {
      v4_cidr_blocks = ["10.10.20.0/24"]
    }
    "backend-subnet" = {
      v4_cidr_blocks = ["10.10.30.0/24"]
    }
    */
  }

  #subnet_cidrs  = ["10.10.50.0/24"]
  #subnet_name   = "my_vpc_subnet"
  db_count     = "2"
  ceph_count   = "3"
  be_count     = "2"
  lb_count     = "2"
  consul_count = "3"
  disk_count   = "3"
  /*
  disk = {
    "web" = {
      "size" = "1"
    }
  }
  */
}

#resource "yandex_resourcemanager_folder" "folders" {
#  for_each = local.folders
#  name     = each.key
#  cloud_id = var.cloud_id
#}

#data "yandex_resourcemanager_folder" "folders" {
#  for_each   = yandex_resourcemanager_folder.folders
#  name       = each.value["name"]
#  depends_on = [yandex_resourcemanager_folder.folders]
#}

resource "yandex_vpc_network" "vpc" {
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  name      = local.vpc_name
}

data "yandex_vpc_network" "vpc" {
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  name      = yandex_vpc_network.vpc.name
}

resource "yandex_vpc_address" "vmaddr" {
  name = "vmaddr"
  deletion_protection = false
  external_ipv4_address {
    zone_id = var.zone
  }
}

resource "yandex_vpc_address" "lbaddr" {
  name = "lbaddr"
  deletion_protection = false
  external_ipv4_address {
    zone_id = var.zone
  }
}

#resource "yandex_vpc_subnet" "subnet" {
#  count          = length(local.subnet_cidrs)
#  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
#  v4_cidr_blocks = local.subnet_cidrs
#  zone           = var.zone
#  name           = "${local.subnet_name}${format("%1d", count.index + 1)}"
#  network_id     = yandex_vpc_network.vpc.id
#}

resource "yandex_vpc_subnet" "subnets" {
  for_each = local.subnets
  name           = each.key
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  v4_cidr_blocks = each.value["v4_cidr_blocks"]
  zone           = var.zone
  network_id     = data.yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.rt.id
}

#data "yandex_vpc_subnet" "subnets" {
#  for_each   = yandex_vpc_subnet.subnets
#  name       = each.value["name"]
#  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
#  depends_on = [yandex_vpc_subnet.subnets]
#}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "test-gateway"
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
    #next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
    #next_hop_address = data.yandex_lb_network_load_balancer.keepalived.internal_address_spec.0.address
  }
}

module "dbs" {
  source         = "./modules/instances"
  count          = local.db_count
  vm_name        = "db-${format("%02d", count.index + 1)}"
  vpc_name       = local.vpc_name
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph_key.public_key_openssh}"
  secondary_disk = {}
  depends_on     = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "dbs" {
  count      = length(module.dbs)
  name       = module.dbs[count.index].vm_name
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.dbs]
}

module "cephs" {
  source         = "./modules/instances"
  count          = local.ceph_count
  vm_name        = "ceph-${format("%02d", count.index + 1)}"
  vpc_name       = local.vpc_name
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "backend-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = count.index != 0 ? "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph_key.public_key_openssh}" : "#cloud-config\nhostname: ceph-01\nwrite_files:\n- path: /home/${local.vm_user}/.ssh/id_rsa\n  defer: true\n  permissions: 0600\n  owner: ${local.vm_user}:${local.vm_user}\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph_key.private_key_openssh}")}\n- path: /home/${local.vm_user}/.ssh/id_rsa.pub\n  defer: true\n  permissions: 0600\n  owner: ${local.vm_user}:${local.vm_user}\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph_key.public_key_openssh}")}"

  secondary_disk = {
    for disk in yandex_compute_disk.disks :
    disk.name => {
      disk_id = disk.id
      #"auto_delete" = true
      #"mode"        = "READ_WRITE"
    }
    if "${substr(disk.name,0,7)}" == "ceph-${format("%02d", count.index + 1)}"
  }
  depends_on = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "cephs" {
  count      = length(module.cephs)
  name       = module.cephs[count.index].vm_name
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.cephs]
}

module "bes" {
  source         = "./modules/instances"
  count          = local.be_count
  vm_name        = "be-${format("%02d", count.index + 1)}"
  vpc_name       = local.vpc_name
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "backend-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph_key.public_key_openssh}"
  secondary_disk = {}
  depends_on = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "bes" {
  count      = length(module.bes)
  name       = module.bes[count.index].vm_name
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.bes]
}

module "lbs" {
  source         = "./modules/instances"
  count          = local.lb_count
  vm_name        = "lb-${format("%02d", count.index + 1)}"
  cpu            = 2
  memory         = 8
  vpc_name       = local.vpc_name
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id      = subnet.id
      nat            = count.index==0 ? true : false
      nat_ip_address = count.index==0 ? yandex_vpc_address.vmaddr.external_ipv4_address[0].address : ""
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "nginx-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = ""
  secondary_disk = {}
  depends_on     = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "lbs" {
  count      = length(module.lbs)
  name       = module.lbs[count.index].vm_name
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.lbs]
}

module "consuls" {
  source         = "./modules/instances"
  count          = local.consul_count
  vm_name        = "consul-${format("%02d", count.index + 1)}"
  cpu            = 2
  memory         = 2
  vpc_name       = local.vpc_name
  #folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "nginx-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = ""
  secondary_disk = {}
  depends_on     = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "consuls" {
  count      = length(module.consuls)
  name       = module.consuls[count.index].vm_name
  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.consuls]
}

resource "yandex_compute_disk" "disks" {
  count     = local.ceph_count * local.disk_count
  name      = "ceph-${format("%02d", floor(count.index / local.disk_count) + 1)}-disk-${format("%02d", count.index % local.disk_count + 1)}"
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  size      = "10"
  zone      = var.zone
}

#data "yandex_compute_disk" "disks" {
#  for_each   = yandex_compute_disk.disks
#  name       = each.value["name"]
#  #folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
#  depends_on = [yandex_compute_disk.disks]
#}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      dbs          = data.yandex_compute_instance.dbs
      cephs        = data.yandex_compute_instance.cephs
      bes          = data.yandex_compute_instance.bes
      lbs          = data.yandex_compute_instance.lbs
      consuls      = data.yandex_compute_instance.consuls
      remote_user  = local.vm_user
      domain_name  = var.domain_name
      domain_org   = var.domain_org
      domain_token = var.yc_token
    }
  )
  filename = "${path.module}/inventory.ini"
}

resource "local_file" "inintial_ceph_file" {
  content = templatefile("${path.module}/templates/initial-config-primary-cluster.yaml.tpl",
    {
      cephs       = data.yandex_compute_instance.cephs
      bes         = data.yandex_compute_instance.bes
      domain_name = var.domain_name
    }
  )
  filename = "${path.module}/roles/ceph_setup/files/initial-config-primary-cluster.yaml"
}

resource "tls_private_key" "ceph_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "yandex_lb_target_group" "web-tg" {
  name      = "web-group"
  region_id = "ru-central1"
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id

  dynamic "target" {
    for_each = data.yandex_compute_instance.lbs[*].network_interface.0.ip_address
    content {
      subnet_id = yandex_vpc_subnet.subnets["lab-subnet"].id
      address   = target.value
    }
  }
}

resource "yandex_lb_network_load_balancer" "web-lb" {
  name = "web-lb"
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id

  listener {
    name = "web-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.lbaddr.external_ipv4_address[0].address
    }
  }
  
  listener {
    name = "opensearch-dashboard-listener"
    port = 5601
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.lbaddr.external_ipv4_address[0].address
    }
  }
  
  listener {
    name = "grafana-listener"
    port = 3000
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.lbaddr.external_ipv4_address[0].address
    }
  }
  
  attached_target_group {
    target_group_id = yandex_lb_target_group.web-tg.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

data "yandex_lb_network_load_balancer" "web-lb" {
  name = "web-lb"
  #folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [yandex_lb_network_load_balancer.web-lb]
}
