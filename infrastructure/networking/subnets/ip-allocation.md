R1:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth1@if154: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether d2:80:b1:57:53:dc brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.2/24 brd 10.0.0.255 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2@if155: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 0e:00:7b:60:80:89 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.2/28 brd 192.168.0.15 scope global eth2
       valid_lft forever preferred_lft forever
5: eth3@if156: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether be:78:8b:e5:c1:ed brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.1/24 brd 172.20.0.255 scope global eth3
       valid_lft forever preferred_lft forever
```
R2:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth1@if158: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 32:d6:11:aa:bc:d9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.3/28 brd 192.168.0.15 scope global eth1
       valid_lft forever preferred_lft forever
4: eth2@if159: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP 
    link/ether 6e:5c:af:93:8e:81 brd ff:ff:ff:ff:ff:ff
    inet 172.21.0.1/24 brd 172.21.0.255 scope global eth2
       valid_lft forever preferred_lft forever
```
