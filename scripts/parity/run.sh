#!/usr/bin/env bash
# Offline byte-for-byte parity between the ArkTS core modules and upstream uview-plus JS.
# Skips cleanly when node or the upstream checkout is unavailable, so it never blocks CI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVECO_HOME="${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}"
NODE_BIN="${NODE_BIN:-node}"
if ! command -v "$NODE_BIN" >/dev/null 2>&1; then
  NODE_BIN="$DEVECO_HOME/tools/node/bin/node"
fi
UPSTREAM="${PARITY_UPSTREAM:-/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus}"

if [[ ! -x "$NODE_BIN" ]] && ! command -v "$NODE_BIN" >/dev/null 2>&1; then
  echo "parity: skipped (node not found)"
  exit 0
fi
if [[ ! -d "$UPSTREAM/libs" ]]; then
  echo "parity: skipped (upstream checkout not found at $UPSTREAM)"
  exit 0
fi

NODE_VERSION="$("$NODE_BIN" --version 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
if [[ -z "$NODE_VERSION" || "$NODE_VERSION" -lt 22 ]]; then
  echo "parity: skipped (node >= 22 required for --experimental-strip-types, found ${NODE_VERSION:-none})"
  exit 0
fi

SHIMS="$(mktemp -d)"
trap 'rm -rf "$SHIMS"' EXIT
python3 "$ROOT/scripts/parity/build_shims.py" "$SHIMS" >/dev/null

# UPFormat converts dates by UTC on purpose (see docs/compatibility/phase-24.md); the
# upstream JS uses local Date methods, so the diff only holds under a fixed UTC zone.
TZ=UTC PARITY_SHIMS="$SHIMS" PARITY_UPSTREAM="$UPSTREAM" \
  "$NODE_BIN" --experimental-strip-types --no-warnings "$ROOT/scripts/parity/parity.mjs"
