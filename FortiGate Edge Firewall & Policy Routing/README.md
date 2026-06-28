# FortiGate Edge Firewall & Policy Routing — VM 100

> **Home Lab Series** | Proxmox VE 9.1.9 | Part 2 of 4

Deploys a FortiGate VM as the primary edge firewall and gateway for the home lab. Covers WAN/LAN interface configuration, static routing to internal VLANs, firewall policies with NAT, and DNS settings.

---

## Lab Environment

| Parameter | Value |
|-----------|-------|
| VM ID | 100 |
| Hostname | Fortigate-FW-HQ |
| Platform | FortiOS |
| Proxmox Bridge (WAN) | vmbr1 — P2P link to CSR-ISP |
| Proxmox Bridge (LAN) | vmbr2 — Link to CSR-HQ-01 |

---

## Network Diagram

```
CSR-ISP Gi2 [203.0.113.1/30]
        |
        | vmbr1
  [FortiGate port1] — WAN — 203.0.113.2/30
  [FortiGate port2] — LAN — 10.0.0.1/24
        |
        | vmbr2
  [CSR-HQ-01 Gi1] — 10.0.0.2/24
        |
   (VLANs 10/20/30)
```

---

## Interface Summary

| Interface | IP Address | Role |
|-----------|------------|------|
| port1 (WAN) | 203.0.113.2/30 | Uplink to CSR-ISP Gi2 |
| port2 (LAN) | 10.0.0.1/24 | Internal gateway to CSR-HQ-01 |

---

## Configuration

### 3.1 Interface Configuration

```fortios
config system interface
  edit "port1"
    set alias "WAN"
    set ip 203.0.113.2 255.255.255.252
    set allowaccess ping
    set role wan
  next
  edit "port2"
    set alias "LAN"
    set ip 10.0.0.1 255.255.255.0
    set allowaccess ping https ssh
    set role lan
  next
end
```

### 3.2 Static Routes

```fortios
config router static
  edit 1
    set dst 0.0.0.0 0.0.0.0
    set gateway 203.0.113.1
    set device port1
  next
  edit 2
    set dst 10.10.10.0 255.255.255.0
    set gateway 10.0.0.2
    set device port2
  next
  edit 3
    set dst 10.20.20.0 255.255.255.0
    set gateway 10.0.0.2
    set device port2
  next
  edit 4
    set dst 10.30.30.0 255.255.255.0
    set gateway 10.0.0.2
    set device port2
  next
end
```

**Routing logic:**
- Default route `0.0.0.0/0` → CSR-ISP (`203.0.113.1`) via WAN
- VLAN10/20/30 specific routes → CSR-HQ-01 (`10.0.0.2`) via LAN

### 3.3 Firewall Policies

```fortios
config firewall policy
  edit 1
    set name "LAN-to-WAN"
    set srcintf "port2"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set nat enable
    set schedule "always"
    set service "ALL"
  next
  edit 2
    set name "WAN-to-LAN"
    set srcintf "port1"
    set dstintf "port2"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
  edit 3
    set name "Inter-VLAN"
    set srcintf "port2"
    set dstintf "port2"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
  next
end
```

### Policy Summary

| Policy Name | Src Interface | Dst Interface | Source | Destination | Action |
|-------------|---------------|---------------|--------|-------------|--------|
| LAN-to-WAN | port2 (LAN) | port1 (WAN) | All VLANs | All | ACCEPT + NAT |
| WAN-to-LAN | port1 (WAN) | port2 (LAN) | 203.0.113.0/30 | Any | ACCEPT |
| Inter-VLAN | port2 (LAN) | port2 (LAN) | 10.0.0.0/8 | Any | ACCEPT |

### 3.4 DNS Configuration

```fortios
config system dns
  set primary 8.8.8.8
  set secondary 10.20.20.100
end
```

| Parameter | Value |
|-----------|-------|
| Primary DNS | 8.8.8.8 (Google) |
| Secondary DNS | 10.20.20.100 (Internal ADNS server) |

---

## Key Concepts

### Edge NAT
Policy `LAN-to-WAN` applies NAT on egress from port1. All internal VLAN traffic (10.10.10.x, 10.20.20.x, 10.30.30.x) is translated to the FortiGate WAN IP (`203.0.113.2`) before exiting to the ISP.

### Per-VLAN Static Routes
Rather than a summary route, individual `/24` routes are configured per VLAN toward CSR-HQ-01. This supports selective routing and future policy-based routing expansion.

### Inter-VLAN Policy
Policy 3 allows traffic between VLANs to pass through port2 (hairpin). This is required because VLANs are on different subnets that all route back through the FortiGate LAN interface.

---

## Proxmox Setup Notes

1. Deploy FortiGate VM as VM 100 in Proxmox VE
2. Attach two network interfaces:
   - `net0` → `vmbr1` (WAN — shared P2P bridge with CSR-ISP Gi2)
   - `net1` → `vmbr2` (LAN — shared bridge with CSR-HQ-01 Gi1)
3. License FortiOS and apply config above

---

## Phase 3 Expansion — Security Hardening

| Task | Description |
|------|-------------|
| IDS/IPS | Enable FortiGate IPS profiles on LAN-to-WAN |
| VPN | Configure IPSec/SSL VPN tunnels |
| FortiAnalyzer | Add VM for centralized log analytics |
| Refined Policies | Replace `all` source/dest with address objects |

---

## Related Projects

| # | Project | Description |
|---|---------|-------------|
| 1 | [ISP Router Simulation](../1-isp-router-nat) | Upstream ISP router this firewall connects to |
| 3 | [Inter-VLAN Routing & DHCP](../3-inter-vlan-dhcp) | HQ core router on the LAN side |
| 4 | [VLAN Segmentation vIOS-L2](../4-vlan-segmentation-vios-l2) | Layer 2 switching downstream |
