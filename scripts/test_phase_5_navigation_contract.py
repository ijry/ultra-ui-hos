#!/usr/bin/env python3
"""Static contract checks for Phase 5 navigation core components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENT_DIR = ROOT / "ultra-ui/src/main/ets/components"
INDEX = ROOT / "ultra-ui/Index.ets"
CONTEXT = ROOT / "ultra-ui/src/main/ets/internal/UPNavigationContexts.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS_DIR = ROOT / "sample/entry/src/main/ets/demos"
NOTE = ROOT / "docs/compatibility/phase-5.md"
README = ROOT / "README.md"

COMPONENTS = {
    "UPStatusBar": ("UPStatusBarProps", "UPStatusBarOptions", "onHeightChange"),
    "UPSafeBottom": ("UPSafeBottomProps", "UPSafeBottomOptions", "contentBuilder"),
    "UPNavbar": ("UPNavbarProps", "UPNavbarOptions", "UPNavigationAdapter"),
    "UPNavbarMini": ("UPNavbarMiniProps", "UPNavbarMiniOptions", "onHomeClick"),
    "UPTabs": ("UPTabsProps", "UPTabsOptions", "UPTabsContext"),
    "UPTabsItem": ("UPTabsItemProps", "UPTabsItemOptions", "contentBuilder"),
    "UPSubsection": ("UPSubsectionProps", "UPSubsectionOptions", "onCurrentChange"),
    "UPSteps": ("UPStepsProps", "UPStepsOptions", "UPStepsContext"),
    "UPStepsItem": ("UPStepsItemProps", "UPStepsItemOptions", "onClick"),
}

DEMOS = {
    "navbar": "NavbarDemo.ets",
    "navbar-mini": "NavbarMiniDemo.ets",
    "status-bar": "StatusBarDemo.ets",
    "safe-bottom": "SafeBottomDemo.ets",
    "tabs": "TabsDemo.ets",
    "tabs-item": "TabsItemDemo.ets",
    "subsection": "SubsectionDemo.ets",
    "steps": "StepsDemo.ets",
    "steps-item": "StepsItemDemo.ets",
}

FORBIDDEN = ("WebView", "@kit.NetworkKit", "https://", "http://", "vue", "nvue", "ultra-ui/src")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    for name, required in COMPONENTS.items():
        source = read(COMPONENT_DIR / f"{name}.ets")
        assert f"export struct {name}" in source, f"missing public struct {name}"
        for token in required:
            assert token in source or token in index, f"{name} missing {token}"
        assert re.search(rf"export \{{[^}}]*\b{name}\b", index, re.S), f"{name} missing HAR export"

    contexts = read(CONTEXT)
    for token in ("UPTabsContext", "itemIndex", "requestSelect", "UPStepsContext", "stateFor", "connectorColor"):
        assert token in contexts, f"navigation context missing {token}"

    navbar = read(COMPONENT_DIR / "UPNavbar.ets")
    for token in ("safeAreaInsetTop", "placeholder", "fixed", "border", "leftIcon", "autoBack", "onLeftClick", "navigateBack"):
        assert token in navbar, f"navbar missing {token}"
    mini = read(COMPONENT_DIR / "UPNavbarMini.ets")
    for token in ("homeUrl", "relaunch", "onHomeClick", "arrow-leftward"):
        assert token in mini, f"navbar-mini missing {token}"
    tabs = read(COMPONENT_DIR / "UPTabs.ets")
    for token in ("current", "onChange", "scrollable", "contentBuilder", "leftBuilder", "rightBuilder"):
        assert token in tabs, f"tabs missing {token}"
    subsection = read(COMPONENT_DIR / "UPSubsection.ets")
    for token in ("mode", "button", "subsection", "onCurrentChange", "onChange", "disabled"):
        assert token in subsection, f"subsection missing {token}"
    steps = read(COMPONENT_DIR / "UPSteps.ets")
    for token in ("direction", "row", "column", "current", "dot", "contentBuilder"):
        assert token in steps, f"steps missing {token}"
    steps_item = read(COMPONENT_DIR / "UPStepsItem.ets")
    steps_behavior = steps_item + contexts
    for token in ("finish", "process", "wait", "error", "iconBuilder", "titleBuilder", "descBuilder"):
        assert token in steps_behavior, f"steps item behavior missing {token}"

    catalog = read(CATALOG)
    page = read(PAGE)
    for route, filename in DEMOS.items():
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        demo = read(DEMOS_DIR / filename)
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must use public HAR entry"
        assert route in page and filename.removesuffix(".ets") in page, f"SamplePage missing {route}"
        for forbidden in FORBIDDEN:
            assert forbidden not in demo, f"{filename} contains forbidden token {forbidden!r}"

    status_bar_demo = read(DEMOS_DIR / "StatusBarDemo.ets")
    assert "@State private height:" not in status_bar_demo, "StatusBarDemo must not shadow the component height attribute"
    steps_item_demo = read(DEMOS_DIR / "StepsItemDemo.ets")
    assert "contentBuilder: this.customContent" in steps_item_demo, "StepsItemDemo must explicitly bind its multi-builder content"
    assert not re.search(r"UPStepsItem\([^\n]+\)\s*\{", steps_item_demo), "StepsItemDemo must not use a trailing lambda with multiple BuilderParams"

    note = read(NOTE)
    for phrase in ("阶段 5", "API 24", "5.0.0(12)", *COMPONENTS.keys(), "页面受控状态", "无网络", "设备验证", "skipped"):
        assert phrase in note, f"phase-5 note missing {phrase}"
    readme = read(README)
    for phrase in ("阶段 5", "phase-5.md"):
        assert phrase in readme, f"README missing {phrase}"
    print("phase 5 navigation contract: PASS")


if __name__ == "__main__":
    main()
