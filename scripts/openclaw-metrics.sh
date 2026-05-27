#!/usr/bin/env bash
set -euo pipefail

export PATH="$(npm prefix -g)/bin:${PATH}"

if [[ -f /etc/openclaw/provision.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source /etc/openclaw/provision.env
  set +a
fi

cores="$(nproc)"
load1="$(awk '{print $1}' /proc/loadavg)"
cpu_usage="$(awk -v l="${load1}" -v c="${cores}" 'BEGIN { v=int((l/c)*100); if (v>100) v=100; if (v<0) v=0; print v }')"

memory_usage="$(free | awk '/Mem:/ { if ($2 == 0) print 0; else printf "%d", ($3/$2)*100 }')"

openclaw_version="$(openclaw --version 2>/dev/null | head -1 | tr -d '\r\n' || echo "unknown")"

gateway_status="unknown"
if openclaw gateway status --json >/tmp/openclaw-gateway-status.json 2>/dev/null; then
  if command -v jq >/dev/null 2>&1; then
    gateway_status="$(jq -r '.service.state // .service.running // "unknown"' /tmp/openclaw-gateway-status.json 2>/dev/null || echo "unknown")"
  else
    gateway_status="$(openclaw gateway status 2>/dev/null | head -1 | tr -d '\r\n' || echo "unknown")"
  fi
else
  gateway_status="$(openclaw gateway status 2>/dev/null | head -1 | tr -d '\r\n' || echo "stopped")"
fi

rm -f /tmp/openclaw-gateway-status.json

echo "cpu_usage=${cpu_usage}"
echo "memory_usage=${memory_usage}"
echo "openclaw_version=${openclaw_version}"
echo "gateway_status=${gateway_status}"
