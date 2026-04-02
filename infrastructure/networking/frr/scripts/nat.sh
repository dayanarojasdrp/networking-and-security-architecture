#!/bin/bash

set -e

echo "Configuring NAT on R1..."

docker exec R1 sh -c "
apk add --no-cache iptables >/dev/null 2>&1 || true

iptables -t nat -F

iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
"

echo "NAT configured."
