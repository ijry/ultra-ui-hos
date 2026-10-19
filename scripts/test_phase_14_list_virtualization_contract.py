#!/usr/bin/env python3
"""Static contracts for Phase 14 virtual list, pull refresh, waterfall and drag sort."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
CONTROLLER = ROOT / "ultra-ui/src/main/ets/controllers/UPRefreshVirtualListController.ets"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-14.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo",
)

SOURCES = {
    "UPVirtualList": (
        "UPVirtualListOptions", "UPVirtualListProps", "UPVirtualListItem",
        "UPVirtualListItemSlot", "UPVirtualListScrollEvent", "upVirtualListValue",
        "itemBuilder", "windowStart", "windowEnd", "topPlaceholder", "bottomPlaceholder",
        "onScrollTopChange", "onDidScroll", "Scroller",
    ),
    "UPPullRefresh": (
        "UPPullRefreshOptions", "UPPullRefreshProps", "UPPullRefreshScrollEvent",
        "contentBuilder", "pullBuilder", "releaseBuilder", "refreshingBuilder",
        "refreshStatus", "setStatus", "finishRefresh", "onStatusChange", "onLoadmore",
        "UPLoadmoreProps", "onScrollEdge", "下拉刷新", "释放刷新", "正在刷新...",
    ),
    "UPRefreshVirtualList": (
        "UPRefreshVirtualListOptions", "UPRefreshVirtualListProps",
        "UPRefreshVirtualListController", "UPPullRefresh", "UPVirtualList",
        "onRefreshingChange", "finishRefresh", "mount", "unmount",
    ),
    "UPWaterfall": (
        "UPWaterfallOptions", "UPWaterfallProps", "UPWaterfallItem", "UPWaterfallColumn",
        "UPWaterfallColumnSlot", "UPWaterfallItemSlot", "UPWaterfallAddOneEvent",
        "UPWaterfallAddAllEvent", "upWaterfallValue", "upWaterfallClone",
        "upWaterfallAssign", "upWaterfallSame", "columnHeights", "minHeightColumnIndex",
        "onUpdateModelValue", "onAfterAddOne", "onAfterAddAll", "onAreaChange",
    ),
    "UPDragSort": (
        "UPDragSortOptions", "UPDragSortProps", "UPDragSortItem", "UPDragSortItemSlot",
        "itemBuilder", "handlerBuilder", "PanGesture", "beginDrag", "updateDrag",
        "endDrag", "targetIndex", "reorderItems", "onDragEnd", "useHandler",
    ),
}

DEMOS_BY_ROUTE = {
    "virtual-list": "VirtualListDemo.ets",
    "pull-refresh": "PullRefreshDemo.ets",
    "refresh-virtual-list": "RefreshVirtualListDemo.ets",
    "waterfall": "WaterfallDemo.ets",
    "dragsort": "DragSortDemo.ets",
}

DEFAULTS = {
    "UPVirtualList": {
        "listData": r"\[\]", "itemHeight": "50", "height": "'100%'", "buffer": "4",
        "keyField": "'id'", "scrollTop": "0", "showScrollbar": "false",
    },
    "UPPullRefresh": {
        "refreshing": "false", "threshold": "80", "damping": "0.4", "maxDistance": "120",
        "showLoadmore": "false", "loadmoreProps": r"new UPLoadmoreProps\(\)",
        "useScrollView": "true", "enableBackToTop": "false", "lowerThreshold": "50",
        "scrollTop": "0",
    },
    "UPRefreshVirtualList": {
        "listData": r"\[\]", "itemHeight": "50", "height": "'100%'", "buffer": "4",
        "keyField": "'id'", "showScrollbar": "false",
    },
    "UPWaterfall": {
        "modelValue": r"\[\]", "addTime": "200", "idKey": "'id'", "columns": "2",
        "columnsMin": "2", "minColumnWidth": "230", "useColumnSlot": "false",
    },
    "UPDragSort": {
        "initialList": r"\[\]", "draggable": "true", "vibrate": "true",
        "direction": "'vertical'", "columns": "3", "useHandler": "false",
        "itemHeight": "40", "itemWidth": "80",
    },
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)

    controller = read(CONTROLLER)
    for token in (
        "export interface UPRefreshVirtualListCommand",
        "export type UPRefreshVirtualListControllerListener",
        "export class UPRefreshVirtualListController",
        "mount(", "unmount(", "finishRefresh(", "scrollTo(", "scrollToTop(",
        "diagnostics",
    ):
        assert token in controller, f"UPRefreshVirtualListController missing {token}"
    for token in FORBIDDEN:
        assert token not in controller, f"controller contains forbidden boundary {token}"
    for token in (
        "UPRefreshVirtualListController", "UPRefreshVirtualListControllerListener",
        "UPRefreshVirtualListCommand",
    ):
        assert token in index, f"{token} is not publicly exported"

    sources: dict[str, str] = {}
    for name, required in SOURCES.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        assert "@Component" in source and f"export struct {name}" in source
        assert f"export class {name}Props" in source and f"export interface {name}Options" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        assert name in index and f"{name}Props" in index, f"{name} is not publicly exported"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{value}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    virtual = sources["UPVirtualList"]
    assert "LazyForEach" not in virtual, "UPVirtualList windows plain arrays, no LazyForEach source"
    assert "@Watch('applyScrollTop')" in virtual, "UPVirtualList must react to scrollTop writes"

    refresh = sources["UPPullRefresh"]
    assert not re.search(r"(?m)^\s*Refresh\(", refresh), (
        "UPPullRefresh must not delegate to the SDK Refresh component"
    )
    for token in ("onTouchStart", "onTouchMove", "onTouchEnd", "dampingValue", "thresholdValue"):
        assert token in refresh, f"UPPullRefresh missing {token}"
    for token in (".backToTop(", ".maxPullDownDistance(", ".pullUpToCancelRefresh("):
        assert token not in refresh, f"UPPullRefresh must not call post-API-24 attribute {token}"
    assert "requires API 15" in refresh, "UPPullRefresh must report the enableBackToTop no-op"

    waterfall = sources["UPWaterfall"]
    for token in ("setTimeout", "clearTimeout", "generation", "isPureAppend", "redistribute"):
        assert token in waterfall, f"UPWaterfall missing {token}"
    assert "columns" in waterfall and "auto" in waterfall, "UPWaterfall must support columns='auto'"

    dragsort = sources["UPDragSort"]
    assert "vibrateShort" in dragsort or "haptics" in dragsort, (
        "UPDragSort must document the vibrate no-op"
    )
    for token in ("horizontal", "vertical", "PanDirection"):
        assert token in dragsort, f"UPDragSort missing {token}"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components R" in catalog, "missing Phase 14 sample group Components R"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert "../src/main" not in demo and "ultra-ui/src" not in demo
        assert not re.search(r"=>\s*this\.", demo), f"{filename} must not capture this in arrow bodies"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "阶段 14", "UPVirtualList", "UPPullRefresh", "UPRefreshVirtualList", "UPWaterfall",
        "UPDragSort", "Components R", "112 个组件", "112 条组件示例路由", "phase-14.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 14 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPVirtualList", "UPPullRefresh", "UPRefreshVirtualList",
        "UPWaterfall", "UPDragSort", "UPRefreshVirtualListController", "no-op",
        "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-14 note missing {phrase}"

    print("phase 14 list virtualization contract: PASS")


if __name__ == "__main__":
    main()
