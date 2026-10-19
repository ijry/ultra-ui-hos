#!/usr/bin/env python3
"""Static contracts for Phase 8 navigation and more components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-8.md"

SOURCES = {
    "UPPopover": ("UPPopoverOptions", "UPPopoverProps", "UPPopoverSelectEvent", "placement", "triggerMode"),
    "UPTooltip": ("UPTooltipOptions", "UPTooltipProps", "UPTooltipButton", "buttons", "showCopy"),
    "UPSticky": ("UPStickyOptions", "UPStickyProps", "offsetTop", "customNavHeight", "disabled"),
    "UPSwipeAction": ("UPSwipeActionOptions", "UPSwipeActionProps", "autoClose", "opendItem"),
    "UPSwipeActionItem": ("UPSwipeActionItemOptions", "UPSwipeActionItemProps", "UPSwipeActionOption", "threshold"),
    "UPReadMore": ("UPReadMoreOptions", "UPReadMoreProps", "UPReadMoreToggleEvent", "showHeight"),
    "UPPagination": ("UPPaginationOptions", "UPPaginationProps", "UPPaginationChangeEvent", "currentPage"),
}

DEMOS_BY_ROUTE = {
    "popover": "PopoverDemo.ets",
    "tooltip": "TooltipDemo.ets",
    "sticky": "StickyDemo.ets",
    "swipe-action": "SwipeActionDemo.ets",
    "swipe-action-item": "SwipeActionItemDemo.ets",
    "read-more": "ReadMoreDemo.ets",
    "pagination": "PaginationDemo.ets",
}

DEFAULTS = {
    "UPPopover": {"text": "''", "color": "'#333'", "bgColor": "'#f7f7f7'", "popupBgColor": "'#f7f7f7'",
                  "placement": "'top'", "triggerMode": "'click'", "show": "false"},
    "UPTooltip": {"text": "''", "copyText": "''", "size": "14", "color": "'#606266'", "direction": "'top'",
                  "showCopy": "true", "overlay": "true", "triggerMode": "'longpress'", "show": "false"},
    "UPSticky": {"offsetTop": "0", "customNavHeight": "0", "disabled": "false", "bgColor": "'transparent'"},
    "UPSwipeAction": {"autoClose": "true", "opendItem": "false"},
    "UPSwipeActionItem": {"show": "false", "closeOnClick": "true", "disabled": "false", "threshold": "20", "duration": "300"},
    "UPReadMore": {"showHeight": "400", "toggle": "false",
                   "closeText": r"UPI18n\.t\('up\.readMore\.expand'\)",
                   "openText": r"UPI18n\.t\('up\.readMore\.fold'\)",
                   "color": "'#2979ff'", "fontSize": "14", "textIndent": "'2em'"},
    "UPPagination": {"currentPage": "1", "pageSize": "10", "total": "0", "prevText": "''", "nextText": "''",
                     "hideOnSinglePage": "false"},
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    sources: dict[str, str] = {}
    for name, required in SOURCES.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        assert "@Component" in source and f"export struct {name}" in source
        assert f"export class {name}Props" in source and f"export interface {name}Options" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        assert name in index, f"{name} not exported from Index.ets"
        for token in ("WebView", "@kit.NetworkKit", "http://", "https://"):
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{value}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    assert "modelValue !== null" in sources["UPPopover"] or "modelValue !== undefined" in sources["UPPopover"]
    assert "modelValue !== null" in sources["UPTooltip"] or "modelValue !== undefined" in sources["UPTooltip"]
    assert "modelValue !== null" in sources["UPReadMore"] or "modelValue !== undefined" in sources["UPReadMore"]
    context = read(INTERNAL / "UPNavigationMoreContexts.ets")
    for method in ("beginComposition", "openName", "isOpen", "requestOpen", "closeAll"):
        assert method in context, f"swipe context missing {method}"
    assert "@Consume" in sources["UPSwipeActionItem"], "swipe item must consume parent context"
    assert "closeAll()" in sources["UPSwipeAction"] + sources["UPSwipeActionItem"]
    assert "onPageChange" in sources["UPPagination"] and "Math.max" in sources["UPPagination"]
    assert "Math.min" in sources["UPPagination"]

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components L" in catalog, "missing Phase 8 sample group Components L"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{route}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import the public HAR entry"
        assert filename.removesuffix(".ets") in page and f"'{route}'" in page, f"SamplePage missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 8", "API 24", "5.0.0(12)", "设备验证", "skipped"):
        assert phrase in note, f"phase-8 note missing {phrase}"
    assert "phase-8.md" in readme and "阶段 8" in readme
    print("phase 8 navigation-more contract: PASS")


if __name__ == "__main__":
    main()
