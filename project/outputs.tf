
output "dbs-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.dbs :
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
    }
  }
}

output "cephs-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.cephs :
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
    }
  }
}

output "bes-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.bes :
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
    }
  }
}

output "lbs-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.lbs :
    vm.name => {
      ip_address     = vm.network_interface.*.ip_address
      nat_ip_address = vm.network_interface.*.nat_ip_address
    }
  }
}

output "consuls-info" {
  description = "General information about created VMs"
  value = {
    for vm in data.yandex_compute_instance.consuls :
    vm.name => {
      ip_address = vm.network_interface.*.ip_address
    }
  }
}

output "loadbalancer-info" {
  description = "General information about loadbalancer"
  #value = data.yandex_lb_network_load_balancer.web-lb.listener.*.external_address_spec[0].address
  value = {
    for lb in data.yandex_lb_network_load_balancer.web-lb.listener :
    lb.name => {
      ip_address = lb.external_address_spec
      port       = lb.port
    }
  }
}
