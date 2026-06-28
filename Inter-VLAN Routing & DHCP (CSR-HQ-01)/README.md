# Inter-VLAN Routing & DHCP — Cisco CSR-HQ-01

> **Home Lab Series** | Proxmox VE 9.1.9 | Part 3 of 4

Configures a Cisco IOS-XE CSR1000v as the HQ core router. Provides inter-VLAN routing via 802.1Q subinterfaces, DHCP services for three VLANs, NAT overload toward FortiGate, and a default route for internet access.

---

## Lab Environment

| Parameter | Value |
|-----------|-------|
| VM ID | 107 |
| Hostname | CSR-HQ-01 |
| Platform | Cisco IOS-XE CSR1000v |
| Proxmox Bridge (WAN) | vmbr2 — Link from FortiGate port2 |
| Proxmox Bridge (Trunk) | vmbr3 — 802.1Q trunk to SW-HQ-01 |

---

## Network Diagram

```
[FortiGate port2] — 10.0.0.1/24
        |
        | vmbr2
  [CSR-HQ-01 Gi1] — 10.0.0.2/24  (NAT Outside)
  [CSR-HQ-01 Gi2] — 802.1Q Trunk
        |
        | vmbr3
  [SW-HQ-01 Gi0/0] — Trunk (VLANs 10, 20, 30)
     |       |       |
  VLAN10  VLAN20  VLAN30
```

---

## Interface Summary

| Interface | IP Address | Description |
|-----------|------------|-------------|
| GigabitEthernet1 | 10.0.0.2/24 | Uplink from FortiGate (NAT Outside) |
| GigabitEthernet2 | No IP — trunk | 802.1Q trunk to SW-HQ-01 |
| GigabitEthernet2.10 | 10.10.10.1/24 | VLAN10 — Management gateway |
| GigabitEthernet2.20 | 10.20.20.1/24 | VLAN20 — Servers gateway |
| GigabitEthernet2.30 | 10.30.30.1/24 | VLAN30 — Users gateway |

---

## Configuration

### 4.1 Full Interface & Routing Config

```ios
conf t
hostname CSR-HQ-01
no service config
!
! WAN Interface - toward FortiGate
interface GigabitEthernet1
 description UPLINK-FROM-FORTIGATE
 ip address 10.0.0.2 255.255.255.0
 ip nat outside
 no shutdown
!
! Trunk to Switch - no IP on physical
interface GigabitEthernet2
 description TRUNK-TO-SW-HQ-01
 no ip address
 no shutdown
!
! VLAN 10 - Management
interface GigabitEthernet2.10
 description VLAN10-MANAGEMENT
 encapsulation dot1Q 10
 ip address 10.10.10.1 255.255.255.0
 ip nat inside
 no shutdown
!
! VLAN 20 - Servers
interface GigabitEthernet2.20
 description VLAN20-SERVERS
 encapsulation dot1Q 20
 ip address 10.20.20.1 255.255.255.0
 ip nat inside
 no shutdown
!
! VLAN 30 - Users
interface GigabitEthernet2.30
 description VLAN30-USERS
 encapsulation dot1Q 30
 ip address 10.30.30.1 255.255.255.0
 ip nat inside
 no shutdown
!
! Default route toward FortiGate
ip route 0.0.0.0 0.0.0.0 10.0.0.1
!
! NAT ACL
ip access-list standard NAT_ACL
 permit 10.10.10.0 0.0.0.255
 permit 10.20.20.0 0.0.0.255
 permit 10.30.30.0 0.0.0.255
!
! NAT Overload
ip nat inside source list NAT_ACL interface GigabitEthernet1 overload
!
end
write memory
```

### 4.2 DHCP Server Configuration

