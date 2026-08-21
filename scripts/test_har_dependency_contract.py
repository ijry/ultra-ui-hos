#!/usr/bin/env python3
"""Contracts for preserving HAR resources when the sample HAP is built."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLE_PACKAGE = ROOT / "sample/entry/oh-package.json5"
BUILD_SCRIPT = ROOT / "scripts/build.sh"

EXPECTED_HAR = "file:../../ultra-ui/build/default/outputs/default/ultra_ui.har"


def main() -> None:
    package = json.loads(SAMPLE_PACKAGE.read_text(encoding="utf-8"))
    dependency = package["dependencies"]["@lingyun/ultra-ui-hos"]
    assert dependency == EXPECTED_HAR, (
        "the sample must consume the packaged HAR so dependency rawfile resources "
        "are merged into the HAP"
    )

    assert BUILD_SCRIPT.is_file(), "scripts/build.sh is required"
    script = BUILD_SCRIPT.read_text(encoding="utf-8")
    for phrase in (
        "assembleHar",
        "install --all --no-link",
        "assembleApp",
        "upicon.ttf",
    ):
        assert phrase in script, f"build script missing {phrase}"
    assert "clean assembleApp" not in script, (
        "the app build must not clean the HAR output before the final artifact check"
    )

    print("HAR dependency contract: PASS")


if __name__ == "__main__":
    main()
