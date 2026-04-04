#!/bin/sh


sysctl -w net.ipv4.ip_forward=1

iptables -F
iptables -t nat -F

iptables -P FORWARD DROP

iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

iptables -A FORWARD -s 172.20.0.0/24 -o eth2 -j ACCEPT
iptables -A FORWARD -d 172.20.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -s 172.21.0.0/24 -o eth2 -j ACCEPT
iptables -A FORWARD -d 172.21.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -s 172.20.0.0/24 -d 172.21.0.0/24 -j DROP
iptables -A FORWARD -s 172.21.0.0/24 -d 172.20.0.0/24 -j DROP
