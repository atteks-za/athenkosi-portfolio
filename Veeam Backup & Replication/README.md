# Veeam Backup & Replication 

A  project documenting the deployment of **Veeam Backup & Replication (Community Edition)** on a VMware **ESXi** host, and the configuration of a complete backup strategy covering both **virtual machines** and **standalone server**.

## Overview

This project sets up Veeam B&R as a VM on ESXi and uses it to protect two very different types of workloads through two backup job types:

- A **VMware VM backup job** for the `Exchange2019` virtual machine, backed up directly at the hypervisor level.
- A **Veeam Agent backup job** for `PEPS-ADNS01` (Windows Server 2022), a physical/standalone machine outside the virtual infrastructure, protected via an installed Veeam Agent and centrally managed by the backup server.

Together these demonstrate how a single Veeam server can back up both virtualized and physical infrastructure using the same repository, retention policy, and scheduling approach.

## Environment

| Component | Details |
|---|---|
| Hypervisor | VMware ESXi (accessed via ESXi Host Client, `https://192.168.8.200`) |
| Backup Software | Veeam Backup & Replication — Community Edition (Build 12.0.0.334 / 12.2.0.334) |
| Protected VM | Exchange2019 (55.7 GB) |
| Protected Physical Host | PEPS-ADNS01.pepsnet.co.za (Windows Server 2022) |
| Other Inventory | LabClientO2, LabClient01.pepsnet.co.za (Windows 11), Veeam Backup&Replication (backup server itself) |
| Backup Repository | Default Backup Repository (699.1 GB total, 633.1 GB free) |
| Datastore | datastore2 (125.43 GB) |
| Networking | VLAN20 |

## Backup Strategy

Both jobs share a consistent configuration approach:

- **Repository:** Default Backup Repository (`C:\Backup` on the Veeam server)
- **Retention policy:** 7 days, with GFS retention keeping 2 weekly full backups for archival
- **Full backups:** Synthetic full backups created periodically every Saturday
- **Schedule:** Runs automatically, daily at 14:00, with automatic retry (3 attempts, 10-minute wait) and an optional backup window to avoid impacting production hours
- **Guest processing:** Application-aware processing enabled for transactionally-consistent backups (with optional guest file system indexing / malware detection)

## Job 1 — VMware VM Backup (Exchange2019)

Configured directly against the ESXi host's VM inventory:

1. **Name the job** — `Exchange2019`, with an auto-generated description.
2. **Select virtual machines** — Add `Exchange2019` from the host inventory as the backup target.
3. **Configure storage** — Backup proxy (automatic selection), target repository, and 7-day retention with 2 weekly archival backups.
4. **Guest processing** — Application-aware processing and guest indexing/malware detection options.
5. **Set the schedule** — Daily at 14:00, with automatic retry and backup window options.
6. **Review the summary**, including the auto-generated PowerShell cmdlet for manually starting the job:
   ```powershell
   Get-VBRJob -Name "Exchange2019" | Start-VBRJob
   ```
7. **Run and monitor** — Job completes with a `Success` status.

**Result:**

- **Session Type:** Backup
- **Status:** Success
- **Start Time:** 2026-05-24 08:50
- **End Time:** 2026-05-24 18:22

## Job 2 — Veeam Agent Backup (ADNS / Physical Server)

Configured for a physical server discovered under **Inventory > Physical Infrastructure > Manually Added**. This job deploys and manages a Veeam Agent on the guest OS rather than backing up at the hypervisor level.

1. **Job Mode** — Type: `Server`. Mode: `Managed by backup server` (recommended for always-on workloads with a permanent connection to the backup server).
2. **Name the job** — `ADNS`, with an auto-generated description.
3. **Select computers** — Add `PEPS-ADNS01.pepsnet.co.za` to the protected computers list.
4. **Backup Mode** — `Entire computer` (full image backup, with deleted/temp/page files automatically excluded), as opposed to volume-level or file-level backup.
5. **Storage** — Default Backup Repository, 7-day retention, synthetic full backups on Saturdays, GFS: 2 weekly.
6. **Guest processing** — Application-aware processing enabled.
7. **Schedule** — Daily at 14:00, automatic retry (3 attempts, 10-minute wait).
8. **Summary** — Confirmed configuration:
   - Type: server
   - Mode: managed by backup server
   - Protected computers: `PEPS-ADNS01.pepsnet.co.za`
   - Backup mode: entire computer
   - Destination: Default Backup Repository
   - Retention policy: 7 days, GFS: 2 weekly
   - Application-aware processing: enabled
9. **Run and monitor** — Job runs immediately on finish, progressing from "building the list of objects to process" through to completion.

**Result:**

- **Session Type:** Windows Agent Backup
- **Status:** Success
- **Start Time:** 2026-05-30 22:55
- **End Time:** 2026-05-31 00:20
- **Duration:** 01:25:10
- **Processed:** 33.5 GB (100%), Read: 31.8 GB, Transferred: 19.6 GB (1.6x compression)
- **Bottleneck:** Network
- **Errors/Warnings:** 0

