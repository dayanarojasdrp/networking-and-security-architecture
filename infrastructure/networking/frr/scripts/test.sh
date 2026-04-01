#!/bin/bash

docker run -it --rm --network app_net alpine sh -c "ping -c 3 8.8.8.8"
