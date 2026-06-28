
<!-- ═══════════ HERO ═══════════ -->
<div class="hero">
  <div class="hero-eyebrow">▶ Home Lab Documentation</div>
  <h1>Proxmox VE 9.1.9</span> Network Lab</h1>
  <p class="hero-sub">
    Enterprise-grade network simulation running on Proxmox VE. ISP simulation, FortiGate perimeter security, Cisco inter-VLAN routing, and Layer 2 VLAN segmentation — all virtualised.
  </p>
  <div class="badge-row">
    <span class="badge badge-red">FortiOS</span>
    <span class="badge badge-blue">Cisco IOS-XE</span>
    <span class="badge badge-green">vIOS-L2</span>
    <span class="badge badge-yellow">Proxmox VE</span>
    <span class="badge badge-purple">Splunk SIEM</span>
    <span class="badge badge-blue">802.1Q</span>
    <span class="badge badge-green">NAT / PAT</span>
    <span class="badge badge-red">DHCP</span>
  </div>
</div>

<div class="container">

  <!-- ═══════════ TOPOLOGY ═══════════ -->
  <div class="section-label">// Network Topology</div>
  <div class="topo-block">
<pre>
  <span class="t-dim">┌─────────────────────────────────────────────────────────────┐</span>
  <span class="t-dim">│</span>                      PROXMOX VE 9.1.9                       <span class="t-dim">│</span>
  <span class="t-dim">│</span>                                                             <span class="t-dim">│</span>
  <span class="t-dim">│</span>   Internet (vmbr0 — DHCP)                                   <span class="t-dim">│</span>
  <span class="t-dim">│</span>         │                                                   <span class="t-dim">│</span>
  <span class="t-dim">│</span>   <span class="t-isp">[ VM 104 · CSR-ISP ]</span>  192.168.8.39 ← DHCP               <span class="t-dim">│</span>
  <span class="t-dim">│</span>     GE1 ↑ WAN    GE2 ↓ LAN  203.0.113.1/30   Lo0 1.1.1.1  <span class="t-dim">│</span>
  <span class="t-dim">│</span>                       │ vmbr1                              <span class="t-dim">│</span>
  <span class="t-dim">│</span>   <span class="t-fw">[ VM 100 · FortiGate-FW-HQ ]</span>                             <span class="t-dim">│</span>
  <span class="t-dim">│</span>     port1 (WAN) 203.0.113.2/30                             <span class="t-dim">│</span>
  <span class="t-dim">│</span>     port2 (LAN) 10.0.0.1/24                               <span class="t-dim">│</span>
  <span class="t-dim">│</span>                       │ vmbr2                              <span class="t-dim">│</span>
  <span class="t-dim">│</span>   <span class="t-router">[ VM 107 · CSR-HQ-01 ]</span>  Gi1 10.0.0.2/24                 <span class="t-dim">│</span>
  <span class="t-dim">│</span>     Gi2.10  10.10.10.1/24  VLAN 10 — Management            <span class="t-dim">│</span>
  <span class="t-dim">│</span>     Gi2.20  10.20.20.1/24  VLAN 20 — Servers               <span class="t-dim">│</span>
  <span class="t-dim">│</span>     Gi2.30  10.30.30.1/24  VLAN 30 — Users                 <span class="t-dim">│</span>
  <span class="t-dim">│</span>                       │ vmbr3 (802.1Q Trunk)               <span class="t-dim">│</span>
  <span class="t-dim">│</span>   <span class="t-sw">[ VM 106 · SW-HQ-01 ]</span>   Gi0/0 Trunk                     <span class="t-dim">│</span>
  <span class="t-dim">│</span>     │ Gi0/3 VLAN10      │ Gi0/2 VLAN20      │ Gi0/1 VLAN30 <span class="t-dim">│</span>
  <span class="t-dim">│</span>     │ vmbr4             │ vmbr5             │ vmbr6         <span class="t-dim">│</span>
  <span class="t-dim">│</span>   <span class="t-vm">[ VM 102 ]</span>       <span class="t-vm">[ VM 101 ]</span>  <span class="t-vm">[ VM 105 ]</span>  <span class="t-vm">[ VM 103 ]</span>  <span class="t-dim">│</span>
  <span class="t-dim">│</span>   LabControl       Splunk         ADNS       DockerHost     <span class="t-dim">│</span>
  <span class="t-dim">│</span>   10.10.10.x       10.20.20.x  10.20.20.100  10.30.30.x    <span class="t-dim">│</span>
  <span class="t-dim">└─────────────────────────────────────────────────────────────┘</span>
