#!/bin/bash

set -e

echo "Running connectivity tests..."

echo "Test: R1 -> Internet"
docker exec R1 ping -c 2 8.8.8.8 || true

echo "Test: R2 -> Internet"
docker exec R2 ping -c 2 8.8.8.8 || true

echo "Test: APP -> Internet"
docker run --rm --network app_net alpine ping -c 2 8.8.8.8 || true

echo "Test: APP -> LAN (should fail)"
docker run --rm --network app_net alpine ping -c 2 172.20.0.1 || true

echo "Test: LAN -> APP (should fail)"
docker run --rm --network lan_net alpine ping -c 2 172.21.0.1 || true

echo "Tests completed."
