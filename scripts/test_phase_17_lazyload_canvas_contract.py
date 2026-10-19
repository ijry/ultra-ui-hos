#!/usr/bin/env python3
"""Static contracts for Phase 17 lazy load, canvas, signature, color picker and goods sku."""
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
NOTE = ROOT / "docs/compatibility/phase-17.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo",
)

SOURCES = {
    "UPLazyLoad": (
        "UPLazyLoadOptions", "UPLazyLoadProps", "UPLazyLoadEvent",
        "UP_LAZY_LOAD_EFFECT_DELAY", "UP_LAZY_LOAD_STATUS_INITIAL",
        "UP_LAZY_LOAD_STATUS_LAZYED", "UP_LAZY_LOAD_STATUS_LOADED",
        "upLazyLoadThreshold", "upLazyLoadEffectSupported", "upLazyLoadEffectCurve",
        "upLazyLoadFit", "upLazyLoadNextStatus", "isLocalLazyLoadSource",
        "applyImage", "placeholderSource", "errorSource", "boxHeight", "cornerRadius",
        "durationValue", "curveValue", "fitValue", "handleVisibleChange", "reveal",
        "startEffect", "clearEffectTimer", "handleComplete", "handleError",
        "handleClick", "placeholderText", "onVisibleAreaChange", ".alt(",
        "setTimeout", "clearTimeout", "图片占位",
    ),
    "UPCanvas": (
        "UPCanvasOptions", "UPCanvasProps", "UPCanvasSurface", "UPCanvasTextMetrics",
        "UPCanvasTouchEvent", "UPCanvasImageDataOptions", "UPCanvasPutImageDataOptions",
        "UP_CANVAS_DEFAULT_FONT_SIZE", "UP_CANVAS_DEFAULT_FONT_FAMILY", "upCanvasId",
        "upCanvasParseSize", "upCanvasUnitSupported", "upCanvasLineCap",
        "upCanvasLineJoin", "upCanvasTextAlign", "upCanvasTextBaseline",
        "upCanvasDirection", "upCanvasFillRule", "upCanvasEstimateTextWidth",
        "isLocalCanvasSource", "RenderingContextSettings", "CanvasRenderingContext2D",
        "createLinearGradient", "createRadialGradient", "setLineDash", "getLineDash",
        "measureText", "estimateTextWidth", "clearCanvas", "exportImage", "toDataURL",
        "drawImageRegion", "getImageData", "putImageData", "onReady", "onTouchStart",
        "onTouchMove", "onTouchEnd",
    ),
    "UPSignature": (
        "UPSignatureOptions", "UPSignatureProps", "UPSignaturePoint",
        "UPSignatureToolButton", "UP_SIGNATURE_PRESET_COLORS", "UP_SIGNATURE_POINT_START",
        "UP_SIGNATURE_POINT_MOVE", "UP_SIGNATURE_ICON_COLOR",
        "UP_SIGNATURE_ICON_DISABLED_COLOR", "upSignatureStrokeColor",
        "upSignatureLineWidth", "toolButtons", "runAction", "handleReady", "pointOf",
        "handleStart", "handleUpdate", "handleEnd", "applyLineStyle", "undo", "clear",
        "redraw", "clearCanvas", "exportSignature", "reportError",
        "toggleBrushSettings", "toggleColorSettings", "selectColor", "canvasFrame",
        "toolButton", "brushSettings", "colorSettings", "toolPanel", "PanGesture",
        "distance: 0", "toDataURL",
    ),
    "UPColorPicker": (
        "UPColorPickerOptions", "UPColorPickerProps", "UPColorPickerStop",
        "UPColorPickerDirection", "UP_COLOR_PICKER_DIRECTIONS",
        "UP_COLOR_PICKER_TRACK_WIDTH", "UP_COLOR_PICKER_GRADIENT_MAX",
        "UP_COLOR_PICKER_GRADIENT_MIN", "upColorPickerHslToRgb",
        "upColorPickerDirectionAngle", "upColorPickerDirectionFromAngle",
        "upColorPickerGradientCss", "upColorPickerArkAngle", "upColorPickerAddStop",
        "upColorPickerRemoveStop", "UPSubsectionItem", "typeList", "stopIndexes",
        "spectrumColors", "trackColors", "gradientCss", "displayColor",
        "previewIsGradient", "setStopColor", "saveSolidState", "restoreSolidState",
        "saveGradientState", "restoreGradientState", "changeColorType",
        "parseSolidColor", "openStopEditor", "updateSolidColor",
        "updateSaturationPosition", "updateHuePosition", "updateAlphaPosition",
        "startStopDrag", "updateStopDrag", "endStopDrag", "updateDirection", "addStop",
        "selectCommonColor", "saturationPanel", "hueBar", "alphaBar", "stopPointer",
        "gradientTrack", "directionWheel", "gradientSection", "commonSection",
        "previewBlock", "PanGesture", "sweepGradient",
    ),
    "UPGoodsSku": (
        "UPGoodsSkuOptions", "UPGoodsSkuProps", "UPGoodsSkuLeaf", "UPGoodsSkuTreeItem",
        "UPGoodsSkuSelection", "UPGoodsSkuCombination", "UPGoodsSkuInfo",
        "UPGoodsSkuConfirmEvent", "UPGoodsSkuChoice", "UP_GOODS_SKU_MAX_BUY",
        "UP_GOODS_SKU_IMAGE_SIZE", "UP_GOODS_SKU_CONTENT_MAX_HEIGHT",
        "UP_GOODS_SKU_ERROR_COLOR", "UP_GOODS_SKU_RESERVED_KEYS",
        "upGoodsSkuValueOf", "upGoodsSkuKeySupported", "upGoodsSkuPrice",
        "upGoodsSkuStock", "upGoodsSkuMatch", "isLocalGoodsSkuSource", "reportInputs",
        "panelVisible", "activeSelections", "selectionsWith", "combinationOf",
        "priceText", "stockValue", "maxBuyNum", "chosenCount", "canBuy", "selectedText",
        "isSelected", "isDisabled", "chooseSku", "changeNum", "closeIconVisible",
        "UPNumberBoxChangeEvent", "upValueKey", "VerticalAlign.Bottom", "图片占位",
    ),
}

