# Subnet Design

The network is divided into multiple subnets based on functionality.

## Networks

* 192.168.0.0/28 → Inter-router communication
* 172.20.0.0/24 → LAN network
* 172.21.0.0/24 → Application network

## Design Decisions

* /24 used for simplicity and scalability
* /28 used for point-to-point router connection
* Separation of networks improves isolation and security
