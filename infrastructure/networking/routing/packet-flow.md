# Packet Flow

This document explains how packets move through the environment from the LAN client to the Kubernetes application stack.

The goal of the lab was to understand real traffic flow across:

* routers
* firewall layers
* NAT
* reverse proxying
* Kubernetes services
* backend/database communication

instead of only deploying containers.

---

# High-Level Flow

```txt id="m3r8n0"
LAN Client
→ R1
→ R2 firewall/NAT
→ nginx-entry HTTPS
→ Kubernetes frontend
→ backend-service
→ postgres-service
```

---

# Step 1 — Client Request

The process starts from a client located in the LAN network:

```txt id="2vynjj"
172.20.0.0/24
```

The client sends an HTTPS request:

```bash
curl -k https://172.21.0.4/api
```

The `-k` flag is required because nginx-entry uses a self-signed TLS certificate.

Destination:

```txt id="d9cfwx"
172.21.0.4
```

which corresponds to:

```txt id="7t1yfj"
nginx-entry
```

---

# Step 2 — R1 Routing

R1 receives the packet from the LAN side.

R1 knows that the application network:

```txt id="5ts1sx"
172.21.0.0/24
```

must be reached through R2 using the transit network:

```txt id="3hkl2l"
192.168.0.3
```

Static route example:

```txt id="swh8yv"
172.21.0.0/24 via 192.168.0.3
```

R1 forwards the packet toward R2.

---

# Step 3 — R2 Firewall Inspection

R2 acts as the security edge.

The FORWARD policy on R2 is:

```txt id="h0w31v"
DROP
```

meaning traffic is denied unless explicitly allowed.

Allowed traffic:

* TCP/80 to nginx-entry
* TCP/443 to nginx-entry
* established connections

Blocked traffic:

* direct access to Kubernetes NodePort

Example allowed flow:

```txt id="5qfxnp"
172.20.0.0/24
→
172.21.0.4 TCP/443
```

---

# Step 4 — SNAT Processing

Initially, return traffic from nginx-entry back to the LAN network failed.

The reason was that nginx-entry did not know how to route packets back to:

```txt id="8t9zsl"
172.20.0.0/24
```

To solve this, SNAT was configured on R2.

Example:

```bash
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j SNAT \
  --to-source 172.21.0.3
```

This causes nginx-entry to see the request as coming from:

```txt id="ltxj4d"
172.21.0.3
```

instead of the original LAN client.

As a result:

* return traffic succeeds
* nginx-entry remains isolated in app_net
* no additional routes were required inside nginx-entry

---

# Step 5 — nginx-entry TLS Termination

nginx-entry receives the HTTPS request.

Responsibilities:

* receive TLS traffic
* terminate HTTPS
* reverse proxy traffic toward Kubernetes

The request is then forwarded internally to:

```txt id="y4wr8w"
172.21.0.2:30528
```

which corresponds to the Kubernetes frontend NodePort.

---

# Step 6 — Kubernetes Frontend

The frontend service receives the request and forwards API traffic internally to:

```txt id="7qv7pl"
backend-service
```

This communication stays inside the Kubernetes cluster.

---

# Step 7 — Backend to PostgreSQL

The backend communicates with PostgreSQL using:

```txt id="6hrwdv"
postgres-service
```

through Kubernetes internal service discovery.

The database remains internal and is not exposed to the LAN network.

---

# Step 8 — Response Path

The response returns through the same path:

```txt id="0h7vzp"
postgres
→ backend
→ frontend
→ nginx-entry
→ R2
→ R1
→ LAN client
```

Successful response example:

```json
{"status":"ok","backend":"running","database":"connected","db_time":"2026-05-06T02:30:01.354Z"}
```

---

# Why Direct NodePort Access Fails

Direct access to the frontend NodePort was intentionally blocked.

Test:

```bash
curl --connect-timeout 5 http://172.21.0.2:30528
```

Result:

```txt
curl: (28) Connection timeout after 5001 ms
```

This confirms that the firewall prevents LAN clients from bypassing nginx-entry.

The only valid application entry path is:

```txt id="r95l58"
LAN
→ R1
→ R2
→ nginx-entry
→ Kubernetes
```

---

# Final Design Outcome

The final packet flow successfully demonstrates:

* segmented networking
* Layer 3 routing
* firewall enforcement
* NAT behavior
* TLS termination
* reverse proxying
* Kubernetes service communication
* internal database isolation
* controlled application exposure