</pre>
  </div>

 

  <!-- DETAIL 1 -->
  <div class="detail" id="detail-1">
    <div class="detail-header">
      <h3>CSR-ISP — Full Configuration Detail</h3>
      <button class="detail-close" onclick="toggle(1)">✕ Close</button>
    </div>
    <div class="detail-body">
      <div class="detail-section">
        <div class="detail-section-title">Interfaces</div>
        <div class="iface-row">
          <span class="iface-name">GigabitEthernet1</span>
          <span class="iface-ip">DHCP → 192.168.8.39</span>
        </div>
        <div class="iface-row"><span class="iface-desc">WAN — Internet uplink from Proxmox. NAT outside.</span></div>
        <div class="iface-row">
          <span class="iface-name">GigabitEthernet2</span>
          <span class="iface-ip">203.0.113.1/30</span>
        </div>
        <div class="iface-row"><span class="iface-desc">LAN — P2P link to FortiGate port1. NAT inside.</span></div>
        <div class="iface-row">
          <span class="iface-name">Loopback0</span>
          <span class="iface-ip">1.1.1.1/32</span>
        </div>
        <div class="iface-row"><span class="iface-desc">Simulated public IP for BGP/traceroute testing.</span></div>
      </div>
      <div class="detail-section">
        <div class="detail-section-title">Key Config Snippets</div>
        <div class="code-block">
<span class="comment">! NAT overload (PAT)</span>
<span class="keyword">access-list</span> <span class="value">1</span> permit <span class="ip">203.0.113.0</span> 0.0.0.3
<span class="keyword">access-list</span> <span class="value">1</span> permit <span class="ip">10.0.0.0</span> 0.255.255.255
<span class="keyword">ip nat</span> inside source list <span class="value">1</span>
  interface GigabitEthernet1 overload

<span class="comment">! Return route for internal nets</span>
<span class="keyword">ip route</span> <span class="ip">10.0.0.0</span> 255.0.0.0 <span class="ip">203.0.113.2</span>
        </div>
      </div>
    </div>
  </div>

  <!-- DETAIL 2 -->
  <div class="detail" id="detail-2">
    <div class="detail-header">
      <h3>FortiGate-FW-HQ — Full Configuration Detail</h3>
      <button class="detail-close" onclick="toggle(2)">✕ Close</button>
    </div>
    <div class="detail-body">
      <div class="detail-section">
        <div class="detail-section-title">Policies</div>
        <div style="font-size:12px; margin-bottom:10px;">
          <div style="display:flex; gap:8px; align-items:center; padding:6px 0; border-bottom:1px solid var(--border);">
            <span style="font-family:var(--mono);color:var(--green);">●</span>
            <span style="font-family:var(--mono);color:var(--text);">LAN-to-WAN</span>
            <span style="color:var(--muted);font-size:11px;">port2 → port1 · ACCEPT + NAT</span>
          </div>
          <div style="display:flex; gap:8px; align-items:center; padding:6px 0; border-bottom:1px solid var(--border);">
            <span style="font-family:var(--mono);color:var(--yellow);">●</span>
            <span style="font-family:var(--mono);color:var(--text);">WAN-to-LAN</span>
            <span style="color:var(--muted);font-size:11px;">port1 → port2 · ACCEPT</span>
          </div>
          <div style="display:flex; gap:8px; align-items:center; padding:6px 0;">
            <span style="font-family:var(--mono);color:var(--blue);">●</span>
            <span style="font-family:var(--mono);color:var(--text);">Inter-VLAN</span>
            <span style="color:var(--muted);font-size:11px;">port2 → port2 · ACCEPT</span>
          </div>
        </div>
        <div class="detail-section-title" style="margin-top:16px;">Static Routes</div>
        <div style="font-size:12px;">
          <div style="font-family:var(--mono); padding:4px 0; color:var(--muted);">0.0.0.0/0 → <span style="color:var(--green)">203.0.113.1</span> <span style="color:var(--muted)">via port1</span></div>
          <div style="font-family:var(--mono); padding:4px 0; color:var(--muted);">10.10.10.0/24 → <span style="color:var(--green)">10.0.0.2</span> <span style="color:var(--muted)">via port2</span></div>
          <div style="font-family:var(--mono); padding:4px 0; color:var(--muted);">10.20.20.0/24 → <span style="color:var(--green)">10.0.0.2</span> <span style="color:var(--muted)">via port2</span></div>
          <div style="font-family:var(--mono); padding:4px 0; color:var(--muted);">10.30.30.0/24 → <span style="color:var(--green)">10.0.0.2</span> <span style="color:var(--muted)">via port2</span></div>
        </div>
      </div>
      <div class="detail-section">
        <div class="detail-section-title">Key Config Snippets</div>
        <div class="code-block">
