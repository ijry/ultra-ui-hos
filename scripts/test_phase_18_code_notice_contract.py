#!/usr/bin/env python3
"""Static contracts for Phase 18 qrcode, barcode, notice bars and number keyboard."""
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
NOTE = ROOT / "docs/compatibility/phase-18.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo",
)

SOURCES = {
    "UPQrcode": (
        "UPQrcodeOptions", "UPQrcodeProps", "UPQrcodeEncoder", "UPQrcodePolynomial",
        "UPQrcodeGaloisField", "UPQrcodeBitBuffer", "UP_QRCODE_PAD0", "UP_QRCODE_PAD1",
        "UP_QRCODE_ERROR_CORRECT_LEVEL", "UP_QRCODE_G15", "UP_QRCODE_G18",
        "UP_QRCODE_G15_MASK", "UP_QRCODE_PATTERN_POSITION_TABLE",
        "UP_QRCODE_RS_BLOCK_TABLE", "UP_QRCODE_FIELD", "upQrcodeUnicodeFormat8",
        "upQrcodeUtf8Bytes", "upQrcodeBchTypeInfo", "upQrcodeBchTypeNumber",
        "upQrcodeMaskAt", "upQrcodeId", "upQrcodeLevel", "upQrcodeForeground",
        "getModuleCount", "getTypeNumber", "getTotalDataCount", "isDark", "resolveType",
        "createData", "createBytes", "resetMatrix", "setModule", "makeImpl",
        "setupProbe", "setupAdjust", "setupTiming", "setupTypeNumber", "setupTypeInfo",
        "mapData", "lostPoint", "createQrcode", "signature", "edge", "quiet", "backdrop",
        "cid", "handleReady", "publish", "fail", "clear", "draw", "drawIcon",
        "drawRoundedRect", "emitResult", "preview", "longpress", "captureRoot",
        "measure", "loadingMask", "upCanvasParseSize", "upCanvasUnitSupported",
        "isLocalCanvasSource", "UPLoadingIcon", "LongPressGesture", "onAreaChange",
        "RenderingContextSettings", "CanvasRenderingContext2D", "toDataURL",
    ),
    "UPBarcode": (
        "UPBarcodeOptions", "UPBarcodeProps", "UPBarcodeEncodeResult",
        "UPBarcodeRenderedEvent", "UP_BARCODE_CODE128_START_B", "UP_BARCODE_CODE128_STOP",
        "UP_BARCODE_CODE128_CHARS", "UP_BARCODE_CODE128_PATTERNS",
        "UP_BARCODE_CODE39_CHARS", "UP_BARCODE_CODE39_PATTERNS", "UP_BARCODE_LEFT_ODD",
        "UP_BARCODE_LEFT_EVEN", "UP_BARCODE_RIGHT", "UP_BARCODE_EAN13_PATTERNS",
        "UP_BARCODE_FORMATS", "upBarcodeFormatSupported", "upBarcodeCode128Pattern",
        "upBarcodeCode128", "upBarcodeCode39", "upBarcodeEan13", "upBarcodeEan8",
        "upBarcodeEan52", "upBarcodeUpca", "upBarcodeUpce", "upBarcodeEncode",
        "upBarcodeDigitAt", "signature", "barWidth", "barHeight", "textSize", "textGap",
        "label", "textSpot", "alignment", "backdrop", "foreground", "marginTop",
        "marginBottom", "marginLeft", "marginRight", "textBand", "boxWidth", "boxHeight",
        "handleReady", "generate", "drawBars", "emitRendered", "errorBox",
        "upCanvasTextAlign", "clearRect", "fillRect", "fillText", "toDataURL",
    ),
    "UPRowNotice": (
        "UPRowNoticeOptions", "UPRowNoticeProps", "UP_ROW_NOTICE_SLICE_LENGTH",
        "UP_ROW_NOTICE_FRAMES_PER_SECOND", "upRowNoticeSlices", "upRowNoticeSpeedPx",
        "upRowNoticeDuration", "upRowNoticeStep", "upCanvasEstimateTextWidth", "Marquee",
        "MarqueeUpdateStrategy.DEFAULT", "fromStart", "loop: -1", "restart",
        "clearStartTimer", "contentText", "modeName", "iconName", "textColor", "textSize",
        "click", "close", "leftIcon", "rightIcon", "rootBackground", "setTimeout",
        "clearTimeout", "aboutToDisappear",
    ),
    "UPColumnNotice": (
        "UPColumnNoticeOptions", "UPColumnNoticeProps", "UP_COLUMN_NOTICE_SWIPER_HEIGHT",
        "upColumnNoticeItems", "Swiper", "autoPlay(true)", "indicator(false)",
        "loop(true)", "disableSwipe(", "verticalScroll", "itemAlign", "noticeChange",
        "interval", "items", "modeName", "iconName", "textColor", "textSize", "click",
        "close", "leftIcon", "rightIcon", "notice", "carousel", "rootBackground",
        "FlexAlign.SpaceEvenly", "layoutWeight(1)",
    ),
    "UPNumberKeyboard": (
        "UPNumberKeyboardOptions", "UPNumberKeyboardProps", "UPNumberKeyboardKey",
        "UPNumberKeyboardChangeEvent", "UP_NUMBER_KEYBOARD_DOT",
        "UP_NUMBER_KEYBOARD_CARD_X", "UP_NUMBER_KEYBOARD_BACKSPACE",
        "UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL", "upNumberKeyboardShuffle",
        "upNumberKeyboardKeys", "upNumberKeyboardModeSupported", "upNumberKeyboardWideKey",
        "upNumberKeyboardGrayKey", "rebuildKeys", "modeName", "dotHidden", "randomOrder",
        "keyList", "keyWidth", "keyHeight", "keyGap", "press", "beginBackspace",
        "stopBackspace", "keyButton", "backspaceButton", "rootBackground", "setInterval",
        "clearInterval", "TouchType.Down", "TouchType.Up", "TouchType.Cancel",
        "'222rpx'", "'464rpx'", "'90rpx'", "FlexWrap.Wrap", "FlexAlign.SpaceAround",
    ),
}

