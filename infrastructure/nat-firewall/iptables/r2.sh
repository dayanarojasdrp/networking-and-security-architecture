#!/bin/sh

# R2 - Security edge router
# Interfaces:
# eth0 -> app_net: 172.21.0.3/24
# eth1 -> transit network to R1: 192.168.0.3/28

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# Route back to LAN through R1
ip route replace 172.20.0.0/24 via 192.168.0.2 dev eth1

# Default forwarding policy: block everything unless explicitly allowed
iptables -P FORWARD DROP

# Allow return traffic for established connections
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow LAN clients to reach the Nginx entry point over HTTP
iptables -A FORWARD \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 80 \
  -j ACCEPT

# Allow LAN clients to reach the Nginx entry point over HTTPS
iptables -A FORWARD \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j ACCEPT

# Block direct access from LAN to Kubernetes NodePort
iptables -A FORWARD \
  -s 172.20.0.0/24 \
  -d 172.21.0.2 \
  -p tcp \
  --dport 30528 \
  -j DROP

# SNAT for HTTP traffic to nginx-entry
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 80 \
  -j SNAT \
  --to-source 172.21.0.3

# SNAT for HTTPS traffic to nginx-entry
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j SNAT \
  --to-source 172.21.0.3

echo "R2 configured: forwarding, route to LAN, firewall rules, and SNAT enabled."
