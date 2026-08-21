#!/usr/bin/env python3
"""Static contracts for the phase 3B layout and card component batch."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "ultra-ui/Index.ets"
COMP = ROOT / "ultra-ui/src/main/ets/components"
DEMO = ROOT / "sample/entry/src/main/ets/demos"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
NOTE = ROOT / "docs/compatibility/phase-3b.md"
README = ROOT / "README.md"

DEMOS = {
    "row": "RowDemo.ets",
    "col": "ColDemo.ets",
    "grid": "GridDemo.ets",
    "grid-item": "GridItemDemo.ets",
    "card": "CardDemo.ets",
}

ROW_COL_FIELDS = {
    "UPRow": ("gutter", "justify", "align", "customStyle", "contentBuilder", "onClick"),
    "UPCol": ("span", "offset", "justify", "align", "textAlign", "customStyle", "contentBuilder", "onClick"),
}

ROW_COL_DEFAULTS = {
    "UPRow": (("gutter", "0"), ("justify", "'start'"), ("align", "'center'")),
    "UPCol": (("span", "12"), ("offset", "0"), ("justify", "'start'"),
              ("align", "'stretch'"), ("textAlign", "'left'")),
}

GRID_FIELDS = {
    "UPGrid": ("col", "border", "align", "gap", "customStyle", "contentBuilder"),
    "UPGridItem": ("name", "bgColor", "customStyle", "contentBuilder", "onClick"),
}

GRID_DEFAULTS = {
    "UPGrid": (("col", "3"), ("border", "false"), ("align", "'left'"), ("gap", "'0px'")),
    "UPGridItem": (("name", "null"), ("bgColor", "'transparent'")),
}

CARD_FIELDS = (
    "full", "title", "titleColor", "titleSize", "subTitle", "subTitleColor", "subTitleSize",
    "border", "index", "margin", "borderRadius", "headStyle", "bodyStyle", "footStyle",
    "headBorderBottom", "footBorderTop", "thumb", "thumbWidth", "thumbCircle", "padding",
    "paddingHead", "paddingBody", "paddingFoot", "showHead", "showFoot", "boxShadow",
    "customStyle", "contentBuilder", "headBuilder", "footBuilder",
    "onClick", "onHeadClick", "onBodyClick", "onFootClick",
)

CARD_DEFAULTS = (
    ("full", "false"), ("title", "''"), ("titleColor", "'#303133'"), ("titleSize", "'15px'"),
    ("subTitle", "''"), ("subTitleColor", "'#909399'"), ("subTitleSize", "'13px'"),
    ("border", "true"), ("index", "''"), ("margin", "'15px'"), ("borderRadius", "'8px'"),
    ("headBorderBottom", "true"), ("footBorderTop", "true"), ("thumb", "''"),
    ("thumbWidth", "'30px'"), ("thumbCircle", "false"), ("padding", "'15px'"),
    ("paddingHead", "''"), ("paddingBody", "''"), ("paddingFoot", "''"),
    ("showHead", "true"), ("showFoot", "true"), ("boxShadow", "'none'"),
)

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

    for component, fields in GRID_FIELDS.items():
        source = read(COMP / f"{component}.ets")
        assert f"class {component}Props" in source, f"missing {component}Props"
        assert f"export interface {component}Options" in source, f"missing {component}Options"
        assert re.search(rf"export struct {component}\b", source), f"missing {component} struct"
        for field in fields:
            assert_field(source, field, component)
        for field, value in GRID_DEFAULTS[component]:
            assert_default(source, field, value, component)
        assert component in index, f"{component} is not publicly exported"
        assert f"{component}Props" in index, f"{component}Props is not publicly exported"
        assert f"{component}Options" in index, f"{component}Options is not publicly exported"
        for forbidden in FORBIDDEN:
            assert forbidden not in source, f"{component} contains forbidden token {forbidden!r}"

    grid_item = read(COMP / "UPGridItem.ets")
    assert "UPGridItemClickEvent" in grid_item, "UPGridItem missing UPGridItemClickEvent"
    assert "name" in grid_item and "index" in grid_item, "UPGridItemClickEvent missing fields"
    assert "UPGridItemClickEvent" in index, "UPGridItemClickEvent is not publicly exported"
    assert re.search(r"name\s*:\s*UPRawValue", grid_item), "event name must be UPRawValue"
    assert re.search(r"index\s*:\s*number", grid_item), "event index must be number"
    assert "aboutToAppear(): void" in grid_item, "UPGridItem must allocate its visual index during composition"
    assert "this.visualIndex = this.gridContext.allocateIndex()" in grid_item, "UPGridItem must retain its visual index"
    emit_click = grid_item.split("private emitClick(): void", 1)[1].split("build()", 1)[0]
    assert "allocateIndex()" not in emit_click, "UPGridItem must not allocate a new index on every click"

    grid = read(COMP / "UPGrid.ets")
    assert "Grid(" in grid or "Grid()" in grid, "UPGrid must use native Grid"
    assert "columnsTemplate" in grid, "UPGrid must set columnsTemplate"
    assert "columnsGap" in grid, "UPGrid must set columnsGap"
    assert "rowsGap" in grid, "UPGrid must set rowsGap"
    assert "GridLayoutOptions" in grid, "UPGrid must use native layout options for last-row alignment"
    assert "onGetRectByIndex" in grid, "UPGrid must place the last row from its resolved alignment"
    assert "this.gridContext.itemCount()" in grid, "UPGrid alignment must use the composed item count"

    card = read(COMP / "UPCard.ets")
    assert "class UPCardProps" in card, "missing UPCardProps"
    assert "export interface UPCardOptions" in card, "missing UPCardOptions"
    assert re.search(r"export struct UPCard\b", card), "missing UPCard struct"
    for field in CARD_FIELDS:
        assert_field(card, field, "UPCard")
    for field, value in CARD_DEFAULTS:
        assert_default(card, field, value, "UPCard")
    assert "UPCardArea" in card, "UPCard missing UPCardArea"
    assert "UPCardClickEvent" in card, "UPCard missing UPCardClickEvent"
    assert re.search(r"area\s*:\s*UPCardArea", card), "event area must be UPCardArea"
    assert re.search(r"index\s*:\s*UPRawValue", card), "event index must be UPRawValue"
    assert "UPImage" in card, "UPCard must render thumb through UPImage"
    public_card = card.split("export struct UPCard", 1)[1]
    assert public_card.count("@BuilderParam") == 1, "UPCard must keep one trailing body BuilderParam"
    assert "contentBuilder: this.props.headBuilder" in card, "UPCard must bridge headBuilder from props"
    assert "contentBuilder: this.props.footBuilder" in card, "UPCard must bridge footBuilder from props"
    assert "resource://" in card or "file://" in card or "$rawfile:" in card, "UPCard must guard local image sources"
    assert "UPCard" in index and "UPCardProps" in index and "UPCardOptions" in index, "UPCard exports missing"
    assert "UPCardArea" in index and "UPCardClickEvent" in index, "UPCard event exports missing"
    for forbidden in FORBIDDEN:
        assert forbidden not in card, f"UPCard contains forbidden token {forbidden!r}"

    catalog = read(CATALOG)
    page = read(PAGE)
    for route, demo_file in DEMOS.items():
        assert route in catalog, f"missing catalog route: {route}"
        assert re.search(rf"route === ['\"]{re.escape(route)}['\"]", page), f"missing page route: {route}"
        demo = read(DEMO / demo_file)
        assert "@lingyun/ultra-ui-hos" in demo, f"{route} demo must use public HAR entry"
        assert "ultra-ui/src" not in demo and "../src/main" not in demo, f"{route} demo must not use internal paths"
        assert "@Component" in demo and "build()" in demo, f"{route} demo must be a component"
        for forbidden in FORBIDDEN:
            assert forbidden not in demo, f"forbidden dependency {forbidden!r} in {route} demo"

    note = read(NOTE)
    for phrase in (
        "阶段 3B", "API 24", "5.0.0(12)", "UPRow", "UPCol", "UPGrid",
        "UPGridItem", "UPCard", "本地资源", "无网络", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-3b note missing {phrase}"
    readme = read(README)
    for phrase in ("phase-3b.md",):
        assert phrase in readme, f"README missing {phrase}"

    print("phase 3B layout/card contract: PASS")


if __name__ == "__main__":
    main()
