#!/usr/bin/env python3
"""Static contract checks for the ArkTS shared core."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "ultra-ui/src/main/ets/core"


def read(name: str) -> str:
    path = CORE / name
    assert path.is_file(), f"missing core file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    types = read("UPTypes.ets")
    theme = read("UPTheme.ets")
    config = read("UPConfig.ets")
    unit = read("UPUnit.ets")
    color = read("UPColor.ets")
    style = read("UPStyle.ets")
    diagnostics = read("UPDiagnostics.ets")
    builders = read("UPBuilders.ets")
    index = (ROOT / "ultra-ui/Index.ets").read_text(encoding="utf-8")

    for symbol in (
        "UPRawValue",
        "UPStyleInput",
        "UPCompatibilityEvent",
        "UPCompatibilityDiagnostics",
    ):
        assert re.search(rf"\b(?:type|interface|class)\s+{symbol}\b", types + diagnostics), symbol

    for name, value in {
        "primary": "#2979ff",
        "warning": "#ff9900",
        "success": "#19be6b",
        "error": "#fa3534",
        "info": "#909399",
        "main": "#303133",
        "content": "#606266",
        "tips": "#909399",
        "light": "#c0c4cc",
    }.items():
        assert value.lower() in theme.lower(), f"missing theme color {name}"

    assert "rpx" in unit and "viewportWidth" in unit
    assert "#RRGGBBAA" in color or "RRGGBBAA" in color
    for key in (
        "width",
        "height",
        "margin",
        "padding",
        "backgroundColor",
        "borderRadius",
        "fontSize",
        "opacity",
    ):
        assert key in style, f"missing style key {key}"
    assert "Set<string>" in diagnostics
    assert "Builder" in builders
    assert "UPTheme" in config

    for symbol in (
        "UPRawValue",
        "UPStyleInput",
        "UPTheme",
        "UPConfig",
        "UPUnit",
        "UPColor",
        "UPStyle",
        "UPCompatibilityDiagnostics",
    ):
        assert re.search(rf"\b{symbol}\b", index), f"not exported: {symbol}"

    print("core contract: PASS")


if __name__ == "__main__":
    main()
