# FortiGate Site-to-Site VPN — HQ ↔ Branch

Route-based (interface-mode) IPsec VPN between two FortiGate firewalls, connecting HQ's multi-VLAN network to a single-subnet Branch office, with full mesh reachability across all VLANs.

## Topology

```
        HQ (FW-HQ-01)                              Branch (FW-BR-01)
                                      
   ┌─────────────────────┐                    ┌─────────────────────┐
   │  LAN (port2)         │                   │  LAN (port2)         │
   │  10.0.0.0/24         │                   │  172.16.0.0/24       │
   │  10.10.10.0/24 (V10) │                   │                      │
   │  10.20.20.0/24 (V20) │                   │                      │
   │  10.30.30.0/24 (V30) │                   │                      │
   │                       │                   │                      │
   │  WAN (port1)          │                   │  WAN (port1)         │
   │  192.168.8.20 ────────┼───── Internet ────┼──── 192.168.8.50    │
   │                       │                   │                      │
   │  Tunnel: Branch-Tunnel│◄─────IPsec───────►│  Tunnel: HQ-Tunnel   │
   └─────────────────────┘                    └─────────────────────┘
```

## Device Summary

| | HQ (FW-HQ-01) | Branch (FW-BR-01) |
|---|---|---|
| WAN (port1) IP | 192.168.8.20 | 192.168.8.50 |
| LAN (port2) subnet | 10.0.0.0/24 | 172.16.0.0/24 |
| VLAN 10 | 10.10.10.0/24 | — |
| VLAN 20 | 10.20.20.0/24 | — |
| VLAN 30 | 10.30.30.0/24 | — |
| Local tunnel interface name | Branch-Tunnel | HQ-Tunnel |
| Tunnel binding interface | WAN (port1) | WAN (port1) |

## Phase 1 (IKE) Configuration

| Setting | Value |
|---|---|
| Remote gateway | Static IP address |
| Remote IP (HQ → Branch) | 192.168.8.50 |
| Remote IP (Branch → HQ) | 192.168.8.20 |
| Interface | WAN (port1) |
| Local gateway | Primary IP |
| IKE version | Version 2 |
| Authentication method | Pre-shared key |
| Encryption - Authentication | DES - SHA256 |
| Diffie-Hellman group | 14 |
| Key lifetime | 86400 seconds |



Tunnel status confirmed **Up** on both ends via `VPN > IPsec Tunnels`.

## Phase 2 (Quick Mode Selectors)

| Field | HQ (`Branch-Tunnel-P2`) | Branch (`HQ-Tunnel-P2`) |
|---|---|---|
| Local Address | 0.0.0.0/0.0.0.0 | 0.0.0.0/0.0.0.0 |
| Remote Address | 0.0.0.0/0.0.0.0 | 0.0.0.0/0.0.0.0 |

Selectors were widened from narrow per-subnet pairs to **0.0.0.0/0 ↔ 0.0.0.0/0** so that all HQ VLANs (not just the  10.0.0.0/24) can traverse the tunnel. With narrow selectors, VLAN traffic destined for Branch (or vice versa) was silently dropped before encryption ("no matching IPsec selector").

Traffic scoping is instead handled by:
- **Static routes** (which subnets go through the tunnel)
- **Firewall policies** (which subnets are actually permitted to pass)

## Static Routes

### HQ (FW-HQ-01)

| Destination | Gateway | Interface |
|---|---|---|
| 172.16.0.0/24 | — | Branch-Tunnel |
| 0.0.0.0/0 | 192.168.8.1 | WAN (port1) |

### Branch (FW-BR-01)

| Destination | Gateway | Interface |
|---|---|---|
| 0.0.0.0/0 | 192.168.8.1 | WAN (port1) |
| 10.0.0.0/8 | — | HQ-Tunnel |

