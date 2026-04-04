#!/bin/bash


docker exec R1 ping -c 2 8.8.8.8 

docker run --rm --network app_net alpine ping -c 2 8.8.8.8 

docker run --rm --network lan_net alpine ping -c 2 8.8.8.8 
