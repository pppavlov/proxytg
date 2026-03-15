#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "[error] .env is missing. Run ./scripts/up.sh first."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

MTG_SECRET="${MTG_SECRET:-}"
MTG_HOST_PORT="${MTG_HOST_PORT:-3443}"
PUBLIC_HOST="${PUBLIC_HOST:-}"

if [[ -z "$MTG_SECRET" ]]; then
  echo "[error] MTG_SECRET is empty in .env"
  exit 1
fi

if [[ -z "$PUBLIC_HOST" ]]; then
  PUBLIC_HOST="$(curl -4fsS https://api.ipify.org || true)"
fi

if [[ -z "$PUBLIC_HOST" ]]; then
  echo "[warn] Could not auto-detect PUBLIC_HOST."
  echo "[warn] Set PUBLIC_HOST in .env and rerun ./scripts/print-links.sh"
  exit 0
fi

TG_LINK="tg://proxy?server=$PUBLIC_HOST&port=$MTG_HOST_PORT&secret=$MTG_SECRET"
TME_LINK="https://t.me/proxy?server=$PUBLIC_HOST&port=$MTG_HOST_PORT&secret=$MTG_SECRET"

cat > access.txt <<EOF
Telegram proxy link:
$TG_LINK

t.me link:
$TME_LINK
EOF

cat access.txt
