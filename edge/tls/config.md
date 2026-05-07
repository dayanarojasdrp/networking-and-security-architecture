# TLS Configuration

This document explains how TLS was added to the nginx-entry container in this lab.

The goal was to make nginx-entry act as the HTTPS entry point for the application, similar to how a load balancer or reverse proxy would handle TLS termination in a real environment.

This was implemented with a self-signed certificate because the project runs locally and does not use a public domain or a trusted Certificate Authority.

---

# Why TLS Was Added

Before TLS, the application was reachable through HTTP.

The next step was to simulate a more realistic entry point by allowing clients to access the application through HTTPS.

In this lab, TLS is handled at the nginx-entry layer.

The internal traffic from nginx-entry to Kubernetes continues over HTTP.

This means:

```txt
LAN client
    ↓ HTTPS
nginx-entry
    ↓ HTTP
Kubernetes frontend
    ↓
backend
    ↓
PostgreSQL
```

This pattern is called TLS termination.

---

# Certificate Generation

A self-signed certificate was generated using OpenSSL.

Command used:

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx.key \
  -out nginx.crt \
  -subj "/CN=nginx-entry"
```

This command creates:

```txt
nginx.crt  -> certificate
nginx.key  -> private key
```

These files were mounted into the nginx-entry container.

---

# Nginx TLS Configuration

nginx-entry listens on port 443 using the generated certificate.

The HTTP port can also be used to redirect traffic to HTTPS.

Example configuration:

```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;

    ssl_certificate /etc/nginx/certs/nginx.crt;
    ssl_certificate_key /etc/nginx/certs/nginx.key;

    location / {
        proxy_pass http://172.21.0.2:30528;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

In this lab:

```txt
172.21.0.4 -> nginx-entry
172.21.0.2:30528 -> Kubernetes frontend NodePort
```

---

# Why curl -k Is Needed

The certificate used in this lab is self-signed.

That means the certificate was created locally and is not trusted by the operating system or by public Certificate Authorities.

Because of that, normal curl validation would reject it.

For testing, the `-k` flag is used:

```bash
curl -k https://172.21.0.4/api
```

The `-k` flag tells curl to ignore certificate trust validation.

This is acceptable for a local lab, but it would not be appropriate for production.

---

# HTTPS Validation

The final HTTPS test was performed from the LAN client:

```bash
curl -k https://172.21.0.4/api
```

Successful response:

```json
{"status":"ok","backend":"running","database":"connected","db_time":"2026-05-06T02:30:01.354Z"}
```

This confirmed that the request successfully passed through:

```txt
LAN client
→ R1
→ R2 firewall/NAT
→ nginx-entry HTTPS
→ Kubernetes frontend
→ backend
→ PostgreSQL
```

---

# Firewall Update for HTTPS

When HTTPS was added, the firewall initially allowed only HTTP traffic on port 80.

HTTPS uses TCP port 443, so R2 needed additional rules.

FORWARD rule:

```bash
iptables -A FORWARD \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j ACCEPT
```

SNAT rule:

```bash
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 443 \
  -j SNAT \
  --to-source 172.21.0.3
```

After adding these rules, HTTPS worked correctly through nginx-entry.

---

# Notes

This TLS setup is intentionally simple.

It demonstrates:

* HTTPS entry point
* TLS termination
* reverse proxy behavior
* firewall updates for port 443

It does not include:

* public certificates
* automatic renewal
* domain validation
* production certificate management
