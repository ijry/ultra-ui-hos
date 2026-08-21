#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAN_DIRS=("$ROOT/ultra-ui/src" "$ROOT/sample/entry/src")
for dir in "${SCAN_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue
  if grep -RInE --include='*.ets' --include='*.ts' --include='*.json5' --include='*.json' \
      -e 'WebView' -e 'webview' -e 'FastView' -e '\.xyfv' -e 'JSON[[:space:]]*render' \
      -e 'fetch\(' -e 'axios' -e 'http://|https://' "$dir"; then
    echo "boundary check: forbidden runtime/network reference found" >&2
    exit 1
  fi
done
echo "boundary check: PASS"
