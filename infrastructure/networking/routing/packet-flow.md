# Packet Flow Scenarios

##  Overview

This document describes how packets travel across the network under different scenarios.

The lab simulates a segmented infrastructure with controlled communication between networks using routing, NAT, and firewall rules.

---

##  Network Summary

| Network      | CIDR           | Description         |
| ------------ | -------------- | ------------------- |
| Internet     | 10.0.0.0/24    | External network    |
| Inter-router | 192.168.0.0/28 | R1 ↔ R2 connection  |
| LAN          | 172.20.0.0/24  | Internal LAN        |
| App Network  | 172.21.0.0/24  | Application network |

---

##  Scenario 1 — App → Internet

### Flow

1. A container in the App Network (172.21.0.0/24) sends traffic
2. Packet goes to R2 (default gateway)
3. R2 forwards packet to R1 via inter-router network
4. R1 receives packet and checks firewall rules
5. Traffic is allowed (APP → Internet permitted)
6. R1 applies NAT (MASQUERADE)
7. Packet exits to the Internet (10.0.0.0/24)
8. Response returns to R1
9. R1 matches connection (RELATED, ESTABLISHED)
10. Packet is forwarded back to R2
11. R2 delivers packet to the App container

### Result

 Allowed
 NAT applied
 Fully functional outbound connectivity

---

##  Scenario 2 — LAN → Internet

### Flow

1. A host in the LAN (172.20.0.0/24) sends traffic
2. Packet goes directly to R1
3. R1 checks firewall rules
4. Traffic is allowed (LAN → Internet permitted)
5. R1 applies NAT (MASQUERADE)
6. Packet exits to the Internet
7. Response returns to R1
8. R1 forwards response back to LAN

### Result

 Allowed
 NAT applied
 Direct internet access

---

##  Scenario 3 — App → LAN (Blocked)

### Flow

1. App container sends packet to LAN (172.20.0.0/24)
2. Packet reaches R2
3. R2 forwards to R1
4. R1 evaluates firewall rules
5. Matching DROP rule is found
6. Packet is discarded

### Result

 Blocked by firewall
 No communication allowed

---

##  Scenario 4 — LAN → App (Blocked)

### Flow

1. LAN host sends packet to App Network
2. Packet reaches R1
3. Firewall rules are evaluated
4. DROP rule is matched
5. Packet is discarded

### Result

 Blocked by firewall
 Segmentation enforced

---

##  Scenario 5 — R2 → Internet

### Flow

1. R2 sends traffic (e.g., ping 8.8.8.8)
2. Packet is forwarded to R1 (default route)
3. R1 checks firewall rules
4. Traffic is allowed (inter-router → internet)
5. R1 applies NAT
6. Packet exits to internet
7. Response returns to R1
8. R1 forwards response back to R2

### Result

 Allowed
 NAT applied
 Router connectivity verified

---

##  Scenario 6 — Return Traffic Handling

### Flow

1. Internal host initiates connection
2. External server responds
3. Packet arrives at R1
4. R1 matches connection tracking state:

   * RELATED
   * ESTABLISHED
5. Packet is allowed automatically

### Result

 Allowed without explicit rule
 Connection tracking ensures responses

---

##  Key Concepts

### NAT (MASQUERADE)

* Translates private IPs into public IP (R1)
* Required for IPv4 internet access

---

### FORWARD Chain

* Controls traffic passing through routers
* Determines which networks can communicate

---

### Stateful Firewall

* Uses connection tracking
* Allows return traffic automatically

---

### Network Segmentation

* Prevents lateral movement
* Enforces isolation between LAN and App Network

---

##  Summary

| Scenario       | Result   |
| -------------- | -------- |
| App → Internet |  Allowed |
| LAN → Internet |  Allowed |
| R2 → Internet  |  Allowed |
| App → LAN      |  Blocked |
| LAN → App      |  Blocked |

---

##  Future Enhancements

* IPv6 packet flow (no NAT)
* Dual-stack behavior comparison
* Advanced firewall policies (L7 filtering)

---
