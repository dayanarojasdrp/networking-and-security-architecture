# Design Decisions

This project was built as a local simulation of a cloud-style networking and Kubernetes architecture. The goal was not only to make the application run, but to make the traffic flow through controlled layers: routing, firewall, TLS entry point, Kubernetes services, backend, and database.

## 1. Keeping nginx-entry only inside app_net

The nginx-entry container was intentionally kept inside `app_net` instead of connecting it directly to `lan_net`.

The reason was to avoid giving LAN clients direct access to the application network. LAN traffic must pass through R1 and R2 before reaching the entry point.

This made the architecture closer to a real segmented environment, where application services are not directly attached to the client network.

## 2. Using R2 as the security edge

R2 became the main security enforcement point between the LAN network and the application network.

R1 was kept mostly as a routing device, while R2 applies:

- FORWARD default DROP
- allowed HTTP/HTTPS traffic to nginx-entry
- blocked direct access to the Kubernetes NodePort
- SNAT for return traffic

This separation helped keep the design easier to understand:

- R1 handles LAN routing
- R2 handles security and NAT toward app_net

## 3. Using SNAT to solve the return path problem

At one point, the LAN client could reach R1 and R2, but HTTP traffic to nginx-entry did not return correctly.

The issue was that nginx-entry did not have a route back to `172.20.0.0/24`. Since the nginx image was minimal and did not include the `ip` command, adding routes inside the container was not the best solution.

Instead, SNAT was configured on R2.

This made nginx-entry see the traffic as coming from `172.21.0.3` instead of the original LAN client IP. That solved the return path while keeping nginx-entry isolated inside `app_net`.

## 4. Exposing Kubernetes through nginx-entry instead of direct NodePort access

The frontend service uses a NodePort internally, but LAN clients are not supposed to access it directly.

The correct path is:

```txt
LAN client -> R1 -> R2 -> nginx-entry -> Kubernetes NodePort -> frontend -> backend -> postgres
```
Direct access to:
```
172.21.0.2:30528
```
was intentionally blocked by R2.

This makes nginx-entry the required entry point for the application.

## 5. Using self-signed TLS for the entry point

TLS was implemented at nginx-entry using a self-signed certificate.

This is not meant to represent production-grade certificate management, but it demonstrates TLS termination at the edge.

For testing, curl -k is required because the certificate is not signed by a trusted public CA.

## 6. Keeping Kubernetes internal services as ClusterIP

The backend and PostgreSQL services were kept as ClusterIP because they should only be reached from inside the cluster.

Only the frontend is exposed through NodePort, and even that is only consumed by nginx-entry.

This follows the idea that internal services should not be directly exposed to external clients.

## 7. Using PVC for PostgreSQL persistence

PostgreSQL was updated to use a PersistentVolumeClaim.

The reason was to separate application lifecycle from data lifecycle. The Postgres pod can be deleted and recreated, but the data remains available through the PVC.

This was validated by creating a table, inserting data, deleting the Postgres pod, and confirming that the data still existed after the pod was recreated.

## 8. Network Policies limitation

NetworkPolicy manifests were created to express the intended internal security model:

frontend -> backend
backend -> postgres

However, the current Kind environment does not enforce those policies because the default networking layer does not include a CNI with NetworkPolicy support.

The manifests were kept in the repository as documentation of the intended design, but enforcement would require Calico, Cilium, or another compatible CNI.

## 9. IPv6 decision

IPv6 was investigated, but Docker did not have IPv6 enabled for the current lab networks.

Enabling IPv6 would require changes to Docker daemon networking and could break the already working environment. For that reason, IPv6 was documented as future work instead of being forced into the current implementation.
