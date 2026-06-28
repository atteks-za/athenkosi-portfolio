# ISP Router Simulation with NAT — Cisco CSR1000v

> **Home Lab Series** | Proxmox VE 9.1.9 | Part 1 of 4

Simulates an Internet Service Provider (ISP) edge router using a Cisco IOS-XE CSR1000v VM. Demonstrates WAN connectivity, NAT overload (PAT), static routing, and loopback-based public IP simulation.

---

## Lab Environment

| Parameter | Value |
|-----------|-------|
| VM ID | 104 |
| Hostname | CSR-ISP |
| Platform | Cisco IOS-XE CSR1000v |
| Proxmox Bridge (WAN) | vmbr0 — Internet uplink |
| Proxmox Bridge (LAN) | vmbr1 — Link to FortiGate WAN |

---

## Network Diagram

```
Internet (Proxmox DHCP)
        |
        | GigabitEthernet1 — 192.168.8.39 (DHCP)
     [CSR-ISP]
        | GigabitEthernet2 — 203.0.113.1/30
        |
  [FortiGate port1] — 203.0.113.2/30
```

---

## Interface Summary

| Interface | IP Address | Description |
|-----------|------------|-------------|
| GigabitEthernet1 | DHCP (192.168.8.39) | WAN — Internet uplink from Proxmox |
| GigabitEthernet2 | 203.0.113.1/30 | LAN — P2P link to FortiGate WAN port |
| Loopback0 | 1.1.1.1/32 | Simulated public IP address |

---

## Configuration

### Full Running Config

```ios
hostname CSR-ISP
!
interface GigabitEthernet1
 description WAN-INTERNET
 ip address dhcp
 ip nat outside
 no shutdown
!
interface GigabitEthernet2
 description LAN-TO-FORTIGATE
 ip address 203.0.113.1 255.255.255.252
 ip nat inside
 no shutdown
!
interface Loopback0
 description SIMULATED-PUBLIC-IP
 ip address 1.1.1.1 255.255.255.255
 no shutdown
!
access-list 1 permit 203.0.113.0 0.0.0.3
access-list 1 permit 10.0.0.0 0.255.255.255
ip nat inside source list 1 interface GigabitEthernet1 overload
!
ip route 10.0.0.0 255.0.0.0 203.0.113.2
!
end
```

---

## Key Concepts

### NAT Overload (PAT)
Both the ISP-FortiGate link (`203.0.113.0/30`) and all internal `10.0.0.0/8` networks are translated out via the WAN interface. This simulates how an ISP provides internet access to downstream customers.

```
Internal 10.x.x.x → NAT Overload → Gi1 Public IP (192.168.8.39)
```

### Static Route
A static route points all `10.0.0.0/8` traffic back toward the FortiGate (`203.0.113.2`), enabling return traffic to reach internal hosts.

```
ip route 10.0.0.0 255.0.0.0 203.0.113.2
```

### Loopback Simulation
`Loopback0` with `1.1.1.1/32` simulates a reachable public IP — useful for BGP peering tests and traceroute validation.

---

## Verification Commands

```ios
! Interface status
show ip interface brief

! Routing table
show ip route

! Active NAT translations
show ip nat translations

! Connectivity tests
ping 8.8.8.8          ! Internet
ping 203.0.113.2      ! FortiGate WAN port
```

### Expected Output — Interface Brief

```
GigabitEthernet1   192.168.8.39   YES DHCP    up  up
GigabitEthernet2   203.0.113.1    YES manual  up  up
Loopback0          1.1.1.1        YES manual  up  up
```

---

## Proxmox Setup Notes

1. Deploy CSR1000v OVA as VM 104 in Proxmox VE
2. Attach two network interfaces:
   - `net0` → `vmbr0` (WAN — internet-facing bridge)
   - `net1` → `vmbr1` (LAN — shared with FortiGate port1)
3. Boot and apply config above via console


