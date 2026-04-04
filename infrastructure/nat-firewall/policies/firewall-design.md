# Firewall Design

## Overview

This firewall implements a **segmented network security model** using iptables.

R1 acts as the **central security boundary**, controlling all traffic between:

* Internal networks (LAN, App)
* External network (Internet)

---

## Security Model

The design follows a **default deny policy**:

* All traffic is blocked unless explicitly allowed
* Only required flows are permitted

---

## Allowed Traffic

### LAN → Internet

* Allowed for outbound connectivity
* NAT applied on R1

---

### App → Internet

* Allowed for application communication
* Routed through R2 → R1
* NAT applied on R1

---

### Return Traffic

* Allowed automatically using connection tracking:

```
RELATED, ESTABLISHED
```

---

## Blocked Traffic

### LAN → App

* Blocked to enforce segmentation

---

### App → LAN

* Blocked to prevent lateral movement

---

## NAT Behavior

* Implemented using MASQUERADE on R1
* Translates private IPs to external interface

---

## Design Justification

This model simulates:

* AWS NAT Gateway
* AWS Security Groups behavior
* Network segmentation in cloud environments

---

## Key Principles

* Least privilege
* Network isolation
* Controlled internet access
* Stateful inspection

---

## Summary

| Traffic        | Allowed |
| -------------- | ------- |
| LAN → Internet | Yes     |
| App → Internet | Yes     |
| LAN → App      | No      |
| App → LAN      | No      |

---
