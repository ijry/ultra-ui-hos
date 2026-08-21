#!/usr/bin/env python3
"""Static contracts for Phase 4A native interaction components."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "ultra-ui/Index.ets"
COMPONENTS_DIR = ROOT / "ultra-ui/src/main/ets/components"
DEMOS_DIR = ROOT / "sample/entry/src/main/ets/demos"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
NOTE = ROOT / "docs/compatibility/phase-4a.md"
README = ROOT / "README.md"

COMPONENTS = {
    "UPCircleProgress": (
        "percentage", "activeColor", "inactiveColor", "width", "borderWidth",
        "customStyle", "contentBuilder",
    ),
    "UPAlert": (
        "title", "type", "description", "closable", "showIcon", "effect",
        "modelValue", "value", "customStyle", "onVisibleChange", "onClick",
        "onClose", "onClosed",
    ),
    "UPNotify": (
        "show", "message", "type", "color", "bgColor", "onShowChange",
        "onClick", "onClose", "customStyle",
    ),
    "UPNoticeBar": (
        "show", "text", "direction", "mode", "url", "linkType",
        "onShowChange", "onClick", "onClose", "customStyle",
    ),
    "UPActionSheet": (
        "show", "title", "description", "actions", "nameKey", "subnameKey",
        "cancelText", "closeOnClickAction", "safeAreaInsetBottom", "openType",
        "closeOnClickOverlay", "round", "wrapMaxHeight", "index", "customStyle",
        "onShowChange", "onSelect", "onCancel", "onClose", "onClickOverlay",
    ),
    "UPBackTop": (
        "mode", "icon", "text", "duration", "scrollTop", "top", "bottom",
        "right", "zIndex", "iconStyle", "customStyle", "onClick", "onBackToTop",
    ),
    "UPCollapse": (
        "value", "modelValue", "accordion", "border", "arrow", "disabled", "clickable",
        "customStyle", "onChange", "onValueChange", "contentBuilder",
    ),
    "UPCollapseItem": (
        "title", "titleStyle", "value", "label", "disabled", "isLink", "clickable",
        "border", "align", "name", "icon", "duration", "showRight", "iconStyle",
        "rightIconStyle", "cellCustomStyle", "cellCustomClass", "customStyle", "isOpen",
        "open", "onClick", "contentBuilder",
    ),
    "UPDropdown": (
        "activeColor", "inactiveColor", "closeOnClickMask", "closeOnClickSelf", "duration",
        "height", "borderBottom", "titleSize", "borderRadius", "menuIcon", "menuIconSize",
        "customStyle", "closeOnClickOverlay", "direction", "menu", "bgColor", "openIndex",
        "onOpenChange", "onOpen", "onClose", "contentBuilder",
    ),
    "UPDropdownItem": (
        "modelValue", "value", "title", "options", "disabled", "height", "closeOnClickOverlay",
        "customStyle", "multiple", "onValueChange", "onChange", "onSelect",
    ),
}

DEMOS = {
    "circle-progress": "CircleProgressDemo.ets",
    "alert": "AlertDemo.ets",
    "notify": "NotifyDemo.ets",
    "notice-bar": "NoticeBarDemo.ets",
    "action-sheet": "ActionSheetDemo.ets",
    "back-top": "BackTopDemo.ets",
    "collapse": "CollapseDemo.ets",
    "collapse-item": "CollapseItemDemo.ets",
    "dropdown": "DropdownDemo.ets",
    "dropdown-item": "DropdownItemDemo.ets",
}

DEFAULTS = {
    "UPCircleProgress": (("percentage", "30"), ("width", "100"), ("borderWidth", "5")),
    "UPAlert": (("type", "'warning'"), ("effect", "'light'"), ("value", "true")),
    "UPNotify": (("show", "false"), ("type", "'primary'")),
    "UPNoticeBar": (("show", "true"), ("direction", "'row'"), ("mode", "''")),
    "UPActionSheet": (("show", "false"), ("closeOnClickAction", "true"), ("closeOnClickOverlay", "true")),
    "UPBackTop": (("mode", "'circle'"), ("scrollTop", "0"), ("top", "400")),
    "UPCollapse": (("accordion", "false"), ("disabled", "false"), ("clickable", "true")),
    "UPCollapseItem": (("disabled", "false"), ("clickable", "true"), ("isOpen", "false"), ("open", "undefined")),
    "UPDropdown": (("openIndex", "-1"), ("direction", "'down'"), ("closeOnClickMask", "true")),
    "UPDropdownItem": (("disabled", "false"), ("multiple", "false")),
}

FORBIDDEN = (
    "WebView", "FastView", ".xyfv", "@ohos.net", "request(",
    "http://", "https://",
)


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def assert_public_component(name: str, fields: tuple[str, ...], index: str) -> str:
    source = read(COMPONENTS_DIR / f"{name}.ets")
    assert f"export interface {name}Options" in source, f"missing {name}Options"
    assert f"export class {name}Props" in source, f"missing {name}Props"
    assert re.search(rf"export struct {name}\b", source), f"missing {name} component"
    for field in fields:
        assert re.search(rf"\b{re.escape(field)}\b", source), f"{name} missing {field}"
    for field, value in DEFAULTS[name]:
        pattern = rf"\b{re.escape(field)}\s*:\s*UPRawValue\s*=\s*{re.escape(value)}"
        assert re.search(pattern, source), f"{name} missing default {field} = {value}"
    assert name in index, f"{name} is not publicly exported"
    assert f"{name}Props" in index, f"{name}Props is not publicly exported"
    assert f"{name}Options" in index, f"{name}Options is not publicly exported"
    for token in FORBIDDEN:
        assert token not in source, f"{name} contains forbidden token {token!r}"
    return source


def main() -> None:
    index = read(INDEX)
    sources = {
        name: assert_public_component(name, fields, index)
        for name, fields in COMPONENTS.items()
    }

    assert "ProgressType.Ring" in sources["UPCircleProgress"], "circle progress must use native ring progress"
    assert "UPNoticeBarClickEvent" in sources["UPNoticeBar"], "notice bar click event is required"
    assert "index: number" in sources["UPNoticeBar"], "notice click event must preserve the visible item index"
    assert "url: string" in sources["UPNoticeBar"], "notice click event must preserve url"
    assert "linkType: string" in sources["UPNoticeBar"], "notice click event must preserve linkType"
    assert "modelValue !== null" in sources["UPAlert"] or "modelValue !== undefined" in sources["UPAlert"], (
        "alert must preserve modelValue/value priority"
    )
    assert "UPActionSheetAction" in sources["UPActionSheet"], "action sheet action type is required"
    assert "UPActionSheetSelectEvent" in sources["UPActionSheet"], "action sheet select event is required"
    assert "disabled" in sources["UPActionSheet"] and "loading" in sources["UPActionSheet"], (
        "action sheet must guard disabled and loading actions"
    )
    assert "onCancel" in sources["UPActionSheet"] and "onClickOverlay" in sources["UPActionSheet"]
    assert "scrollTop" in sources["UPBackTop"] and ">=" in sources["UPBackTop"], (
        "back-top must use the controlled scroll threshold"
    )
    assert "onBackToTop" in sources["UPBackTop"], "back-top callback is required"
    assert "return 'circle'" in sources["UPBackTop"], "invalid back-top modes must fall back to circle"
    context = read(COMPONENTS_DIR.parent / "internal/UPInteractionContexts.ets")
    for method in ("beginComposition", "itemName", "isOpen", "requestToggle", "itemCount"):
        assert method in context, f"collapse context missing {method}"
    assert "accordion" in sources["UPCollapse"] and "modelValue" in sources["UPCollapse"]
    assert "modelValue !== null" in sources["UPCollapse"] or "modelValue !== undefined" in sources["UPCollapse"], (
        "collapse must preserve modelValue/value priority"
    )
    assert "contentBuilder" in sources["UPCollapseItem"], "collapse item content builder is required"
    assert "@Consume" in sources["UPCollapseItem"], "collapse item must consume a group context"
    dropdown_context = context
    for method in ("openIndex", "requestOpen", "close", "isOpen"):
        assert method in dropdown_context, f"dropdown context missing {method}"
    assert "UPDropdownOption" in sources["UPDropdownItem"], "dropdown option type is required"
    assert "UPDropdownItemSelectEvent" in sources["UPDropdownItem"], "dropdown select event is required"
    assert "modelValue !== null" in sources["UPDropdownItem"] or "modelValue !== undefined" in sources["UPDropdownItem"], (
        "dropdown item must preserve modelValue/value priority"
    )
    assert "disabled" in sources["UPDropdownItem"] and "return" in sources["UPDropdownItem"], (
        "dropdown item must guard disabled options"
    )
    assert "requestOpen(-1)" in sources["UPDropdownItem"], "single-select dropdown must request close"
    assert "multiple" in sources["UPDropdownItem"], "multiple-select dropdown must retain open state"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components F" in catalog, "sample catalog missing Components F"
    assert "Components G" in catalog, "sample catalog missing Components G"
    assert "Components H" in catalog, "sample catalog missing Components H"
    for route, filename in DEMOS.items():
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        demo = read(DEMOS_DIR / filename)
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must use the public HAR entry"
        assert route in page, f"SamplePage missing route dispatch {route}"
        assert filename.removesuffix(".ets") in page, f"SamplePage missing {filename} import"
        assert "ultra-ui/src" not in demo and "../src/main" not in demo
        for token in FORBIDDEN:
            assert token not in demo, f"{filename} contains forbidden token {token!r}"

    circle_demo = read(DEMOS_DIR / "CircleProgressDemo.ets")
    for percentage in (0, 30, 100):
        assert f"percentage: {percentage}" in circle_demo, f"circle demo missing {percentage}% state"

    note = read(NOTE)
    for phrase in (
        "阶段 4A", "API 24", "5.0.0(12)", *COMPONENTS.keys(),
        "页面受控状态", "无网络", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-4a note missing {phrase}"

    readme = read(README)
    for phrase in (
        "阶段 4A", "54 个已实现组件/控制器", "52 条组件示例路由", "phase-4a.md",
    ):
        assert phrase in readme, f"README missing {phrase}"

    print("phase 4A native interaction contract: PASS")


if __name__ == "__main__":
    main()
