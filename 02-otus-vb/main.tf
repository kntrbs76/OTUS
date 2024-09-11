terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

# В настоящее время нет никаких опций конфигурации для самого провайдера.
resource "virtualbox_vm" "node" {
  count     = 4
  name      = format("node-%02d", count.index + 1)
 # image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  image     = "./virtualbox.box"
  cpus      = 2
  memory    = "512 mib"

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet1"
  }
}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}

output "IPAddr_2" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 2)
}

output "IPAddr_3" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 3)
}

output "IPAddr_4" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 4)
}