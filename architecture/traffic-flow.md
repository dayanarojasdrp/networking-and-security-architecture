# Traffic Flow

This document explains how traffic moves across the environment from the LAN client to the backend database.

The goal of the architecture was to force all application access through controlled layers instead of exposing Kubernetes services directly to the LAN network.

---

# High-Level Flow

```txt id="xz8gmk"
LAN Client
    ↓
R1 (routing)
    ↓
R2 (firewall + NAT)
    ↓
nginx-entry (HTTPS reverse proxy)
    ↓
Kubernetes frontend
    ↓
backend-service
    ↓
postgres-service
    ↓
PostgreSQL database
```

---

# Step-by-Step Packet Flow

## 1. LAN Client Sends HTTPS Request

The client initiates an HTTPS request:

```bash id="0y9d66"
curl -k https://172.21.0.4/api
```

The `-k` flag is required because nginx-entry uses a self-signed TLS certificate.

At this point:

* source network: `172.20.0.0/24`
* destination: `172.21.0.4`
* protocol: HTTPS / TCP 443

---

# 2. Traffic Reaches R1

R1 acts mainly as the routing device for the LAN network.

R1 knows that the application network:

```txt id="58dbv4"
172.21.0.0/24
```

must be reached through R2:

```txt id="xylgqv"
192.168.0.3
```

Static route on R1:

```txt id="rw5v20"
172.21.0.0/24 via 192.168.0.3
```

R1 forwards the packet toward R2.

---

# 3. R2 Applies Firewall and NAT Rules

R2 is the security edge between the LAN network and the application network.

The FORWARD policy on R2 is:

```txt id="6mwn7j"
DROP
```

Only explicitly allowed traffic is permitted.

Allowed traffic:

* HTTP to nginx-entry
* HTTPS to nginx-entry
* established connections

Blocked traffic:

* direct access to Kubernetes NodePort

Example firewall rule:

```txt id="n4lv94"
ALLOW 172.20.0.0/24 -> 172.21.0.4 TCP/443
```

R2 also performs SNAT.

Without SNAT, nginx-entry would not know how to return traffic back to the LAN network.

SNAT makes nginx-entry see traffic as coming from:

```txt id="d5jlwm"
172.21.0.3
```

instead of the original LAN client IP.

---

# 4. nginx-entry Receives HTTPS Traffic

nginx-entry acts as the TLS termination and reverse proxy layer.

Responsibilities:

* receive HTTPS traffic
* terminate TLS
* forward requests internally to Kubernetes frontend

The request arrives at:

```txt id="pfemto"
https://172.21.0.4/api
```

nginx-entry forwards the request internally to the Kubernetes frontend NodePort.

---

# 5. Kubernetes Frontend Receives the Request

The frontend service is exposed internally through:

```txt id="g1ydbx"
frontend-service
```

using a NodePort.

The frontend container receives the request and forwards API traffic to:

```txt id="a2ylmq"
backend-service
```

using Kubernetes internal service discovery.

---

# 6. Backend Communicates with PostgreSQL

The backend API communicates with PostgreSQL using:

```txt id="wq4v2u"
postgres-service
```

The backend connects through:

```txt id="dr8qiv"
DB_HOST=postgres-service
```

The database request stays completely inside the Kubernetes cluster.

---

# 7. PostgreSQL Returns the Response

PostgreSQL processes the request and returns data back through the chain:

```txt id="44u10z"
postgres
→ backend
→ frontend
→ nginx-entry
→ R2
→ R1
→ LAN client
```

Final successful response example:

```json id="8n6a5t"
{"status":"ok","backend":"running","database":"connected","db_time":"2026-05-06T02:30:01.354Z"}
```

---

# Why Direct NodePort Access Fails

Direct access to the Kubernetes frontend NodePort was intentionally blocked.

Test:

```bash id="sl8r8u"
curl --connect-timeout 5 http://172.21.0.2:30528
```

Result:

```txt id="t0l7ah"
curl: (28) Connection timeout after 5001 ms
```

This happens because R2 blocks forwarding traffic from the LAN network directly to the Kubernetes NodePort.

The only allowed path is through nginx-entry.

This design prevents clients from bypassing:

* TLS termination
* reverse proxy layer
* firewall policy
* centralized entry point

---

# Internal Kubernetes Communication

Inside Kubernetes:

```txt id="h4g5yu"
frontend
→ backend-service
→ postgres-service
```

Internal services use ClusterIP and are not exposed directly to the LAN network.

Only the frontend NodePort is reachable internally by nginx-entry.

---

# Persistence Flow

PostgreSQL uses a PersistentVolumeClaim (PVC).

This means:

* deleting the pod does not delete the data
* Kubernetes can recreate the pod while keeping the database files

Persistence was validated by:

1. creating a table
2. inserting data
3. restarting the PostgreSQL pod
4. confirming the data still existed
