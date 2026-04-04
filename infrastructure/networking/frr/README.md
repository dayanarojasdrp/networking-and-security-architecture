# Routing Configuration (FRR-Ready Design)

## Overview

This section defines the routing configuration of the lab environment.

Currently, routing is implemented using **static routes (Linux networking)**.
However, the design is prepared to later integrate **FRR (Free Range Routing)** to simulate dynamic routing protocols such as BGP.

The goal is to replicate a real-world network with multiple subnets, controlled traffic flow, and a centralized routing architecture.

---

## Network Topology

The lab is composed of two routers:

* **R1** → Main router (NAT Gateway + Internet access)
* **R2** → Internal router (connects Application Network to R1)

---

## Subnets

| Network          | CIDR           | Description                     |
| ---------------- | -------------- | ------------------------------- |
| Internet Network | 172.17.0.0/16  | Docker bridge (external access) |
| Inter-router     | 192.168.0.0/28 | R1 ↔ R2 communication           |
| LAN Network      | 172.20.0.0/24  | Internal LAN                    |
| App Network      | 172.21.0.0/24  | Application network             |

---

## Network Roles

### R1 Interfaces

| Interface | Network        | Role                     |
| --------- | -------------- | ------------------------ |
| eth2      | 172.17.0.0/16  | Internet (Docker bridge) |
| eth1      | 192.168.0.0/28 | Connection to R2         |
| eth0      | 172.20.0.0/24  | LAN network              |

---

### R2 Interfaces

| Interface | Network        | Role                |
| --------- | -------------- | ------------------- |
| eth0      | 192.168.0.0/28 | Connection to R1    |
| eth1      | 172.21.0.0/24  | Application network |

---

## Routing Strategy

### R1 — Main Router

R1 is responsible for:

* Acting as **default gateway to the internet**
* Routing traffic between LAN and App networks
* Performing NAT (MASQUERADE)

#### Routes

* Default route → Docker bridge:

```bash
ip route add default via 172.17.0.1
```

* Route to App Network → via R2:

```bash
ip route add 172.21.0.0/24 via 192.168.0.3
```

---

### R2 — Internal Router

R2 is responsible for:

* Routing App Network traffic
* Forwarding all external traffic to R1

#### Routes

```bash
ip route add default via 192.168.0.2
ip route add 172.20.0.0/24 via 192.168.0.2
```

---

## Packet Flow

### App → Internet

1. App container sends traffic to R2
2. R2 forwards to R1
3. R1 applies NAT
4. Traffic exits via Docker bridge
5. Response returns through R1 → R2 → App

---

### LAN → Internet

1. LAN sends traffic directly to R1
2. R1 applies NAT
3. Traffic exits to internet
4. Response returns to LAN

---

### App → LAN (Blocked)

* Traffic reaches R1 via R2
* Firewall rules drop the packet
* Network segmentation is enforced

---

## Notes

* Routing is currently **static (Linux-based)**
* NAT is applied **only on R1**
* Firewall rules control **inter-network access**
* Interface naming depends on Docker network attachment order

---

## FRR Integration (Future Phase)

This architecture is designed to support **FRR (Free Range Routing)** in a future phase.

Planned improvements:

* Replace static routes with **BGP (FRR)**
* Simulate real internet routing behavior
* Enable dynamic route propagation between routers

---

## Future Improvements

* Introduce FRR with BGP
* Add IPv6 (dual-stack networking)
* Implement advanced routing policies
* Integrate with Kubernetes networking layer

---
