---

ip_address:
%{ for loadbalancer in loadbalancers ~}
  ${ loadbalancer["vm_name"] }: ${ loadbalancer["instance_internal_ip_address"] }
%{ endfor ~}
%{ for backend in backends ~}
  ${ backend["vm_name"] }: ${ backend["instance_internal_ip_address"] }
%{ endfor ~}
%{ for database in databases ~}
  ${ database["vm_name"] }: ${ database["instance_internal_ip_address"] }
%{ endfor ~}
