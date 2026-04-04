R1:
```
dayarojas@linux-vm:~$ docker exec -it R1 sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: eth0@if383: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 4a:07:d8:0b:10:d4 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.20.0.2/24 brd 172.20.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1@if384: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 96:0b:de:bf:04:23 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.0.2/28 brd 192.168.0.15 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2@if385: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 2a:72:4c:11:2d:0b brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth2
       valid_lft forever preferred_lft forever
/ # 

```
R2:
```
dayarojas@linux-vm:~$ docker exec -it R2 sh
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: eth0@if406: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether da:73:8d:61:9e:51 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.0.3/28 brd 192.168.0.15 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1@if407: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 06:bd:69:e1:fc:c0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.21.0.2/24 brd 172.21.0.255 scope global eth1
       valid_lft forever preferred_lft forever
/ # 

```
