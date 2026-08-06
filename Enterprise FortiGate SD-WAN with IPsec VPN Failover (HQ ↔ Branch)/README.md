# Enterprise FortiGate SD-WAN with IPsec VPN Failover (HQ ↔ Branch)

A home-lab build simulating a two-site enterprise network with dual-WAN SD-WAN
failover over site-to-site IPsec VPN, built on FortiGate VMs (ESXi, Proxmox VE,
and Hyper-V) with MikroTik CHR routers acting as simulated ISPs.

## Topology

```
                         Shared "Internet" Segment
                              192.168.8.0/24
                              gateway 192.168.8.1
                    (single home router — see Known Limitations)
        ┌───────────────────────────┬───────────────────────────┐
        │                           │
 ISP-HQ MikroTik              ISP-Branch MikroTik
 WAN 192.168.8.40             WAN 192.168.8.50
 LAN 203.0.113.1/24           LAN 198.51.100.1/24
        │                           │
 FW-HQ-01 (WAN2/port3)       FW-BR-01 (WAN2/port3)
 203.0.113.2/24               198.51.100.2/24
        │                           │
 FW-HQ-01 (WAN1/port1)       FW-BR-01 (WAN1/port1)
 192.168.8.20/24              192.168.8.50/24
 (direct on shared segment)   (direct on shared segment)
        │                           │
 FW-HQ-01 LAN (port2)        FW-BR-01 LAN (port2)
 10.0.0.1/24                  172.16.0.1/24
```

Two IPsec tunnels connect the branch to HQ — one riding WAN1 (direct on the
shared segment) and one riding WAN2 (through each site's own simulated ISP
MikroTik). Both tunnels are members of an SD-WAN zone, with FortiGate's
Performance SLA health-check driving automatic failover between them.

## Addressing Reference

| Site   | LAN            | WAN1 (shared)     | WAN2               | ISP MikroTik LAN |
|--------|----------------|-------------------|---------------------|-------------------|
| HQ     | 10.0.0.1/24    | 192.168.8.20/24   | 203.0.113.2/24      | 203.0.113.1/24    |
| Branch | 172.16.0.1/24  | 192.168.8.50/24   | 198.51.100.2/24     | 198.51.100.1/24   |

## Hypervisors Used

| Site   | FortiGate host | ISP MikroTik host |
|--------|-----------------|--------------------|
| HQ     | Proxmox VE      | Proxmox VE         |
| Branch | ESXi            | ESXi               |

Mixing hypervisors across sites was intentional — it mirrors how real
multi-site deployments often run on whatever virtualization platform each
location already has, and it stress-tests the lab against platform-specific
quirks (vSwitch/bridge config, disk formats, boot firmware).

## Build Steps

### 1. Deploy MikroTik CHR "ISP" routers (one per site)
- WAN interface on the shared 192.168.8.0/24 segment, static IP, gateway 192.168.8.1
- LAN interface on the site's dedicated WAN2 subnet (no NAT — direct routing)
- Static route added so each ISP MikroTik can reach the other sites' WAN2
  subnets via the shared segment

### 2. Deploy FortiGate VMs (one per site)
- WAN1 (port1): static IP directly on the shared 192.168.8.0/24 segment
- WAN2 (port3): static IP on the site's dedicated ISP-facing subnet
- LAN (port2): static IP for the internal LAN