```ios
conf t
!
! Exclude gateway and reserved IPs from pools
ip dhcp excluded-address 10.10.10.1 10.10.10.10
ip dhcp excluded-address 10.20.20.1 10.20.20.10
ip dhcp excluded-address 10.30.30.1 10.30.30.10
!
! VLAN 10 - Management
ip dhcp pool VLAN10-Management
 network 10.10.10.0 255.255.255.0
 default-router 10.10.10.1
 dns-server 8.8.8.8 10.20.20.100
 lease 1
!
! VLAN 20 - Servers
ip dhcp pool VLAN20-Servers
 network 10.20.20.0 255.255.255.0
 default-router 10.20.20.1
 dns-server 8.8.8.8 10.20.20.100
 lease 1
!
! VLAN 30 - Users
ip dhcp pool VLAN30-Users
 network 10.30.30.0 255.255.255.0
 default-router 10.30.30.1
 dns-server 8.8.8.8 10.20.20.100
 lease 1
!
end
write memory
```

---

## DHCP Pool Summary

| VLAN | Pool Name | Network | Gateway | DNS | Lease |
|------|-----------|---------|---------|-----|-------|
| 10 | VLAN10-Management | 10.10.10.0/24 | 10.10.10.1 | 8.8.8.8, 10.20.20.100 | 1 day |
| 20 | VLAN20-Servers | 10.20.20.0 /24 | 10.20.20.1 | 8.8.8.8, 10.20.20.100 | 1 day |
| 30 | VLAN30-Users | 10.30.30.0/24 | 10.30.30.1 | 8.8.8.8, 10.20.20.100 | 1 day |

**Excluded ranges** (gateways + reserved): `.1`–`.10` on each subnet. DHCP assigns from `.11` onward.

---

## Key Concepts

### Router-on-a-Stick (802.1Q Subinterfaces)
A single physical trunk link (`Gi2`) carries all VLAN traffic. Each subinterface strips its tag and acts as the Layer 3 gateway for its VLAN — enabling inter-VLAN routing without a dedicated link per VLAN.

### Double NAT
Traffic from VLANs undergoes NAT twice:
1. **Here (CSR-HQ-01):** VLAN IPs → 10.0.0.2 (NAT overload via `NAT_ACL`)
2. **At FortiGate:** 10.0.0.2 → 203.0.113.2 (LAN-to-WAN policy NAT)

This mirrors real enterprise designs where internal routing and perimeter NAT are separate functions.

---

## Verification Commands

```ios
show ip interface brief       ! Interface status and IPs
show ip route                 ! Routing table
show ip dhcp binding          ! Active DHCP leases
show ip dhcp pool             ! Pool utilization
show ip nat translations      ! Active NAT entries

! Connectivity tests
ping 10.0.0.1          ! FortiGate port2
ping 10.10.10.1        ! VLAN10 gateway (loopback to self)
ping 10.20.20.1        ! VLAN20 gateway
ping 10.30.30.1        ! VLAN30 gateway
ping 8.8.8.8           ! Internet
```

### Expected Ping Results

```
CSR-HQ-01# ping 10.0.0.1   -> 100% (FortiGate port2)
CSR-HQ-01# ping 8.8.8.8    -> 100% (Internet via FortiGate + ISP)
```

---

## Proxmox Setup Notes

1. Deploy CSR1000v OVA as VM 107 in Proxmox VE
2. Attach two network interfaces:
   - `net0` → `vmbr2` (WAN side — shared with FortiGate port2)
   - `net1` → `vmbr3` (Trunk — shared with SW-HQ-01 Gi0/0)
3. Apply config in order: interfaces → routing → NAT → DHCP

---

## Phase 2 Expansion — Routing Protocols

| Task | Description |
|------|-------------|
| OSPF | Replace static default route with OSPF toward FortiGate |
| Route Redistribution | Redistribute OSPF into BGP (via CSR-ISP) |
| ACLs | Add inter-VLAN ACLs to restrict traffic (Phase 3) |

---

## Related Projects

| # | Project | Description |
|---|---------|-------------|
| 1 | [ISP Router Simulation](../1-isp-router-nat) | Upstream ISP router |
| 2 | [FortiGate Edge Firewall](../2-fortigate-edge-fw) | Firewall this router connects to |
| 4 | [VLAN Segmentation vIOS-L2](../4-vlan-segmentation-vios-l2) | Downstream switch receiving the trunk |
