# Limitations

This document describes the main technical and environmental limitations encountered during the development of this lab.

The purpose of this section is to honestly document the constraints of the environment instead of presenting the project as a fully enterprise-grade infrastructure deployment.

A large part of this project was built under conditions where internet access, cloud resources, and external services were limited or unavailable for long periods of time.

---

# Offline-First Development Constraints

One of the biggest limitations of this project was the need to work in environments with unstable or restricted internet connectivity.

Because of this:

* many components had to be prepared locally
* Docker images were reused whenever possible
* troubleshooting often had to be done offline
* documentation had to be created without relying constantly on external cloud platforms

This heavily influenced the design decisions of the lab.

The environment was intentionally built to function locally with:

* Docker
* Kind Kubernetes
* local networking
* local TLS
* local persistence

instead of depending on external cloud infrastructure.

---

# Limited Access to Cloud Platforms

The project was designed conceptually around cloud infrastructure ideas such as:

* segmented networks
* NAT gateways
* load balancers
* Kubernetes orchestration
* persistent storage

However, real AWS, Azure, or GCP infrastructure was not used.

Reasons included:

* infrastructure costs
* connectivity limitations
* access restrictions
* the need to keep the project reproducible locally

For that reason, cloud concepts were mapped conceptually instead of implemented directly in public cloud environments.

---

# Docker and Kubernetes Environment Limitations

The project used Kind (Kubernetes in Docker), which is lightweight and practical for local experimentation, but introduces limitations compared to production Kubernetes clusters.

Examples:

* limited CNI functionality
* no built-in NetworkPolicy enforcement
* simplified networking behavior
* local-only service exposure

Because of this, Kubernetes NetworkPolicies were created but not enforced in practice.

The manifests remain documented as part of the intended architecture design.

---

# IPv6 Limitations

IPv6 implementation was investigated but ultimately not enabled.

The Docker daemon in the current environment was configured only for IPv4 networking.

Enabling IPv6 would have required:

* daemon reconfiguration
* Docker network recreation
* partial rebuilding of the environment

Since the rest of the architecture was already stable and functional, IPv6 support was postponed.

---

# Hardware and Resource Constraints

The environment was developed using local virtualization and containerization instead of dedicated servers.

As a result:

* resources were limited
* the cluster size remained intentionally small
* some components were simplified to keep the environment stable

The focus remained on understanding architecture and packet flow rather than scaling or performance testing.

---

# TLS Limitations

HTTPS was implemented using self-signed certificates.

This allowed:

* TLS testing
* reverse proxy validation
* encrypted traffic flow

but it is not equivalent to production certificate management.

The environment does not include:

* public certificate authorities
* automatic certificate renewal
* DNS validation
* production-grade PKI infrastructure

---

# BGP and SDN Scope

The original project structure included placeholders for BGP and SDN concepts.

However, these areas were intentionally reduced because they were not fully implemented in the final environment.

The final project focuses primarily on:

* routing
* NAT
* firewalling
* TLS
* Kubernetes
* persistence
* traffic flow analysis

instead of advanced dynamic routing protocols.

---

# Educational Focus vs Production Focus

This project was built primarily as:

* a networking learning environment
* a Kubernetes architecture lab
* a troubleshooting and packet flow exercise

rather than a production-ready deployment.

Several decisions prioritized:

* clarity
* observability
* reproducibility
* local execution

over production-scale complexity.

---

# Most Important Limitation

The biggest limitation throughout the project was not technical complexity itself, but working under constrained conditions while still trying to build and understand a complete multi-layer architecture.

Because of that, the project evolved gradually:

* testing one layer at a time
* validating traffic step by step
* solving routing and return-path problems incrementally
* documenting failures and corrections during the process

This strongly shaped the final structure and design of the lab.
