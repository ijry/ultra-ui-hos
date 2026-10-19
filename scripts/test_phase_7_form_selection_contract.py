#!/usr/bin/env python3
"""Static contract checks for Phase 7 form-selection components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENT_DIR = ROOT / "ultra-ui/src/main/ets/components"
CONTROLLER = ROOT / "ultra-ui/src/main/ets/controllers/UPPickerController.ets"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS_DIR = ROOT / "sample/entry/src/main/ets/demos"
NOTE = ROOT / "docs/compatibility/phase-7.md"

COMPONENTS = {
    "UPSlider": ("UPSliderOptions", "UPSliderProps", "UPSliderChangeEvent", "UPSliderChangeMode", "formatByStep"),
    "UPPicker": ("UPPickerOptions", "UPPickerProps", "UPPickerChangeEvent", "UPPickerConfirmEvent", "TextPicker"),
    "UPSelect": ("UPSelectOptions", "UPSelectProps", "UPSelectOption", "UPSelectSelectEvent"),
}
DEMOS = {"slider": "SliderDemo.ets", "picker": "PickerDemo.ets", "picker-cascade": "PickerCascadeDemo.ets", "select": "SelectDemo.ets"}
DEFAULTS = {
    "UPSlider": (("min", "0"), ("step", "1"), ("blockSize", "18"), ("isRange", "false")),
    "UPPicker": (("confirmText", "UPI18n.t('up.common.confirm')"), ("confirmColor", "''"), ("immediateChange", "true")),
    "UPSelect": (("keyName", "'id'"), ("labelName", "'name'"), ("maxHeight", "'90vh'")),
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def assert_default(source: str, component: str, field: str, value: str) -> None:
    pattern = rf"\b{re.escape(field)}\b[^=;\n]*=\s*{re.escape(value)}\s*;"
    assert re.search(pattern, source), f"{component} missing default {field} = {value}"


def main() -> None:
    index = read(INDEX)
    for name, required in COMPONENTS.items():
        source = read(COMPONENT_DIR / f"{name}.ets")
        assert "@Component" in source, f"{name} missing @Component"
        assert f"export struct {name}" in source, f"missing public struct {name}"
        for token in required:
            assert token in source, f"{name} missing API token {token}"
        assert re.search(rf"export\s+\{{[^}}]*\b{name}\b", index, re.S), f"Index.ets missing {name} export"
        for field, value in DEFAULTS[name]:
            assert_default(source, name, field, value)

    controller = read(CONTROLLER)
    for method in ("setColumnValues", "setIndexs", "getIndexs", "getValues", "getColumnValues"):
        assert re.search(rf"\b{method}\s*\(", controller), f"controller missing {method}"
    assert "UPPickerController" in index, "Index.ets missing picker controller export"

    catalog = read(CATALOG)
    page = read(PAGE)
    for route, filename in DEMOS.items():
        source = read(DEMOS_DIR / filename)
        assert "@lingyun/ultra-ui-hos" in source, f"{filename} must use public HAR import"
        assert "ultra-ui/src" not in source, f"{filename} reaches into HAR internals"
        assert f"'{route}'" in catalog, f"catalog missing route {route}"
        assert f"'{route}'" in page, f"SamplePage missing route {route}"

    for source in (index, controller, catalog, page):
        assert "WebView" not in source
        assert "@kit.NetworkKit" not in source

    note = read(NOTE)
    for phrase in ("isRange", "UPPickerController", "UPPickerColumn", "skipped"):
        assert phrase in note, f"phase-7 compatibility note missing {phrase}"

    print("phase 7 form-selection contract: passed")


if __name__ == "__main__":
    main()
