# Incident 01: High CPU Utilization

## Summary
A simulated CPU load test on the `mini-msp-ops` EC2 web server triggered the
`mini-msp-high-cpu` CloudWatch alarm, confirming that metric collection,
alarm evaluation, and SNS email notification are working end to end.

## Environment
- **Instance:** `mini-msp-ops-web-server` (t3.micro, Amazon Linux 2023)
- **Region:** us-east-1
- **Monitoring:** CloudWatch (default EC2 metrics) + custom CWAgent metrics
- **Alarm:** `mini-msp-high-cpu` — CPUUtilization > 70% (5 min period, 1 datapoint)
- **Notification:** SNS topic `mini-msp-ops-alerts` → email subscription

## Timeline (UTC, 2026-08-22)
| Time | Event |
|------|-------|
| ~21:20 | `stress-ng --cpu 2 --timeout 360s` executed on the instance to simulate sustained high CPU load |
| 21:21:00 | CloudWatch datapoint recorded CPUUtilization at 99.99% |
| 21:26:35 | Alarm `mini-msp-high-cpu` transitioned **OK → ALARM** (threshold of 70% breached) |
| 21:26 | SNS notification email received: "ALARM: mini-msp-high-cpu in US East (N. Virginia)" |
| ~21:30 | Confirmed `stress-ng` process still running via `ps aux \| grep stress-ng` |
| ~21:30 | Manually terminated the process: `sudo pkill stress-ng` |
| ~21:35–21:40 | CPU utilization dropped to idle levels; alarm returned to **OK** after the next evaluation period |

## Detection
- CloudWatch alarm `mini-msp-high-cpu` entered ALARM state after CPUUtilization
  exceeded the 70% threshold for one 5-minute evaluation period.
- Notification delivered via email through the `mini-msp-ops-alerts` SNS topic,
  containing the alarm name, threshold, breaching datapoint, and a deep link
  to the alarm in the AWS Console.

## Triage
1. Received alarm email and confirmed the alarm state in the CloudWatch console.
2. SSH'd into the instance to check running processes:
   ```bash
   ps aux | grep stress-ng
   ```
3. Checked live CPU usage:
   ```bash
   top -bn1 | head -5
   ```
4. Confirmed the load was the expected/known test process (`stress-ng`), not
   an unexpected workload — in a real incident this step is where you'd
   distinguish "known cause" from "needs investigation."

## Remediation
- Terminated the stress process manually:
  ```bash
  sudo pkill stress-ng
  ```
- Verified CPU utilization returned to normal (single-digit %) via `top`.
- Waited for the next CloudWatch evaluation period; alarm cleared back to OK.

## Root Cause
Deliberately induced for testing purposes — `stress-ng` was used to simulate
a CPU-bound workload (e.g. a runaway process, inefficient application code,
or a traffic spike) to validate the monitoring and alerting pipeline.

## Prevention / Follow-up
- In a production environment, an alarm alone doesn't fix the problem — this
  would ideally trigger an Auto Scaling policy (scale out) rather than
  requiring manual intervention.
- Consider adding a second, higher-severity alarm (e.g. >90% for 15 minutes)
  to distinguish transient spikes from sustained resource exhaustion.
- Document expected CPU baseline for this instance so future alarms can be
  tuned to reduce false positives.

## What This Demonstrates
- End-to-end monitoring pipeline: metric → alarm → SNS → email, working correctly
- Manual incident response workflow: SSH triage → process identification → remediation → verification
- Understanding of CloudWatch alarm evaluation periods and their effect on response timing
