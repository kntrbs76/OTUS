
[all]
%{ for db in dbs ~}
${ db["name"] } ansible_host=${ db.network_interface[0].ip_address }
%{ endfor ~}
%{ for ceph in cephs ~}
${ ceph["name"] } ansible_host=${ ceph.network_interface[0].ip_address }
%{ endfor ~}
%{ for be in bes ~}
${ be["name"] } ansible_host=${ be.network_interface[0].ip_address }
%{ endfor ~}
%{ for lb in lbs ~}
${ lb["name"] } ansible_host=${ lb.network_interface[0].ip_address } public_ip=${ lb.network_interface[0].nat_ip_address }
%{ endfor ~}
%{ for index, consul in consuls ~}
${ consul["name"] } ansible_host=${ consul.network_interface[0].ip_address }
%{ endfor ~}

[dbs]
%{ for db in dbs ~}
${ db["name"] }
%{ endfor ~}

[cephs]
%{ for ceph in cephs ~}
${ ceph["name"] }
%{ endfor ~}

[bes]
%{ for be in bes ~}
${ be["name"] }
%{ endfor ~}

[lbs]
%{ for lb in lbs ~}
${ lb["name"] }
%{ endfor ~}

[consuls]
%{ for consul in consuls ~}
${ consul["name"] }
%{ endfor ~}

[os_cluster]
%{ for lb in lbs ~}
${ lb["name"] } roles=data,master,ingest
%{ endfor ~}

[master]
%{ for lb in lbs ~}
${ lb["name"] }
%{ endfor ~}

[dashboards]
%{ for lb in lbs ~}
${ lb["name"] }
%{ endfor ~}

[prometheus]
%{ for lb in lbs ~}
${ lb["name"] }
%{ endfor ~}

[grafana]
%{ for lb in lbs ~}
${ lb["name"] }
%{ endfor ~}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyJump="${ remote_user }@${ lbs[0].network_interface[0].nat_ip_address }"'
#ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -p 22 -W %h:%p -q ${ remote_user }@${ lbs[0].network_interface[0].nat_ip_address }"'

[lbs:vars]
srv_name=balancer
domain=${domain_name}
token=${domain_token}
org=${domain_org}

[bes:vars]
srv_name=backend
