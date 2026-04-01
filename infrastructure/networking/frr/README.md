#  Docker Networking Lab with FRRouting (FRR)

##  Overview

This project simulates a network architecture using Docker containers and FRRouting (FRR).

It includes:

* Static routing between routers
* Communication across multiple subnets
* NAT (Network Address Translation) for internet access

---

##  Topology

```
[ APP Network ]
     |
     R2
     |
     R1 (NAT)----[LAN Net]
     |
  Internet
```

---

##  Networks

| Network          | Subnet         | Purpose             |
| ---------------- | -------------- | ------------------- |
| internet_net     | 10.0.0.0/24    | External access     |
| inter_router_net | 192.168.0.0/28 | R1 ↔ R2             |
| lan_net          | 172.20.0.0/24  | Internal LAN        |
| app_net          | 172.21.0.0/24  | Application network |

---

## Components

* **R1** → Edge router with NAT
* **R2** → Internal router
* **Alpine container** → Test host

---

##  How to Run

### 1. Create networks

```bash
./scripts/create_networks.sh
```

### 2. Start routers

```bash
./scripts/run_routers.sh
```

### 3. Apply NAT

```bash
./scripts/nat.sh
```

---

##  Testing

Run a test container:

```bash
docker run -it --rm --network app_net alpine sh
```

Test connectivity:

```bash
ping 8.8.8.8
```

---

##  Expected Result

* Internal networks can communicate
* Traffic is routed through R1
* NAT allows internet access

---

##  Key Learnings

* Linux networking fundamentals
* Static routing with FRR
* NAT using iptables
* Debugging real network issues

---

## Troubleshooting Insights

* Incorrect destination IP can break connectivity
* Default route misconfiguration causes packet loss
* IP forwarding must be enabled
* Docker network gateway (.1) must be considered

---

##  Project Structure

```
infrastructure/networking/frr/lab-docker/
```

---

##  Future Improvements

* OSPF dynamic routing
* Firewall rules
* Traffic filtering
* High availability scenarios
