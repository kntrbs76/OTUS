locals {
  vm_user         = "almalinux"
  ssh_public_key  = "~/.ssh/id_rsa.pub"
  ssh_private_key = "~/.ssh/id_rsa"
  #vm_name         = "instance"
  vpc_name        = "my_vpc_network"

  folders = {
    "lab-folder" = {}
    #"lb_folder" = {}
    #"be_folder" = {}
  }

  subnets = {
    "lab-subnet" = {
      v4_cidr_blocks = ["10.10.10.0/24"]
    }
    /*
    "lb-subnet" = {
      v4_cidr_blocks = ["10.10.20.0/24"]
    }
    "be-subnet" = {
      v4_cidr_blocks = ["10.10.30.0/24"]
    }
    */
  }

  #subnet_cidrs = ["10.10.50.0/24"]
  #subnet_name  = "my_vpc_subnet"
  master_count = "1"
  db_count     = "1"
  iscsi_count  = "0"
  be_count     = "2"
  lb_count     = "1"
  /*
  disk = {
    "web" = {
      "size" = "1"
    }
  }
  */
}

resource "yandex_resourcemanager_folder" "folders" {
  for_each = local.folders
  name     = each.key
  cloud_id = var.cloud_id
}

#data "yandex_resourcemanager_folder" "folders" {
#  for_each   = yandex_resourcemanager_folder.folders
#  name       = each.value["name"]
#  depends_on = [yandex_resourcemanager_folder.folders]
#}

resource "yandex_vpc_network" "vpc" {
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  name = local.vpc_name
}

data "yandex_vpc_network" "vpc" {
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  name = yandex_vpc_network.vpc.name
}

#resource "yandex_vpc_subnet" "subnet" {
#  count          = length(local.subnet_cidrs)
#  folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
#  v4_cidr_blocks = local.subnet_cidrs
#  zone           = var.zone
#  name           = "${local.subnet_name}${format("%1d", count.index + 1)}"
#  network_id     = yandex_vpc_network.vpc.id
#}

resource "yandex_vpc_subnet" "subnets" {
  for_each       = local.subnets
  name           = each.key
  folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  v4_cidr_blocks = each.value["v4_cidr_blocks"]
  zone           = var.zone
  network_id     = data.yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.rt.id
}

#data "yandex_vpc_subnet" "subnets" {
#  for_each   = yandex_vpc_subnet.subnets
#  name       = each.value["name"]
#  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
#  depends_on = [yandex_vpc_subnet.subnets]
#}

resource "yandex_vpc_gateway" "nat_gateway" {
  name      = "test-gateway"
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

module "masters" {
  source    = "./modules/instances"
  count     = local.master_count
  vm_name   = "master-${format("%02d", count.index + 1)}"
  vpc_name  = local.vpc_name
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      nat       = true
    }
    if subnet.name == "lab-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = "#cloud-config\nwrite_files:\n- content: ${base64encode("master:\n- 127.0.0.1\nid: master-${format("%02d", count.index + 1)}")}\n  encoding: b64\n  path: /etc/salt/minion.d/minion.conf\n${file("cloud-init-salt-master.yml")}"
  secondary_disk = {}
  #depends_on     = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "masters" {
  count      = length(module.masters)
  name       = module.masters[count.index].vm_name
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.masters]
}

module "dbs" {
  source    = "./modules/instances"
  count     = local.db_count
  vm_name   = "db-${format("%02d", count.index + 1)}"
  vpc_name  = local.vpc_name
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
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
  user-data      = "#cloud-config\nwrite_files:\n- content: ${base64encode("master:\n- ${data.yandex_compute_instance.masters[0].network_interface[0].ip_address}\nid: db-${format("%02d", count.index + 1)}")}\n  encoding: b64\n  path: /etc/salt/minion.d/minion.conf\n${file("cloud-init-salt-minion.yml")}"
  secondary_disk = {}
  #depends_on     = [yandex_compute_disk.disks]
  depends_on     = [data.yandex_compute_instance.masters]
}

data "yandex_compute_instance" "dbs" {
  count      = length(module.dbs)
  name       = module.dbs[count.index].vm_name
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.dbs]
}
/*
module "iscsi-servers" {
  source         = "./modules/instances"
  count          = local.iscsi_count
  vm_name        = "iscsi-${format("%02d", count.index + 1)}"
  vpc_name       = local.vpc_name
  folder_id      = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "be-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  secondary_disk = {
    for disk in yandex_compute_disk.disks :
    disk.name => {
      disk_id = disk.id
      #"auto_delete" = true
      #"mode"        = "READ_WRITE"
    }
    if disk.name == "web-${format("%02d", count.index + 1)}"
  }
  depends_on = [yandex_compute_disk.disks]
}

data "yandex_compute_instance" "iscsi-servers" {
  count      = length(module.iscsi-servers)
  name       = module.iscsi-servers[count.index].vm_name
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.iscsi-servers]
}
*/
module "bes" {
  source    = "./modules/instances"
  count     = local.be_count
  vm_name   = "be-${format("%02d", count.index + 1)}"
  vpc_name  = local.vpc_name
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      #nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "be-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = "#cloud-config\nwrite_files:\n- content: ${base64encode("master:\n- ${data.yandex_compute_instance.masters[0].network_interface[0].ip_address}\nid: be-${format("%02d", count.index + 1)}")}\n  encoding: b64\n  path: /etc/salt/minion.d/minion.conf\n${file("cloud-init-salt-minion.yml")}"
  secondary_disk = {}
  #depends_on     = [yandex_compute_disk.disks]
  depends_on     = [data.yandex_compute_instance.masters]

}