DEMOS_BY_ROUTE = {
    "lazy-load": "LazyLoadDemo.ets",
    "canvas": "CanvasDemo.ets",
    "signature": "SignatureDemo.ets",
    "color-picker": "ColorPickerDemo.ets",
    "goods-sku": "GoodsSkuDemo.ets",
}

DEFAULTS = {
    "UPLazyLoad": {
        "index": "''", "image": "''", "imgMode": "'widthFix'", "loadingImg": "''",
        "errorImg": "''", "threshold": "100", "duration": "500",
        "effect": "'ease-in-out'", "isEffect": "true", "borderRadius": "0",
        "height": "'200'",
    },
    "UPCanvas": {
        "canvasId": "''", "width": "300", "height": "300", "unit": "'px'",
        "useRootHeightAndWidth": "false", "bgColor": "'#ffffff'",
        "disableScroll": "false",
    },
    "UPSignature": {
        "width": "300", "height": "200", "bgColor": "'#ffffff'", "color": "'#000000'",
        "thickness": "3", "showToolbar": "true",
    },
    "UPColorPicker": {
        "modelValue": "'#ff0000'", "commonColors": r"\[\]", "show": "false",
    },
    "UPGoodsSku": {
        "goodsInfo": r"\{\}", "skuTree": r"\[\]", "skuList": r"\[\]",
        "maxBuy": "UP_GOODS_SKU_MAX_BUY", "confirmText": r"UPI18n\.t\('up\.common\.confirm'\)", "closeable": "true",
        "pageInline": "false", "show": "false",
    },
}

CONSTANTS = {
    "UPLazyLoad": {"UP_LAZY_LOAD_EFFECT_DELAY": "30"},
    "UPCanvas": {"UP_CANVAS_DEFAULT_FONT_SIZE": "12"},
    "UPColorPicker": {
        "UP_COLOR_PICKER_TRACK_WIDTH": "280",
        "UP_COLOR_PICKER_GRADIENT_MAX": "5",
        "UP_COLOR_PICKER_GRADIENT_MIN": "2",
    },
    "UPGoodsSku": {
        "UP_GOODS_SKU_MAX_BUY": "999",
        "UP_GOODS_SKU_IMAGE_SIZE": "90",
        "UP_GOODS_SKU_CONTENT_MAX_HEIGHT": "300",
    },
}

