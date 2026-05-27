#!/usr/bin/env bash
set -euo pipefail

export PATH="$(npm prefix -g)/bin:${PATH}"

if [[ -f /etc/openclaw/provision.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source /etc/openclaw/provision.env
  set +a
fi

command="${1:?command required}"
shift || true

case "${command}" in
  stop)
    openclaw gateway stop
    ;;
  restart)
    openclaw gateway restart
    ;;
  upgrade)
    target_version="${1:-latest}"
    if [[ "${target_version}" == "latest" ]]; then
      openclaw update --yes
    else
      npm install -g "openclaw@${target_version}"
      openclaw gateway install --force
      openclaw gateway restart
    fi
    openclaw doctor --non-interactive || true
    ;;
  metrics)
    exec "$(dirname "$0")/openclaw-metrics.sh"
    ;;
  *)
    echo "unknown command: ${command}" >&2
    exit 1
    ;;
esac

"$(dirname "$0")/openclaw-metrics.sh"
