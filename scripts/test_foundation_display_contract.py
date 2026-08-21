#!/usr/bin/env python3
"""Static contracts for the phase 2A foundation/display component batch."""
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
    "UPLine": "line",
    "UPGap": "gap",
    "UPLink": "link",
    "UPTitle": "title",
    "UPBadge": "badge",
    "UPDivider": "divider",
    "UPSkeleton": "skeleton",
    "UPLineProgress": "line-progress",
    "UPLoadmore": "loadmore",
}

DEMO_FILES = {
    "line": "LineDemo.ets",
    "gap": "GapDemo.ets",
    "link": "LinkDemo.ets",
    "title": "TitleDemo.ets",
    "badge": "BadgeDemo.ets",
    "divider": "DividerDemo.ets",
    "skeleton": "SkeletonDemo.ets",
    "line-progress": "LineProgressDemo.ets",
    "loadmore": "LoadmoreDemo.ets",
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
        assert route in catalog, f"missing catalog route: {route}"
        assert re.search(rf"route === ['\"]{re.escape(route)}['\"]", page), f"missing page route: {route}"

        demo = read(DEMO / DEMO_FILES[route])
        assert "@lingyun/ultra-ui-hos" in demo, f"{route} demo must import public HAR entry"
        assert "ultra-ui/src" not in demo and "../src/main" not in demo
        assert "@Component" in demo and "build()" in demo

    for symbol in (
        "UPLineProps", "UPGapProps", "UPLinkProps", "UPTitleProps", "UPBadgeProps",
        "UPDividerProps", "UPSkeletonProps", "UPLineProgressProps", "UPLoadmoreProps",
    ):
        assert re.search(rf"\b{re.escape(symbol)}\b", index), f"{symbol} is not publicly exported"

    paths = [*(COMP / f"{name}.ets" for name in COMPONENTS), *(DEMO / name for name in DEMO_FILES.values())]
    for forbidden in ("WebView", "FastView", ".xyfv", "http://", "https://"):
        for path in paths:
            assert forbidden not in read(path), f"forbidden dependency {forbidden!r} in {path}"

    print("foundation display contract: PASS")


if __name__ == "__main__":
    main()
