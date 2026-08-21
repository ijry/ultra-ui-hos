#!/usr/bin/env python3
"""Static contracts for the phase 2C form and selection batch."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMP = ROOT / "ultra-ui/src/main/ets/components"
DEMO = ROOT / "sample/entry/src/main/ets/demos"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"

COMPONENTS = {
    "UPForm": "form",
    "UPFormItem": "form-item",
    "UPCheckbox": "checkbox",
    "UPCheckboxGroup": "checkbox-group",
    "UPRadio": "radio",
    "UPRadioGroup": "radio-group",
}

FIELDS = {
    "UPForm": ("model", "rules", "errorType", "labelPosition", "labelWidth", "labelAlign", "borderBottom", "disabled", "onSubmit", "onValidate"),
    "UPFormItem": ("label", "prop", "required", "borderBottom", "labelPosition", "labelWidth", "labelAlign", "error", "rightIcon", "onClick"),
    "UPCheckbox": ("name", "shape", "size", "checked", "disabled", "activeColor", "inactiveColor", "iconSize", "iconColor", "label", "labelSize", "labelColor", "labelDisabled", "usedAlone", "onChange"),
    "UPCheckboxGroup": ("name", "modelValue", "value", "shape", "disabled", "activeColor", "inactiveColor", "size", "placement", "labelSize", "labelColor", "labelDisabled", "iconColor", "iconSize", "borderBottom", "iconPlacement", "gap", "onChange"),
    "UPRadio": ("name", "shape", "disabled", "label", "labelSize", "labelColor", "labelDisabled", "iconColor", "iconSize", "activeColor", "inactiveColor", "onChange"),
    "UPRadioGroup": ("name", "modelValue", "value", "shape", "disabled", "activeColor", "inactiveColor", "size", "placement", "labelSize", "labelColor", "labelDisabled", "iconColor", "iconSize", "borderBottom", "iconPlacement", "gap", "onChange"),
}

DEMOS = {
    "form": "FormDemo.ets",
    "form-item": "FormItemDemo.ets",
    "checkbox": "CheckboxDemo.ets",
    "checkbox-group": "CheckboxGroupDemo.ets",
    "radio": "RadioDemo.ets",
    "radio-group": "RadioGroupDemo.ets",
}

EVENTS = ("UPFormValidateEvent", "UPCheckboxChangeEvent", "UPCheckboxGroupChangeEvent", "UPRadioChangeEvent", "UPRadioGroupChangeEvent")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index, catalog, page = read(INDEX), read(CATALOG), read(PAGE)
    for component, route in COMPONENTS.items():
        source = read(COMP / f"{component}.ets")
        assert f"class {component}Props" in source, f"missing {component}Props"
        assert re.search(rf"export struct {component}\b", source), f"missing {component} struct"
        assert re.search(rf"\b{component}\b", index), f"{component} is not publicly exported"
        for field in FIELDS[component]:
            assert re.search(rf"\b{re.escape(field)}\b", source), f"{component} missing {field}"
        assert route in catalog, f"missing catalog route: {route}"
        assert re.search(rf"route === ['\"]{re.escape(route)}['\"]", page), f"missing page route: {route}"
        demo = read(DEMO / DEMOS[route])
        assert "@lingyun/ultra-ui-hos" in demo
        assert "ultra-ui/src" not in demo and "../src/main" not in demo
        assert "@Component" in demo and "build()" in demo
    for symbol in [*(f"{name}Props" for name in COMPONENTS), *EVENTS]:
        assert re.search(rf"\b{re.escape(symbol)}\b", index), f"{symbol} is not publicly exported"
    paths = [*(COMP / f"{name}.ets" for name in COMPONENTS), *(DEMO / name for name in DEMOS.values())]
    for forbidden in ("WebView", "FastView", ".xyfv", "http://", "https://", "@ohos.net", "request("):
        for path in paths:
            assert forbidden not in read(path), f"forbidden dependency {forbidden!r} in {path}"
    print("phase 2C form selection contract: PASS")


if __name__ == "__main__":
    main()
