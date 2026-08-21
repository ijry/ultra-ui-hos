#!/usr/bin/env python3
"""Static contract checks for Phase 6 list and index components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENT_DIR = ROOT / "ultra-ui/src/main/ets/components"
INDEX = ROOT / "ultra-ui/Index.ets"
CONTEXT = ROOT / "ultra-ui/src/main/ets/internal/UPListContexts.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS_DIR = ROOT / "sample/entry/src/main/ets/demos"
NOTE = ROOT / "docs/compatibility/phase-6.md"
README = ROOT / "README.md"

COMPONENTS = {
    "UPList": (
        "UPListOptions",
        "UPListProps",
        "UPListScrollEvent",
        "UPListContext",
        "contentBuilder",
    ),
    "UPListItem": (
        "UPListItemOptions",
        "UPListItemProps",
        "UPListContext",
        "anchor",
        "contentBuilder",
    ),
    "UPIndexList": (
        "UPIndexListOptions",
        "UPIndexListProps",
        "UPIndexListSelectEvent",
        "UPIndexListContext",
        "contentBuilder",
    ),
    "UPIndexItem": (
        "UPIndexItemOptions",
        "UPIndexItemProps",
        "UPIndexListContext",
        "headerBuilder",
        "contentBuilder",
    ),
    "UPIndexAnchor": (
        "UPIndexAnchorOptions",
        "UPIndexAnchorProps",
        "text",
        "bgColor",
        "height",
    ),
    "UPScrollList": (
        "UPScrollListOptions",
        "UPScrollListProps",
        "UPScrollListEdgeEvent",
        "UPScrollListScrollEvent",
        "contentBuilder",
    ),
}

DEMOS = {
    "list": "ListDemo.ets",
    "list-item": "ListItemDemo.ets",
    "index-list": "IndexListDemo.ets",
    "index-item": "IndexItemDemo.ets",
    "index-anchor": "IndexAnchorDemo.ets",
    "scroll-list": "ScrollListDemo.ets",
}

FORBIDDEN = (
    "WebView",
    "@kit.NetworkKit",
    "http://",
    "https://",
    "vue",
    "nvue",
    "ultra-ui/src",
)

DEFAULTS = {
    "UPList": {
        "showScrollbar": "false",
        "lowerThreshold": "50",
        "upperThreshold": "0",
        "scrollTop": "0",
        "offsetAccuracy": "10",
        "enableFlex": "false",
        "pagingEnabled": "false",
        "scrollable": "true",
        "scrollIntoView": "''",
        "scrollWithAnimation": "false",
        "enableBackToTop": "false",
        "height": "0",
        "width": "0",
        "preLoadScreen": "1",
        "refresherEnabled": "false",
        "refresherThreshold": "45",
        "refresherDefaultStyle": "'black'",
        "refresherBackground": "'#FFF'",
        "refresherTriggered": "false",
        "customStyle": "undefined",
    },
    "UPListItem": {
        "anchor": "''",
        "customStyle": "undefined",
    },
    "UPIndexList": {
        "inactiveColor": "'#606266'",
        "activeColor": "'#5677fc'",
        "indexList": "[]",
        "current": "undefined",
        "sticky": "true",
        "showSidebar": "true",
        "customNavHeight": "0",
        "safeBottomFix": "false",
        "itemMargin": "'0rpx'",
        "customStyle": "undefined",
    },
    "UPIndexItem": {
        "index": "''",
        "customStyle": "undefined",
    },
    "UPIndexAnchor": {
        "text": "''",
        "color": "'#606266'",
        "size": "14",
        "bgColor": "'#f1f1f1'",
        "height": "32",
        "customStyle": "undefined",
    },
    "UPScrollList": {
        "indicatorWidth": "50",
        "indicatorBarWidth": "20",
        "indicator": "true",
        "indicatorColor": "'#f2f2f2'",
        "indicatorActiveColor": "'#3c9cff'",
        "indicatorStyle": "undefined",
        "customStyle": "undefined",
    },
}

OPTIONAL_CALLBACKS = {
    "UPList": (
        "onScroll",
        "onScrollToLower",
        "onScrollToUpper",
        "onRefresherRefresh",
        "onRefresherTriggeredChange",
    ),
    "UPIndexList": ("onSelect", "onChange", "onCurrentChange"),
    "UPScrollList": ("onLeft", "onRight", "onScroll"),
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def assert_default(source: str, component: str, field: str, value: str) -> None:
    pattern = rf"\b{re.escape(field)}\b[^=;\n]*=\s*{re.escape(value)}\s*;"
    assert re.search(pattern, source), f"{component} missing default {field} = {value}"


def assert_optional(source: str, component: str, field: str) -> None:
    pattern = rf"\b{re.escape(field)}\?\s*:"
    assert re.search(pattern, source), f"{component} missing optional {field}"


def main() -> None:
    index = read(INDEX)
    sources: dict[str, str] = {}
    for name, required in COMPONENTS.items():
        source = read(COMPONENT_DIR / f"{name}.ets")
        sources[name] = source
        assert "@Component" in source, f"{name} missing @Component"
        assert f"export struct {name}" in source, f"missing public struct {name}"
        for token in required:
            assert token in source or token in index, f"{name} missing {token}"
        assert re.search(rf"export \{{[^}}]*\b{name}\b", index, re.S), f"{name} missing HAR export"

    for component, defaults in DEFAULTS.items():
        for field, value in defaults.items():
            assert_default(sources[component], component, field, value)

    for component in ("UPList", "UPIndexList", "UPScrollList"):
        assert_optional(sources[component], component, "diagnostics")
        assert "UPCompatibilityDiagnostics" in sources[component], f"{component} missing diagnostics type"
    for component, callbacks in OPTIONAL_CALLBACKS.items():
        for callback in callbacks:
            assert_optional(sources[component], component, callback)

    list_source = sources["UPList"]
    for token in (
        "Scroller",
        "List",
        "scrollTo",
        "scrollToIndex",
        "onScroll",
        "onReachStart",
        "onReachEnd",
        "enableScrollInteraction",
    ):
        assert token in list_source, f"UPList missing native behavior token {token}"

    index_list_source = sources["UPIndexList"]
    for token in ("Scroller", "List", "StickyStyle", "scrollToIndex", "requestSelect"):
        assert token in index_list_source, f"UPIndexList missing native behavior token {token}"
    index_item_source = sources["UPIndexItem"]
    for token in ("ListItemGroup", "ListItem", "headerBuilder", "contentBuilder"):
        assert token in index_item_source, f"UPIndexItem missing native group token {token}"

    scroll_list_source = sources["UPScrollList"]
    for token in ("Scroller", "Scroll", "ScrollDirection.Horizontal", "currentOffset", "maxOffset"):
        assert token in scroll_list_source, f"UPScrollList missing native behavior token {token}"

    builder_params = re.findall(r"@BuilderParam\s+\w+\s*:\s*\(\)\s*=>\s*void", index_item_source)
    assert len(builder_params) == 2, "UPIndexItem must declare exactly two @BuilderParam fields"
    for field in ("headerBuilder", "contentBuilder"):
        assert re.search(rf"@BuilderParam\s+{field}\s*:", index_item_source), f"UPIndexItem missing {field} BuilderParam"

    contexts = read(CONTEXT)
    for token in (
        "UPListContext",
        "beginComposition",
        "itemIndex",
        "registerAnchor",
        "anchorIndex",
        "requestScrollIntoView",
        "pendingAnchor",
        "UPIndexListContext",
        "normalizedItems",
        "isActive",
        "requestSelect",
        "requestScrollToIndex",
        "duplicate",
        "UP_SILENT_DIAGNOSTICS",
    ):
        assert token in contexts, f"list context missing {token}"
    for event in ("UPIndexListSelectEvent", "UPScrollListEdgeEvent", "UPScrollListScrollEvent"):
        assert f"export interface {event}" in contexts, f"list context missing event {event}"
    for helper in ("UPRawValue", "upBoolean", "upNumber", "upString", "upValueKey"):
        assert helper in contexts, f"list context missing helper {helper}"
    imports = "\n".join(line for line in contexts.splitlines() if line.strip().startswith("import "))
    assert "../core/UPTypes" in imports, "list context must import core UPTypes"
    assert "../core/UPDiagnostics" in imports, "list context must import core UPDiagnostics"
    for forbidden in ("@kit.", "@ohos.", "router", "AppStorage", "PersistentStorage"):
        assert forbidden not in contexts, f"list context contains forbidden dependency {forbidden!r}"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components J" in catalog, "sample catalog missing Components J"
    for route, filename in DEMOS.items():
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        demo = read(DEMOS_DIR / filename)
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must use public HAR entry"
        demo_name = filename.removesuffix(".ets")
        assert route in page and demo_name in page, f"SamplePage missing {route} dispatch"
        for forbidden in FORBIDDEN:
            assert forbidden not in demo, f"{filename} contains forbidden token {forbidden!r}"

    index_item_demo = read(DEMOS_DIR / "IndexItemDemo.ets")
    assert re.search(r"headerBuilder\s*:\s*this\.", index_item_demo), "IndexItemDemo must explicitly bind headerBuilder"
    assert re.search(r"contentBuilder\s*:\s*this\.", index_item_demo), "IndexItemDemo must explicitly bind contentBuilder"
    trailing_builder = re.compile(r"UPIndexItem\s*\([\s\S]*?\n\s*\}\s*\)\s*\{")
    assert not trailing_builder.search(index_item_demo), "IndexItemDemo must not use a trailing Builder with UPIndexItem"

    note = read(NOTE)
    for phrase in (
        "阶段 6",
        "API 24",
        "UPList",
        "UPIndexList",
        "UPScrollList",
        "no-op",
        "设备验证",
        "skipped",
    ):
        assert phrase in note, f"phase-6 note missing {phrase}"
    readme = read(README)
    for phrase in (
        "阶段 6",
        "69 个已实现组件/控制器",
        "68 个组件 + 1 个控制器",
        "67 条组件示例路由",
        "Components J",
        "phase-6.md",
        "UPList",
        "UPIndexList",
        "UPScrollList",
    ):
        assert phrase in readme, f"README missing {phrase}"

    print("phase 6 list and index contract: PASS")


if __name__ == "__main__":
    main()
