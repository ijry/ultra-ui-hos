#!/usr/bin/env python3
"""Static contracts for Phase 11 containers, swiper and tabbar components."""
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
NOTE = ROOT / "docs/compatibility/phase-11.md"

SOURCES = {
    "UPView": ("UPViewOptions", "UPViewProps", "contentBuilder", "onClick"),
    "UPBox": ("UPBoxOptions", "UPBoxProps", "title", "contentBuilder"),
    "UPSection": ("UPSectionOptions", "UPSectionProps", "subTitle", "onClick"),
    "UPToolbar": ("UPToolbarOptions", "UPToolbarProps", "cancelText", "onConfirm"),
    "UPSwiper": ("UPSwiperOptions", "UPSwiperProps", "UPSwiperItem", "onChange"),
    "UPSwiperIndicator": ("UPSwiperIndicatorOptions", "UPSwiperIndicatorProps", "count", "onClick"),
    "UPTabbar": ("UPTabbarOptions", "UPTabbarProps", "UPTabbarItemData", "onChange"),
    "UPTabbarItem": ("UPTabbarItemOptions", "UPTabbarItemProps", "name", "onClick"),
}

DEMOS_BY_ROUTE = {
    "view": "ViewDemo.ets",
    "box": "BoxDemo.ets",
    "section": "SectionDemo.ets",
    "toolbar": "ToolbarDemo.ets",
    "swiper": "SwiperDemo.ets",
    "swiper-indicator": "SwiperIndicatorDemo.ets",
    "tabbar": "TabbarDemo.ets",
    "tabbar-item": "TabbarItemDemo.ets",
}

DEFAULTS = {
    "UPView": {"flexDirection": "'column'", "width": "'100%'"},
    "UPBox": {"bgColor": "'#ffffff'", "height": "120"},
    "UPSection": {"subTitle": "UPI18n.t('up.common.more')", "right": "true", "showLine": "true"},
    "UPToolbar": {"show": "true", "cancelText": "UPI18n.t('up.common.cancel')",
                  "confirmText": "UPI18n.t('up.common.confirm')"},
    "UPSwiper": {"list": "[]", "indicator": "false", "autoplay": "true", "current": "0", "interval": "3000"},
    "UPSwiperIndicator": {"current": "0", "count": "0", "mode": "'line'"},
    "UPTabbar": {"current": "0", "fixed": "true", "placeholder": "false", "safeAreaInsetBottom": "true"},
    "UPTabbarItem": {"name": "''", "disabled": "false"},
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
        assert name in index and f"{name}Props" in index, f"{name} is not publicly exported"
        for token in ("WebView", "@kit.NetworkKit", "http://", "https://", "JSON.parse"):
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    assert "Swiper(" in sources["UPSwiper"]
    assert ".onChange" in sources["UPSwiper"] and "onClick" in sources["UPSwiper"]
    assert "ForEach" in sources["UPSwiper"] and "circular" in sources["UPSwiper"]
    assert "Math.max" in sources["UPSwiperIndicator"] and "ForEach" in sources["UPSwiperIndicator"]
    assert "ForEach" in sources["UPTabbar"] and "disabled" in sources["UPTabbar"]
    assert "safeAreaInsetBottom" in sources["UPTabbar"] and "onChange" in sources["UPTabbar"]
    assert "contentBuilder" in sources["UPView"] and "UPStyle.parse" in sources["UPView"]
    assert "contentBuilder" in sources["UPBox"] and "borderRadius" in sources["UPBox"]
    assert "showLine" in sources["UPSection"] and "arrow" in sources["UPSection"]
    assert "onCancel" in sources["UPToolbar"] and "onConfirm" in sources["UPToolbar"]

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components O" in catalog, "missing Phase 11 sample group Components O"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "100 个已实现组件/控制器", "98 个组件 + 2 个控制器", "98 条组件示例路由",
        "阶段 11", "UPView", "UPBox", "UPSwiper", "UPTabbar", "Components O", "phase-11.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 11 documentation missing {phrase}"
    for phrase in ("阶段 11", "API 24", "5.0.0(12)", "设备验证", "skipped", "no-op"):
        assert phrase in note, f"phase-11 note missing {phrase}"

    print("phase 11 container-swiper-tabbar contract: PASS")


if __name__ == "__main__":
    main()
