#!/bin/bash

set -e

echo "Creating Docker networks..."

docker network create --subnet 10.0.0.0/24 internet_net || true
docker network create --subnet 192.168.0.0/28 inter_router_net || true
docker network create --subnet 172.20.0.0/24 lan_net || true
docker network create --subnet 172.21.0.0/24 app_net || true

echo "Networks created."
