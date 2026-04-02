#!/bin/bash

set -e

echo "Configuring firewall on R1..."

docker exec R1 sh -c "
iptables -F FORWARD

# Allow LAN -> Internet

iptables -A FORWARD -i eth3 -o eth1 -j ACCEPT

# Allow APP -> Internet (via R2)

iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT

# Allow responses

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Block APP <-> LAN

iptables -A FORWARD -s 172.21.0.0/24 -d 172.20.0.0/24 -j DROP
iptables -A FORWARD -s 172.20.0.0/24 -d 172.21.0.0/24 -j DROP
"

echo "Firewall configured."
