#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVECO_HOME="${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}"
DEVECO_SDK_HOME="${DEVECO_SDK_HOME:-$DEVECO_HOME/sdk}"
JAVA_HOME="${JAVA_HOME:-$DEVECO_HOME/jbr/Contents/Home}"
HVIGOR_BIN="${HVIGOR_BIN:-$DEVECO_HOME/tools/hvigor/bin/hvigorw}"
OHPM_BIN="${OHPM_BIN:-$DEVECO_HOME/tools/ohpm/bin/ohpm}"
HAR_PATH="$ROOT/ultra-ui/build/default/outputs/default/ultra_ui.har"
HAP_PATH="$ROOT/sample/entry/build/default/outputs/default/entry-default-unsigned.hap"

for required in "$HVIGOR_BIN" "$OHPM_BIN"; do
  if [[ ! -x "$required" ]]; then
    echo "missing executable: $required" >&2
    exit 1
  fi
done

export DEVECO_SDK_HOME
export JAVA_HOME
export OHOS_BASE_SDK_HOME="${OHOS_BASE_SDK_HOME:-$DEVECO_SDK_HOME/default/openharmony}"

cd "$ROOT"

# The sample consumes the packaged HAR rather than a source directory. Build it
# before ohpm resolves the local file dependency, so HAR resources are available
# to the HAP resource merger.
"$HVIGOR_BIN" clean assembleHar --no-daemon --parallel
"$OHPM_BIN" install --all --no-link
"$HVIGOR_BIN" assembleApp --no-daemon --parallel

python3 - "$HAR_PATH" "$HAP_PATH" <<'PY'
from __future__ import annotations

import sys
import tarfile
import zipfile
from pathlib import Path

har_path = Path(sys.argv[1])
hap_path = Path(sys.argv[2])

if not har_path.is_file():
    raise SystemExit(f"HAR was not produced: {har_path}")
if not hap_path.is_file():
    raise SystemExit(f"HAP was not produced: {hap_path}")

with tarfile.open(har_path, "r:gz") as har:
    har_names = set(har.getnames())
if "package/src/main/resources/rawfile/upicon.ttf" not in har_names:
    raise SystemExit("HAR is missing package/src/main/resources/rawfile/upicon.ttf")

with zipfile.ZipFile(hap_path) as hap:
    hap_names = set(hap.namelist())
if "resources/rawfile/upicon.ttf" not in hap_names:
    raise SystemExit("HAP is missing resources/rawfile/upicon.ttf")

print(f"build artifacts: HAR={har_path}")
print(f"build artifacts: HAP={hap_path}")
print("build resource contract: PASS (upicon.ttf is present in HAR and HAP)")
PY
