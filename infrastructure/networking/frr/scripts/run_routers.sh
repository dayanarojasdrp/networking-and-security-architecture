#!/bin/bash

 docker run -dit \
--name R1 \
--privileged \
--network lan_net \
--ip 172.20.0.2 \
alpine sh




docker run -dit \
--name R2 \
--privileged \
--network router_net \
--ip 192.168.0.3 \
alpine sh
