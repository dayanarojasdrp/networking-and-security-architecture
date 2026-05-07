# Subnet Plan

This document describes the network segmentation used in the lab environment.

The goal of the subnet design was to separate:

* client traffic
* application traffic
* router transit traffic

instead of placing everything in a single flat network.

---

# Network Overview

| Network         | CIDR           | Purpose                                        |
| --------------- | -------------- | ---------------------------------------------- |
| LAN network     | 172.20.0.0/24  | Client-side network                            |
| app_net         | 172.21.0.0/24  | Application network                            |
| transit network | 192.168.0.0/28 | Point-to-point communication between R1 and R2 |

---

# LAN Network

```txt
172.20.0.0/24
```

Purpose:

* simulate internal client devices
* source network for application requests
* isolated from the application layer

Traffic from this network must pass through:

* R1
* R2 firewall/NAT

before reaching the application environment.

---

# Application Network

```txt
172.21.0.0/24
```

Purpose:

* host nginx-entry
* host Kubernetes exposure layer
* isolate application traffic from the LAN network

This network contains:

* nginx-entry
* Kubernetes frontend exposure path

Direct LAN access to Kubernetes services is intentionally restricted.

---

# Transit Network

```txt
192.168.0.0/28
```

Purpose:

* communication between R1 and R2
* routing exchange between the LAN side and application side

This network acts as the routing link between both routers.

---

# Design Philosophy

The network segmentation was intentionally simple but layered.

The objective was to understand:

* routing behavior
* firewall control
* NAT
* segmented traffic flow
* controlled entry points

instead of placing all containers in the same Docker network.

---

# Final Traffic Flow

```txt
LAN Client
→ R1
→ R2
→ nginx-entry
→ Kubernetes
→ backend
→ postgres
```

This structure allowed the lab to simulate:

* internal networks
* protected application networks
* centralized entry points
* firewall enforcement
* cloud-style segmentation concepts
