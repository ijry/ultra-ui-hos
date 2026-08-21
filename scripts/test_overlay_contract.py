#!/usr/bin/env python3
"""Static contracts for the controlled overlay/popup/modal batch."""
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
    overlay = read("UPOverlay.ets")
    popup = read("UPPopup.ets")
    modal = read("UPModal.ets")

    for source, symbols in (
        (overlay, ("UPOverlayProps", "UPOverlay", "show", "opacity", "closeOnClickOverlay")),
        (popup, ("UPPopupProps", "UPPopup", "top", "bottom", "left", "right", "center", "closeable", "safeArea")),
        (modal, ("UPModalProps", "UPModal", "UPModalAction", "confirm", "cancel", "async", "done")),
    ):
        for symbol in symbols:
            assert symbol in source, f"missing {symbol}"

    assert "onShowChange" in overlay and "onClickOverlay" in overlay
    assert "onShowChange" in popup and "closeOnClickOverlay" in popup
    assert "onShowChange" in modal and "onAction" in modal
    assert re.search(r"done.*once|once.*done|completed", modal, re.IGNORECASE)
    assert re.search(r"show\s*:\s*UPRawValue\s*=\s*false", overlay)
    assert "overlay" in popup and "safeAreaInsetBottom" in popup and "safeAreaInsetTop" in popup
    assert "confirmText" in modal and "cancelText" in modal and "closeOnClickOverlay" in modal
    assert "onClose" in popup and "onOpen" in popup
    assert "confirm" in modal.lower() and "cancel" in modal.lower()

    for symbol in (
        "UPOverlay", "UPOverlayProps", "UPPopup", "UPPopupProps",
        "UPModal", "UPModalProps", "UPModalAction",
    ):
        assert re.search(rf"\b{symbol}\b", INDEX), f"not exported: {symbol}"

    print("overlay contract: PASS")


if __name__ == "__main__":
    main()
