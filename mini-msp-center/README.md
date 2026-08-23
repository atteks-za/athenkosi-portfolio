# Mini MSP Ops Center

A hands-on cloud operations project simulating the first-responder monitoring
and incident-response workflow of an MSP (Managed Service Provider) cloud
operations team — built to demonstrate practical AWS, CloudWatch, and
incident-response skills.

## What This Is

A small but complete AWS environment — provisioned entirely with Terraform —
instrumented with custom CloudWatch monitoring, real alerting via SNS, and
two documented, deliberately-triggered incidents showing the full detect →
triage → remediate → recover lifecycle.

This isn't a tutorial project copy-pasted from docs. Every alarm in this repo
has actually fired, sent a real email notification, and been resolved
through manual triage — the runbooks are written from that first-hand
experience, not hypothetical scenarios.

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │              AWS VPC                 │
                    │           10.0.0.0/16                │
                    │                                       │
                    │  ┌─────────────────────────────┐    │
                    │  │      Public Subnet            │    │
                    │  │      10.0.1.0/24              │    │
                    │  │                                │    │
                    │  │   ┌──────────────────┐        │    │
                    │  │   │   EC2 Instance    │        │    │
                    │  │   │   (t3.micro)      │        │    │
                    │  │   │   nginx + CWAgent │        │    │
                    │  │   └────────┬──────────┘        │    │
                    │  └────────────┼──────────────────┘    │
                    │               │                        │
                    │        Internet Gateway                │
                    └───────────────┼────────────────────────┘
                                    │
                     ┌──────────────┴───────────────┐
                     │                                │
              ┌──────▼──────┐                ┌───────▼────────┐
              │  CloudWatch  │                │   IAM Role      │
              │  - Metrics   │                │  (least-priv,   │
              │  - Alarms    │                │   CWAgent only) │
              │  - Dashboard │                └─────────────────┘
              └──────┬───────┘
                     │
              ┌──────▼───────┐
              │  SNS Topic    │
              │ mini-msp-ops- │
              │    alerts     │
              └──────┬────────┘
                     │
              ┌──────▼───────┐
              │  Email Alert  │
              └───────────────┘
