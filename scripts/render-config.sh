#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "[info] Created .env from .env.example"
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

MTG_IMAGE="${MTG_IMAGE:-nineseconds/mtg:2}"
MTG_BIND_PORT="${MTG_BIND_PORT:-3128}"
MTG_FAKE_TLS_DOMAIN="${MTG_FAKE_TLS_DOMAIN:-cloudflare.com}"
MTG_SECRET="${MTG_SECRET:-}"

if [[ -z "$MTG_SECRET" ]]; then
  echo "[info] MTG_SECRET is empty, generating a new one..."
  MTG_SECRET="$(docker run --rm "$MTG_IMAGE" generate-secret --hex "$MTG_FAKE_TLS_DOMAIN" | tr -d '\r\n')"

  if grep -q '^MTG_SECRET=' .env; then
    sed -i "s|^MTG_SECRET=.*|MTG_SECRET=$MTG_SECRET|" .env
  else
    printf '\nMTG_SECRET=%s\n' "$MTG_SECRET" >> .env
  fi
  echo "[info] MTG_SECRET generated and saved into .env"
fi

if [[ ! "$MTG_SECRET" =~ ^ee[0-9a-fA-F]+$ ]]; then
  echo "[error] MTG_SECRET must be hex and start with 'ee'"
  echo "[error] Current value: $MTG_SECRET"
  exit 1
fi

cat > config.toml <<EOF
secret = "$MTG_SECRET"
bind-to = "0.0.0.0:$MTG_BIND_PORT"
EOF

echo "[info] config.toml updated"
