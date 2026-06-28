# Proxmox VE 9.1.9 Network Lab

Enterprise-grade virtual networking lab built on **Proxmox VE 9.1.9**, simulating a real-world ISP-to-enterprise architecture with firewall security, VLAN segmentation, inter-VLAN routing, and monitoring services.

---

## 📌 Overview

This project demonstrates a fully virtualized enterprise network environment featuring:

- ISP simulation (Cisco CSR)
- FortiGate perimeter firewall
- Cisco inter-VLAN routing (Router-on-a-Stick)
- Layer 2 VLAN segmentation
- NAT/PAT internet access
- Splunk SIEM monitoring
- Active Directory DNS integration
- Scalable infrastructure design for future automation

---

## 🌐 Network Topology
<img width="1536" height="1024" alt="Networking Lab" src="https://github.com/user-attachments/assets/36a297d2-f981-4a23-b5ac-96115ed0bcb4" />
<img width="1897" height="862" alt="image" src="https://github.com/user-attachments/assets/2ad0dd66-aaec-4e60-9a51-d9402cf80669" />


---

## 🧱 Architecture Components

### 🛰 ISP Layer (CSR-ISP)
- WAN via Proxmox bridge (DHCP)
- NAT Overload (PAT)
- Static routing to internal networks
- Loopback interface (1.1.1.1) for simulation

---

### 🔐 Security Layer (FortiGate Firewall)
- Acts as perimeter security gateway
- Policies:
  - LAN → WAN (NAT enabled)
  - WAN → LAN (restricted access)
  - Inter-VLAN communication allowed
- Default route points to ISP router

---

### 🌐 Core Routing Layer (CSR-HQ-01)
- Inter-VLAN routing (802.1Q trunking)
- VLAN segmentation:
  - VLAN 10 → Management (10.10.10.0/24)
  - VLAN 20 → Servers (10.20.20.0/24)
  - VLAN 30 → Users (10.30.30.0/24)
- DHCP scopes per VLAN
- NAT applied at edge

---

### 🔀 Switching Layer (SW-HQ-01)
- 802.1Q trunk uplink to router
- Access ports assigned per VLAN
- Management SVI:
  - 10.10.10.2/24
- Default gateway: 10.10.10.1

---

## 🖥 Deployed Services

| Service | VLAN | IP Address | Role |
|--------|------|------------|------|
| LabControl | 10 | 10.10.10.x | Admin workstation |
| Splunk SIEM | 20 | 10.20.20.x | Log monitoring |
| AD DNS | 20 | 10.20.20.100 | Internal DNS |
| Docker Host | 30 | 10.30.30.x | Application hosting |

---

## 📡 IP Addressing Scheme

| Device | Interface | IP Address | Purpose |
|--------|----------|------------|----------|
| CSR-ISP | Gi1 | 192.168.8.39 | WAN uplink |
| CSR-ISP | Gi2 | 203.0.113.1/30 | ISP ↔ Firewall |
| FortiGate | port1 | 203.0.113.2 | WAN |
| FortiGate | port2 | 10.0.0.1 | LAN Gateway |
| CSR-HQ-01 | Gi1 | 10.0.0.2 | Firewall uplink |
| CSR-HQ-01 | VLAN10 | 10.10.10.1 | Management GW |
| CSR-HQ-01 | VLAN20 | 10.20.20.1 | Server GW |
| CSR-HQ-01 | VLAN30 | 10.30.30.1 | User GW |
| SW-HQ-01 | VLAN10 | 10.10.10.2 | Switch management |
| AD DNS | eth0 | 10.20.20.100 | DNS service |

---

## ⚙️ Key Features

- Fully virtualized enterprise lab on Proxmox
- Multi-tier network design (ISP → Firewall → Core → Access)
- VLAN segmentation with 802.1Q trunking
- NAT/PAT internet access simulation
- Centralized DNS and SIEM monitoring
- Real-world enterprise topology design

---

## 🚀 Future Improvements

### Phase 2: Routing
- OSPF implementation
- BGP ISP peering simulation
- Route redistribution

### Phase 3: Security
- ACL enforcement between VLANs
- IDS/IPS on FortiGate
- VPN (IPSec / SSL)
- FortiAnalyzer integration

### Phase 4: Automation
- Ansible configuration management
- Python Netmiko automation
- Backup automation scripts

### Phase 5: Monitoring
- Splunk dashboards
- SNMP monitoring
- Syslog centralization
- Performance alerting

---

## 📎 Purpose

This lab is designed to demonstrate practical skills in:

- Network engineering
- Cybersecurity architecture
- Enterprise routing & switching
- Firewall configuration
- Virtual infrastructure design
- Observability and monitoring

---

## 🧑‍💻 Author

**Athenkosi Pepengweni**  
IT Systems & Network Engineering Portfolio Project
