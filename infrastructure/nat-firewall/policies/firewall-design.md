# Firewall Design

This document explains the firewall and NAT design used in the lab environment.

The main objective of the firewall layer was to control how traffic moves from the LAN network toward the Kubernetes application environment.

The design intentionally prevents clients from directly reaching Kubernetes services.

All allowed traffic must pass through the nginx-entry reverse proxy.

---

# Security Philosophy

The firewall design follows a simple principle:

```txt id="z03wkk"
deny by default, allow only what is required
```

Instead of exposing the entire application network, only specific traffic paths are permitted.

This makes the environment easier to understand and closer to a segmented infrastructure design.

---

# Network Overview

## Networks

| Network        | Purpose                           |
| -------------- | --------------------------------- |
| 172.20.0.0/24  | LAN network                       |
| 172.21.0.0/24  | Application network               |
| 192.168.0.0/28 | Transit network between R1 and R2 |

---

# Router Responsibilities

## R1 Responsibilities

R1 acts mainly as a routing device.

Responsibilities:

* LAN gateway
* route traffic toward R2
* maintain routes between LAN and app_net

R1 does not perform security filtering.

Its role is mostly Layer 3 routing.

---

## R2 Responsibilities

R2 acts as the security edge of the environment.

Responsibilities:

* firewall filtering
* NAT
* traffic control
* protecting app_net from direct LAN access

R2 decides which traffic is allowed into the application network.

This separation keeps:

* routing logic on R1
* security logic on R2

---

# Default DROP Philosophy

The FORWARD chain on R2 uses:

```txt id="3ovmnx"
policy DROP
```

This means:

* all forwarded traffic is blocked by default
* only explicitly allowed traffic passes through

This approach is safer than allowing everything and trying to block unwanted traffic later.

---

# Allowed Traffic

The firewall allows only:

* HTTP traffic to nginx-entry
* HTTPS traffic to nginx-entry
* established and related connections

Example allowed flows:

```txt id="br6zvb"
172.20.0.0/24
    ↓
172.21.0.4 TCP/80
```

```txt id="e7bq5x"
172.20.0.0/24
    ↓
172.21.0.4 TCP/443
```

Where:

```txt id="65r4g7"
172.21.0.4 = nginx-entry
```

---

# Why nginx-entry Is the Only Allowed Entry Point

The project intentionally forces all application traffic through nginx-entry.

nginx-entry performs:

* TLS termination
* reverse proxying
* centralized application access

This design provides:

* a single controlled entry point
* easier traffic inspection
* easier HTTPS management
* separation between clients and Kubernetes

---

# Intentionally Blocking Direct NodePort Access

The Kubernetes frontend NodePort:

```txt id="0j0o2q"
172.21.0.2:30528
```

was intentionally blocked from direct LAN access.

Validation test:

```bash
curl --connect-timeout 5 http://172.21.0.2:30528
```

Result:

```txt id="d5v5f4"
curl: (28) Connection timeout after 5001 ms
```

This confirms that clients cannot bypass nginx-entry.

The only valid path is:

```txt id="k94dhq"
LAN
→ R1
→ R2
→ nginx-entry
→ Kubernetes
```

---

# SNAT Design

Initially, LAN traffic could reach nginx-entry, but responses did not return correctly.

The reason was that nginx-entry did not know how to route traffic back toward the LAN network.

To solve this, SNAT was added on R2.

Example:

```bash
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j SNAT \
  --to-source 172.21.0.3
```

This makes nginx-entry see the traffic as coming from:

```txt id="xzyjuh"
172.21.0.3
```

instead of the original LAN client IP.

As a result:

* return traffic flows correctly
* nginx-entry remains isolated inside app_net
* no extra static routes were needed inside nginx-entry

---

# HTTPS Firewall Updates

When HTTPS was introduced, the firewall originally allowed only port 80.

Additional rules were required for TCP 443.

This demonstrated that firewall policies must always match the actual application traffic flow.

---

# Final Traffic Model

The final validated flow became:

```txt id="b4f8co"
LAN client
→ R1
→ R2 firewall/NAT
→ nginx-entry HTTPS
→ Kubernetes frontend
→ backend
→ postgres
```

This architecture successfully demonstrates:

* segmented networking
* controlled entry points
* firewall filtering
* NAT
* TLS termination
* reverse proxying
* internal Kubernetes service isolation

