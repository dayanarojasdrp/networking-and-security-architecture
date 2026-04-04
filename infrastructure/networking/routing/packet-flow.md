# Packet Flow Scenarios (Updated)

## Overview

This document describes how packets flow across the network in the current lab implementation.

The architecture simulates a segmented infrastructure using:

* Multi-router topology (R1 as NAT Gateway, R2 as internal router)
* Docker-based subnets
* Stateful firewall (iptables)
* Source NAT (MASQUERADE)

All outbound traffic is forced through R1, which acts as the security boundary.

---

## Network Summary

| Network      | CIDR           | Description                     |
| ------------ | -------------- | ------------------------------- |
| Internet     | 172.17.0.0/16  | Docker bridge (external access) |
| Inter-router | 192.168.0.0/28 | R1 ↔ R2 communication           |
| LAN          | 172.20.0.0/24  | Internal LAN                    |
| App Network  | 172.21.0.0/24  | Application network             |

---

## Architecture Roles

| Component | Role                          |
| --------- | ----------------------------- |
| R1        | NAT Gateway + Firewall        |
| R2        | Internal router (App network) |
| LAN       | Internal clients              |
| APP       | Application subnet            |

---

## Scenario 1 — App → Internet

### Flow

1. App container (172.21.0.x) sends traffic
2. Default gateway → R2 (172.21.0.2)
3. R2 forwards traffic to R1 (192.168.0.2)
4. R1 evaluates firewall rules
5. Traffic is allowed (APP → Internet permitted)
6. R1 applies NAT (MASQUERADE on eth2)
7. Packet exits via Docker bridge (172.17.0.0/16)
8. Response returns to R1
9. R1 matches connection tracking (ESTABLISHED, RELATED)
10. Packet is forwarded back to R2
11. R2 delivers packet to App container

### Result

✔ Allowed
✔ NAT applied at R1
✔ Fully functional outbound connectivity

---

## Scenario 2 — LAN → Internet

### Flow

1. LAN host (172.20.0.x) sends traffic
2. Default gateway → R1 (172.20.0.2)
3. R1 evaluates firewall rules
4. Traffic is allowed (LAN → Internet permitted)
5. R1 applies NAT (MASQUERADE)
6. Packet exits via eth2 (Docker bridge)
7. Response returns to R1
8. R1 forwards response back to LAN

### Result

✔ Allowed
✔ NAT applied
✔ Direct outbound access

---

## Scenario 3 — App → LAN (Blocked)

### Flow

1. App container sends traffic to LAN (172.20.0.0/24)
2. Packet reaches R2
3. R2 forwards to R1
4. R1 evaluates firewall rules
5. Explicit DROP rule matches
6. Packet is discarded

### Result

 Blocked
 No lateral movement
 Network segmentation enforced

---

## Scenario 4 — LAN → App (Blocked)

### Flow

1. LAN host sends traffic to App Network
2. Packet reaches R1
3. Firewall rules are evaluated
4. DROP rule matches
5. Packet is discarded

### Result

 Blocked
 Isolation between subnets

---

## Scenario 5 — R2 → Internet (Current Behavior)

### Flow

1. R2 generates traffic (e.g., ping 8.8.8.8)
2. Packet is sent to R1 (default route)
3. Traffic is evaluated by firewall

### Current Behavior

 Not allowed by design

### Explanation

* Firewall rules are focused on forwarding traffic from internal networks
* R2 is not intended to act as an internet client
* The architecture enforces that only internal networks (LAN / APP) access external resources

### Result

 No direct internet access from R2
 Consistent with secure network design

---

## Scenario 6 — Return Traffic Handling

### Flow

1. Internal host initiates connection

2. External system responds

3. Packet arrives at R1

4. Connection tracking module evaluates state:

   * ESTABLISHED
   * RELATED

5. Packet is automatically allowed

6. Traffic is forwarded back to origin

### Result

 No explicit rule required
 Stateful firewall behavior

---

## Key Concepts

### NAT (MASQUERADE)

* Implemented on R1 (eth2)
* Translates private IPs to external interface
* Required for outbound internet access

---

### Stateful Firewall

* Based on connection tracking
* Allows return traffic automatically
* Prevents unsolicited inbound connections

---

### Network Segmentation

* LAN and APP networks are isolated
* No lateral movement allowed
* Enforced via DROP rules in FORWARD chain

---

### Controlled Egress

* Only approved subnets can access internet
* Traffic must pass through R1

---

## Summary

| Scenario       | Result               |
| -------------- | -------------------- |
| App → Internet |  Allowed             |
| LAN → Internet |  Allowed             |
| R2 → Internet  |  Blocked (by design) |
| App → LAN      |  Blocked             |
| LAN → App      |  Blocked             |

---

## Architectural Insight

This lab simulates a real cloud design pattern:

* Private subnets (APP, LAN)
* NAT Gateway (R1)
* Internal routing layer (R2)
* Stateful firewall enforcement

---

## Future Enhancements

* IPv6 (no NAT required)
* Dual-stack implementation
* Layer 7 filtering (Nginx)
* Kubernetes network policies

---

