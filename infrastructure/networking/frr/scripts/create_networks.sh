#!/bin/bash

docker network create --subnet 10.0.0.0/24 internet_net
docker network create --subnet 192.168.0.0/28 inter_router_net
docker network create --subnet 172.20.0.0/24 lan_net
docker network create --subnet 172.21.0.0/24 app_net
