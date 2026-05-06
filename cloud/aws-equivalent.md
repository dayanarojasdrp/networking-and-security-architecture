# AWS Equivalent Mapping

This document describes how the local lab components conceptually relate to services and architectural patterns commonly used in AWS environments.

The goal of this section is not to claim that the project was deployed in AWS, but to understand how the same ideas could map to cloud infrastructure concepts.

This project was implemented locally using Docker, Kind Kubernetes, Linux routing, and iptables.

---

# Conceptual Architecture Mapping

| Local Lab Component     | AWS Equivalent Concept                                        |
| ----------------------- | ------------------------------------------------------------- |
| lan_net                 | Private subnet / client subnet                                |
| app_net                 | Application subnet                                            |
| R1                      | Route table / internal routing                                |
| R2 firewall             | Security Groups / Network ACL concepts                        |
| SNAT on R2              | NAT Gateway concept                                           |
| nginx-entry             | Application Load Balancer (ALB) / Network Load Balancer (NLB) |
| Kind Kubernetes cluster | Amazon EKS concept                                            |
| frontend-service        | Kubernetes Service                                            |
| backend-service         | Internal microservice                                         |
| postgres-service        | Database service layer                                        |
| PersistentVolumeClaim   | Amazon EBS persistent storage concept                         |
| PostgreSQL pod          | Amazon RDS conceptual equivalent                              |

---

# Network Segmentation

The lab separates traffic into multiple Docker networks:

```txt id="a7nvry"
172.20.0.0/24 -> LAN network
172.21.0.0/24 -> application network
192.168.0.0/28 -> transit network
```

This conceptually resembles subnet segmentation inside a cloud VPC.

The goal was to avoid exposing the application services directly to the client network.

---

# Security Edge Concept

R2 acts as the security boundary between the LAN network and the application network.

Responsibilities:

* firewall filtering
* NAT
* traffic control
* blocked direct NodePort access

Conceptually, this resembles the role of:

* Security Groups
* Network ACLs
* NAT Gateway behavior

The project intentionally forces traffic through the nginx entry point instead of allowing direct access to Kubernetes services.

---

# TLS and Entry Point

The nginx-entry container performs:

* TLS termination
* reverse proxying
* centralized application entry

This conceptually resembles:

* AWS Application Load Balancer (ALB)
* AWS Network Load Balancer (NLB)

The project uses a self-signed certificate for local HTTPS testing.

---

# Kubernetes Conceptual Mapping

The Kind cluster represents a local Kubernetes environment similar in architecture to a managed Kubernetes platform such as Amazon EKS.

The project includes:

* frontend deployment
* backend deployment
* PostgreSQL deployment
* Kubernetes services
* PersistentVolumeClaim storage
* internal service communication

The purpose was to understand Kubernetes networking and service flow in a controlled local environment before moving toward cloud-native concepts.

---

# Persistent Storage

PostgreSQL uses a PersistentVolumeClaim (PVC).

Conceptually, this is similar to attaching persistent block storage to workloads in cloud environments.

In AWS terminology, the closest equivalent would be:

* Amazon EBS volumes
* storage attached to Kubernetes workloads
* or conceptually managed database persistence

The important architectural idea is that data survives pod recreation.

---

# Internal Service Communication

Inside the Kubernetes cluster:

```txt id="0nq0h5"
frontend
→ backend-service
→ postgres-service
```

This resembles a microservice-style internal communication pattern where services are isolated from external clients.

Only the frontend entry layer is externally reachable through nginx-entry.

---

# Cloud vs Local Lab Reality

This project does not implement real AWS infrastructure.

Instead, it uses:

* Docker networking
* Linux routing
* iptables
* Kind Kubernetes
* local TLS
* local persistence

to simulate and better understand the architectural behavior of:

* segmented networks
* security boundaries
* reverse proxies
* Kubernetes service exposure
* persistence
* traffic control

The focus of the project was practical understanding of packet flow and infrastructure behavior rather than cloud deployment itself.
