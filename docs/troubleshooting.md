# Troubleshooting Notes

This document records the main issues found during the implementation of the lab and how they were solved.

## 1. Frontend pod stuck in ImagePullBackOff

### Problem

The frontend pod was not starting and showed:

```txt
ImagePullBackOff
```
After describing the pod, the image was shown as:
```
ngninx:latest
```
Cause

The image name was misspelled. It should have been:
```
nginx:latest
```
Solution

The deployment was recreated with a corrected image name. Later, a repaired local image was used:
```
nginx-repaired:local
```
and the deployment was configured with:
```
imagePullPolicy: Never
```
This prevented Kubernetes from trying to download the image from the internet.

## 2. kind load failed with digest not found
Problem

Loading images into Kind failed with errors similar to:
```
content digest ... not found
```
This happened with nginx, node, and postgres images.

Cause

The images existed in Docker, but Kind/containerd could not import them correctly because some image metadata or layers were inconsistent.

Solution

The images were repaired by running containers from the original images and then committing them into new local images:
```
docker commit nginx-repair nginx-repaired:local
docker commit node-repair node-repaired:local
docker commit postgres-repair postgres-repaired:local
```
Those repaired images were successfully loaded into Kind.

## 3. Backend could not connect to PostgreSQL
Problem

The backend was running, but it could not connect to PostgreSQL because the Node image did not include the PostgreSQL client library.

The test showed:
```
pg missing
```
Solution

A new backend image was created:
```
backend-db:local
```
The image included:

Node.js
server.js
pg library
database connection logic

After updating the backend deployment, the backend successfully connected to PostgreSQL through:
```
postgres-service
```
Validated output:
```
{"status":"ok","backend":"running","database":"connected"}
```
## 4. LAN could reach R2 but not nginx-entry
Problem

The LAN client could ping R1 and reach R2, but HTTP traffic to nginx-entry did not work.

Cause

The return path from nginx-entry back to the LAN network was missing.

nginx-entry lived only inside app_net, and it did not know how to return traffic to 172.20.0.0/24.

Solution

SNAT was configured on R2 for traffic from LAN to nginx-entry:
```
iptables -t nat -A POSTROUTING \
  -s 172.20.0.0/24 \
  -d 172.21.0.4 \
  -p tcp \
  --dport 80 \
  -j SNAT \
  --to-source 172.21.0.3
```
The same was later added for HTTPS port 443.

## 5. HTTPS did not work at first
Problem

HTTP worked, but HTTPS failed when testing:
```
curl -k https://172.21.0.4/api
```
Cause

The firewall and SNAT rules initially allowed only port 80.

HTTPS uses port 443, so R2 was dropping the traffic.

Solution

Rules for port 443 were added to both the FORWARD chain and NAT table.

After that, HTTPS worked through nginx-entry.

## 6. Direct Kubernetes NodePort access was blocked
Validation

Direct access from LAN to the Kubernetes NodePort was tested:
```
curl --connect-timeout 5 http://172.21.0.2:30528
```
Result:
```
curl: (28) Connection timeout after 5001 ms
```
This confirmed that LAN clients cannot bypass nginx-entry.

## 7. Network Policies were not enforced
Problem

NetworkPolicy manifests were applied successfully, but the test pod could still reach backend and postgres.

Cause

The default Kind networking layer does not enforce NetworkPolicies without a compatible CNI.

Solution

The manifests were kept for documentation, and the limitation was recorded. A future version of this lab can use Calico or Cilium.
