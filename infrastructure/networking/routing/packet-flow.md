# Packet Flow

Example: Traffic from APP to Internet

1. Packet originates from APP container (172.21.0.x)
2. Sent to R2 (default gateway)
3. R2 forwards to R1
4. R1 applies NAT (source IP changes)
5. Packet is sent to the internet
6. Response returns to R1
7. R1 reverses NAT
8. Packet goes back to R2
9. Delivered to APP
