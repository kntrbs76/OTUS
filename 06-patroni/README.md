# lab-06
otus | postresql cluster

### Домашнее задание
реализация кластера postgreSQL с помощью patroni

#### Цель:
Перевести БД веб проекта на кластер postgreSQL с ипользованием patroni, etcd/consul/zookeeper и haproxy/pgbouncer

#### Критерии оценки:
Статус "Принято" ставится при выполнении перечисленных требований.


### Выполнение домашнего задания

#### Создание стенда

Стенд будем разворачивать с помощью Terraform на YandexCloud, настройку серверов будем выполнять с помощью Ansible.

Необходимые файлы размещены в репозитории GitHub по ссылке:
```
https://github.com/SergSha/lab-06.git
```

Схема:

<img src="pics/infra.png" alt="infra.png" />

Для начала получаем OAUTH токен:
```
https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
```

Настраиваем аутентификации в консоли:
```
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_yc_token=$YC_TOKEN
```

Скачиваем проект с гитхаба:
```
git clone https://github.com/SergSha/lab-06.git && cd ./lab-06
```

В файле provider.tf нужно вставить свой 'cloud_id':
```
cloud_id  = "..."
```

При необходимости в файле main.tf вставить нужные 'ssh_public_key' и 'ssh_private_key', так как по умолчанию соответсвенно id_rsa.pub и id_rsa:
```
ssh_public_key  = "~/.ssh/id_rsa.pub"
ssh_private_key = "~/.ssh/id_rsa"
```

Для того чтобы развернуть стенд, нужно выполнить следующую команду:
```
terraform init && terraform apply -auto-approve && \
sleep 60 && ansible-playbook ./provision.yml
```

По завершению команды получим данные outputs:
```
backend-servers-info = {
  "backend-01" = {
    "ip_address" = tolist([
      "10.10.10.21",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
  "backend-02" = {
    "ip_address" = tolist([
      "10.10.10.8",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
}
db-servers-info = {
  "db-01" = {
    "ip_address" = tolist([
      "10.10.10.14",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
  "db-02" = {
    "ip_address" = tolist([
      "10.10.10.6",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
  "db-03" = {
    "ip_address" = tolist([
      "10.10.10.15",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
}
iscsi-servers-info = {
  "iscsi-01" = {
    "ip_address" = tolist([
      "10.10.10.38",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
}
jump-servers-info = {
  "jump-01" = {
    "ip_address" = tolist([
      "10.10.10.22",
    ])
    "nat_ip_address" = tolist([
      "89.169.173.24",
    ])
  }
}
loadbalancer-info = toset([
  {
    "external_address_spec" = toset([
      {
        "address" = "84.201.147.191"
        "ip_version" = "ipv4"
      },
    ])
    "internal_address_spec" = toset([])
    "name" = "http-listener"
    "port" = 80
    "protocol" = "tcp"
    "target_port" = 80
  },
])
nginx-servers-info = {
  "nginx-01" = {
    "ip_address" = tolist([
      "10.10.10.20",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
  "nginx-02" = {
    "ip_address" = tolist([
      "10.10.10.16",
    ])
    "nat_ip_address" = tolist([
      "",
    ])
  }
}
```

На всех серверах будут установлены ОС Almalinux 8, настроены смнхронизация времени Chrony, система принудительного контроля доступа SELinux, в качестве firewall будет использоваться NFTables.

Стенд был взят из лабораторной работы 4 https://github.com/SergSha/lab-04, только вместо одного сервера для базы данных, будет кластер, состоящий из серверов db-01, db-02 и db-03. Для создания кластера базы данных будем использовать кластер PostgreSQL с ипользованием Patroni, ETCD и HAProxy.

Так как на YandexCloud ограничено количество выделяемых публичных IP адресов, в дополнение к этому стенду создадим ещё один сервер jump-01 в качестве JumpHost, через который будем подключаться по SSH (в частности для Ansible) к другим серверам той же подсети.

Список виртуальных машин после запуска стенда:

<img src="pics/screen-001.png" alt="screen-001.png" />

С помощью ssh через jump-сервер jump-01 подключися к какому-либо сервера PostgreSQL кластера, например, db-02:
```
ssh -J cloud-user@158.160.68.18 cloud-user@10.10.10.27
```

