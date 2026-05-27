# OpenClaw Manager

[![Launch in SuperPlane](http://superplane.com/badges/launch-in-superplane.svg)](http://app.superplane.com/install?repo=github.com/superplanehq/app_openclaw-manager)

Operate a real [OpenClaw](https://openclaw.ai) fleet on **AWS EC2** from SuperPlane — launch Ubuntu instances, install the official OpenClaw gateway, collect live host metrics, upgrade in place, and snapshot AMIs for backup.

Built with [SuperPlane](https://superplane.com).

## How it works

1. **Start** — EC2 user data bootstraps the host, loads credentials from SSM, installs OpenClaw (official installer, onboard, gateway). An SSH step waits for boot and verifies the install before registering the agent.
2. **Metrics sync** — every 5 minutes, SSH collects CPU/memory from the host and gateway status from `openclaw gateway status`
3. **Stop / Restart** — `openclaw gateway stop` and `openclaw gateway restart` over SSH
4. **Upgrade** — `openclaw update --yes` or `npm install -g openclaw@<version>` plus gateway restart
5. **Backup** — `aws.ec2.createImage` AMI snapshot (no reboot)
6. **Console** — fleet table backed by the `openclawAgents` memory namespace

## Prerequisites

- [SuperPlane](https://superplane.com) account
- **AWS** integration with EC2 permissions (launch, create AMI, EventBridge for AMI completion)
- EC2 key pair + SuperPlane SSH secret `openclaw-ec2-ssh-key` (private key)
- Public subnet with internet access (OpenClaw installer downloads packages)
- **Recommended:** `t3.small` (2 GB RAM) or larger per [OpenClaw hosting guidance](https://docs.openclaw.ai/install)
- Model API keys in AWS SSM (see below) or in `/etc/openclaw/provision.env`

## Model credentials (SSM)

Store a dotenv file in Parameter Store:

```bash
aws ssm put-parameter \
  --name "/openclaw/provision" \
  --type "SecureString" \
  --value $'ANTHROPIC_API_KEY=sk-ant-...\nAUTH_CHOICE=anthropic-api-key\n'
```

Attach an IAM instance profile to your EC2 launches that allows `ssm:GetParameter` on `/openclaw/provision`. The canvas user data fetches this into `/etc/openclaw/provision.env`, then runs the OpenClaw install script on first boot.

Supported keys in `provision.env`:

| Variable | Purpose |
|---|---|
| `OPENAI_API_KEY` | OpenAI provider for onboarding |
| `ANTHROPIC_API_KEY` | Anthropic provider for onboarding |
| `AUTH_CHOICE` | `anthropic-api-key` (default), `openai-api-key`, or `skip` |
| `OPENCLAW_GATEWAY_TOKEN` | Optional; auto-generated if omitted |

## Customization

| Setting | Default |
|---|---|
| Memory namespace | `openclawAgents` |
| AWS region | `us-east-1` |
| Instance type | `t3.small` |
| Root volume | 30 GiB gp3 |
| OS | Ubuntu 24.04 (`imageOs: ubuntu`) |
| SSH secret | `openclaw-ec2-ssh-key` |
| Metrics interval | 5 minutes |
| Default machine | `claw-prod-01` |
| Default agent | `research-bot` |
| Upgrade target | `latest` |

## License

MIT
