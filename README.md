# Networking and Security Architecture Lab

## Overview

This project is a local networking and Kubernetes lab designed to simulate a segmented application architecture similar to what could exist in a cloud or enterprise environment.

The main goal of the lab was not only to deploy containers, but to understand how traffic moves across different layers:

* routing
* firewall filtering
* NAT
* TLS termination
* reverse proxying
* Kubernetes services
* backend/database communication
* persistence

The environment was built step by step using Docker containers, custom networks, Kind Kubernetes, Nginx, PostgreSQL, and Linux networking tools.

The project focuses heavily on troubleshooting, packet flow understanding, and network segmentation instead of only deploying applications.

---

# Final Architecture

```txt
LAN Client
    ↓
R1 (Routing)
    ↓
R2 (Firewall + NAT)
    ↓
nginx-entry (TLS termination / reverse proxy)
    ↓
Kubernetes Frontend
    ↓
Backend API
    ↓
PostgreSQL + Persistent Volume
```

Traffic from the LAN network is intentionally forced through the nginx entry point.

Direct access to Kubernetes NodePort services is blocked by firewall rules on R2.

---

# Technologies Used

## Container and Platform

* Docker
* Kind (Kubernetes in Docker)
* Kubernetes
* Nginx
* PostgreSQL
* Node.js

## Networking

* Linux routing
* iptables
* SNAT
* static routing
* Docker bridge networks
* segmented subnets

## Security

* TLS / HTTPS
* reverse proxy isolation
* firewall filtering
* blocked direct NodePort access
* NetworkPolicy manifests

## Validation and Troubleshooting

* curl
* nc
* kubectl
* docker exec
* iptables inspection
* logs and connectivity testing

---

# Network Topology

## Networks

| Network        | Purpose                           |
| -------------- | --------------------------------- |
| 172.20.0.0/24  | LAN network                       |
| 172.21.0.0/24  | Application network               |
| 192.168.0.0/28 | Transit network between R1 and R2 |

## Main Components

| Component   | Role                         |
| ----------- | ---------------------------- |
| R1          | LAN routing                  |
| R2          | Firewall + NAT security edge |
| nginx-entry | HTTPS entry point            |
| frontend    | Kubernetes frontend service  |
| backend     | API service                  |
| postgres    | Database service             |

---

# Kubernetes Architecture

The Kubernetes cluster was deployed using Kind.

## Services

| Service          | Type      |
| ---------------- | --------- |
| frontend-service | NodePort  |
| backend-service  | ClusterIP |
| postgres-service | ClusterIP |

The backend communicates internally with PostgreSQL using Kubernetes services.

The PostgreSQL deployment uses a PersistentVolumeClaim so that data survives pod recreation.

---

# Security Controls

## Firewall

R2 uses iptables with a default DROP forwarding policy.

Allowed traffic:

* HTTP to nginx-entry
* HTTPS to nginx-entry
* established and related traffic

Blocked traffic:

* direct LAN access to Kubernetes NodePort

## TLS

Nginx performs TLS termination using a self-signed certificate.

HTTPS validation is tested using:

```bash
curl -k https://172.21.0.4/api
```

## Reverse Proxy Isolation

Clients are required to access the application through nginx-entry.

Direct access to the Kubernetes frontend NodePort is intentionally blocked.

## Network Policies

NetworkPolicy manifests were created for:

* frontend → backend
* backend → postgres

However, enforcement was not active because the default Kind networking layer does not include a compatible CNI with NetworkPolicy enforcement support.

---

# Validation

The lab was validated using real connectivity tests.

## Successful HTTPS request

```bash
curl -k https://172.21.0.4/api
```

Example response:

```json
{"status":"ok","backend":"running","database":"connected"}
```

## Direct NodePort access blocked

```bash
curl --connect-timeout 5 http://172.21.0.2:30528
```

Result:

```txt
Connection timeout
```

## PostgreSQL persistence test

A table was created inside PostgreSQL, data was inserted, the pod was recreated, and the data remained available through the PersistentVolumeClaim.

---

# Repository Structure

```txt
architecture/
docs/
edge/
infrastructure/
platform/
security/
cloud/
```

## Main Areas

* `platform/kubernetes/manifests`
  Kubernetes manifests used in the lab.

* `infrastructure/nat-firewall`
  Routing, firewall, and NAT configuration.

* `edge/nginx`
  Reverse proxy and TLS configuration.

* `docs/evidence`
  Real command outputs and validation results from the lab.

* `architecture`
  Design decisions and packet flow explanations.

---

# Known Limitations

## NetworkPolicy Enforcement

Kind does not enforce Kubernetes NetworkPolicies by default without an additional CNI such as Calico or Cilium.

The manifests were preserved as part of the intended architecture design.

## TLS Certificates

The environment uses self-signed certificates for local HTTPS testing.

## IPv6

IPv6 was investigated but not enabled because Docker daemon IPv6 support was disabled in the current environment.

## Production Scope

This project is a local educational and architectural simulation, not a production-ready deployment.

---

# Main Lessons Learned

* Routing success does not guarantee application success.
* Return paths matter as much as forward paths.
* Kubernetes services simplify internal communication.
* Local images and imagePullPolicy are critical in restricted environments.
* Firewall rules must reflect the actual traffic flow.
* Persistence must be explicitly configured.
* NetworkPolicies depend on the underlying CNI implementation.

---

# Author

This project was built as a hands-on networking and Kubernetes architecture lab focused on understanding real packet flow, segmentation, troubleshooting, and infrastructure behavior across multiple layers.