DEMOS_BY_ROUTE = {
    "qrcode": "QrcodeDemo.ets",
    "barcode": "BarcodeDemo.ets",
    "row-notice": "RowNoticeDemo.ets",
    "column-notice": "ColumnNoticeDemo.ets",
    "number-keyboard": "NumberKeyboardDemo.ets",
}

DEFAULTS = {
    "UPQrcode": {
        "cid": "''", "size": "200", "unit": "'px'", "show": "true", "val": "''",
        "background": "'#ffffff'", "foreground": "'#000000'", "pdground": "'#000000'",
        "icon": "''", "iconSize": "40", "lv": "3", "quietZone": "0", "onval": "true",
        "loadMake": "true", "usingComponents": "true", "showLoading": "true",
        "loadingText": "'生成中'", "allowPreview": "false",
        "useRootHeightAndWidth": "false",
    },
    "UPBarcode": {
        "value": "''", "format": "'auto'", "width": "200", "height": "80",
        "displayValue": "true", "text": "undefined", "fontOptions": "''",
        "font": "'monospace'", "textAlign": "'center'", "textPosition": "'bottom'",
        "textMargin": "2", "fontSize": "14", "background": "'#ffffff'",
        "lineColor": "'#000000'", "margin": "10", "useCanvas": "true",
    },
    "UPRowNotice": {
        "text": "''", "icon": "'volume'", "mode": "''", "color": "'#f9ae3d'",
        "bgColor": "'#fdf6ec'", "fontSize": "14", "speed": "80",
    },
    "UPColumnNotice": {
        "text": "''", "icon": "'volume'", "mode": "''", "color": "'#f9ae3d'",
        "bgColor": "'#fdf6ec'", "fontSize": "14", "speed": "80", "step": "false",
        "duration": "1500", "disableTouch": "true", "justifyContent": "'flex-start'",
    },
    "UPNumberKeyboard": {
        "mode": "'number'", "dotDisabled": "false", "random": "false",
    },
}

CONSTANTS = {
    "UPQrcode": {"UP_QRCODE_PAD0": "0xEC", "UP_QRCODE_PAD1": "0x11"},
    "UPBarcode": {
        "UP_BARCODE_CODE128_START_B": "104",
        "UP_BARCODE_CODE128_STOP": "106",
    },
    "UPRowNotice": {
        "UP_ROW_NOTICE_SLICE_LENGTH": "20",
        "UP_ROW_NOTICE_FRAMES_PER_SECOND": "60",
    },
    "UPColumnNotice": {"UP_COLUMN_NOTICE_SWIPER_HEIGHT": "16"},
    "UPNumberKeyboard": {"UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL": "250"},
}

STRING_CONSTANTS = {
    "UPNumberKeyboard": {
        "UP_NUMBER_KEYBOARD_DOT": "'.'",
        "UP_NUMBER_KEYBOARD_CARD_X": "'X'",
        "UP_NUMBER_KEYBOARD_BACKSPACE": "'backspace'",
    },
}

EXPORTS = (
    "UPQrcodeEncoder", "upQrcodeUnicodeFormat8", "upQrcodeUtf8Bytes",
    "upQrcodeBchTypeInfo", "upQrcodeBchTypeNumber", "upQrcodeMaskAt", "upQrcodeId",
    "upQrcodeLevel", "upQrcodeForeground", "UPBarcodeEncodeResult",
    "UPBarcodeRenderedEvent", "upBarcodeFormatSupported", "upBarcodeCode128Pattern",
    "upBarcodeCode128", "upBarcodeCode39", "upBarcodeEan13", "upBarcodeEan8",
    "upBarcodeEan52", "upBarcodeUpca", "upBarcodeUpce", "upBarcodeEncode",
    "UP_ROW_NOTICE_SLICE_LENGTH", "UP_ROW_NOTICE_FRAMES_PER_SECOND",
    "upRowNoticeSlices", "upRowNoticeSpeedPx", "upRowNoticeDuration", "upRowNoticeStep",
    "UP_COLUMN_NOTICE_SWIPER_HEIGHT", "upColumnNoticeItems", "UPNumberKeyboardKey",
    "UPNumberKeyboardChangeEvent", "UP_NUMBER_KEYBOARD_DOT", "UP_NUMBER_KEYBOARD_CARD_X",
    "UP_NUMBER_KEYBOARD_BACKSPACE", "UP_NUMBER_KEYBOARD_BACKSPACE_INTERVAL",
    "upNumberKeyboardShuffle", "upNumberKeyboardKeys", "upNumberKeyboardModeSupported",
    "upNumberKeyboardWideKey", "upNumberKeyboardGrayKey",
)

