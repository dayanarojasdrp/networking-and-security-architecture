# FRR Routing Configuration

##  Overview

This section defines the routing configuration for the lab environment using FRR (Free Range Routing).

The goal is to simulate a real-world network topology with multiple subnets, routers, and controlled traffic flow between segments.

---

## Network Topology

The lab is composed of two routers:

* **R1** → Main router (acts as gateway to the internet)
* **R2** → Internal router (connects application network to R1)

### Subnets

| Network          | CIDR           | Description           |
| ---------------- | -------------- | --------------------- |
| Internet Network | 10.0.0.0/24    | Simulated internet    |
| Inter-router     | 192.168.0.0/28 | R1 ↔ R2 communication |
| LAN Network      | 172.20.0.0/24  | Internal LAN          |
| App Network      | 172.21.0.0/24  | Application network   |

---

##  Network Roles

### R1 Interfaces

| Interface | Network        | Role             |
| --------- | -------------- | ---------------- |
| eth1      | 10.0.0.0/24    | Internet gateway |
| eth2      | 192.168.0.0/28 | Connection to R2 |
| eth3      | 172.20.0.0/24  | LAN network      |

### R2 Interfaces

| Interface | Network        | Role                |
| --------- | -------------- | ------------------- |
| eth1      | 192.168.0.0/28 | Connection to R1    |
| eth2      | 172.21.0.0/24  | Application network |

---

##  Routing Strategy

### R1

R1 is responsible for:

* Routing traffic between all networks
* Providing internet access (default gateway)
* Applying NAT for outbound traffic

#### Routes

* Default route → Internet gateway (10.0.0.1)
* Route to App Network → via R2 (192.168.0.4)

---

### R2

R2 is responsible for:

* Connecting the App Network to the rest of the infrastructure
* Forwarding traffic to R1

#### Routes

* Default route → R1 (192.168.0.2)
* Route to LAN → via R1
* Route to Internet → via R1

---

##  Packet Flow

### App → Internet

1. App container sends traffic to R2
2. R2 forwards to R1
3. R1 performs NAT
4. Traffic exits to internet
5. Response returns via R1 → R2 → App

---

### LAN → Internet

1. LAN sends traffic to R1
2. R1 performs NAT
3. Traffic exits to internet
4. Response returns to LAN

---

### App → LAN (Blocked)

Traffic is explicitly blocked by firewall rules in R1.

---

##  Notes

* Routing is based on static routes
* NAT is only applied on R1
* Firewall rules enforce network segmentation
* Interface naming must match Docker network attachments

---

##  Future Improvements

* Add IPv6 support (dual stack)
* Replace static routing with dynamic protocols (OSPF/BGP)
* Introduce network policies for fine-grained control

---

