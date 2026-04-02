#!/bin/bash

set -e

echo "Configuring routing..."

# Enable IP forwarding

docker exec R1 sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
docker exec R2 sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# R1 routes

docker exec R1 ip route add 172.21.0.0/24 via 192.168.0.3

# R2 routes

docker exec R2 ip route add default via 192.168.0.2
docker exec R2 ip route add 172.20.0.0/24 via 192.168.0.2
docker exec R2 ip route add 10.0.0.0/24 via 192.168.0.2

echo "Routing configured."
