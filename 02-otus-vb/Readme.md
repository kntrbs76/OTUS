Домашнее задание

Реализация GFS2 хранилища на виртуалках под виртуалбокс
**Цель**:

развернуть в VirtualBox следующую конфигурацию с помощью terraform

Описание/Пошаговая инструкция выполнения домашнего задания:

- виртуалка с iscsi
- 3 виртуальные машины с разделяемой файловой системой GFS2 поверх cLVM
- должен быть настроен fencing для VirtualBox - https://github.com/ClusterLabs/fence-agents/tree/master/agents/vbox   


1. Предварительно настраиваем виртуальную сеть в virtualbox (vboxnet0) с DHCP сервером
2. 