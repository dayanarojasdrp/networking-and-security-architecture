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
2: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 4a:74:c8:22:f1:c3 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 5e:3f:37:e7:45:55 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.20.0.2/24 brd 172.20.0.255 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 16:49:50:bd:67:ea brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.0.2/28 brd 192.168.0.15 scope global eth2
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
2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 6e:b7:8d:be:84:e8 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.21.0.3/24 brd 172.21.0.255 scope global eth0
       valid_lft forever preferred_lft forever
3: eth1@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether da:cc:b3:d6:92:e2 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.0.3/28 brd 192.168.0.15 scope global eth1
       valid_lft forever preferred_lft forever
/ # 

```
