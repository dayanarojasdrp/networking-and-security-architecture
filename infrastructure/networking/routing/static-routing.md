# Static Routing

Routing is configured manually using static routes.

## R1 Routes

* Route to 172.21.0.0/24 via R2 (192.168.0.4)

## R2 Routes

* Default route to R1 (192.168.0.2)

## Explanation

R2 sends all unknown traffic to R1.
R1 performs NAT and forwards traffic to external networks.
