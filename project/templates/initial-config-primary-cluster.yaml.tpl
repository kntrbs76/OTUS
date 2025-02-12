%{ for host in cephs ~}
service_type: host
addr: ${ host.network_interface[0].ip_address }
hostname: ${ host["name"] }.${ domain_name }
---
%{ endfor ~}
service_type: mon
placement:
  host_pattern: 'ceph*'
---
service_type: mgr
placement:
  host_pattern: 'ceph*'
---
service_type: mds
service_id: otus_ceph_fs
placement:
  host_pattern: 'ceph*'
---
service_type: osd
service_id: default_drive_group
placement:
  host_pattern: 'ceph*'
data_devices:
  paths:
    - /dev/vdb
    - /dev/vdc
    - /dev/vdd
