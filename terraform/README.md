# OTUS  Домашние задания.

Регистрируемся на яндекс клауд.
Создаем сервисный аккаунт
Согласно инструкции получаем необходимые id для облака и папки и токен
Всвязи с проблемами доступа создаем файл .terraformrc в домашней папке
с зеркалом провайдера на яндекс клауд

Сервисному аккаунту добавляем роли доступа по ssh

вывод консоли. вм поднялись , nginx накатился
----------------------------------
(base) kntrbs@kntrbs-ThinkPad-T490:~/my_proj/OTUS/terraform$ terraform apply 
***********************************
yandex_vpc_network.network-1: Creating...
yandex_compute_disk.boot-disk: Creating...
yandex_vpc_network.network-1: Creation complete after 4s [id=enpv83eokqlv4631fp2i]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 0s [id=e9bek3grjptga4efho2l]
yandex_compute_disk.boot-disk: Still creating... [10s elapsed]
yandex_compute_disk.boot-disk: Creation complete after 13s [id=fhmhj9lf7s5u48gfb6gb]
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Still creating... [30s elapsed]
yandex_compute_instance.vm-1: Provisioning with 'local-exec'...
yandex_compute_instance.vm-1 (local-exec): Executing: ["/bin/sh" "-c" "until nc -zv 62.84.126.182 22; do echo 'Waiting for SSH to be available...'; sleep 5; done"]
yandex_compute_instance.vm-1: Still creating... [40s elapsed]
yandex_compute_instance.vm-1 (local-exec): nc: connect to 62.84.126.182 port 22 (tcp) failed: Connection refused
yandex_compute_instance.vm-1 (local-exec): Waiting for SSH to be available...
yandex_compute_instance.vm-1: Still creating... [50s elapsed]
yandex_compute_instance.vm-1 (local-exec): Connection to 62.84.126.182 22 port [tcp/ssh] succeeded!
yandex_compute_instance.vm-1: Provisioning with 'local-exec'...
yandex_compute_instance.vm-1 (local-exec): Executing: ["/bin/sh" "-c" "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '62.84.126.182,' -u kntrbs --private-key ~/.ssh/id_rsa ./ansible/playbooks/nginx_install.yaml"]

yandex_compute_instance.vm-1 (local-exec): PLAY [Install NGNIX] ***********************************************************

yandex_compute_instance.vm-1 (local-exec): TASK [Gathering Facts] *********************************************************
yandex_compute_instance.vm-1 (local-exec): ok: [62.84.126.182]

yandex_compute_instance.vm-1 (local-exec): TASK [Update packet list] ******************************************************
yandex_compute_instance.vm-1: Still creating... [1m0s elapsed]
yandex_compute_instance.vm-1: Still creating... [1m10s elapsed]
yandex_compute_instance.vm-1 (local-exec): changed: [62.84.126.182]

yandex_compute_instance.vm-1 (local-exec): TASK [Install NGNIX] ***********************************************************
yandex_compute_instance.vm-1: Still creating... [1m20s elapsed]
yandex_compute_instance.vm-1 (local-exec): changed: [62.84.126.182]

yandex_compute_instance.vm-1 (local-exec): TASK [NGNIX Enabled, Autostart] ************************************************
yandex_compute_instance.vm-1 (local-exec): ok: [62.84.126.182]

yandex_compute_instance.vm-1 (local-exec): PLAY RECAP *********************************************************************
yandex_compute_instance.vm-1 (local-exec): 62.84.126.182              : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

yandex_compute_instance.vm-1: Creation complete after 1m24s [id=fhmg4aarrplje9ltqfsb]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_vm_1 = "62.84.126.182"
internal_ip_address_vm_1 = "192.168.10.5"
-----------------------------------------------