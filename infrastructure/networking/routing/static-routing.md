# Static Routing (Updated)

## Overview

Static routing is used in this lab to explicitly define how packets travel between network segments.

Each router is manually configured with routes that determine how to reach remote networks. This provides precise control over traffic flow and is ideal for a controlled lab environment.

---

## Why Static Routing?

Static routing is used because:

* The topology is small and deterministic
* Full control over traffic paths is required
* It simplifies debugging during network construction
* It avoids the complexity of dynamic protocols (e.g., OSPF, BGP)

---

## Network Topology

| Network      | CIDR           | Location                               |
| ------------ | -------------- | -------------------------------------- |
| Internet     | 172.17.0.0/16  | Docker bridge (external access via R1) |
| Inter-router | 192.168.0.0/28 | R1 ↔ R2                                |
| LAN          | 172.20.0.0/24  | Connected to R1                        |
| App Network  | 172.21.0.0/24  | Connected to R2                        |

---

## Routing Design

### R1 — Main Router (NAT Gateway)

R1 is the central router and acts as:

* Gateway to the internet (via Docker bridge)
* Router for LAN
* Transit router for App Network traffic

#### Routes configured:

* Default route → Docker bridge (internet)
* Route to App Network → via R2

```bash
ip route add 172.21.0.0/24 via 192.168.0.3
```

---

### R2 — Internal Router

R2 connects the App Network with the rest of the infrastructure.

All external communication must go through R1.

#### Routes configured:

* Default route → R1
* Route to LAN → via R1

```bash
ip route add default via 192.168.0.2
ip route add 172.20.0.0/24 via 192.168.0.2
```

---

## How Routing Works

### Example 1 — App → Internet

1. App container sends traffic (172.21.0.x)
2. Packet goes to R2 (default gateway)
3. R2 forwards to R1 (192.168.0.2)
4. R1 forwards traffic to Docker bridge (internet)
5. NAT is applied on R1
6. Response returns through the same path

---

### Example 2 — LAN → Internet

1. LAN host sends traffic (172.20.0.x)
2. Packet goes directly to R1
3. R1 forwards to internet via Docker bridge
4. NAT is applied
5. Response returns to R1 and back to LAN

---

### Example 3 — App → LAN

1. App sends traffic to LAN
2. R2 forwards packet to R1
3. R1 identifies LAN as directly connected
4. Packet is forwarded to LAN (if firewall allows)

---

## Important Notes

* Routing must exist in **both directions** for communication to work
* Missing routes = unreachable networks
* Routing does NOT guarantee access → firewall rules still apply
* R1 is the **only exit point** to the internet

---

## Key Concepts

### Routing

Defines **where packets go**

---

### Firewall

Defines **whether packets are allowed**

---

### NAT

Defines **how packets are translated externally**

---

## Design Insight

This routing model follows a real-world cloud pattern:

* R1 behaves like a **NAT Gateway**
* R2 behaves like an **internal routing layer**
* LAN and App networks behave like **private subnets**

---

## Summary

| Path            | Behavior         |
| --------------- | ---------------- |
| App → R2 → R1   | Routed correctly |
| LAN → R1        | Direct routing   |
| R2 → R1         | Default path     |
| Internet access | Only through R1  |

---

## Future Improvements

* Introduce dynamic routing (BGP with FRR)
* Add redundant paths (failover)
* Implement IPv6 (dual-stack routing)
* Integrate routing with Kubernetes networking

---

