#!/usr/bin/env python3
"""Static contracts for Phase 9 time, date, and interaction components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-9.md"

SOURCES = {
    "UPCountDown": ("UPCountDownOptions", "UPCountDownProps", "UPCountDownFinishEvent", "remainTime", "autoStart"),
    "UPCountTo": ("UPCountToOptions", "UPCountToProps", "UPCountToFinishEvent", "startValue", "endValue"),
    "UPTimeline": ("UPTimelineOptions", "UPTimelineProps", "UPTimelineItem", "UPTimelineItemData"),
    "UPCalendar": ("UPCalendarOptions", "UPCalendarProps", "UPCalendarSelectEvent", "selectedDate"),
    "UPKeyboard": ("UPKeyboardOptions", "UPKeyboardProps", "UPKeyboardKeyEvent", "keys"),
    "UPFloatingBubble": ("UPFloatingBubbleOptions", "UPFloatingBubbleProps", "UPFloatingBubbleClickEvent"),
}

DEMOS_BY_ROUTE = {
    "count-down": "CountDownDemo.ets",
    "count-to": "CountToDemo.ets",
    "timeline": "TimelineDemo.ets",
    "calendar": "CalendarDemo.ets",
    "keyboard": "KeyboardDemo.ets",
    "floating-bubble": "FloatingBubbleDemo.ets",
}

DEFAULTS = {
    "UPCountDown": {"remainTime": "0", "autoStart": "true", "showDays": "false", "separator": "':'"},
    "UPCountTo": {"startValue": "0", "endValue": "0", "duration": "2000", "decimals": "0", "separator": "','"},
    "UPTimeline": {"direction": "'column'", "color": "'#2979ff'"},
    "UPCalendar": {"month": "-1", "year": "-1", "selectedDate": "''", "weekStart": "0"},
    "UPKeyboard": {"mode": "'number'", "value": "''", "randomKeys": "false",
                    "confirmText": r"UPI18n\.t\('up\.common\.confirm'\)"},
    "UPFloatingBubble": {"text": "''", "icon": "''", "bottom": "24", "right": "24", "disabled": "false"},
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

    assert "clearInterval" in sources["UPCountDown"] and "aboutToDisappear" in sources["UPCountDown"]
    assert "onFinish" in sources["UPCountDown"]
    assert "Math.min" in sources["UPCountTo"] and "Math.max" in sources["UPCountTo"]
    assert "onFinish" in sources["UPCountTo"] and "toFixed" in sources["UPCountTo"]
    assert "ForEach" in sources["UPTimeline"] and "Circle()" in sources["UPTimeline"]
    assert "Date(" in sources["UPCalendar"] and "Math.max" in sources["UPCalendar"]
    assert "onSelect" in sources["UPCalendar"]
    assert "modelValue !== null" in sources["UPKeyboard"] or "modelValue !== undefined" in sources["UPKeyboard"]
    assert "onKey" in sources["UPKeyboard"] and "onDelete" in sources["UPKeyboard"] and "onConfirm" in sources["UPKeyboard"]
    assert "onClick" in sources["UPFloatingBubble"] and "upNumber" in sources["UPFloatingBubble"]

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components M" in catalog, "missing Phase 9 sample group Components M"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{route}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("86 个已实现组件/控制器", "84 个组件 + 2 个控制器", "84 条组件示例路由",
                   "阶段 9", "UPCountDown", "UPCountTo", "UPTimeline", "UPCalendar", "UPKeyboard",
                   "UPFloatingBubble", "phase-9.md", "Components M"):
        assert phrase in readme or phrase in note, f"Phase 9 documentation missing {phrase}"
    for phrase in ("阶段 9", "API 24", "5.0.0(12)", "设备验证", "skipped", "no-op"):
        assert phrase in note, f"phase-9 note missing {phrase}"
    print("phase 9 time-interaction contract: PASS")


if __name__ == "__main__":
    main()
