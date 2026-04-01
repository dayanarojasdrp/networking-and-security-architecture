#!/bin/bash

docker exec R1 sh -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