Посмотрим конфиги кластера:
```
less /etc/etcd/etcd.conf
```
```
# [member]
ETCD_NAME=etcd2
ETCD_DATA_DIR="/var/lib/etcd"
#ETCD_WAL_DIR=""
#ETCD_SNAPSHOT_COUNT="10000"
ETCD_HEARTBEAT_INTERVAL="100"
ETCD_ELECTION_TIMEOUT="5000"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.10.10.27:2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="etcd1=http://10.10.10.28:2380,etcd2=http://10.10.10.27:2380,etcd3=http://10.10.10.16:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="PgsqlCluster"
ETCD_ADVERTISE_CLIENT_URLS="http://10.10.10.27:2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
ETCD_ENABLE_V2="true"
#ETCD_STRICT_RECONFIG_CHECK="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"
#
#[proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[security]
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_CLIENT_CERT_AUTH="false"
#ETCD_TRUSTED_CA_FILE=""
#ETCD_AUTO_TLS="false"
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
#ETCD_PEER_CLIENT_CERT_AUTH="false"
#ETCD_PEER_TRUSTED_CA_FILE=""
#ETCD_PEER_AUTO_TLS="false"
#
#[logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
```

```
etcdctl endpoint status --write-out=table --endpoints=10.10.10.28:2379,10.10.10.27:2379,10.10.10.16:2379
```
```
+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|     ENDPOINT     |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| 10.10.10.28:2379 | 2369b0f621f6f6c2 |  3.5.10 |   20 kB |     false |      false |         2 |       2503 |               2503 |        |
| 10.10.10.27:2379 | 748ec4f03d81c239 |  3.5.10 |   20 kB |      true |      false |         2 |       2503 |               2503 |        |
| 10.10.10.16:2379 | d997fca8eedb89ce |  3.5.10 |   20 kB |     false |      false |         2 |       2503 |               2503 |        |
+------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
```

Конфигурация Patroni:
```
less /etc/patroni/patroni.yml 
```
```
cat /etc/patroni/patroni.yml
scope: PgsqlCluster
#namespace: /service/
name: etcd2

restapi:
  listen: 10.10.10.27:8008
  connect_address: 10.10.10.27:8008
#  cafile: /etc/ssl/certs/ssl-cacert-snakeoil.pem
#  certfile: /etc/ssl/certs/ssl-cert-snakeoil.pem
#  keyfile: /etc/ssl/private/ssl-cert-snakeoil.key
#  authentication:
#    username: username
#    password: password

#ctl:
#  insecure: false # Allow connections to Patroni REST API without verifying certificates
#  certfile: /etc/ssl/certs/ssl-cert-snakeoil.pem
#  keyfile: /etc/ssl/private/ssl-cert-snakeoil.key
#  cacert: /etc/ssl/certs/ssl-cacert-snakeoil.pem

#citus:
#  database: citus
#  group: 0  # coordinator

etcd:
  #Provide host to do the initial discovery of the cluster topology:
  hosts: 10.10.10.28:2379,10.10.10.27:2379,10.10.10.16:2379
  #Or use "hosts" to provide multiple endpoints
  #Could be a comma separated string:
  #hosts: host1:port1,host2:port2
  #or an actual yaml list:
  #hosts:
  #- host1:port1
  #- host2:port2
  #Once discovery is complete Patroni will use the list of advertised clientURLs
  #It is possible to change this behavior through by setting:
  #use_proxies: true

#raft:
#  data_dir: .
#  self_addr: 127.0.0.1:2222
#  partner_addrs:
#  - 127.0.0.1:2223
#  - 127.0.0.1:2224

# The bootstrap configuration. Works only when the cluster is not yet initialized.
# If the cluster is already initialized, all changes in the `bootstrap` section are ignored!
bootstrap:
  # This section will be written into Etcd:/<namespace>/<scope>/config after initializing new cluster
  # and all other cluster members will use it as a `global configuration`.
  # WARNING! If you want to change any of the parameters that were set up
  # via `bootstrap.dcs` section, please use `patronictl edit-config`!
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
#    primary_start_timeout: 300
#    synchronous_mode: false
    #standby_cluster:
      #host: 127.0.0.1
      #port: 1111
      #primary_slot_name: patroni
    postgresql:
      use_pg_rewind: true
      pg_hba:
      # For kerberos gss based connectivity (discard @.*$)
      #- host replication replicator 127.0.0.1/32 gss include_realm=0
      #- host all all 0.0.0.0/0 gss include_realm=0
      - host replication replicator 127.0.0.1/32 md5
      - host replication replicator 10.10.10.16/0 md5
      - host replication replicator 10.10.10.27/0 md5
      - host replication replicator 10.10.10.28/0 md5
      - host all all 0.0.0.0/0 md5
      #  - hostssl all all 0.0.0.0/0 md5
#      use_slots: true
      parameters:
#        wal_level: hot_standby
#        hot_standby: "on"
#        max_connections: 100
#        max_worker_processes: 8
#        wal_keep_segments: 8
#        max_wal_senders: 10
#        max_replication_slots: 10
#        max_prepared_transactions: 0
#        max_locks_per_transaction: 64
#        wal_log_hints: "on"
#        track_commit_timestamp: "off"
#        archive_mode: "on"
#        archive_timeout: 1800s
#        archive_command: mkdir -p ../wal_archive && test ! -f ../wal_archive/%f && cp %p ../wal_archive/%f
#      recovery_conf:
#        restore_command: cp ../wal_archive/%f %p

  # some desired options for 'initdb'
  initdb:  # Note: It needs to be a list (some options need values, others are switches)
  - encoding: UTF8
  - data-checksums

  # Additional script to be launched after initial cluster creation (will be passed the connection URL as parameter)
# post_init: /usr/local/bin/setup_cluster.sh

postgresql:
  listen: 10.10.10.27:5432
  connect_address: 10.10.10.27:5432

#  proxy_address: 127.0.0.1:5433  # The address of connection pool (e.g., pgbouncer) running next to Patroni/Postgres. Only for service discovery.
  data_dir: /var/lib/pgsql/16/data
  bin_dir: /usr/pgsql-16/bin/
#  config_dir:
  pgpass: /tmp/pgpass0
  authentication:
    replication:
      username: replicator
      password: rep-pass
    superuser:
      username: postgres
      password: zalando
    rewind:  # Has no effect on postgres 10 and lower
      username: rewind_user
      password: rewind_password
  # Server side kerberos spn
#  krbsrvname: postgres
  parameters:
    # Fully qualified kerberos ticket file for the running user
    # same as KRB5CCNAME used by the GSS
#   krb_server_keyfile: /var/spool/keytabs/postgres
    unix_socket_directories: '..'  # parent directory of data_dir
  # Additional fencing script executed after acquiring the leader lock but before promoting the replica
  #pre_promote: /path/to/pre_promote.sh

#watchdog:
#  mode: automatic # Allowed values: off, automatic, required
#  device: /dev/watchdog
#  safety_margin: 5

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
```

