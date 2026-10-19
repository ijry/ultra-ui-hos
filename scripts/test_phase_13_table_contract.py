#!/usr/bin/env python3
"""Static contracts for Phase 13 table, row, header-cell and cell components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal/UPTableContexts.ets"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-13.md"

SOURCES = {
    "UPTable": (
        "UPTableOptions", "UPTableProps", "UPTableStyleContext", "borderColor",
        "thStyle", "bgColor", "contentBuilder", "@Provide",
    ),
    "UPTr": (
        "UPTrOptions", "UPTrProps", "UPTableStyleContext", "contentBuilder", "@Consume",
    ),
    "UPTh": (
        "UPThOptions", "UPThProps", "UPTableStyleContext", "contentBuilder", "@Consume",
        "layoutWeight",
    ),
    "UPTd": (
        "UPTdOptions", "UPTdProps", "UPTableStyleContext", "contentBuilder", "@Consume",
        "textAlign", "fontSize", "layoutWeight",
    ),
    "UPTable2": (
        "UPTable2Options", "UPTable2Props", "UPTable2Column", "UPTable2Row",
        "UPTable2RowEvent", "UPTable2CellEvent", "UPTable2HeaderEvent",
        "UPTable2SortEvent", "UPTable2SelectionEvent", "UPTable2ExpandEvent",
        "onRowClick", "onCellClick", "onHeaderClick", "onSortChange",
        "onSelectionChange", "onExpandChange", "emptyText", "rowKey", "stripe",
    ),
}

DEMOS_BY_ROUTE = {
    "table": "TableDemo.ets",
    "tr": "TrDemo.ets",
    "th": "ThDemo.ets",
    "td": "TdDemo.ets",
    "table2": "Table2Demo.ets",
}

DEFAULTS = {
    "UPTable": {
        "borderColor": "'#e4e7ed'", "align": "'center'", "padding": "'5px 3px'",
        "fontSize": "'14px'", "color": "'#606266'", "bgColor": "'#ffffff'",
    },
    "UPTh": {"width": "''"},
    "UPTd": {
        "width": "'auto'", "textAlign": "''", "fontSize": "''", "borderColor": "''",
        "color": "''",
    },
    "UPTable2": {
        "stripe": "false", "border": "false", "showHeader": "true", "rowKey": "'id'",
        "emptyText": "'暂无数据'", "rowHeight": "'36px'", "expandWidth": "'25px'",
        "highlightCurrentRow": "false", "defaultExpandAll": "false", "sortable": "false",
        "multiSort": "false", "mainCol": "''", "lazy": "false", "showOverflowTooltip": "false",
        "fixedHeader": "true",
    },
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    context = read(INTERNAL)
    for token in (
        "export class UPTableStyleContext", "beginComposition", "borderColor", "align",
        "padding", "fontSize", "color", "bgColor", "thStyle", "upTableAlign",
    ):
        assert token in context, f"UPTableContexts missing {token}"

    sources: dict[str, str] = {}
    for name, required in SOURCES.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        assert "@Component" in source and f"export struct {name}" in source
        assert f"export class {name}Props" in source and f"export interface {name}Options" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        assert name in index and f"{name}Props" in index, f"{name} is not publicly exported"
        for token in (
            "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
            "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
            "openSystemSettings", "plus.runtime.quit", "navigateTo",
        ):
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    assert "UPTableStyleContext" in index, "UPTableStyleContext must be publicly exported"
    assert "@Provide('UPTableStyleContext')" in sources["UPTable"]
    assert "@Consume('UPTableStyleContext')" in sources["UPTr"]
    assert "@Consume('UPTableStyleContext')" in sources["UPTh"]
    assert "@Consume('UPTableStyleContext')" in sources["UPTd"]
    assert "flex: 0 0" not in sources["UPTh"], "UPTh must use native width, not CSS flex strings"
    for token in ("UPTableRow", "headers", "rows", "widths"):
        assert token in sources["UPTable"], (
            f"UPTable must accept the data-driven model field {token} besides the slot form"
        )
    table2 = sources["UPTable2"]
    for token in (
        "ascending", "descending", "selection", "expand", "treeProps", "expandRowKeys",
        "currentRowKey", "sortOrders", "diagnostics", "Scroll", "flattenedRows",
    ):
        assert token in table2, f"UPTable2 missing {token}"
    for noop in ("spanMethod", "cellClassName", "rowClassName", "headerCellClassName", "load"):
        assert noop in table2, f"UPTable2 must keep compatibility field {noop}"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components Q" in catalog, "missing Phase 13 sample group Components Q"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert "../src/main" not in demo and "ultra-ui/src" not in demo
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "阶段 13", "UPTable", "UPTable2", "UPTr", "UPTh", "UPTd", "Components Q",
        "107 个组件", "107 条组件示例路由", "phase-13.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 13 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPTable", "UPTable2", "UPTr", "UPTh", "UPTd",
        "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-13 note missing {phrase}"

    print("phase 13 table contract: PASS")


if __name__ == "__main__":
    main()
