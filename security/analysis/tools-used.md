# Security and Troubleshooting Tools

This document summarizes the main tools used during validation, debugging, and traffic analysis throughout the project.

The objective of these tools was not only to verify connectivity, but to understand how packets moved across:

* routers
* firewall layers
* NAT
* reverse proxies
* Kubernetes services
* backend/database communication

---

# curl

Used for:

* HTTP testing
* HTTPS validation
* API endpoint testing
* end-to-end connectivity validation

Examples:

```bash
curl -k https://172.21.0.4/api
```

```bash
curl --connect-timeout 5 http://172.21.0.2:30528
```

curl was heavily used to validate:

* TLS functionality
* reverse proxy behavior
* firewall filtering
* blocked NodePort access

---

# nc (netcat)

Used for:

* TCP port validation
* service reachability testing

Example:

```bash
nc -vz postgres-service 5432
```

This helped verify:

* PostgreSQL port exposure
* internal Kubernetes communication
* service availability

---

# kubectl

Used for:

* Kubernetes management
* pod inspection
* logs
* service validation
* persistence testing

Examples:

```bash
kubectl get pods
kubectl get svc
kubectl logs deployment/postgres
kubectl exec
```

kubectl was the primary troubleshooting tool for Kubernetes-related debugging.

---

# docker exec

Used to:

* inspect router containers
* validate routing tables
* inspect interfaces
* run firewall commands
* execute internal curl tests

Examples:

```bash
docker exec -it R1 sh
docker exec -it R2 sh
```

This allowed direct validation of:

* routing behavior
* firewall state
* NAT configuration
* internal connectivity

---

# iptables

Used to inspect:

* firewall rules
* NAT rules
* packet counters
* forwarding policies

Examples:

```bash
iptables -L -n -v
iptables -t nat -L -n -v
```

This was critical for understanding:

* why traffic was blocked
* why HTTPS initially failed
* how SNAT fixed the return-path problem

---

# psql

Used for PostgreSQL validation and persistence testing.

Example:

```bash
psql -U appuser -d appdb
```

This was used to:

* create test tables
* insert test data
* validate PersistentVolumeClaim behavior after pod recreation

---

# Main Lesson

One of the biggest lessons during the project was understanding that infrastructure troubleshooting requires validating every layer independently.

Examples:

* routing can work while applications still fail
* firewall rules can silently block valid traffic
* Kubernetes services can exist while applications are unhealthy
* NAT problems can break return traffic even when routes are correct

Because of that, most debugging was performed incrementally:

* one hop at a time
* one protocol at a time
* one layer at a time