### 3. Build dual IPsec tunnels (per branch, to HQ)
- Tunnel 1: WAN1 ↔ WAN1 (direct, same shared segment, no ISP hop)
- Tunnel 2: WAN2 ↔ WAN2 (routed through each site's own ISP MikroTik)
- Phase 2 selectors: `0.0.0.0/0 ↔ 0.0.0.0/0`
- NAT traversal disabled (no NAT devices sit in the path — see IP addressing above)

### 4. SD-WAN configuration (per FortiGate)
- **SD-WAN Zone** (`overlay-zone`): both tunnel interfaces as members
- **Performance SLA** (`overlay_sla`):
  - Protocol: DNS
  - Detect Server: **1.1.1.1**
  - Participants: both tunnel members
  - Check interval: 500ms, Failures before inactive: 3, Restore link after: 5 checks
- **SD-WAN Rule**: LAN subnet → remote LAN subnet, outgoing interface =
  `overlay-zone`, strategy = Lowest Cost (SLA), tied to `overlay_sla`

### 5. Static routes
- Point routes to remote LAN subnets via `overlay-zone` (not individual
  tunnels) so SD-WAN can actually arbitrate between the two paths
- Point routes to the *other site's WAN2 subnet* via each local ISP MikroTik,
  scoped (not a default route), so tunnel underlay reachability doesn't
  compete with the real default route out WAN1

### 6. Firewall policies
- LAN → `overlay-zone` and `overlay-zone` → LAN, both directions, NAT disabled

## Known Limitations

### Simulated WAN links share one real public IP

This lab runs on a **single home internet connection**, so every site's
WAN1 interface (192.168.8.20/.50/.60) sits on the *same* physical LAN
segment behind the *same* home router and the *same* real public IP.
There is no genuine path diversity between "WAN1" and "WAN2" at the
physical/internet layer — both simulated ISPs (the MikroTik CHRs) ultimately
share the identical uplink back out to the real internet.

This has a direct, visible consequence in the Performance SLA statistics:
tunnels can show intermittent or elevated **packet loss** in the SD-WAN
health-check dashboard, because DNS/ping probes for both tunnel members are
contending for the same limited home-router uplink bandwidth and NAT state
table, rather than traversing genuinely independent carrier paths as they
would in a real enterprise dual-ISP deployment.

**In a production deployment**, WAN1 and WAN2 would terminate on physically
distinct ISPs (different last-mile circuits, different public IPs, different
failure domains), which is what makes real SD-WAN failover meaningful — a
fiber outage doesn't take down the LTE backup, etc. In this lab, a failure
of the shared home router would take down *both* simulated WAN paths
simultaneously, since they're not actually independent. The topology,
tunnel configuration, SD-WAN rule logic, and failover mechanics are all
built and tested exactly as they would be in production — only the
underlying physical internet diversity is simulated/collapsed for lab
purposes.

### Trial license constraints

FortiGate VMs used here run on Fortinet's free evaluation license, which
caps each unit to 1 vCPU, 2GB RAM, and a maximum of 3 firewall policies,
3 static routes, and 3 interfaces. This limits how many additional
branches or tunnels can be added to a single FortiGate before requiring
a full/paid license.

## Verification Commands

```
diagnose vpn ike gateway list
diagnose sys sdwan health-check status
diagnose sys sdwan service-status
execute ping <remote LAN gateway>
```

## Lessons Learned / Gotchas

- **Once SD-WAN is fully established, the main outstanding issue is packet
  loss** — not tunnel formation or routing. All "WAN" paths (WAN1 and WAN2,
  at both HQ and Branch) ultimately break out through the same single real
  public IP on the shared home router, since every simulated ISP MikroTik is
  itself behind that one uplink. With no genuine path diversity, the Performance SLA
  health-check probes for both tunnel members compete for the same uplink
  bandwidth/NAT state, which shows up as intermittent/elevated packet loss in
  the SD-WAN dashboard even though the configuration itself is correct. See
  "Simulated WAN links share one real public IP" under Known Limitations for
  the full explanation.
- **WAN2 interface netmask must match the actual local subnet** (e.g. /24),
  not /32 — a /32 mask prevents reaching even the directly-connected next-hop
  and silently breaks the tunnel underlay.
- **SD-WAN zone members can corrupt** into unresolved "Member N" placeholders
  after tunnel recreation; these must be removed and the real tunnel objects
  re-added by name, or health-check/rule matching silently fails.
- **Static routes to remote LANs must point at the SD-WAN zone**, not an
  individual tunnel interface — otherwise SD-WAN has nothing to arbitrate
  between and traffic is hard-pinned to one path.
- **A stray `0.0.0.0/0` default route via WAN2** (instead of a scoped route
  to only the remote WAN2 subnet) causes ECMP load-balancing between real
  internet and the isolated ISP segment, silently dropping ~50% of general
  traffic.
- **IPsec tunnels are on-demand by default** and won't auto-establish after
  a reboot until triggering traffic (or SLA health-check probes) hit them;
  `auto-negotiate enable` on the phase1-interface (CLI-only in this build)
  makes tunnels initiate on their own at boot.
