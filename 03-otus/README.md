## lab-02
otus | nginx - setting up web application balancing

### Домашнее задание
Настраиваем балансировку веб-приложения

#### Цель:
научиться использовать Nginx в качестве балансировщика
В результате получаем рабочий пример Nginx в качестве балансировщика, и базовую отказоустойчивость бекенда.

- развернуть 4 виртуалки терраформом в яндекс облаке
- 1 виртуалка - Nginx - с публичным IP адресом
- 2 виртуалки - бэкенд на выбор студента (любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java) + nginx со статикой
- 1 виртуалкой с БД на выбор mysql/mongodb/postgres/redis.
- репозиторий в github: README, схема, манифесты терраформ и ансибл
- стенд должен разворачиваться с помощью terraform и ansible
- при отказе (выключение) виртуалки с бекендом система должна продолжать работать

#### Описание/Пошаговая инструкция выполнения домашнего задания:
В работе должны применяться:
- terraform
- ansible
- nginx;
- uwsgi/unicorn/php-fpm;
- некластеризованная бд mysql/mongodb/postgres/redis.-

### Выполнение домашнего задания

#### Создание стенда

Получаем OAUTH токен:
```
https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
```
Настраиваем аутентификации в консоли:
```
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_yc_token=$YC_TOKEN
```

Сервер loadbalancer-1 будет служить балансировщиком для распределения пакетов между серверами backend-1 и backend-2. 
Для балансировки на сервере loadbalancer-1 будет использоватья приложение Nginx. 
Балансировку настроим в режиме Robin Round, с максимальном количеством ошибок - 2, и timeout - 10 секунд:
```
upstream backend {
        server {{ ip_address['backend-1'] }}:80 max_fails=2 fail_timeout=10s;
        server {{ ip_address['backend-2'] }}:80 max_fails=2 fail_timeout=10s;
}
```
Для проверки работы балансировщика loadbalancer-1 воспользуемся отображением в браузере веб-страниц, размещённых на серверах backend-1 и backend-2, где установлены php-fpm. 
Для хранения баз данных будет использоваться сервер database-1, но котором установлено приложение Percona server для MySQL.

На всех серверах будут использоваться ОС Debian 11.

Чтобы развернуть данную инфраструктуры запустим следующую команду:
```

Получим запущенные виртуальные машины:

<img src="pics/screen-001.png" alt="screen-001.png" />

После запуска предыдущей команды terraform автоматически сгенерировал inventory файл, 
который понадобится для последующего запуска команды ansible:
```
cat ./inventory.ini
```
```
[all]
loadbalancer-1 ansible_host=158.160.3.21
backend-1 ansible_host=158.160.71.187
backend-2 ansible_host=51.250.20.114
database-1 ansible_host=158.160.74.82

[loadbalancers]
loadbalancer-1

[backends]
backend-1
backend-2

[databases]
database-1
```
Далее для настройки этих виртуальных машин запустим ansible-playbook :
Ждем какое то время - потому как мгновенно все не поднимается, а для отладки  sleep не нравится, 
поэтому ручками...

```
ansible-playbook -u debian --private-key ~/.ssh/id_rsa -b ./provision.yml

```

Дл проверки работы балансировщика воспользуемся отображением простой страницы  созданного добрым человеком сайта на PHP, 
имитирующий продажу новых и подержанных автомобилей:

<img src="pics/screen-002.png" alt="screen-002.png" />

При напонении сайта данные будут размещаться на сервере database-1. На данном сервере установлено приложение MySQL от Percona.
Заранее создана база данных 'cars', в котором созданы таблицы 'new' и 'used', имитирующие списки соответственно новых и подержанных автомобилей.

Начнём наполнять этот сайт:

<img src="pics/screen-003.png" alt="screen-003.png" />

<img src="pics/screen-004.png" alt="screen-004.png" />

Отключим одну виртуальную машину, например, backend-1:

<img src="pics/screen-005.png" alt="screen-005.png" />

<img src="pics/screen-006.png" alt="screen-006.png" />

Обновим страницу:

<img src="pics/screen-007.png" alt="screen-007.png" />

Продолжим наполнять сайт:

<img src="pics/screen-008.png" alt="screen-008.png" />

<img src="pics/screen-009.png" alt="screen-009.png" />

Запустим сервер backend-1:

<img src="pics/screen-010.png" alt="screen-010.png" />

и остановим сервер backend-2:

<img src="pics/screen-011.png" alt="screen-011.png" />

<img src="pics/screen-012.png" alt="screen-012.png" />

Снова наполняем сайт:

<img src="pics/screen-013.png" alt="screen-013.png" />

<img src="pics/screen-014.png" alt="screen-014.png" />

Как видим, сайт работает при отключении одного из backend-серверов.

По ssh подключимся к серверу database-1:
```
ssh -i ~/.ssh/otus debian@158.160.74.82
```
чтобы проверить наличие заполненных таблиц MySQL new и used в базе данных cars:
```

```
Как видим, таблицы заполнены.

Убеждаемся, что балансировщик loadbalancer-1 корректно выполняет свою функцию при отключении одного из backend-серверов.



### Удаление стенда

Удалить развернутый стенд командой:
```
terraform destroy -auto-approve
```