<span class="comment"># Default route to ISP</span>
<span class="keyword">config</span> router static
  edit <span class="value">1</span>
    set dst <span class="ip">0.0.0.0 0.0.0.0</span>
    set gateway <span class="ip">203.0.113.1</span>
    set device port1
  next
end

<span class="comment"># LAN-to-WAN with NAT</span>
<span class="keyword">config</span> firewall policy
  edit <span class="value">1</span>
    set name <span class="value">"LAN-to-WAN"</span>
    set srcintf <span class="value">"port2"</span>
    set dstintf <span class="value">"port1"</span>
    set action accept
    set nat enable
  next
end
        </div>
      </div>
    </div>
  </div>

  <!-- DETAIL 3 -->
  <div class="detail" id="detail-3">
    <div class="detail-header">
      <h3>CSR-HQ-01 — Full Configuration Detail</h3>
      <button class="detail-close" onclick="toggle(3)">✕ Close</button>
    </div>
    <div class="detail-body">
      <div class="detail-section">
        <div class="detail-section-title">DHCP Pools</div>
        <div style="font-size:12px;">
          <div style="padding:8px 0; border-bottom:1px solid var(--border);">
            <span style="font-family:var(--mono);color:var(--blue);">VLAN10-Management</span><br>
            <span style="color:var(--muted);">10.10.10.11–199 · GW 10.10.10.1 · Lease 1d</span>
          </div>
          <div style="padding:8px 0; border-bottom:1px solid var(--border);">
            <span style="font-family:var(--mono);color:var(--blue);">VLAN20-Servers</span><br>
            <span style="color:var(--muted);">10.20.20.11–199 · GW 10.20.20.1 · Lease 1d</span>
          </div>
          <div style="padding:8px 0;">
            <span style="font-family:var(--mono);color:var(--blue);">VLAN30-Users</span><br>
            <span style="color:var(--muted);">10.30.30.11–199 · GW 10.30.30.1 · Lease 1d</span>
          </div>
        </div>
        <div class="detail-section-title" style="margin-top:16px;">DNS for all pools</div>
        <div style="font-family:var(--mono);font-size:12px;color:var(--muted);">
          Primary: <span style="color:var(--green)">8.8.8.8</span><br>
          Secondary: <span style="color:var(--green)">10.20.20.100</span> (ADNS VM)
        </div>
      </div>
      <div class="detail-section">
        <div class="detail-section-title">Key Config Snippets</div>
        <div class="code-block">
<span class="comment">! 802.1Q subinterface — VLAN 10</span>
<span class="keyword">interface</span> GigabitEthernet2.10
 encapsulation dot1Q <span class="value">10</span>
 ip address <span class="ip">10.10.10.1</span> 255.255.255.0
 ip nat inside

