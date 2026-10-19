#!/usr/bin/env python3
"""Static contracts for the phase 3A content and input component batch."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMP = ROOT / "ultra-ui/src/main/ets/components"
DEMO = ROOT / "sample/entry/src/main/ets/demos"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-3a.md"

COMPONENTS = {
    "UPText": "text",
    "UPImage": "image",
    "UPEmpty": "empty",
    "UPLoadingPage": "loading-page",
    "UPSearch": "search",
    "UPCodeInput": "code-input",
}

FIELDS = {
    "UPText": (
        "type", "show", "text", "prefixIcon", "suffixIcon", "mode", "href", "format", "call",
        "openType", "bold", "block", "lines", "color", "size", "iconStyle", "decoration", "margin",
        "lineHeight", "align", "wordWrap", "flex1", "customStyle", "onClick", "onOpen", "onCall",
    ),
    "UPImage": (
        "src", "mode", "width", "height", "shape", "radius", "lazyLoad", "showMenuByLongpress",
        "loadingIcon", "errorIcon", "showLoading", "showError", "fade", "webp", "duration", "bgColor",
        "customStyle", "onClick",
    ),
    "UPEmpty": (
        "icon", "text", "textColor", "textSize", "iconColor", "iconSize", "mode", "width", "height",
        "show", "marginTop", "customStyle",
    ),
    "UPLoadingPage": (
        "loadingText", "image", "loadingMode", "loading", "bgColor", "color", "fontSize", "iconSize",
        "loadingColor", "zIndex", "customStyle",
    ),
    "UPSearch": (
        "modelValue", "value", "shape", "bgColor", "placeholder", "clearabled", "onlyClearableOnFocused",
        "focus", "showAction", "actionText", "label", "inputAlign", "disabled", "animation", "borderColor",
        "searchIconColor", "searchIconSize", "color", "placeholderColor", "searchIcon", "margin", "iconPosition",
        "maxlength", "height", "adjustPosition", "autoBlur", "inputStyle", "actionStyle", "customStyle",
        "onInput", "onChange", "onClear", "onSearch", "onCustom", "onFocus", "onBlur", "onClick", "onClickIcon",
    ),
    "UPCodeInput": (
        "adjustPosition", "maxlength", "dot", "mode", "hairline", "space", "modelValue", "value", "focus",
        "bold", "color", "fontSize", "size", "disabledKeyboard", "borderColor", "disabledDot", "customStyle",
        "onInput", "onChange", "onFinish",
    ),
}

DEMOS = {
    "text": "TextDemo.ets",
    "image": "ImageDemo.ets",
    "empty": "EmptyDemo.ets",
    "loading-page": "LoadingPageDemo.ets",
    "search": "SearchDemo.ets",
    "code-input": "CodeInputDemo.ets",
}

DEFAULTS = {
    "UPText": (("show", "true"), ("mode", "'text'"), ("lines", "1"), ("size", "15"), ("decoration", "'none'"), ("align", "'left'"), ("wordWrap", "'normal'"), ("bold", "false"), ("block", "false")),
    "UPImage": (("mode", "'aspectFill'"), ("width", "300"), ("height", "225"), ("shape", "'square'"), ("radius", "0"), ("showLoading", "true"), ("showError", "true"), ("bgColor", "'#f3f4f6'")),
    "UPEmpty": (("textColor", "'#c0c4cc'"), ("textSize", "14"), ("iconSize", "90"), ("mode", "'data'"), ("width", "160"), ("height", "160"), ("show", "true")),
    "UPLoadingPage": (("loadingText", "UPI18n.t('up.common.loading2')"), ("loadingMode", "'circle'"), ("loading", "false"), ("fontSize", "19"), ("iconSize", "19"), ("loadingColor", "'#C8C8C8'"), ("zIndex", "10")),
}

FORBIDDEN = ("WebView", "FastView", ".xyfv", "http://", "https://", "@ohos.net", "request(")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    catalog = read(CATALOG)
    page = read(PAGE)
    readme = read(README)
    note = read(NOTE)

    for component, route in COMPONENTS.items():
        source = read(COMP / f"{component}.ets")
        assert f"class {component}Props" in source, f"missing {component}Props"
        assert re.search(rf"export struct {component}\b", source), f"missing {component} struct"
        assert component in index, f"{component} is not publicly exported"
        for field in FIELDS[component]:
            assert re.search(rf"\b{re.escape(field)}\b", source), f"{component} missing {field}"
        for field, value in DEFAULTS.get(component, ()):
            expected = rf"\b{re.escape(field)}\s*:\s*UPRawValue\s*=\s*{re.escape(value)}"
            assert re.search(expected, source), f"{component} missing default {field} = {value}"
        assert route in catalog, f"missing catalog route: {route}"
        assert re.search(rf"route === ['\"]{re.escape(route)}['\"]", page), f"missing page route: {route}"
        demo = read(DEMO / DEMOS[route])
        assert "@lingyun/ultra-ui-hos" in demo, f"{route} demo must use public HAR entry"
        assert "ultra-ui/src" not in demo and "../src/main" not in demo
        assert "@Component" in demo and "build()" in demo

        for forbidden in FORBIDDEN:
            assert forbidden not in source, f"forbidden dependency {forbidden!r} in {component}"
            assert forbidden not in demo, f"forbidden dependency {forbidden!r} in {route} demo"

    for symbol in [*(f"{name}Props" for name in COMPONENTS), "UPTextClickEvent", "UPImageClickEvent", "UPSearchChangeEvent", "UPSearchConfirmEvent", "UPCodeInputChangeEvent"]:
        assert re.search(rf"\b{re.escape(symbol)}\b", index), f"{symbol} is not publicly exported"

    for phrase in (
        "阶段 3A", "UPText", "UPImage", "UPEmpty", "UPLoadingPage", "UPSearch", "UPCodeInput",
        "API 24", "5.0.0(12)", "modelValue", "clearabled", "本地资源", "无网络", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-3a note missing {phrase}"
    for phrase in ("阶段 3A", "UPText", "UPImage", "UPEmpty", "UPLoadingPage", "UPSearch", "UPCodeInput", "phase-3a.md"):
        assert phrase in readme, f"README missing {phrase}"

    print("phase 3A content input contract: PASS")


if __name__ == "__main__":
    main()
