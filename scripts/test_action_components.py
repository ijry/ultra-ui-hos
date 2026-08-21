#!/usr/bin/env python3
"""Static contracts for the icon/loading/button/tag batch."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMP = ROOT / "ultra-ui/src/main/ets/components"
INDEX = (ROOT / "ultra-ui/Index.ets").read_text(encoding="utf-8")


def read(name: str) -> str:
    path = COMP / name
    assert path.is_file(), f"missing component file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    icon = read("UPIcon.ets")
    loading = read("UPLoadingIcon.ets")
    button = read("UPButton.ets")
    tag = read("UPTag.ets")

    for source, symbols in (
        (icon, ("UPIconProps", "UPIcon", "customPrefix", "labelPos", "imgMode")),
        (loading, ("UPLoadingIconProps", "UPLoadingIcon", "spinner", "semicircle", "inactiveColor")),
        (button, ("UPButtonProps", "UPButton", "throttleTime", "loadingMode", "hairline", "openType")),
        (tag, ("UPTagProps", "UPTag", "closable", "plainFill", "autoBgColor")),
    ):
        for symbol in symbols:
            assert symbol in source, f"missing {symbol}"

    assert "disabled" in button and "loading" in button and "onClick" in button
    assert re.search(r"lastClick|throttle", button, re.IGNORECASE)
    assert "name" in tag and "onClose" in tag
    for symbol in ("UPIcon", "UPLoadingIcon", "UPButton", "UPTag", "UPButtonProps", "UPTagProps"):
        assert re.search(rf"\b{symbol}\b", INDEX), f"not exported: {symbol}"

    print("action components contract: PASS")


if __name__ == "__main__":
    main()
