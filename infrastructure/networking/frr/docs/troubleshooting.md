# Troubleshooting (Updated)

## Overview

This section documents the main issues encountered during the implementation of the network lab, along with their root causes and solutions.

The troubleshooting process was essential to understand how Docker networking, routing, NAT, and firewall rules interact in a real environment.

---

## Issue 1 — No Connectivity Between Networks

### Cause

* Incorrect or missing routes between R1 and R2
* Containers attempting to reach non-existent or wrong IP addresses
* Networks created with conflicting or reused subnets

### Solution

* Verified IP addressing using:

```bash
ip a
ip route
```

* Ensured correct static routes:

```bash
# R1
ip route add 172.21.0.0/24 via 192.168.0.3

# R2
ip route add default via 192.168.0.2
```

* Recreated Docker networks with clean subnets when conflicts occurred

---

## Issue 2 — Routing Not Working Properly

### Cause

* Incorrect default route configuration on R1
* R1 pointing to the wrong interface instead of Docker bridge

### Solution

* Verified correct default route on R1:

```bash
ip route
```

* Ensured R1 uses Docker bridge as internet gateway:

```bash
ip route add default via 172.17.0.1
```

---

## Issue 3 — Packets Not Forwarding

### Cause

* IP forwarding disabled inside router containers

### Solution

Enabled IP forwarding:

```bash
sysctl -w net.ipv4.ip_forward=1
```

✔ Required for routers to behave like actual network devices

---

## Issue 4 — No Internet Access from Internal Networks

### Cause

* NAT (MASQUERADE) not configured on R1
* Traffic leaving private networks without translation

### Solution

Configured NAT on R1:

```bash
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
```

✔ eth2 corresponds to the external interface (Docker bridge)

---

## Issue 5 — Containers Could Not Reach Router

### Cause

* Docker host firewall (FORWARD chain) blocking traffic
* Default policy set to DROP

### Solution

On the host machine:

```bash
sudo iptables -P FORWARD ACCEPT
```

✔ Allowed inter-container traffic across bridges

---

## Issue 6 — Docker Network Conflicts

### Cause

* Subnets already in use by previous Docker networks
* Recreating networks without cleanup

### Solution

Performed full cleanup:

```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker network rm lan_net app_net router_net
```

Restarted Docker:

```bash
sudo systemctl restart docker
```

Recreated networks with clean state

---

## Issue 7 — Configuration Lost After Container Restart

### Cause

* Manual configuration inside containers is ephemeral
* Changes are not persisted after exit

### Solution

Two possible approaches:

1. Reapply configuration manually (temporary)
2. Automate configuration using startup scripts (recommended)

Example:

```bash
#!/bin/sh

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
```

---

## Key Lessons Learned

* Docker networking adds an additional abstraction layer that affects routing and NAT
* Routing, firewall, and NAT must be aligned simultaneously
* Debugging requires validating:

  * Interfaces (`ip a`)
  * Routes (`ip route`)
  * Firewall rules (`iptables`)
* The host system (VM) can also block traffic

---

## Summary

| Issue             | Root Cause           | Solution           |
| ----------------- | -------------------- | ------------------ |
| No connectivity   | Wrong routes / IPs   | Fix static routing |
| Routing failure   | Bad default route    | Correct gateway    |
| No forwarding     | IP forwarding off    | Enable sysctl      |
| No internet       | Missing NAT          | Add MASQUERADE     |
| Blocked traffic   | Host firewall        | Allow FORWARD      |
| Network conflicts | Docker reuse         | Clean networks     |
| Config loss       | Ephemeral containers | Automate setup     |

---