```

## What's Built

### Infrastructure (Terraform)
- VPC with public subnet, internet gateway, and route table
- Security group scoped to SSH (from a single IP) and HTTP only
- EC2 instance running nginx, with an IAM instance profile attached
  (least-privilege — `CloudWatchAgentServerPolicy` only, no broad access)
- All infrastructure defined as code in [`terraform/`](./terraform), fully
  reproducible with `terraform apply` / `terraform destroy`

### Monitoring
- **Default EC2 metrics**: CPU utilization, status checks, network
- **Custom metrics via CloudWatch Agent**: memory usage, disk usage, swap
  usage — none of which are available out of the box, all configured
  manually via agent config
- **Dashboard**: single-pane view of all key metrics
  (`mini-msp-ops-dashboard`)

### Alerting
Four CloudWatch alarms, all wired to a shared SNS topic with email
notification:

| Alarm | Metric | Threshold |
|---|---|---|
| `mini-msp-high-cpu` | CPUUtilization | > 70% |
| `mini-msp-ops-high-disk` | disk_used_percent | > 85% |
| `mini-msp-ops-high-memory` | mem_used_percent | > 80% |
| `mini-ops-status-check-failed` | StatusCheckFailed | >= 1 |

### Incident Response
Two incidents were deliberately triggered, observed end-to-end, and
documented as runbooks:

- [`runbooks/incident-01-high-cpu.md`](./runbooks/incident-01-high-cpu.md) —
  simulated CPU load via `stress-ng`, alarm fired, manually remediated
- [`runbooks/incident-02-high-disk.md`](./runbooks/incident-02-high-disk.md) —
  simulated disk exhaustion via `fallocate`, alarm fired, manually remediated

Each runbook follows a consistent format: Summary → Timeline → Detection →
Triage → Remediation → Root Cause → Prevention/Follow-up — the same
structure used in real MSP/SRE postmortems.

## ITSM / Ticketing Integration

A FreshService trial instance was used to demonstrate the incident → ticket
workflow that closes the loop between alerting and formal incident tracking.

**Ticket #INC-1** (`ALARM: mini-msp-high-cpu in US East (N. Virginia)`) was
created reflecting the real CPU alarm from
[incident-01-high-cpu.md](./runbooks/incident-01-high-cpu.md) — same alarm
name, same threshold-breach reason string, same timestamp — logged with
Priority and auto-calculated First Response / Resolution SLA due dates.

### How this would be automated in production

In a live deployment, ticket creation would be automatic rather than manual,
using the same SNS topic already wired to the CloudWatch alarms:

```
CloudWatch Alarm → SNS Topic (mini-msp-ops-alerts) → Lambda function → FreshService API
```

1. **SNS topic** publishes the alarm payload (already built and tested — see
   alarm/email screenshots in the runbooks) — no change needed here.
2. **Lambda function**, subscribed to the same SNS topic, parses the alarm
   message (`AlarmName`, `NewStateReason`, `StateChangeTime`, region) and
   maps it to a FreshService ticket payload.
3. **FreshService API call** (`POST /api/v2/tickets`) creates the ticket
   automatically, using the API key from Profile Settings, with fields like:
   ```json
   {
     "subject": "ALARM: {{AlarmName}} in {{Region}}",
     "description": "{{NewStateReason}}",
     "priority": 3,
     "status": 2,
     "source": 2
   }
   ```
4. **Resolution sync (optional, further maturity)**: when the alarm returns
   to OK, a second Lambda invocation could auto-update the ticket status or
   post a resolution comment, closing the loop without manual updates.

This wasn't wired end-to-end in this project (the ticket above was created
manually to demonstrate the target format), since it would require
re-provisioning the AWS infrastructure — Lambda, an SNS subscription, and
FreshService API credentials — after the environment had already been torn
down. The manual ticket demonstrates the exact output format; the automation
path above is the natural next step to remove the human from that loop.

## Repo Structure

```
mini-msp-ops-center/
├── terraform/              # Infrastructure as code (VPC, EC2, IAM, security groups)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── runbooks/                # Incident documentation
│   ├── incident-01-high-cpu.md
│   └── incident-02-high-disk.md
└── README.md                 # This file
```

## Setup

```bash
cd terraform
terraform init
terraform plan -var="my_ip=<YOUR_IP>/32"
terraform apply -var="my_ip=<YOUR_IP>/32"
```

After apply, the EC2 instance's public IP is available via:
```bash
terraform output instance_public_ip
```

The CloudWatch Agent was installed and configured manually via SSH
(`dnf install amazon-cloudwatch-agent`, custom `config.json` for mem/disk/swap
metrics) — a deliberate choice to show hands-on agent configuration rather
than hiding it entirely behind automation, though in a production setup this
would be baked into the EC2 user-data or managed via SSM.

## Teardown

To avoid ongoing AWS charges, the environment is destroyed when not actively
being demoed:
```bash
terraform destroy -var="my_ip=<YOUR_IP>/32"
```

## Limitations

- This is a single-account, single-instance environment — a real MSP setup
  would be multi-account/multi-tenant. Kept single-account here to focus
  time on the monitoring and incident-response workflow rather than
  account-management plumbing.
- The IAM user used to run Terraform started with broad permissions during
  initial setup and should be scoped down for any long-term use — noted here
  deliberately rather than glossed over, since recognizing and calling out a
  security gap is itself part of the Ops mindset.
- Status-check-failure alarm was configured and validated in the console but
  not deliberately triggered (doing so safely typically requires stopping/
  degrading the instance in a way that's harder to control precisely) — the
  CPU and disk incidents demonstrate the same alert → triage → remediate
  pattern.