RESERVED_HELPER_NAMES = ("overlay", "position", "margin", "offset")


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
        for helper in RESERVED_HELPER_NAMES:
            assert f"private {helper}(" not in source, (
                f"{name} helper {helper}() collides with a CommonAttribute method"
            )

    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

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

    for component, constants in STRING_CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*string\s*=\s*{value}\s*;", sources[component]), (
                f"{component} constant {constant}={value} missing"
            )

    qrcode = sources["UPQrcode"]
    assert "[1, 0, 3, 2]" in qrcode, (
        "UPQrcode keeps the upstream L/M/Q/H error correction level order"
    )
    assert "return 3;" in qrcode, "UPQrcode clamps an out-of-range lv back to H"
    assert "isLocalCanvasSource(icon)" in qrcode, (
        "UPQrcode only draws local center icons"
    )
    assert "'二维码内容不能为空'" in qrcode and "'二维码导出失败'" in qrcode
    for field in ("unit", "show", "allowPreview", "val", "icon"):
        assert f"'{field}'" in qrcode, f"UPQrcode must report the {field} boundary"
    assert "'data-url'" in qrcode, "UPQrcode must report the data URL export boundary"
    assert "onResult" in qrcode and "onPreview" in qrcode and "onLongpress" in qrcode and "onError" in qrcode

    barcode = sources["UPBarcode"]
    for fmt in ("'CODE128'", "'CODE39'", "'EAN13'", "'EAN8'", "'UPCA'", "'UPCE'", "'ITF14'", "'codabar'"):
        assert fmt in barcode, f"UPBarcode format {fmt} missing from the upstream whitelist"
    assert "'top'" in barcode and "'bottom'" in barcode, (
        "UPBarcode keeps both upstream text positions"
    )
    assert "size !== 0 ? size : 20" in barcode, (
        "UPBarcode mirrors the upstream `fontSize || 20` fallback"
    )
    assert "'生成条码图片失败'" in barcode
    for field in ("format", "font", "useCanvas"):
        assert f"'{field}'" in barcode, f"UPBarcode must report the {field} boundary"
    assert "'canvas'" in barcode and "'image'" in barcode, (
        "UPBarcode rendered event keeps both upstream shapes"
    )
    assert "onRendered" in barcode and "onError" in barcode

    row = sources["UPRowNotice"]
    assert "'link'" in row and "'closable'" in row, "UPRowNotice mode branches missing"
    assert "return 80;" in row, "UPRowNotice falls back to the upstream default speed"
    for field in ("text", "mode", "bgColor", "speed"):
        assert f"'{field}'" in row, f"UPRowNotice must report the {field} boundary"
    assert "'volume'" in row, "UPRowNotice keeps the upstream default icon"
    assert "onClick" in row and "onClose" in row

    column = sources["UPColumnNotice"]
    for align in ("'center'", "'flex-end'", "'space-between'", "'space-around'", "'space-evenly'"):
        assert align in column, f"UPColumnNotice justifyContent {align} missing"
    assert "Math.max(100" in column, "UPColumnNotice clamps the swiper interval"
    for field in ("text", "mode", "speed", "bgColor"):
        assert f"'{field}'" in column, f"UPColumnNotice must report the {field} boundary"
    assert "onClick" in column and "onClose" in column

    keyboard = sources["UPNumberKeyboard"]
    assert "'card'" in keyboard and "'number'" in keyboard, "UPNumberKeyboard modes missing"
    assert "Math.random()" in keyboard, "UPNumberKeyboard random order needs the upstream shuffle"
    assert "'#bbbcc6'" in keyboard and "rgb(200, 202, 210)" in keyboard and "rgb(224, 228, 230)" in keyboard
    for field in ("mode", "hoverClass"):
        assert f"'{field}'" in keyboard, f"UPNumberKeyboard must report the {field} boundary"
    assert "onChange" in keyboard and "onBackspace" in keyboard

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components V" in catalog, "missing Phase 18 sample group Components V"
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
        "阶段 18", "UPQrcode", "UPBarcode", "UPRowNotice", "UPColumnNotice",
        "UPNumberKeyboard", "Components V", "132 个组件", "132 条组件示例路由",
        "phase-18.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 18 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPQrcode", "UPBarcode", "UPRowNotice",
        "UPColumnNotice", "UPNumberKeyboard", "toTempFilePath", "previewImage",
        "hover-class", "Marquee", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-18 note missing {phrase}"

    print("phase 18 code notice contract: PASS")


if __name__ == "__main__":
    main()
