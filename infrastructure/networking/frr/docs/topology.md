# Topology

The lab consists of two routers (R1 and R2) connected through an internal network.

R1 acts as the edge router and provides NAT to external networks.

R2 connects the application network to R1.

Topology:

APP (172.21.0.0/24)
|
R2 (172.21.0.2 / 192.168.0.4)
|         
R1 (192.168.0.2 / 10.0.0.2)--------------------LAN
|                        172.21.0.2/24      ( 172.20.0.0/24)
Internet
 (10.0.0.0/24)