```
patronictl -c /etc/patroni/patroni.yml list
```
```
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd1  | 10.10.10.28 | Leader  | running   |  1 |           |
| etcd2  | 10.10.10.27 | Replica | streaming |  1 |         0 |
| etcd3  | 10.10.10.16 | Replica | streaming |  1 |         0 |
+--------+-------------+---------+-----------+----+-----------+
```

Как видим, мастером является хост с IP адресом 10.10.10.28, то есть сервер db-01.

Следующей командой мы можем вручную переключить режим мастера на другой хост, например, db-03 с IP адресом 10.10.10.16:
```
patronictl -c /etc/patroni/patroni.yml switchover
```
```
Current cluster topology
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd1  | 10.10.10.28 | Leader  | running   |  1 |           |
| etcd2  | 10.10.10.27 | Replica | streaming |  1 |         0 |
| etcd3  | 10.10.10.16 | Replica | streaming |  1 |         0 |
+--------+-------------+---------+-----------+----+-----------+
Primary [etcd1]: 
Candidate ['etcd2', 'etcd3'] []: etcd3
When should the switchover take place (e.g. 2023-11-07T17:10 )  [now]: 
Are you sure you want to switchover cluster PgsqlCluster, demoting current leader etcd1? [y/N]: y
2023-11-07 16:11:02.43717 Successfully switched over to "etcd3"
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd1  | 10.10.10.28 | Replica | stopped   |    |   unknown |
| etcd2  | 10.10.10.27 | Replica | streaming |  1 |         0 |
| etcd3  | 10.10.10.16 | Leader  | running   |  1 |           |
+--------+-------------+---------+-----------+----+-----------+
```

Снова проверим:
```
patronictl -c /etc/patroni/patroni.yml list
```
```
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd1  | 10.10.10.28 | Replica | streaming |  2 |         0 |
| etcd2  | 10.10.10.27 | Replica | streaming |  2 |         0 |
| etcd3  | 10.10.10.16 | Leader  | running   |  2 |           |
+--------+-------------+---------+-----------+----+-----------+
```

Как видим, мастером стал хост с IP адресом 10.10.10.16, то есть сервер db-03.

Для проверки работы стенда воспользуемся отображением простой страницы собственноручно созданного сайта на PHP, 
имитирующий продажу новых и подержанных автомобилей:

<img src="pics/screen-002.png" alt="screen-002.png" />

Значение IP адреса сайта получен от балансировщика от YandexCloud:

<img src="pics/screen-003.png" alt="screen-003.png" />

При напонении сайта данные будут размещаться в базе данных кластера серверов db-01, db-02, db-03. На данном кластере, как и ранее заявлялось, установлены приложения PostgreSQL, Patroni, etcd.
Заранее создана база данных 'cars', в котором созданы таблицы 'new' и 'used', имитирующие списки соответственно новых и подержанных автомобилей.

