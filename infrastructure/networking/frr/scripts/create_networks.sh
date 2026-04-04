#!/bin/bash

docker network create --subnet 172.20.0.0/24 lan_net
docker network create --subnet 172.21.0.0/24 app_net
docker network create --subnet 192.168.0.0/28 router_net
