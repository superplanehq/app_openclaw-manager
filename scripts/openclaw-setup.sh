#!/usr/bin/env bash
set -euo pipefail

AGENT_NAME="${AGENT_NAME:-openclaw-agent}"
AUTH_CHOICE="${AUTH_CHOICE:-skip}"
TARGET_VERSION="${TARGET_VERSION:-latest}"

export OPENCLAW_NOPROMPT=1
export DEBIAN_FRONTEND=noninteractive

if [[ -f /etc/openclaw/provision.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source /etc/openclaw/provision.env
  set +a
fi

if command -v loginctl >/dev/null 2>&1; then
  sudo loginctl enable-linger "${USER}" || true
fi

sudo mkdir -p /etc/openclaw
sudo chown "${USER}:${USER}" /etc/openclaw

echo "Installing OpenClaw..."
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

export PATH="$(npm prefix -g)/bin:${PATH}"

if [[ "${TARGET_VERSION}" != "latest" ]]; then
  npm install -g "openclaw@${TARGET_VERSION}"
fi

if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  OPENCLAW_GATEWAY_TOKEN="$(openssl rand -hex 32)"
  export OPENCLAW_GATEWAY_TOKEN
  echo "OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}" | sudo tee /etc/openclaw/provision.env >/dev/null
  sudo chmod 600 /etc/openclaw/provision.env
  sudo chown "${USER}:${USER}" /etc/openclaw/provision.env
fi

if [[ "${AUTH_CHOICE}" == "openai-api-key" && -n "${OPENAI_API_KEY:-}" ]]; then
  AUTH_ARGS=(--auth-choice openai-api-key --secret-input-mode plaintext --openai-api-key "${OPENAI_API_KEY}")
elif [[ "${AUTH_CHOICE}" == "anthropic-api-key" && -n "${ANTHROPIC_API_KEY:-}" ]]; then
  AUTH_ARGS=(--auth-choice anthropic-api-key --secret-input-mode plaintext --anthropic-api-key "${ANTHROPIC_API_KEY}")
elif [[ "${AUTH_CHOICE}" == "skip" ]]; then
  AUTH_ARGS=(--auth-choice skip)
else
  echo "No model API key found for ${AUTH_CHOICE}; onboarding with auth skipped." >&2
  AUTH_ARGS=(--auth-choice skip)
fi

openclaw onboard \
  --non-interactive \
  --mode local \
  "${AUTH_ARGS[@]}" \
  --gateway-auth token \
  --gateway-token-ref-env OPENCLAW_GATEWAY_TOKEN \
  --install-daemon \
  --skip-bootstrap \
  --skip-health \
  --accept-risk

if openclaw agents add --help >/dev/null 2>&1; then
  openclaw agents add "${AGENT_NAME}" 2>/dev/null || true
fi

openclaw gateway install --force
openclaw gateway start
openclaw doctor --non-interactive || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/openclaw-metrics.sh"
