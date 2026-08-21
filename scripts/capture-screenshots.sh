#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HDC_BIN="${HDC_BIN:-/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc}"
OUT_DIR="${1:-$ROOT/build/screenshots}"
OUT_FILE="$OUT_DIR/ultra-ui-hos.png"
mkdir -p "$OUT_DIR"

has_connected_target() {
  local targets
  targets="$("$HDC_BIN" list targets 2>/dev/null || true)"
  printf '%s\n' "$targets" | awk '
    NF && $0 !~ /^\[Empty\][[:space:]]*$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  '
}

if [[ ! -x "$HDC_BIN" ]] || ! has_connected_target; then
  echo "screenshots: skipped (no connected HarmonyOS device)"
  exit 0
fi

# hdc can return status 0 while printing a command-level [Fail] message. Treat
# that response as an unavailable device rather than claiming a screenshot.
snapshot_result="$("$HDC_BIN" shell snapshot_display -f /data/local/tmp/ultra-ui-hos.png 2>&1 || true)"
if printf '%s\n' "$snapshot_result" | grep -qE '^\[Fail\]|need connect-key|no connected'; then
  echo "screenshots: skipped (hdc could not access the HarmonyOS device)"
  exit 0
fi

# Truncate a prior output before receiving so a failed transfer cannot leave a
# stale image that looks like a fresh capture.
: > "$OUT_FILE"
receive_result="$("$HDC_BIN" file recv /data/local/tmp/ultra-ui-hos.png "$OUT_FILE" 2>&1 || true)"
if printf '%s\n' "$receive_result" | grep -qE '^\[Fail\]|need connect-key|no connected'; then
  echo "screenshots: skipped (hdc could not receive the screenshot)"
  exit 0
fi

png_signature="$(od -An -t x1 -N 8 "$OUT_FILE" 2>/dev/null | tr -d ' \n' || true)"
if [[ "$png_signature" != "89504e470d0a1a0a" ]]; then
  echo "screenshots: skipped (hdc did not produce a valid PNG)"
  exit 0
fi

echo "screenshots: captured $OUT_FILE"
