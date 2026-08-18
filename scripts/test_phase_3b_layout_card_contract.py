#!/usr/bin/env python3
"""Static contracts for the phase 3B layout and card component batch."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "ultra-ui/Index.ets"
COMP = ROOT / "ultra-ui/src/main/ets/components"

ROW_COL_FIELDS = {
    "UPRow": ("gutter", "justify", "align", "customStyle", "contentBuilder", "onClick"),
    "UPCol": ("span", "offset", "justify", "align", "textAlign", "customStyle", "contentBuilder", "onClick"),
}

ROW_COL_DEFAULTS = {
    "UPRow": (("gutter", "0"), ("justify", "'start'"), ("align", "'center'")),
    "UPCol": (("span", "12"), ("offset", "0"), ("justify", "'start'"),
              ("align", "'stretch'"), ("textAlign", "'left'")),
}

FORBIDDEN = ("WebView", "FastView", ".xyfv", "http://", "https://", "@ohos.net", "request(")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def assert_field(source: str, field: str, component: str) -> None:
    assert re.search(rf"\b{re.escape(field)}\b", source), f"{component} missing {field}"


def assert_default(source: str, field: str, value: str, component: str) -> None:
    expected = rf"\b{re.escape(field)}\s*:\s*UPRawValue\s*=\s*{re.escape(value)}"
    assert re.search(expected, source), f"{component} missing default {field} = {value}"


def main() -> None:
    index = read(INDEX)
    for component, fields in ROW_COL_FIELDS.items():
        source = read(COMP / f"{component}.ets")
        assert f"class {component}Props" in source, f"missing {component}Props"
        assert f"export interface {component}Options" in source, f"missing {component}Options"
        assert re.search(rf"export struct {component}\b", source), f"missing {component} struct"
        for field in fields:
            assert_field(source, field, component)
        for field, value in ROW_COL_DEFAULTS[component]:
            assert_default(source, field, value, component)
        assert component in index, f"{component} is not publicly exported"
        assert f"{component}Props" in index, f"{component}Props is not publicly exported"
        assert f"{component}Options" in index, f"{component}Options is not publicly exported"
        for forbidden in FORBIDDEN:
            assert forbidden not in source, f"{component} contains forbidden token {forbidden!r}"

    print("phase 3B layout/card contract: PASS")


if __name__ == "__main__":
    main()