Начнём наполнять этот сайт:

<img src="pics/screen-004.png" alt="screen-004.png" />

<img src="pics/screen-005.png" alt="screen-005.png" />

Сайт наполняется, серверы работают пока корректно.

Отключим одну виртуальную машину из кластера, например, db-01 (первый возможный вариант):

<img src="pics/screen-006.png" alt="screen-006.png" />

<img src="pics/screen-007.png" alt="screen-007.png" />

Обновим страницу:

<img src="pics/screen-008.png" alt="screen-008.png" />

Продолжим наполнять сайт:

<img src="pics/screen-009.png" alt="screen-009.png" />

<img src="pics/screen-010.png" alt="screen-010.png" />

Как видим, сайт работает с отключенным сервером db-01.

```
patronictl -c /etc/patroni/patroni.yml list
```
```
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd2  | 10.10.10.27 | Replica | streaming |  2 |         0 |
| etcd3  | 10.10.10.16 | Leader  | running   |  2 |           |
+--------+-------------+---------+-----------+----+-----------+
```

Запускаем db-01 и отключаем виртуальную машину из кластера db-03 (второй возможный вариант):

<img src="pics/screen-011.png" alt="screen-011.png" />

Проверяем:
```
patronictl -c /etc/patroni/patroni.yml list
```
```
+ Cluster: PgsqlCluster (7298700573789334176) --+-----------+
| Member | Host        | Role    | State   | TL | Lag in MB |
+--------+-------------+---------+---------+----+-----------+
| etcd1  | 10.10.10.28 | Replica | running |  2 |         0 |
| etcd2  | 10.10.10.27 | Leader  | running |  2 |           |
+--------+-------------+---------+---------+----+-----------+
```

Как видим, мастер перешёл с хоста db-03 (ip 10.10.10.16) на хост db-02 (ip 10.10.10.27).

Обновим страницу:

<img src="pics/screen-012.png" alt="screen-012.png" />

Продолжим наполнять сайт:

<img src="pics/screen-013.png" alt="screen-013.png" />

<img src="pics/screen-014.png" alt="screen-014.png" />

Как видим, сайт продолжает работать с отключенным сервером db-03.

Запустим db-03 и отключим db-02 (третий и последний вариант):

<img src="pics/screen-015.png" alt="screen-015.png" />

На сервере db-01 проверяем:
```
patronictl -c /etc/patroni/patroni.yml list
```
```
+ Cluster: PgsqlCluster (7298700573789334176) ----+-----------+
| Member | Host        | Role    | State     | TL | Lag in MB |
+--------+-------------+---------+-----------+----+-----------+
| etcd1  | 10.10.10.28 | Leader  | running   |  4 |           |
| etcd3  | 10.10.10.16 | Replica | streaming |  4 |         0 |
+--------+-------------+---------+-----------+----+-----------+
```

Как видим, мастер перешёл уже на сервер db-01 (ip 10.10.10.28).

Снова обновим страницу:

<img src="pics/screen-016.png" alt="screen-016.png" />

Продолжаем далее наполнять сайт:

<img src="pics/screen-017.png" alt="screen-017.png" />

<img src="pics/screen-018.png" alt="screen-018.png" />

Войдём в консоль сервера backend-01 и выполним команды postgresql, чтобы убедиться в базе данных присутствуют введённые с сайта данные:
```
[root@backend-01 ~]# psql -h 10.10.10.254 -p 5433 -U postgres --dbname cars -c "SELECT * FROM new;"
Password for user postgres: 
 id |    name     | year |  price  
----+-------------+------+---------
  1 | Lada Granta | 2022 | 1099000
  3 | Renault     | 2021 | 1299000
(2 rows)

[root@backend-01 ~]# psql -h 10.10.10.254 -p 5433 -U postgres --dbname cars -c "SELECT * FROM used;"
Password for user postgres: 
 id |    name     | year | price  
----+-------------+------+--------
  2 | Lada Kalina | 2017 | 650000
  4 | Audi        | 2003 | 710000
(2 rows)

[root@backend-01 ~]#
```
где -h 10.10.10.254 -p 5433 - соответсвенно виртуальный IP адрес и порт, настроенные с помощью создания ресурса VirtualIP (PCS IPaddr2).

--dbname cars - база данных PostgreSQL.

Как мы наблюдаем, сайт продолжает работать с отключенным сервером db-02.

Мы провели все возможные варианты отключения серверов, но сайт продолжает работать, а кластер сохраняет данные.значит созданный нами PostgreSQL кластер выполняет свою функцию.


#### Удаление стенда

Удалить развернутый стенд командой:
```
terraform destroy -auto-approve
```
