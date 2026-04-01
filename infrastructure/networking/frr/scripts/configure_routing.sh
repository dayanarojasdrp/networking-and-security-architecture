#!/bin/bash

# R1 rutas
docker exec -it R1 vtysh -c "conf t" \
  -c "ip route 172.21.0.0/24 192.168.0.4" \
  -c "end" \
  -c "write"

# R2 rutas
docker exec -it R2 vtysh -c "conf t" \
  -c "ip route 0.0.0.0/0 192.168.0.2" \
  -c "end" \
  -c "write"
