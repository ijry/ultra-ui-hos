#!/usr/bin/env python3
"""Static contracts for Toast controller/host and cell components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMP = ROOT / "ultra-ui/src/main/ets/components"
CTRL = ROOT / "ultra-ui/src/main/ets/controllers"
INDEX = (ROOT / "ultra-ui/Index.ets").read_text(encoding="utf-8")


def read(directory: Path, name: str) -> str:
    path = directory / name
    assert path.is_file(), f"missing source file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    controller = read(CTRL, "UPToastController.ets")
    host = read(COMP, "UPToastHost.ets")
    group = read(COMP, "UPCellGroup.ets")
    cell = read(COMP, "UPCell.ets")

    for symbol in (
        "UPToastOptions", "UPToastController", "duration", "-1", "clearTimeout",
        "position", "center", "onComplete", "show", "close",
    ):
        assert symbol in controller, f"missing {symbol}"
    assert re.search(r"current|replace", controller, re.IGNORECASE)
    assert re.search(r"duration.*>.*0|>.*0.*duration", controller)

    for symbol in ("UPToastHost", "mask", "overlay", "UPToastState", "aboutToAppear", "aboutToDisappear"):
        assert symbol in host, f"missing {symbol}"

    for symbol in ("UPCellGroupProps", "UPCellGroup", "border", "title"):
        assert symbol in group, f"missing {symbol}"
    for symbol in (
        "UPCellProps", "UPCell", "title", "label", "value", "required", "arrow",
        "disabled", "clickable", "name", "url", "linkType", "onClick",
    ):
        assert symbol in cell, f"missing {symbol}"
    assert re.search(r"no.?op|diagnos", cell, re.IGNORECASE)
    assert "UPCellClickEvent" in cell

    for symbol in (
        "UPToastHost", "UPToastController", "UPToastOptions", "UPToastCompleteEvent",
        "UPCellGroup", "UPCellGroupProps", "UPCell", "UPCellProps", "UPCellClickEvent",
    ):
        assert re.search(rf"\b{symbol}\b", INDEX), f"not exported: {symbol}"

    print("feedback components contract: PASS")


if __name__ == "__main__":
    main()
