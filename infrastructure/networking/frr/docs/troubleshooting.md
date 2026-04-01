# Troubleshooting

## Issue 1: No connectivity between networks

Cause:
The destination IP did not exist in the network.

Solution:
Use valid container IP addresses.

---

## Issue 2: Routing not working

Cause:
Incorrect default route on R1.

Solution:
Removed invalid default route.

---

## Issue 3: Packets not forwarding

Cause:
IP forwarding disabled.

Solution:
Enabled with:
sysctl -w net.ipv4.ip_forward=1

---

## Issue 4: No internet access

Cause:
NAT not configured.

Solution:
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
