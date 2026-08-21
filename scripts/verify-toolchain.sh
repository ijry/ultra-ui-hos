#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVECO_HOME="${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}"
DEVECO_SDK_HOME="${DEVECO_SDK_HOME:-$DEVECO_HOME/sdk}"
NODE_BIN="${NODE_BIN:-$DEVECO_HOME/tools/node/bin/node}"
HVIGOR_BIN="${HVIGOR_BIN:-$DEVECO_HOME/tools/hvigor/bin/hvigorw}"
OHPM_BIN="${OHPM_BIN:-$DEVECO_HOME/tools/ohpm/bin/ohpm}"
HDC_BIN="${HDC_BIN:-$DEVECO_SDK_HOME/default/openharmony/toolchains/hdc}"
JAVA_HOME="${JAVA_HOME:-$DEVECO_HOME/jbr/Contents/Home}"
SDK_DIR="${SDK_DIR:-$DEVECO_SDK_HOME/default/openharmony}"

check_file() {
  local label="$1" path="$2"
  if [[ -x "$path" || -f "$path" ]]; then
    echo "$label: $path"
  else
    echo "$label: MISSING ($path)" >&2
    return 1
  fi
}

check_file node "$NODE_BIN"
check_file hvigor "$HVIGOR_BIN"
check_file ohpm "$OHPM_BIN"
check_file sdk "$SDK_DIR"
export DEVECO_SDK_HOME
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
export OHOS_BASE_SDK_HOME="${OHOS_BASE_SDK_HOME:-$SDK_DIR}"

"$NODE_BIN" --version
"$HVIGOR_BIN" --version
"$OHPM_BIN" --version
java -version
if [[ -x "$HDC_BIN" ]]; then
  "$HDC_BIN" version
  targets="$($HDC_BIN list targets 2>/dev/null || true)"
  if printf '%s\n' "$targets" | awk '
    NF && $0 !~ /^\[Empty\][[:space:]]*$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  '; then
    echo "device: available"
  else
    echo "device: skipped (no connected target)"
  fi
else
  echo "device: skipped (hdc not found)"
fi

echo "toolchain check: PASS"
