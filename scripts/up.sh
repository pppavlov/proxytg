#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./scripts/render-config.sh
docker compose up -d
./scripts/print-links.sh || true

echo
docker compose ps
