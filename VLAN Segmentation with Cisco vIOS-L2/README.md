# VLAN Segmentation with Cisco vIOS-L2 — SW-HQ-01


Configures a Cisco vIOS-L2 virtual switch as the Layer 2 distribution switch for the home lab. Implements 802.1Q trunking toward the HQ core router, access port segmentation into three VLANs, and a management SVI.

---

## Lab Environment

| Parameter | Value |
|-----------|-------|
| VM ID | 106 |
| Hostname | SW-HQ-01 |
| Platform | Cisco vIOS-L2 |
| Proxmox Bridge (Trunk) | vmbr3 — Trunk from CSR-HQ-01 |
| Proxmox Bridge (VLAN10) | vmbr4 — Management access |
| Proxmox Bridge (VLAN20) | vmbr5 — Servers access |
| Proxmox Bridge (VLAN30) | vmbr6 — Users access |

---

## Network Diagram

```
[CSR-HQ-01 Gi2] — 802.1Q Trunk (VLANs 10,20,30)
        |
        | vmbr3
  [SW-HQ-01 Gi0/0] — Trunk
        |
        |——— Gi0/3 — Access VLAN10 — vmbr4 ——> LabControl  (10.10.10.x)
        |——— Gi0/2 — Access VLAN20 — vmbr5 ——> Splunk, ADNS (10.20.20.x)
        '——— Gi0/1 — Access VLAN30 — vmbr6 ——> DockerHost  (10.30.30.x)
```

---

## VLAN Summary

| VLAN ID | Name | Subnet | Access Port | Proxmox Bridge |
|---------|------|--------|-------------|----------------|
| 10 | MANAGEMENT | 10.10.10.0/24 | Gi0/3 | vmbr4 |
| 20 | SERVERS | 10.20.20.0/24 | Gi0/2 | vmbr5 |
| 30 | USERS | 10.30.30.0/24 | Gi0/1 | vmbr6 |

---

## Interface Summary

| Interface | Mode | VLAN | Description |
|-----------|------|------|-------------|
| GigabitEthernet0/0 | Trunk | 10, 20, 30 | Uplink to CSR-HQ-01 |
| GigabitEthernet0/1 | Access | VLAN30 | User hosts (DockerHost) |
| GigabitEthernet0/2 | Access | VLAN20 | Server hosts (Splunk, ADNS) |
| GigabitEthernet0/3 | Access | VLAN10 | Management hosts (LabControl) |
| Vlan10 SVI | L3 | 10 | Switch management IP: 10.10.10.2 |

---

## Configuration

### 5.1 Full Running Configuration

```ios
conf t
hostname SW-HQ-01
no service config
!
! Create VLANs
vlan 10
 name Management
vlan 20
 name Servers
vlan 30
 name Users
!
! Trunk uplink to CSR-HQ-01
interface GigabitEthernet0/0
 description TRUNK-TO-CSR-HQ-01
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
 no shutdown
!
! Access ports
interface GigabitEthernet0/1
 description ACCESS-VLAN30-USERS
 switchport mode access
 switchport access vlan 30
 no shutdown
!
interface GigabitEthernet0/2
 description ACCESS-VLAN20-SERVERS
 switchport mode access
 switchport access vlan 20
 no shutdown
!
interface GigabitEthernet0/3
 description ACCESS-VLAN10-MGMT
 switchport mode access
 switchport access vlan 10
 no shutdown
!
! Management SVI
interface Vlan10
 description SW-MANAGEMENT
 ip address 10.10.10.2 255.255.255.0
 no shutdown
!
ip default-gateway 10.10.10.1
!
end
write memory
```

---

## VM to VLAN Mapping

| VM | VLAN | Bridge | IP Range | Gateway |
|----|------|--------|----------|---------|
| 102 — LabControl | VLAN10 MGMT | vmbr4 | 10.10.10.11–199 | 10.10.10.1 |
| 101 — Splunk | VLAN20 SERVERS | vmbr5 | 10.20.20.11–199 | 10.20.20.1 |
| 105 — ADNS | VLAN20 SERVERS | vmbr5 | 10.20.20.11–199 | 10.20.20.1 |
| 103 — DockerHost | VLAN30 USERS | vmbr6 | 10.30.30.11–199 | 10.30.30.1 |

---

## Key Concepts

### 802.1Q Trunking
`Gi0/0` carries tagged frames for VLANs 10, 20, and 30 to the router. The `switchport trunk allowed vlan` command explicitly restricts the trunk to only these VLANs — a security best practice.

### Access Port Segmentation
Each access port strips the VLAN tag before delivering frames to the connected VM. VMs are unaware of VLAN tagging — they just see their subnet.

### Management SVI
The `Vlan10` SVI gives the switch a routable IP (`10.10.10.2`) for SSH/Telnet management. The `ip default-gateway` points to the CSR-HQ-01 VLAN10 subinterface for management traffic routing.

---

## Verification Commands

```ios
! VLAN database and port assignments
show vlan brief

! Trunk status and allowed VLANs
show interfaces trunk

! SVI and management IP
show ip interface brief

! Connectivity tests
ping 10.10.10.1        ! CSR-HQ-01 VLAN10 gateway
ping 10.0.0.2          ! CSR-HQ-01 uplink (Gi1)
ping 10.0.0.1          ! FortiGate port2
ping 8.8.8.8           ! Internet
```

### Expected Ping Results

```
SW-HQ-01# ping 10.10.10.1  -> 100% (CSR-HQ-01 VLAN10)
SW-HQ-01# ping 10.0.0.1    -> 100% (FortiGate port2)
SW-HQ-01# ping 8.8.8.8     -> 100% (Internet)
```

### Expected `show vlan brief` Output

```
VLAN  Name        Status    Ports
----  ----------  --------  ---------------------------
1     default     active    
10    Management  active    Gi0/3
20    Servers     active    Gi0/2
30    Users       active    Gi0/1
```

---

## Proxmox Setup Notes

1. Deploy vIOS-L2 image as VM 106 in Proxmox VE
2. Attach four network interfaces:
   - `net0` → `vmbr3` (Trunk — shared with CSR-HQ-01 Gi2)
   - `net1` → `vmbr4` (VLAN10 Access — shared with LabControl)
   - `net2` → `vmbr5` (VLAN20 Access — shared with Splunk + ADNS)
   - `net3` → `vmbr6` (VLAN30 Access — shared with DockerHost)
3. Apply config above; VMs on each bridge receive DHCP from CSR-HQ-01

---

## Phase 3 Expansion — Security

| Task | Description |
|------|-------------|
| Port Security | Limit MAC addresses per access port |
| BPDU Guard | Protect access ports from rogue switches |
| DHCP Snooping | Prevent rogue DHCP servers on access VLANs |
| 802.1X | Port-based NAC for user authentication |

---

