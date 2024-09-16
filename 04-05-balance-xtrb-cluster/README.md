### Описание стенда

Данный стенд демонстрирует технологию построения отказоустойчивого сайта Wordpress с применением кластера СУБД Percona XtraDB Cluster, маршрутизатора SQL запросов ProxySQL, а также кластера Keepalived. 

Стенд тестировался на Ubuntu 22 LTS со следующим установленным ПО:

1. VirtualBox 7.0.20
2. Vagrant 2.4.1
3. Ansible 2.10.5
4. Python 3.9.13

После развертывания стенда будет создано 6 ВМ:

1. **db1 [10.0.0.13]** - 1-я нода Percona кластера. 
2. **db2 [10.0.0.14]** - 2-я нода Percona кластера. 
3. **db3 [10.0.0.15]** - 3-я нода Percona кластера.
4. **dbproxy [10.0.0.20]** - машина с ProxySQL, которая является единой точкой входа в базу данных.
5. **node1 [192.168.100.11, 10.0.0.11]** - фронтэнд-1. ВМ Centos 7 с Nginx, php-fpm и keepalived. 
6. **node2 [192.168.100.12, 10.0.0.12]** - фронтэнд-2. ВМ Centos 7 с Nginx, php-fpm и keepalived.

Между машинами node1 и node2 подвешен плавающий VRRP_IP 192.168.100.100 По умолчанию VRRP_IP 192.168.100.100 висит на машине node1.


***Цель лабораторной работы: продемонстрировать доступность сайта Wordpress с хост-машины по адресу http://192.168.100.100 после того как станет недоступна одна из машин фронтэнда и одна из нод Percona кластера.***


Сети 192.168.100.0/24 и 10.0.0.0/24, созданные в рамках VirtualBox являются "private_network" и доступны с хост-машины на которой разворачивается стенд. Каждая машина создается с RAM 256Gb на борту.

### Как поднять стенд?

sudo su -
mkdir /etc/vbox/
cd /etc/vbox/
echo '* 0.0.0.0/0 ::/0' > /etc/vbox/networks.conf
chmod 644 /etc/vbox/networks.conf

В Vagrantfile - добавлен
ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'
config.vm.provision 
поменять путь до своего ssh ключа

Исправлены репозитории Centos7 на рабочие.

1. **vagrant up**
2. **ansible-playbook site.yml**

### Как проверить отказоустойчивость?
------------------ проверка балансировщика-----------------------
1. Зайти с хост-машины через браузер по адресу http://192.168.100.100
2. Заполнить 4 поля начальной регистрации Wordpress и нажать внизу кнопку "Install Wordpress"
3. Зайти в панель управления Wordpress и, например, опубликовать тестовый пост.
4. Подключиться по ssh к node1: **vagrant ssh node1** и, например, выключить эту ВМ: **shutdown -h now**
----------------- проверка работы db кластера -------------------
5. Обновить страницу http://192.168.100.100 на хост-машине и убедиться, что Wordpress по прежнему доступен.
6. Далее, можно уничтожить, например, одну из нод Percona кластера, выполнив команду **vagrant destroy db1 -f**
7. Убедиться, что опубликованный ранее пост по прежнему доступен.