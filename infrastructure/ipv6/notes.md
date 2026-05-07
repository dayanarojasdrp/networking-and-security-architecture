# IPv6 Notes

IPv6 support was investigated during the development of this lab, but it was not fully implemented in the final environment.

The original goal was to extend the existing segmented architecture to support dual-stack networking and modern IPv6 traffic flow concepts.

Initial validation steps included checking IPv6 interfaces inside the router containers:

```bash
docker exec R1 ip -6 addr
docker exec R2 ip -6 addr
```

The result showed only loopback IPv6 addresses:

```txt
inet6 ::1/128 scope host
```

No global or network-assigned IPv6 addresses were present on the Docker interfaces.

---

# Root Cause

The current Docker environment did not have IPv6 enabled at the Docker daemon level.

Because of that:

* Docker bridge networks were IPv4-only
* containers did not receive IPv6 addresses
* dual-stack routing could not be tested properly

---

# Why IPv6 Was Not Forced Into the Environment

At the time IPv6 was investigated, the rest of the lab was already fully functional:

* routing
* firewall
* NAT
* TLS
* Kubernetes
* persistence
* end-to-end traffic flow

Enabling IPv6 would have required:

* modifying Docker daemon configuration
* recreating Docker networks
* potentially rebuilding parts of the environment

Because the existing architecture was already stable and validated, IPv6 implementation was postponed instead of risking breaking the working lab.

---

# Current Status

IPv6 was researched and partially investigated, but the final implementation remains IPv4-only.

The current lab successfully demonstrates:

* segmented networking
* firewalling
* NAT
* reverse proxying
* Kubernetes service flow
* persistence
* TLS termination

without requiring IPv6 support.

---

# Future Work

A future version of the lab could include:

* Docker daemon IPv6 enablement
* dual-stack Docker networks
* IPv6 routing between R1 and R2
* IPv6 firewall rules
* Kubernetes dual-stack networking
* IPv6 service exposure

This would allow the architecture to evolve toward a more modern dual-stack design while preserving the same layered security model.
