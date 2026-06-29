# OSPF Configuration Documentation
## Home Lab — Phase 2 Routing Protocols

**Date:** June 2026  
**Environment:** Proxmox VE 9.1.9  
**Devices:** FortiGate FW-HQ-01 ↔ CiscoCSR-HQ-01

---

## 1. OSPF Design

```
CSR-ISP (104)
     |
FortiGate (108) — Router ID: 2.2.2.2 — Area 0
     | port2 (10.0.0.1/24)
     | OSPF Area 0
     | port2 (10.0.0.2/24)
CSR-HQ-01 (107) — Router ID: 1.1.1.1 — Area 0
     |
     |—— VLAN10 10.10.10.0/24
     |—— VLAN20 10.20.20.0/24
     |—— VLAN30 10.30.30.0/24
```

### OSPF Summary

| Parameter | FortiGate | CSR-HQ-01 |
|---|---|---|
| Router ID | 2.2.2.2 | 1.1.1.1 |
| Area | 0.0.0.0 | 0 |
| Interface | port2 (LAN) | GigabitEthernet1 |
| Link IP | 10.0.0.1 | 10.0.0.2 |
| Neighbor State | FULL/DR | FULL/BDR |

---

## 2. CSR-HQ-01 OSPF Configuration

```ios
router ospf 1
 router-id 1.1.1.1
 network 10.0.0.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.255 area 0
 network 10.20.20.0 0.0.0.255 area 0
 network 10.30.30.0 0.0.0.255 area 0
 default-information originate always

end
write memory
```

---

## 3. FortiGate OSPF Configuration

### Via GUI
```
Network → OSPF
  Router ID    : 2.2.2.2
  Area         : 0.0.0.0 (Regular)

  Networks:
    10.0.0.0/24 → Area 0.0.0.0

  Interfaces:
    OSPF-LAN → port2 (LAN) → Cost 0

  Default Settings:
    Inject default route : Always
    Redistribute Connected : ON
    Redistribute Static   : ON
```

### Via CLI
```bash
config router ospf
 set router-id 2.2.2.2
 set default-information-originate always
 config area
  edit 0.0.0.0
  next
 end
 config network
  edit 1
   set prefix 10.0.0.0 255.255.255.0
   set area 0.0.0.0
  next
 end
 config ospf-interface
  edit "OSPF-LAN"
   set interface "port2"
   set area 0.0.0.0
  next
 end
 config redistribute "connected"
  set status enable
 end
 config redistribute "static"
  set status enable
 end
end
```

---

## 4. Verification Commands

### CSR-HQ-01
```ios
show ip ospf neighbor
show ip ospf database
show ip ospf interface
show ip route ospf
```

### Expected Output
```
! show ip ospf neighbor
Neighbor ID   Pri  State      Dead Time  Address    Interface
2.2.2.2        1   FULL/BDR   00:00:32   10.0.0.1   GigabitEthernet1

! show ip route ospf
O E2  203.0.113.0/30 [110/10] via 10.0.0.1
O*E2  0.0.0.0/0 [110/10] via 10.0.0.1      ← default via OSPF
```

### FortiGate
```bash
get router info ospf neighbor
get router info routing-table all
get router info ospf status
```

### Expected Output
```
Neighbor ID: 1.1.1.1  State: Full/DR  Address: 10.0.0.2  Interface: port2

Routing table:
S*  0.0.0.0/0 via 203.0.113.1 port1
O   10.10.10.0/24 via 10.0.0.2 port2
O   10.20.20.0/24 via 10.0.0.2 port2
O   10.30.30.0/24 via 10.0.0.2 port2
```

---

## 5. Routes Learned via OSPF

| Route | Learned By | Via | Method |
|---|---|---|---|
| 10.10.10.0/24 | FortiGate | 10.0.0.2 (CSR-HQ-01) | OSPF O |
| 10.20.20.0/24 | FortiGate | 10.0.0.2 (CSR-HQ-01) | OSPF O |
| 10.30.30.0/24 | FortiGate | 10.0.0.2 (CSR-HQ-01) | OSPF O |
| 203.0.113.0/30 | CSR-HQ-01 | 10.0.0.1 (FortiGate) | OSPF E2 |
| 0.0.0.0/0 | CSR-HQ-01 | 10.0.0.1 (FortiGate) | Static (fallback) |

---

## 6. Known Issues & Workarounds

| Issue | Cause | Workaround |
|---|---|---|
| 0.0.0.0/0 not propagating via OSPF | FortiGate OSPF default-info not exporting | Keep static default on CSR-HQ-01 |
| OSPF config lost on reboot | CSR1000v NVRAM issue | Re-apply after boot or use EEM |

---

## 7. Current Status

```
✅ OSPF Neighbor: FULL between FortiGate (2.2.2.2) and CSR-HQ-01 (1.1.1.1)
✅ VLAN routes (10.10/20/30.x) learned dynamically via OSPF
✅ No static routes needed for inter-VLAN routing
⚠️  Default route (0.0.0.0/0) still uses static on CSR-HQ-01 as fallback
⏳ BGP (Phase 2b) will replace static default route permanently
```

---

## 8. Next Step — BGP Configuration

BGP will be configured between:

| Device | Role | AS Number | Peer |
|---|---|---|---|
| CSR-ISP | eBGP peer / ISP | AS 65000 | FortiGate |
| FortiGate | eBGP customer edge | AS 65001 | CSR-ISP |

BGP will advertise `0.0.0.0/0` from CSR-ISP to FortiGate, which FortiGate will then redistribute into OSPF — permanently solving the default route issue.
