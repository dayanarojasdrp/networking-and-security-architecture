#!/bin/bash


docker exec R1 sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
docker exec R2 sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

