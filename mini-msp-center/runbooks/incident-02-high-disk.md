# Incident 02: High Disk Utilization

## Summary
A simulated disk-fill test on the `mini-msp-ops` EC2 web server pushed root
volume utilization to ~98%, triggering the `mini-msp-ops-high-disk`
CloudWatch alarm and confirming the custom CWAgent disk metric, alarm
evaluation, and SNS email notification pipeline all work correctly.

## Environment
- **Instance:** `mini-msp-ops-web-server` (t3.micro, Amazon Linux 2023)
- **Region:** us-east-1
- **Root volume:** `/dev/nvme0n1p1`, 30G total
- **Monitoring:** CWAgent custom metric `disk_used_percent` (path: `/`)
- **Alarm:** `mini-msp-ops-high-disk` — disk_used_percent > 85% (5 min period, 1 datapoint)
- **Notification:** SNS topic `mini-msp-ops-alerts` → email subscription

## Timeline (UTC, 2026-08-22)
| Time | Event |
|------|-------|
| ~21:40 | Began filling disk incrementally using `fallocate -l 5G` in `~/diskfill/` |
| ~21:42 | Disk usage crossed 31% → 48% → 64% → 81% as fill files were added one at a time |
| ~21:44 | Disk usage reached 98% (5 x 5G fill files created) |
| ~21:45–21:50 | `mini-msp-ops-high-disk` alarm transitioned **OK → ALARM** after the 85% threshold was breached; confirmed via SNS email notification |
| after alarm | Remediated by removing fill files: `rm -f ~/diskfill/fill*` |
| after remediation | Disk usage dropped back to baseline (~14%); alarm returned to **OK** on next evaluation period |

## Detection
- CloudWatch alarm `mini-msp-ops-high-disk` entered ALARM state once
  `disk_used_percent` on the root volume exceeded 85% for one 5-minute
  evaluation period.
- Notification delivered via email through the `mini-msp-ops-alerts` SNS topic.
- Note: because the CWAgent collects disk metrics on a 60-second interval and
  the alarm evaluates on a 5-minute period, there was a short delay between
  disk usage crossing 85% and the alarm actually firing — an expected
  characteristic of the monitoring setup, not a fault.

## Triage
1. Received alarm email and confirmed ALARM state in the CloudWatch console.
2. SSH'd into the instance and checked actual disk usage:
   ```bash
   df -h /
   ```
3. Identified the cause: test fill files (`fill1`–`fill5`) created under
   `~/diskfill/` via `fallocate`, deliberately consuming ~25G to simulate a
   disk-filling event (e.g. runaway log files, a stuck upload, or an
   application writing excessive temp data).

## Remediation
- Removed the fill files:
  ```bash
  rm -f ~/diskfill/fill*
  ```
- Verified usage dropped back to baseline:
  ```bash
  df -h /
  ```
- Waited for the next CloudWatch evaluation period; alarm cleared back to OK.

## Root Cause
Deliberately induced for testing purposes — `fallocate` was used to rapidly
consume disk space and simulate a real-world disk-exhaustion scenario (e.g.
unrotated logs, a runaway process writing to disk, or an incomplete cleanup
job).

## Prevention / Follow-up
- In production, this would ideally be paired with automated log rotation
  (`logrotate`) and/or a scheduled cleanup job for temp directories, so disk
  pressure is prevented rather than just detected.
- Consider adding a second, lower-severity "warning" alarm (e.g. >70%) to
  give earlier notice before the volume becomes critical.
- For a production MSP environment, this alarm would typically also trigger
  automated remediation (e.g. a Lambda function to clear known-safe temp
  paths) rather than requiring manual SSH intervention.

## What This Demonstrates
- Correct configuration and validation of a custom CloudWatch metric
  (`disk_used_percent`) via the CloudWatch agent, beyond default EC2 metrics
- Understanding of alarm evaluation timing and its effect on detection delay
- Manual incident response workflow: SSH triage → root cause identification
  → remediation → verification of recovery
