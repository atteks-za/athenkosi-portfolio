# BGP Configuration Documentation
## Home Lab — Phase 2b: Border Gateway Protocol

**Date:** June 2026  
**Environment:** Proxmox VE 9.1.9  
**Devices:** CSR-ISP (AS 65000) ↔ FortiGate (AS 65001)

---

## 1. BGP Design

```
Internet (Proxmox DHCP)
        |
   CSR-ISP (AS 65000)
   Router ID: 1.1.1.1
   Gi2: 203.0.113.1/30
        |
        | eBGP Session
        |
   FortiGate (AS 65001)
   Router ID: 2.2.2.2
   port1: 203.0.113.2/30
        |
   OSPF Area 0
        |
   CSR-HQ-01 → VLANs
```

### BGP Summary

| Parameter | CSR-ISP | FortiGate |
|---|---|---|
| AS Number | 65000 | 65001 |
| Router ID | 1.1.1.1 | 2.2.2.2 |
| Peer IP | 203.0.113.2 | 203.0.113.1 |
| Session Type | eBGP | eBGP |
| Uptime | 6h 22min+ | 6h 22min+ |
| State | Established | Established |
| Prefixes Sent | 2 | 1 |
| Prefixes Received | 1 | 2 |

---

## 2. CSR-ISP BGP Configuration

```ios
router bgp 65000
 bgp router-id 1.1.1.1
 neighbor 203.0.113.2 remote-as 65001
 neighbor 203.0.113.2 description FORTIGATE-PEER

 address-family ipv4
  neighbor 203.0.113.2 activate
  network 203.0.113.0 mask 255.255.255.252
  default-information originate
 exit-address-family

end
write memory
```

---

## 3. FortiGate BGP Configuration

### Via CLI
```bash
config router bgp
 set as 65001
 set router-id 2.2.2.2

 config neighbor
  edit "203.0.113.1"
   set remote-as 65000
   set description "CSR-ISP-PEER"
   set activate enable
   set default-originate enable
  next
 end

 config network
  edit 1
   set prefix 10.0.0.0 255.255.255.0
  next
 end
end
```

---

## 4. BGP Routes Exchanged

### CSR-ISP BGP Table
```
Network          Next Hop      Path
10.0.0.0/24      203.0.113.2   65001 i  ← FortiGate LAN
203.0.113.0/30   0.0.0.0       32768 i  ← Own network
```

### FortiGate BGP Table
```
Network          Next Hop      Path
0.0.0.0/0        203.0.113.1   65000 i  ← Default from ISP ✅
10.0.0.0/24      0.0.0.0       32768 i  ← Own LAN
203.0.113.0/30   203.0.113.1   65000 i  ← ISP link
Total: 3 prefixes
```

---

## 5. Verification Commands

### CSR-ISP
```ios
show ip bgp summary
show ip bgp
show ip bgp neighbors 203.0.113.2
show ip route bgp
```

### FortiGate
```bash
get router info bgp summary
get router info bgp network
get router info routing-table bgp
get router info bgp neighbors 203.0.113.1
```

### Expected BGP Summary Output (CSR-ISP)
```
BGP router identifier 1.1.1.1, local AS number 65000
Neighbor        AS     MsgRcvd  MsgSent  Up/Down   State/PfxRcd
203.0.113.2     65001  436      422      06:19:26  1
```

---

## 6. Route Redistribution Plan

| From | To | Method | Status |
|---|---|---|---|
| BGP | OSPF | redistribute bgp in OSPF | ⚠️ Partial |
| OSPF | BGP | redistribute ospf in BGP | ❌ Not configured |
| Connected | OSPF | redistribute connected | ✅ Done |
| Static | OSPF | redistribute static | ✅ Done |

### Workaround Applied
Static default route kept on CSR-HQ-01 as reliable fallback:
```ios
ip route 0.0.0.0 0.0.0.0 10.0.0.1
```

---

## 7. Final Routing Architecture

```
CSR-ISP (AS 65000)
  ↓ eBGP advertises 0.0.0.0/0
FortiGate (AS 65001)
  ↓ OSPF redistributes to CSR-HQ-01
CSR-HQ-01
  ↓ Static fallback 0.0.0.0/0 via 10.0.0.1
  ↓ OSPF for VLANs
VLANs 10/20/30
```

---

## 8. Current Status

```
✅ eBGP session: ESTABLISHED (CSR-ISP AS65000 ↔ FortiGate AS65001)
✅ BGP uptime: 6+ hours stable
✅ Prefixes exchanged: FortiGate LAN → CSR-ISP, Default → FortiGate
✅ FortiGate receives 0.0.0.0/0 from CSR-ISP via BGP
✅ OSPF converged: FortiGate ↔ CSR-HQ-01 FULL/DR
✅ VLANs routing dynamically via OSPF
✅ Internet working end-to-end
⚠️  Default route uses static fallback on CSR-HQ-01 (by design)
```

---

## 9. Next Step — Phase 3: Security

| Task | Device | Description |
|---|---|---|
| ACLs | CSR-HQ-01 | Restrict inter-VLAN traffic |
| IPS Profiles | FortiGate | Enable intrusion prevention |
| IPSec VPN | FortiGate | Site-to-site tunnel |
| SSL VPN | FortiGate | Remote access VPN |
| FortiGate Policies | FortiGate | Zone-based firewall rules |
| Syslog to Splunk | All devices | Forward logs to Splunk VM |
