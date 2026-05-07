# Static Routing

This document explains the static routing configuration used in the lab environment.

The routing design was intentionally kept simple in order to clearly understand how packets move between:

* the LAN network
* the transit network
* the application network

before introducing more advanced routing concepts.

---

# Network Overview

| Network         | CIDR           | Purpose                        |
| --------------- | -------------- | ------------------------------ |
| LAN network     | 172.20.0.0/24  | Client-side network            |
| app_net         | 172.21.0.0/24  | Application network            |
| transit network | 192.168.0.0/28 | Router-to-router communication |

---

# Router Topology

```txt id="x2l8j9"
LAN Client
    ↓
R1
    ↓
Transit Network
    ↓
R2
    ↓
app_net
    ↓
nginx-entry / Kubernetes
```

---

# R1 Routing

R1 is connected to:

* the LAN network
* the transit network

Interfaces:

| Interface | Address     |
| --------- | ----------- |
| eth1      | 172.20.0.2  |
| eth2      | 192.168.0.2 |

R1 must know how to reach the application network:

```txt id="r5f9qy"
172.21.0.0/24
```

through R2.

Static route configured on R1:

```bash
ip route add 172.21.0.0/24 via 192.168.0.3
```

This tells R1:

```txt id="2y9o0j"
To reach app_net, forward traffic to R2.
```

---

# R2 Routing

R2 is connected to:

* the application network
* the transit network

Interfaces:

| Interface | Address     |
| --------- | ----------- |
| eth0      | 172.21.0.3  |
| eth1      | 192.168.0.3 |

R2 must know how to return traffic toward the LAN network:

```txt id="f0v69v"
172.20.0.0/24
```

through R1.

Static route configured on R2:

```bash
ip route add 172.20.0.0/24 via 192.168.0.2
```

This tells R2:

```txt id="4mj5i5"
To reach the LAN network, forward traffic to R1.
```

---

# Why Static Routing Was Used

Static routing was chosen because:

* the topology is small
* the environment is controlled
* the objective was to understand packet flow clearly

Using static routes made troubleshooting easier during:

* firewall testing
* NAT debugging
* HTTPS validation
* Kubernetes connectivity testing

---

# Interaction with Firewall and NAT

Routing alone was not enough for full connectivity.

Even after routes were working:

* HTTPS initially failed
* return traffic problems still existed

This happened because:

* R2 firewall rules were incomplete
* nginx-entry did not know how to return traffic to the LAN network

SNAT on R2 was later added to solve the return path issue.

This demonstrated an important lesson:

```txt id="a9kk9n"
successful routing does not automatically mean successful application communication
```

Firewall behavior and NAT must also be correct.

---

# Validation

Routing was validated through:

* ping tests
* curl requests
* Kubernetes service access
* HTTPS traffic flow

Successful validation example:

```bash
curl -k https://172.21.0.4/api
```

Response:

```json
{"status":"ok","backend":"running","database":"connected"}
```

This confirmed:

* R1 routing worked
* R2 routing worked
* return traffic worked
* firewall rules matched the intended flow

---

# Design Outcome

The final static routing setup successfully allowed:

```txt id="r0sq6x"
LAN
↔
R1
↔
R2
↔
app_net
↔
Kubernetes
```

while still maintaining:

* firewall control
* segmented networking
* controlled entry points
* HTTPS-only application exposure


