#!/usr/bin/env python3
"""Static contracts for the phase 2B avatar and standalone input batch."""
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
    "UPAvatar": "avatar",
    "UPAvatarGroup": "avatar-group",
    "UPInput": "input",
    "UPTextarea": "textarea",
    "UPSwitch": "switch",
    "UPRate": "rate",
    "UPNumberBox": "number-box",
}

DEMO_FILES = {
    "avatar": "AvatarDemo.ets",
    "avatar-group": "AvatarGroupDemo.ets",
    "input": "InputDemo.ets",
    "textarea": "TextareaDemo.ets",
    "switch": "SwitchDemo.ets",
    "rate": "RateDemo.ets",
    "number-box": "NumberBoxDemo.ets",
}

EVENT_TYPES = (
    "UPAvatarClickEvent",
    "UPInputChangeEvent",
    "UPInputConfirmEvent",
    "UPTextareaChangeEvent",
    "UPSwitchChangeEvent",
    "UPRateChangeEvent",
    "UPNumberBoxChangeEvent",
)

REQUIRED_FIELDS = {
    "UPAvatar": ("src", "text", "shape", "size", "icon", "randomBgColor", "defaultUrl", "onClick"),
    "UPAvatarGroup": ("urls", "maxCount", "shape", "showMore", "size", "gap", "keyName"),
    "UPInput": ("modelValue", "value", "type", "clearable", "password", "maxlength", "placeholder", "showWordLimit", "prefixIcon", "suffixIcon", "border", "readonly", "onInput", "onChange", "onConfirm", "onClear"),
    "UPTextarea": ("modelValue", "value", "placeholder", "height", "count", "autoHeight", "maxlength", "border", "onInput", "onChange", "onConfirm"),
    "UPSwitch": ("modelValue", "value", "loading", "disabled", "activeValue", "inactiveValue", "asyncChange", "onChange"),
    "UPRate": ("modelValue", "value", "count", "allowHalf", "minCount", "activeIcon", "inactiveIcon", "onChange"),
    "UPNumberBox": ("modelValue", "value", "min", "max", "step", "integer", "disabledInput", "showMinus", "showPlus", "decimalLength", "onChange", "onPlus", "onMinus", "onBlur"),
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    catalog = read(CATALOG)
    page = read(PAGE)

    for component, route in COMPONENTS.items():
        source = read(COMP / f"{component}.ets")
        assert f"class {component}Props" in source, f"missing {component}Props"
        assert re.search(rf"export struct {component}\b", source), f"missing {component} struct"
        assert re.search(rf"export \{{[^}}]*\b{component}\b", index, re.DOTALL) or re.search(
            rf"export \{{\s*{component}\b", index
        ), f"{component} is not publicly exported"
        for field in REQUIRED_FIELDS[component]:
            assert re.search(rf"\b{re.escape(field)}\b", source), f"{component} missing compatible field {field}"
        assert route in catalog, f"missing catalog route: {route}"
        assert re.search(rf"route === ['\"]{re.escape(route)}['\"]", page), f"missing page route: {route}"

        demo = read(DEMO / DEMO_FILES[route])
        assert "@lingyun/ultra-ui-hos" in demo, f"{route} demo must import public HAR entry"
        assert "ultra-ui/src" not in demo and "../src/main" not in demo
        assert "@Component" in demo and "build()" in demo
        assert not re.search(r"=>\s*this\.", demo), f"{route} demo callbacks must use explicit void block bodies"

    for symbol in [*(f"{name}Props" for name in COMPONENTS), *EVENT_TYPES]:
        assert re.search(rf"\b{re.escape(symbol)}\b", index), f"{symbol} is not publicly exported"

    paths = [*(COMP / f"{name}.ets" for name in COMPONENTS), *(DEMO / name for name in DEMO_FILES.values())]
    for forbidden in ("WebView", "FastView", ".xyfv", "http://", "https://", "@ohos.net", "request("):
        for path in paths:
            assert forbidden not in read(path), f"forbidden dependency {forbidden!r} in {path}"

    print("form entry contract: PASS")


if __name__ == "__main__":
    main()