data "yandex_compute_instance" "bes" {
  count      = length(module.bes)
  name       = module.bes[count.index].vm_name
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.bes]
}

module "lbs" {
  source    = "./modules/instances"
  count     = local.lb_count
  vm_name   = "lb-${format("%02d", count.index + 1)}"
  vpc_name  = local.vpc_name
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  network_interface = {
    for subnet in yandex_vpc_subnet.subnets :
    subnet.name => {
      subnet_id = subnet.id
      nat       = true
    }
    if subnet.name == "lab-subnet" #|| subnet.name == "lb-subnet"
  }
  #subnet_cidrs   = yandex_vpc_subnet.subnet.v4_cidr_blocks
  #subnet_name    = yandex_vpc_subnet.subnet.name
  #subnet_id      = yandex_vpc_subnet.subnet.id
  vm_user        = local.vm_user
  ssh_public_key = local.ssh_public_key
  user-data      = "#cloud-config\nwrite_files:\n- content: ${base64encode("master:\n- ${data.yandex_compute_instance.masters[0].network_interface[0].ip_address}\nid: lb-${format("%02d", count.index + 1)}")}\n  encoding: b64\n  path: /etc/salt/minion.d/minion.conf\n${file("cloud-init-salt-minion.yml")}"
  secondary_disk = {}
  #depends_on     = [yandex_compute_disk.disks]
  depends_on = [data.yandex_compute_instance.masters]
}

data "yandex_compute_instance" "lbs" {
  count      = length(module.lbs)
  name       = module.lbs[count.index].vm_name
  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
  depends_on = [module.lbs]
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      masters       = data.yandex_compute_instance.masters
      dbs           = data.yandex_compute_instance.dbs
      #iscsi-servers = data.yandex_compute_instance.iscsi-servers
      bes           = data.yandex_compute_instance.bes
      lbs           = data.yandex_compute_instance.lbs
      remote_user   = local.vm_user
    }
  )
  filename = "${path.module}/inventory.ini"
}

resource "local_file" "roster_file" {
  content = templatefile("${path.module}/templates/roster.tpl",
    {
      masters       = data.yandex_compute_instance.masters
      dbs           = data.yandex_compute_instance.dbs
      #iscsi-servers = data.yandex_compute_instance.iscsi-servers
      bes           = data.yandex_compute_instance.bes
      lbs           = data.yandex_compute_instance.lbs
      remote_user   = local.vm_user
    }
  )
  filename = "${path.module}/srv/salt/roster"
}
#resource "yandex_compute_disk" "disks" {
#  for_each  = local.disks
#  name      = each.key
#  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
#  size      = each.value["size"]
#  zone      = var.zone
#}
/*
resource "yandex_compute_disk" "disks" {
  count     = local.iscsi_count
  name      = "web-${format("%02d", count.index + 1)}"
  folder_id = yandex_resourcemanager_folder.folders["lab-folder"].id
  size      = "1"
  zone      = var.zone
}
*/
#data "yandex_compute_disk" "disks" {
#  for_each   = yandex_compute_disk.disks
#  name       = each.value["name"]
#  folder_id  = yandex_resourcemanager_folder.folders["lab-folder"].id
#  depends_on = [yandex_compute_disk.disks]
#}
/*
resource "null_resource" "masters" {

  count = length(module.masters)

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    name = "${module.masters[count.index].vm_name}"
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["sudo rpm --import https://repo.saltproject.io/salt/py3/redhat/8/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub",
    "curl -fsSL https://repo.saltproject.io/salt/py3/redhat/8/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo",
    "sudo dnf install salt-minion -y",
    "sudo echo -e 'master:\n  - ${data.yandex_compute_instance.masters[count.index].network_interface[0].ip_address}' > /etc/salt/minion"]
  }
  
  connection {
    type        = "ssh"
    user        = local.vm_user
    private_key = file(local.ssh_private_key)
    host        = data.yandex_compute_instance.masters[count.index].network_interface[0].ip_address
  }
  
  # Note that the -i flag expects a comma separated list, so the trailing comma is essential!

  provisioner "local-exec" {
    command = "ansible-playbook -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i '${module.bes[count.index].instance_external_ip_address},' provision.yml"
    #command = "ansible-playbook provision.yml -u '${local.vm_user}' --private-key '${local.ssh_private_key}' --become -i '${element(module.bes.nat_ip_address, 0)},' "
  }
  
}
*/