<span class="comment">! DHCP pool — VLAN 10</span>
<span class="keyword">ip dhcp pool</span> VLAN10-Management
 network <span class="ip">10.10.10.0</span> 255.255.255.0
 default-router <span class="ip">10.10.10.1</span>
 dns-server <span class="ip">8.8.8.8 10.20.20.100</span>
 lease <span class="value">1</span>

<span class="comment">! NAT overload for all VLANs</span>
<span class="keyword">ip nat</span> inside source list NAT_ACL
  interface GigabitEthernet1 overload
        </div>
      </div>
    </div>
  </div>

  <!-- DETAIL 4 -->
  <div class="detail" id="detail-4">
    <div class="detail-header">
      <h3>SW-HQ-01 — Full Configuration Detail</h3>
      <button class="detail-close" onclick="toggle(4)">✕ Close</button>
    </div>
    <div class="detail-body">
      <div class="detail-section">
        <div class="detail-section-title">VLAN &amp; Port Map</div>
        <div style="font-size:12px;">
          <div style="display:grid;grid-template-columns:60px 80px 1fr;gap:4px 12px;font-family:var(--mono);padding-bottom:8px;border-bottom:1px solid var(--border);color:var(--muted);margin-bottom:8px;">
            <span>VLAN</span><span>Port</span><span>VMs</span>
          </div>
          <div style="display:grid;grid-template-columns:60px 80px 1fr;gap:4px 12px;font-family:var(--mono);padding:4px 0;border-bottom:1px solid var(--border);">
            <span style="color:var(--accent)">10</span><span style="color:var(--muted)">Gi0/3</span><span style="color:var(--text)">LabControl</span>
          </div>
          <div style="display:grid;grid-template-columns:60px 80px 1fr;gap:4px 12px;font-family:var(--mono);padding:4px 0;border-bottom:1px solid var(--border);">
            <span style="color:var(--blue)">20</span><span style="color:var(--muted)">Gi0/2</span><span style="color:var(--text)">Splunk, ADNS</span>
          </div>
          <div style="display:grid;grid-template-columns:60px 80px 1fr;gap:4px 12px;font-family:var(--mono);padding:4px 0;">
            <span style="color:var(--green)">30</span><span style="color:var(--muted)">Gi0/1</span><span style="color:var(--text)">DockerHost</span>
          </div>
        </div>
        <div class="detail-section-title" style="margin-top:16px;">Management SVI</div>
        <div style="font-family:var(--mono);font-size:12px;color:var(--muted);">
          Vlan10 SVI: <span style="color:var(--green)">10.10.10.2/24</span><br>
          Default GW: <span style="color:var(--green)">10.10.10.1</span>
        </div>
      </div>
      <div class="detail-section">
        <div class="detail-section-title">Key Config Snippets</div>
        <div class="code-block">
<span class="comment">! 802.1Q trunk to CSR-HQ-01</span>
<span class="keyword">interface</span> GigabitEthernet0/0
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan <span class="value">10,20,30</span>

<span class="comment">! Access port — VLAN 20 Servers</span>
<span class="keyword">interface</span> GigabitEthernet0/2
 switchport mode access
 switchport access vlan <span class="value">20</span>

<span class="comment">! Management SVI</span>
<span class="keyword">interface</span> Vlan10
 ip address <span class="ip">10.10.10.2</span> 255.255.255.0