> **Design note:** A single summarized **10.0.0.0/8** route was used on Branch instead of one static route per VLAN. This device has a 3-static-route limit, and per-VLAN /24 routes (10.0.0.0/24, 10.10.10.0/24, 10.20.20.0/24, 10.30.30.0/24) would exceed it. Since all HQ subnets fall under 10.x.x.x and Branch has no local use of that range (Branch LAN is 172.16.0.0/24), the /8 summary route safely covers all current and future HQ VLANs in a single entry.

## Firewall Policies

### HQ (FW-HQ-01)

| Policy | Source Interface | Destination Interface | Source | Destination | Action |
|---|---|---|---|---|---|
| IN_HQ-to-BranchLAN | Branch-Tunnel | LAN (port2) | all | all | ACCEPT |
| OUT_Branch-to-HQLAN | LAN (port2) | Branch-Tunnel | all | all | ACCEPT |
| LAN-to-WAN | LAN (port2) | WAN (port1) | all | all | ACCEPT (NAT) |

### Branch (FW-BR-01)

| Policy | Source Interface | Destination Interface | Source | Destination | Action |
|---|---|---|---|---|---|
| IN_HQ-to-BranchLAN | HQ-Tunnel | LAN (port2) | all | all | ACCEPT |
| OUT_BranchLAN-to-HQ | LAN (port2) | HQ-Tunnel | all | all | ACCEPT |
| LAN-to-WAN | LAN (port2) | WAN (port1) | all | all | ACCEPT (NAT) |

> Source/Destination set to **all** on both interface-pair policies rather than narrow per-VLAN address objects, so that new VLANs added at HQ are automatically permitted through the tunnel without additional firewall policy changes — traffic scoping is handled by the static routes instead.

## Verification

IPsec dashboard (Branch) confirmed:
- Tunnel: **Branch-Tunnel**, Remote Gateway **192.168.8.50**
- Status: Connected, uptime < 4 hours
- Phase 1: Branch-Tunnel / Phase 2 Selector: Branch-Tunnel-P2
- Traffic: 161.15 MB transferred

### Ping tests (from HQ-side host to Branch and reverse)

| Source subnet | Destination | Result |
|---|---|---|
| 10.0.0.0/24 | 172.16.0.1 | ✅ 4/4 packets, 0% loss |
| 10.10.10.0/24 (VLAN 10) | 172.16.0.1 | ✅ 4/4 packets, 0% loss |
| 10.20.20.0/24 (VLAN 20) | 172.16.0.1 | ✅ 4/4 packets, 0% loss |
| 10.30.30.0/24 (VLAN 30) | 172.16.0.1 | ✅ 4/4 packets, 0% loss |
| Branch LAN (172.16.0.0/24) | 10.0.0.1 (HQ) | ✅ 4/4 packets, 0% loss |

## Design Decisions / Lessons Learned

1. **Phase 2 selectors must be wide enough to cover all routed subnets.** Narrow selectors matching only the original LAN pair silently dropped VLAN traffic even though routing and firewall policy were otherwise correct.
3. **OSPF over IPsec was attempted and reverted.** Static unicast neighbor configuration isn't supported with `network-type point-to-point`, and switching to `point-to-multipoint` plus static neighbors still didn't resolve hello packets being sent but never received on either side — suspected multicast-over-IPsec limitation. Static routing was used as the reliable, working alternative.
4. **Route count limits matter at scale.** A single summarized route (10.0.0.0/8) is more maintainable and avoids hitting per-device static route limits compared to one entry per VLAN.
5. **Firewall policies set to `all`/`all`** avoid needing a policy update every time a new VLAN is added at HQ — only a routing change is needed for new subnets, not a firewall change.

## Outstanding / Possible Future Improvements

- [ ] Replace DES-SHA256 Phase 1 proposal with a stronger cipher (e.g. AES256-SHA256) for production use
- [ ] Revisit OSPF over IPsec with a different approach (e.g. GRE-over-IPsec to support multicast) if dynamic routing is desired
- [ ] Consider narrowing firewall policies from `all`/`all` to explicit subnet groups if tighter segmentation is required between HQ VLANs and Branch
