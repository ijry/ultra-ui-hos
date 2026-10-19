#!/usr/bin/env python3
"""Static contracts for Phase 15 car keyboard, message input, cate tab, coupon and tabs pro."""
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
NOTE = ROOT / "docs/compatibility/phase-15.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo",
)

SOURCES = {
    "UPCarKeyboard": (
        "UPCarKeyboardOptions", "UPCarKeyboardProps", "UPCarKeyboardRow",
        "UPCarKeyboardChangeEvent", "upCarKeyboardShuffle", "upCarKeyboardRows",
        "toggleMode", "beginBackspace", "stopBackspace", "clearAutoTimer",
        "keyboardRow", "langButton", "backspaceButton", "onTouch", "setInterval",
        "onBackspace", "autoChange", "backspace",
    ),
    "UPMessageInput": (
        "UPMessageInputOptions", "UPMessageInputProps", "UPMessageInputChangeEvent",
        "upMessageInputDigits", "hiddenInput", "cellIndexes", "cellValue", "cellColor",
        "cellOpacity", "isActiveCell", "breatheOn", "startBreathe", "stopBreathe",
        "TextInput", "InputType.Number", "bottomLine", "middleLine", "onFinish",
        "finishedValue", "dotFill",
    ),
    "UPCateTab": (
        "UPCateTabOptions", "UPCateTabProps", "UPCateTabItem", "UPCateTabChildItem",
        "UPCateTabItemSlot", "UPCateTabPageSlot", "UPCateTabPageItemSlot",
        "UPCateTabRightTopSlot", "upCateTabValue", "upCateTabChildValue",
        "tabItemBuilder", "rightTopBuilder", "itemListBuilder", "pageItemBuilder",
        "menuScroller", "pageScroller", "groupOffsets", "recordOffset", "scrollMenuTo",
        "scrollPageTo", "selectMenu", "syncFromScroll", "scrollLocked", "onAreaChange",
        "onDidScroll", "isVisibleGroup", "onCurrentChange",
    ),
    "UPCoupon": (
        "UPCouponOptions", "UPCouponProps", "UPCouponAmountSlot", "UPCouponInfoSlot",
        "UPCouponActionSlot", "UPCouponGradient", "upCouponGradient", "amountBuilder",
        "infoBuilder", "actionBuilder", "contentBuilder", "notches", "envelopeStripe",
        "surface", "linearGradient", "dividerColor", "themeName", "shapeName",
        "sizeName", "couponHeight", "gradientFrom", "gradientTo", "UPTag", "envelope",
    ),
    "UPTabsPro": (
        "UPTabsProOptions", "UPTabsProProps", "UPTabsProContentSlot",
        "upTabsProNormalizeCurrent", "leftRegion", "rightRegion", "iconRegion",
        "tabRegion", "contentBuilder", "contentSlot", "currentValue", "currentItem",
        "handleChange", "updateCurrent", "applyCurrent", "resolvedLineColor",
        "UPTabs", "UPTabsProps", "showContent",
    ),
}

DEMOS_BY_ROUTE = {
    "car-keyboard": "CarKeyboardDemo.ets",
    "message-input": "MessageInputDemo.ets",
    "cate-tab": "CateTabDemo.ets",
    "coupon": "CouponDemo.ets",
    "tabs-pro": "TabsProDemo.ets",
}

DEFAULTS = {
    "UPCarKeyboard": {
        "random": "false", "autoChange": "false",
    },
    "UPMessageInput": {
        "maxlength": "4", "dotFill": "false", "mode": "'box'", "modelValue": "''",
        "breathe": "true", "focus": "false", "bold": "false", "fontSize": "60",
        "activeColor": "'#2979ff'", "inactiveColor": "'#606266'", "width": "'80'",
        "disabledKeyboard": "false",
    },
    "UPCateTab": {
        "mode": "'follow'", "height": "'100%'", "tabList": r"\[\]",
        "tabKeyName": "'name'", "itemKeyName": "'name'", "current": "0",
    },
    "UPCoupon": {
        "amount": "''", "unit": "'￥'", "unitPosition": "'left'", "limit": "''",
        "title": "'优惠券'", "desc": "''", "time": "''", "actionText": "'使用'",
        "shape": "'coupon'", "size": "'medium'", "circle": "false", "disabled": "false",
        "bgColor": "''", "color": "''", "type": "''",
    },
    "UPTabsPro": {
        "list": r"\[\]", "keyName": "'name'", "current": "0", "contentMode": "'static'",
        "lineWidth": "20", "lineHeight": "3", "lineBgSize": "'cover'",
        "scrollable": "true", "duration": "300", "showContent": "true",
        "contentClass": "''", "bindIndexRef": "''",
    },
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
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{value}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    keyboard = sources["UPCarKeyboard"]
    for token in ("京", "沪", "粤", "使", "学"):
        assert token in keyboard, f"UPCarKeyboard province key {token} missing"
    assert keyboard.count("slice(") >= 4, "UPCarKeyboard must slice 36 keys into four rows"
    assert "'backspace'" in keyboard, "UPCarKeyboard must reuse the shipped backspace glyph"
    assert "clearTimeout" in keyboard and "clearInterval" in keyboard, (
        "UPCarKeyboard must release both the auto switch and repeat timers"
    )

    message = sources["UPMessageInput"]
    assert "UP_MESSAGE_INPUT_BREATHE_DURATION" in message, (
        "UPMessageInput must keep the upstream 1.2s breathing period as a constant"
    )
    assert ".opacity(0.01)" in message, "UPMessageInput must keep the hidden input tappable"
    assert "keyframes" in message, "UPMessageInput must document the css keyframes fallback"

    cate = sources["UPCateTab"]
    assert "createSelectorQuery" in cate, "UPCateTab must document the measurement fallback"
    assert "'tab'" in cate and "'follow'" in cate, "UPCateTab must support both upstream modes"

    coupon = sources["UPCoupon"]
    assert "'primary'" in coupon and "'success'" in coupon and "'warning'" in coupon and "'error'" in coupon, (
        "UPCoupon must map the four built-in gradients"
    )
    assert "repeating: true" in coupon, "UPCoupon envelope stripes rely on a repeating gradient"
    assert "BorderStyle.Dashed" in coupon, "UPCoupon must keep the dashed amount divider"

    tabs_pro = sources["UPTabsPro"]
    assert "diagnostics" in tabs_pro, "UPTabsPro must report unsupported props"
    for token in ("contentMode", "contentClass", "bindIndexRef", "lineBgSize"):
        assert f"'{token}'" in tabs_pro, f"UPTabsPro must report the {token} no-op"
    assert re.search(r"leftBuilder:\s*this\.leftRegion", tabs_pro), (
        "UPTabsPro must forward builder params through wrapper builders"
    )

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components S" in catalog, "missing Phase 15 sample group Components S"
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
        "阶段 15", "UPCarKeyboard", "UPMessageInput", "UPCateTab", "UPCoupon",
        "UPTabsPro", "Components S", "117 个组件", "117 条组件示例路由", "phase-15.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 15 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPCarKeyboard", "UPMessageInput", "UPCateTab",
        "UPCoupon", "UPTabsPro", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-15 note missing {phrase}"

    print("phase 15 keyboard content contract: PASS")


if __name__ == "__main__":
    main()