<span class="keyword">ip</span> default-gateway <span class="ip">10.10.10.1</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ═══════════ IP TABLE ═══════════ -->
  <div class="section-label">// Complete IP Address Reference</div>
  <div class="ip-table-wrap">
    <div style="background:var(--surface);border:1px solid var(--border);border-radius:8px;overflow:hidden;">
      <table>
        <thead>
          <tr>
            <th>Device</th>
            <th>Interface</th>
            <th>IP Address</th>
            <th>Subnet</th>
            <th>Role</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="td-mono" style="color:var(--accent)">CSR-ISP</td>
            <td class="td-mono td-muted">Gi1</td>
            <td class="td-green">192.168.8.39</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">WAN Uplink</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--accent)">CSR-ISP</td>
            <td class="td-mono td-muted">Gi2</td>
            <td class="td-green">203.0.113.1</td>
            <td class="td-mono td-muted">/30</td>
            <td><span class="role-pill">ISP→FW Link</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--accent)">CSR-ISP</td>
            <td class="td-mono td-muted">Lo0</td>
            <td class="td-green">1.1.1.1</td>
            <td class="td-mono td-muted">/32</td>
            <td><span class="role-pill">Simulated Public IP</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:#ff9500">FortiGate</td>
            <td class="td-mono td-muted">port1</td>
            <td class="td-green">203.0.113.2</td>
            <td class="td-mono td-muted">/30</td>
            <td><span class="role-pill">WAN (to ISP)</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:#ff9500">FortiGate</td>
            <td class="td-mono td-muted">port2</td>
            <td class="td-green">10.0.0.1</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">LAN Gateway</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--blue)">CSR-HQ-01</td>
            <td class="td-mono td-muted">Gi1</td>
            <td class="td-green">10.0.0.2</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">Uplink to FW</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--blue)">CSR-HQ-01</td>
            <td class="td-mono td-muted">Gi2.10</td>
            <td class="td-green">10.10.10.1</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">VLAN 10 GW</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--blue)">CSR-HQ-01</td>
            <td class="td-mono td-muted">Gi2.20</td>
            <td class="td-green">10.20.20.1</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">VLAN 20 GW</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--blue)">CSR-HQ-01</td>
            <td class="td-mono td-muted">Gi2.30</td>
            <td class="td-green">10.30.30.1</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">VLAN 30 GW</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--green)">SW-HQ-01</td>
            <td class="td-mono td-muted">Vlan10</td>
            <td class="td-green">10.10.10.2</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">Mgmt SVI</span></td>
          </tr>
          <tr>
            <td class="td-mono" style="color:var(--purple)">ADNS</td>
            <td class="td-mono td-muted">eth0</td>
            <td class="td-green">10.20.20.100</td>
            <td class="td-mono td-muted">/24</td>
            <td><span class="role-pill">Internal DNS</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <!-- ═══════════ PHASES ═══════════ -->
  <div class="section-label">// Lab Expansion Roadmap</div>
  <div class="phases">
    <div class="phase-card">
      <div class="phase-num">PHASE 2</div>
      <div class="phase-title">Routing Protocols</div>
      <ul class="phase-items">
        <li>OSPF — replace statics</li>
        <li>BGP — ISP peering sim</li>
        <li>Route redistribution</li>
      </ul>
    </div>
    <div class="phase-card">
      <div class="phase-num">PHASE 3</div>
      <div class="phase-title">Security</div>
      <ul class="phase-items">
        <li>ACLs — inter-VLAN</li>
        <li>FortiGate IDS/IPS</li>
        <li>IPSec / SSL VPN</li>
        <li>FortiAnalyzer</li>
      </ul>
    </div>
    <div class="phase-card">
      <div class="phase-num">PHASE 4</div>
      <div class="phase-title">Automation</div>
      <ul class="phase-items">
        <li>Ansible playbooks</li>
        <li>Python Netmiko</li>
        <li>Config backups</li>
        <li>Firmware updates</li>
      </ul>
    </div>
    <div class="phase-card">
      <div class="phase-num">PHASE 5</div>
      <div class="phase-title">Monitoring</div>
      <ul class="phase-items">
        <li>Syslog → Splunk</li>
        <li>SNMP polling</li>
        <li>BGP/OSPF dashboards</li>
        <li>Interface alerts</li>
      </ul>
    </div>
  </div>

</div>

<!-- ═══════════ FOOTER ═══════════ -->
<div class="footer">
  <div class="footer-left">Proxmox VE 9.1.9 · FortiGate Edition · June 2026</div>
  <div class="footer-right">Prepared for Wavenet Network Engineer Role</div>
</div>

<script>
  function toggle(n) {
    const detail = document.getElementById('detail-' + n);
    const isOpen = detail.classList.contains('open');

    // Close all
    document.querySelectorAll('.detail').forEach(d => d.classList.remove('open'));

    // Open clicked one unless it was already open
    if (!isOpen) detail.classList.add('open');
  }
</script>
</body>
</html>
