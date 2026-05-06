#!/bin/sh

# R1 - LAN router
# Interfaces:
# eth0 -> Docker default bridge / external Docker network: 172.17.0.2/16
# eth1 -> LAN network: 172.20.0.2/24
# eth2 -> Transit network to R2: 192.168.0.2/28

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# Route to app_net through R2
ip route replace 172.21.0.0/24 via 192.168.0.3 dev eth2

# R1 does not apply firewall filtering in this lab.
# Security enforcement is handled by R2.

echo "R1 configured: forwarding enabled and route to app_net added."
