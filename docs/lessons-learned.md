# Lessons Learned

## 1. A running container image is not always usable by Kubernetes

One of the biggest lessons was that Docker could run an image, but Kind/containerd could still fail to import it.

This happened with several images and forced me to understand the difference between Docker image availability and containerd image availability inside a Kind node.

## 2. imagePullPolicy matters in offline environments

Because the lab was built in an offline or restricted environment, Kubernetes had to use local images only.

Setting:

```yaml
imagePullPolicy: Never
```
was necessary to stop Kubernetes from trying to download images from the internet.

## 3. Services are the stable way to reach pods

Pods changed names and IPs, but services provided stable access.

This became clear when connecting:
```
frontend -> backend-service -> backend pod
backend -> postgres-service -> postgres pod
```
## 4. Routing success does not mean application success

At one point, the LAN client could reach R2, but the application still did not work.

The problem was not Kubernetes. It was the return path from nginx-entry back to the LAN network.

That was solved with SNAT on R2.

## 5. Firewall rules must match the real traffic

HTTPS failed because the firewall only allowed HTTP.

Adding port 443 rules fixed the problem.

This showed why packet flow must be understood before writing firewall rules.

## 6. Persistence is not automatic

Postgres was running before the PVC, but the data was tied to the pod lifecycle.

Adding a PVC made the database more realistic because data survived pod recreation.

## 7. NetworkPolicy objects are not enough by themselves

Kubernetes accepted the NetworkPolicy manifests, but they were not enforced.

This helped clarify that NetworkPolicy requires support from the CNI plugin.
