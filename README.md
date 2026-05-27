# OpenClaw Manager

[![Launch in SuperPlane](http://superplane.com/badges/launch-in-superplane.svg)](http://app.superplane.com/install?repo=github.com/superplanehq/app_openclaw-manager)

Operate your OpenClaw agent fleet from a single SuperPlane console — start and stop machines, track CPU and memory, upgrade agents, and trigger backups from row actions or canvas triggers.

Built with [SuperPlane](https://superplane.com).

## How it works

1. **Start** — register an agent in memory with machine name, agent name, and version
2. **Stop / Restart** — update agent status and simulated resource metrics in memory
3. **Upgrade** — bump an agent to a target version from the console table or canvas trigger
4. **Backup** — invoke the backup flow for a selected machine
5. **Console** — KPIs, charts, and a live agent table backed by the `openclawAgents` memory namespace

The canvas uses SuperPlane memory nodes to track fleet state. The console reads that memory and exposes row actions that trigger canvas flows directly.

## Prerequisites

- [SuperPlane](https://superplane.com) account
- SuperPlane CLI installed ([installation guide](https://docs.superplane.com/installation/cli))

## Quick start

**Option A — Launch in SuperPlane** (recommended)

Click the badge above. SuperPlane installs `canvas.yaml` and `console.yaml` from this repo in one step.

**Option B — CLI**

1. Import the canvas:

```bash
superplane canvases create --file canvas.yaml
```

2. Import the console YAML from the SuperPlane UI (Console → Import), or re-run the install flow so `console.yaml` is applied automatically.

3. Open the console and run **Start OpenClaw server** to register your first agent

## Customization

| Setting | Default |
|---|---|
| Memory namespace | `openclawAgents` |
| Default machine | `claw-prod-01` |
| Default agent | `research-bot` |
| Target upgrade version | `1.5.0` |
| Start version | `1.4.2` |

Update trigger payloads in `canvas.yaml` and row-action payloads in `console.yaml` to match your fleet.

## License

MIT
