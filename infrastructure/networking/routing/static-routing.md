# Static Routing

##  Overview

Static routing is used in this lab to define how packets move between different network segments.

Each router is manually configured with specific routes to reach remote networks. This approach provides full control over traffic flow and is ideal for small and controlled environments.

---

##  Why Static Routing?

Static routing was chosen for this lab because:

* The network topology is simple and predictable
* Full control over routing decisions is required
* It avoids the complexity of dynamic routing protocols (e.g., OSPF, BGP)

---

##  Network Topology

| Network      | CIDR           | Location |
| ------------ | -------------- | -------- |
| Internet     | 10.0.0.0/24    | R1       |
| Inter-router | 192.168.0.0/28 | R1 ↔ R2  |
| LAN          | 172.20.0.0/24  | R1       |
| App Network  | 172.21.0.0/24  | R2       |

---

##  Routing Design

### R1 (Main Router)

R1 connects all networks and acts as the gateway to the internet.

#### Routes configured:

* Default route → Internet gateway
* Route to App Network → via R2

```bash
ip route add 172.21.0.0/24 via 192.168.0.3
```

---

### R2 (Internal Router)

R2 connects the App Network to the rest of the infrastructure.

#### Routes configured:

* Default route → R1
* Route to LAN → via R1
* Route to Internet → via R1

```bash
ip route add default via 192.168.0.2
ip route add 172.20.0.0/24 via 192.168.0.2
ip route add 10.0.0.0/24 via 192.168.0.2
```

---

##  How It Works

### Example: App → Internet

1. App container sends traffic
2. R2 receives packet
3. R2 uses default route → forwards to R1
4. R1 forwards to internet gateway
5. NAT is applied
6. Response returns via R1 → R2 → App

---

### Example: App → LAN

1. App sends packet to LAN
2. R2 forwards to R1
3. R1 knows LAN is directly connected
4. Firewall decides whether to allow or block

---

##  Important Notes

* Static routes must be configured on both routers
* Missing routes will result in unreachable networks
* Routing works together with firewall rules (routing ≠ permission)

---

##  Key Takeaways

* Routing defines **where packets go**
* Firewall defines **whether packets are allowed**
* NAT defines **how packets appear externally**

---

##  Future Improvements

* Replace static routing with dynamic routing (OSPF/BGP)
* Add redundancy and failover routes
* Extend routing for IPv6 (dual stack)

---
