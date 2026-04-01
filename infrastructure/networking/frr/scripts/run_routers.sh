#!/bin/bash

# R1
docker run -d --name R1 --privileged \
  --network internet_net --ip 10.0.0.2 \
  quay.io/frrouting/frr:8.5.2

docker network connect --ip 192.168.0.2 inter_router_net R1
docker network connect --ip 172.20.0.2 lan_net R1

# R2
docker run -d --name R2 --privileged \
  --network inter_router_net --ip 192.168.0.4 \
  quay.io/frrouting/frr:8.5.2

docker network connect --ip 172.21.0.2 app_net R2