LOCAL_SOURCE_GUARDS = ("UPLazyLoad", "UPCanvas", "UPGoodsSku")


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

    for component, constants in CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", sources[component]), (
                f"{component} constant {constant}={value} missing"
            )

    for component in LOCAL_SOURCE_GUARDS:
        source = sources[component]
        for scheme in ("'resource://'", "'file://'", "'$rawfile:'"):
            assert scheme in source, f"{component} local source whitelist missing {scheme}"

    lazy = sources["UPLazyLoad"]
    for effect in ("linear", "ease", "ease-in", "ease-out", "ease-in-out"):
        assert f"'{effect}'" in lazy, f"UPLazyLoad effect {effect} missing"
    for fit in ("ImageFit.Contain", "ImageFit.Cover", "ImageFit.Fill"):
        assert fit in lazy, f"UPLazyLoad image mode {fit} missing"
    for mode in ("'widthfix'", "'heightfix'", "'aspectfit'", "'scaletofill'"):
        assert mode in lazy, f"UPLazyLoad must map the upstream image mode {mode}"
    assert "onVisibleAreaChange([0.0, 0.01]" in lazy, (
        "UPLazyLoad reveals as soon as any sliver of the frame enters the viewport"
    )
    for field in ("threshold", "effect", "image"):
        assert f"'{field}'" in lazy, f"UPLazyLoad must report the {field} boundary"
    assert "onLoad" in lazy and "onError" in lazy and "onClick" in lazy

    canvas = sources["UPCanvas"]
    for unit in ("'px'", "'rpx'", "'upx'"):
        assert unit in canvas, f"UPCanvas unit {unit} missing"
    assert "'vw'" not in canvas and "'em'" not in canvas, (
        "UPCanvas only supports the px/rpx/upx trio"
    )
    assert "callback();" in canvas, "UPCanvas draw() must keep the upstream callback timing"
    assert "`image/${fileType}`" in canvas, "UPCanvas exportImage() must honour the fileType"
    for field in ("canvasId", "disableScroll", "unit", "drawImage"):
        assert f"'{field}'" in canvas, f"UPCanvas must report the {field} boundary"
    assert "* 0.56" in canvas and "* 0.28" in canvas, (
        "UPCanvas keeps the upstream text width estimation ratios"
    )

    signature = sources["UPSignature"]
    for action in ("'undo'", "'clear'", "'confirm'", "'brush'", "'color'"):
        assert action in signature, f"UPSignature toolbar action {action} missing"
    assert "return 1;" in signature and "return 20;" in signature, (
        "UPSignature thickness must be clamped into the upstream 1-20 slider range"
    )
    assert "'thickness'" in signature and "'onTouch'" in signature and "'confirm'" in signature
    assert "'data-url'" in signature, "UPSignature must report the data URL export boundary"
    assert "onConfirm" in signature and "onClear" in signature and "onError" in signature

    picker = sources["UPColorPicker"]
    for direction in ("'to right'", "'to left'", "'to top'", "'to bottom'"):
        assert direction in picker, f"UPColorPicker direction {direction} missing"
    assert "panelWidth" in picker and "panelHeight" in picker, (
        "UPColorPicker normalises saturation per axis instead of the upstream min(width, height)"
    )
    assert "onShowChange" not in picker, "UPColorPicker replaces the trigger slot with a controlled show"
    for field in ("trigger", "onTouch", "saturation", "alphaBackground", "directionCircle"):
        assert f"'{field}'" in picker, f"UPColorPicker must report the {field} boundary"
    assert "onModelValueChange" in picker and "onConfirm" in picker and "onClose" in picker and "onClosed" in picker

    sku = sources["UPGoodsSku"]
    assert "'price'" in sku and "'price_fee'" in sku and "'stock'" in sku and "'quantity'" in sku, (
        "UPGoodsSku must keep the upstream reserved sku keys"
    )
    assert "values" in sku and "Array<UPGoodsSkuSelection>" in sku, (
        "UPGoodsSku replaces the flat sku index signature with a values array"
    )
    for field in ("trigger", "header", "borderRadius", "skuList", "close", "reset", "scrollView"):
        assert f"'{field}'" in sku, f"UPGoodsSku must report the {field} boundary"
    assert "'no-op'" in sku and "'slot'" in sku and "'method'" in sku
    assert "onOpen" in sku and "onConfirm" in sku and "onClose" in sku and "onClosed" in sku

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components U" in catalog, "missing Phase 17 sample group Components U"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert "../src/main" not in demo and "ultra-ui/src" not in demo
        assert not re.search(r"=>\s*this\.", demo), f"{filename} must not capture this in arrow bodies"
        for token in FORBIDDEN:
            assert token not in demo, f"{filename} contains forbidden boundary {token}"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "阶段 17", "UPLazyLoad", "UPCanvas", "UPSignature", "UPColorPicker",
        "UPGoodsSku", "Components U", "127 个组件", "127 条组件示例路由", "phase-17.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 17 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPLazyLoad", "UPCanvas", "UPSignature",
        "UPColorPicker", "UPGoodsSku", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-17 note missing {phrase}"

    print("phase 17 lazyload canvas contract: PASS")


if __name__ == "__main__":
    main()
