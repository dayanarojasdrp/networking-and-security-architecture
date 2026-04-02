#!/bin/bash

set -e

echo "Starting routers..."

# Remove existing containers if they exist

docker rm -f R1 R2 2>/dev/null || true

# R1

docker run -d --name R1 
--network internet_net --ip 10.0.0.2 
--privileged 
alpine sleep infinity

docker network connect --ip 192.168.0.2 inter_router_net R1
docker network connect --ip 172.20.0.1 lan_net R1

# R2

docker run -d --name R2 
--network inter_router_net --ip 192.168.0.3 
--privileged 
alpine sleep infinity

docker network connect --ip 172.21.0.1 app_net R2

echo "Routers started."
