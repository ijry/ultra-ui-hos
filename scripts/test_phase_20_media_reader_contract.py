#!/usr/bin/env python3
"""Static contracts for Phase 20 cropper, poster, short video and novel reader."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
CONTROLLERS = ROOT / "ultra-ui/src/main/ets/controllers"
INDEX = ROOT / "ultra-ui/Index.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-20.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

SOURCES = {
    "UPCropper": (
        "UPCropperOptions", "UPCropperProps", "UPCropperOpenOptions", "UPCropperConfirmEvent",
        "UPCropperInitEvent", "UPCropperFailureEvent", "UPCropperFailureReason",
        "UPCropperRect", "UPCropperPlacement", "UPCropperConstraint", "UPCropperTouch",
        "UPCropperPreview", "UPCropperHandle", "upCropperSelection", "upCropperPlacement",
        "upCropperConstraint", "upCropperResize", "upCropperTranslate", "upCropperScale",
        "upCropperHandleAt", "upCropperDistance", "upCropperRotate", "upCropperSaturate",
        "upCropperSaturation", "upCropperPreviewPlacement", "upCropperImageBounds",
        "upCropperLength", "upCropperQuality", "upCropperStretchSupported",
        "isLocalCanvasSource", "UPSlider", "PinchGesture", "PanGesture", "GestureGroup",
        "GestureMode.Parallel", "CanvasRenderingContext2D", "RenderingContextSettings",
        "toDataURL", "getImageData", "putImageData", "ImageData", "ImageBitmap",
        "rotateImage", "showPreview", "hidePreview", "paintMask", "paintHandle",
        "paintPreview", "changeSaturation", "actionBar", "previewBar", "runAction",
        "imageWidthValue", "imageHeightValue", "layout", "paint", "touchStart",
        "touchMove", "touchEnd", "no-source", "remote-source", "empty-area", "export-failed",
    ),
    "UPPoster": (
        "UPPosterOptions", "UPPosterProps", "UPPosterFailureEvent", "UPPosterFailureReason",
        "UPPosterConfig", "UPPosterView", "UPPosterStyle", "UPPosterGradient",
        "UPPosterGradientLine", "UPPosterLine", "upPosterLength", "upPosterGradient",
        "upPosterGradientBackground", "upPosterGradientLine", "upPosterWrapText",
        "upPosterLineClamp", "upPosterBaseline", "upPosterStrokeWidth",
        "upPosterTypeSupported", "UPQrcodeEncoder", "upQrcodeForeground", "upQrcodeLevel",
        "isLocalCanvasSource", "UPPosterController", "UPPosterCommand", "UPPosterImage",
        "paintView", "paintBox", "paintText", "paintImage", "paintQrcode", "paintGradient",
        "paintRoundRect", "exportImage", "lastImage", "createLinearGradient",
        "createRadialGradient", "addColorStop", "quadraticCurveTo", "toDataURL",
        "not-ready", "export-failed", "empty-views",
    ),
    "UPShortVideo": (
        "UPShortVideoOptions", "UPShortVideoProps", "UPShortVideoItem", "UPShortVideoAuthor",
        "UPShortVideoActionEvent", "UPShortVideoProgressEvent", "UPShortVideoPlaybackEvent",
        "UPShortVideoTimeEvent", "UPShortVideoSpeedEvent", "UP_SHORT_VIDEO_TABS",
        "UP_SHORT_VIDEO_SPEEDS", "UP_SHORT_VIDEO_TABBAR_TEXTS", "UP_SHORT_VIDEO_TABBAR_ICONS",
        "upShortVideoAuthorName", "upShortVideoAuthorDesc", "upShortVideoAuthorAvatar",
        "upShortVideoRate", "upShortVideoProgress", "upShortVideoSpeedSupported",
        "upShortVideoSpeedLabel", "upShortVideoTabs", "upShortVideoTabbarItems",
        "upShortVideoCount", "VideoController", "Video(", "PreparedInfo", "PlaybackInfo",
        "onPrepared", "onUpdate", "onStart", "onPause", "onFinish", "objectFit",
        "UPActionSheet", "UPAvatar", "UPButton", "UPSlider", "UPTabs", "UPTabbar",
        "changeTab", "changeVideo", "dispatchAction", "progressChanging", "progressChanged",
        "selectSpeed", "timeUpdate", "actionRail", "authorRail", "actionColumn",
        "videoPage", "progressBar", "speedEntry", "vertical(true)",
    ),
    "UPNovelReader": (
        "UPNovelReaderOptions", "UPNovelReaderProps", "UPNovelReaderError",
        "UPNovelLayoutEvent", "UPNovelToolbarEvent", "UPNovelReadingTimeEvent",
        "UPNovelChapter", "UPNovelChapterRequest", "UPNovelBookmark", "UPNovelProgress",
        "UPNovelSettings", "UPNovelSettingsPatch", "UPNovelStorage", "UPNovelTheme",
        "UPNovelPersistedState", "upNovelNormalizeContent", "upNovelPaginate",
        "upNovelResolveAnchor", "upNovelMergeSettings", "upNovelNormalizeProgress",
        "upNovelCreateBookmark", "upNovelToggleBookmark", "upNovelNormalizePersisted",
        "upNovelExcerpt", "upNovelResolveContentWidth", "upNovelTheme", "upNovelThemeLabel",
        "upNovelProgressLabel", "upNovelProgressPercent", "upNovelTapZone", "upNovelMode",
        "UPNovelReaderController", "UPNovelReaderCommand", "refreshContent", "refreshLayout",
        "emitProgress", "prefetchIfNeeded", "requestChapter", "toggleBookmark",
        "updateSettings", "selectChapter", "selectBookmark", "queuePersist",
        "flushPersistence", "activateReading", "pauseReading", "toggleControls",
        "hideControls", "scheduleHide", "handleTap", "movePage", "handlePageChange",
        "handleScroll", "scrollBody", "pageBody", "readerBody", "topToolbar",
        "bottomToolbar", "catalogPanel", "settingsPanel", "settingRow", "initializeState",
        "setTimeout", "clearTimeout", "onDidScroll", "Swiper", "ClickEvent",
    ),
}

INTERNAL_SOURCES = {
    "UPCropperGeometry": (
        "UP_CROPPER_TAB_HEIGHT", "UP_CROPPER_VIEW_INSET_X", "UP_CROPPER_VIEW_INSET_Y",
        "UP_CROPPER_MIN_SCALE", "UP_CROPPER_MAX_SCALE", "UP_CROPPER_QUALITY",
        "UP_CROPPER_HANDLE_HIT", "UP_CROPPER_HANDLE_SIZE", "UP_CROPPER_MIN_SELECTION",
        "UP_CROPPER_MOVE_GUARD", "UP_CROPPER_PINCH_FACTOR", "UP_CROPPER_DRAW_INTERVAL",
        "UP_CROPPER_MASK_ALPHA", "UP_CROPPER_BORDER_WIDTH", "UP_CROPPER_CORNER_LENGTH",
        "UP_CROPPER_STRETCH_MODES", "UP_CROPPER_EMPTY_AREA_TEXT", "upCropperHue",
        "upCropperCorrectHue", "upCropperCreateChannel", "upCropperCovers",
    ),
    "UPPosterLayout": (
        "UP_POSTER_DEFAULT_WIDTH", "UP_POSTER_DEFAULT_HEIGHT", "UP_POSTER_ELLIPSIS",
        "UP_POSTER_GRADIENT_ANGLE", "UP_POSTER_VIEW_TYPES", "UP_POSTER_EXPORT_TIMEOUT",
        "UP_POSTER_QRCODE_PLACEHOLDER_TEXT", "upPosterRatio", "upPosterCharacters",
        "upPosterFitLength", "upPosterEstimateWidth", "upPosterGradientColors",
        "upPosterGradientAngle",
    ),
    "UPNovelLayout": (
        "UP_NOVEL_DEFAULT_FONT_SIZE", "UP_NOVEL_DEFAULT_LINE_HEIGHT",
        "UP_NOVEL_DEFAULT_PARAGRAPH_SPACING", "UP_NOVEL_DEFAULT_CONTENT_WIDTH",
        "UP_NOVEL_FONT_SIZE_MIN", "UP_NOVEL_FONT_SIZE_MAX", "UP_NOVEL_MODES",
        "UP_NOVEL_THEMES", "UP_NOVEL_STORAGE_VERSION", "UP_NOVEL_STORAGE_PREFIX",
        "UP_NOVEL_VIEWPORT_INSET", "UP_NOVEL_PERSIST_DELAY", "UP_NOVEL_EXCERPT_BEFORE",
        "UP_NOVEL_EXCERPT_AFTER", "UP_NOVEL_BLANK_FACTOR", "UP_NOVEL_LATIN_FACTOR",
        "upNovelClamp", "upNovelTokenize", "upNovelWrapText", "upNovelCharacterWidth",
        "upNovelMeasureText", "upNovelLineHeight", "upNovelContentWidth",
        "upNovelStorageKey", "UPNovelParagraph", "UPNovelPage", "UPNovelLine",
        "UPNovelAnchor", "UPNovelLayoutOptions", "UPNovelLayoutResult",
    ),
}

CONTROLLER_TOKENS = {
    "UPPosterController": (
        "UPPosterCommand", "UPPosterControllerListener", "UPPosterImage", "mount",
        "unmount", "exportImage", "redraw", "lastImage", "updateSnapshot", "dispatch",
    ),
    "UPNovelReaderController": (
        "UPNovelReaderCommand", "UPNovelReaderControllerListener", "mount", "unmount",
        "movePage", "requestChapter", "toggleControls", "toggleBookmark", "updateSettings",
        "setMode", "retry", "currentProgress", "currentBookmarks", "currentReadingTime",
        "updateSnapshot", "dispatch",
    ),
}

DEMOS_BY_ROUTE = {
    "cropper": "CropperDemo.ets",
    "poster": "PosterDemo.ets",
    "short-video": "ShortVideoDemo.ets",
    "novel-reader": "NovelReaderDemo.ets",
}

DEFAULTS = {
    "UPCropper": {
        "imageSrc": "''", "areaWidth": "'300rpx'", "areaHeight": "'300rpx'",
        "exportWidth": "'260rpx'", "exportHeight": "'260rpx'", "canScale": "true",
        "canRotate": "true", "canChangeSize": "false", "inner": "false", "noTab": "true",
        "fillColor": "UP_CROPPER_TRANSPARENT", "show": "false",
    },
    "UPPoster": {
        "qrcodeLevel": "3", "viewportWidth": "375", "showCanvas": "true",
    },
    "UPShortVideo": {
        "currentTab": "0", "currentVideo": "0", "autoPlay": "true", "loop": "true",
        "muted": "false", "showTabbar": "true", "showProgress": "true",
        "showSpeedEntry": "false", "followText": "'关注'",
    },
    "UPNovelReader": {
        "loading": "false", "bookId": "''", "storageKey": "''", "persist": "true",
        "mode": "'scroll'", "showBack": "true", "backIcon": "'arrow-left'",
        "safeAreaInsetTop": "true", "safeAreaInsetBottom": "true",
        "preloadThreshold": "2", "pageAnimation": "true", "controlsAutoHide": "0",
    },
}

INTERNAL_CONSTANTS = {
    "UPCropperGeometry": {
        "UP_CROPPER_TAB_HEIGHT": "50", "UP_CROPPER_VIEW_INSET_X": "40",
        "UP_CROPPER_VIEW_INSET_Y": "80", "UP_CROPPER_MAX_SCALE": "4",
        "UP_CROPPER_HANDLE_HIT": "20", "UP_CROPPER_HANDLE_SIZE": "10",
        "UP_CROPPER_MIN_SELECTION": "50", "UP_CROPPER_MOVE_GUARD": "100",
        "UP_CROPPER_DRAW_INTERVAL": "20", "UP_CROPPER_BORDER_WIDTH": "3",
        "UP_CROPPER_CORNER_LENGTH": "20",
    },
    "UPPosterLayout": {
        "UP_POSTER_DEFAULT_LINE_HEIGHT": "20", "UP_POSTER_GRADIENT_ANGLE": "135",
        "UP_POSTER_EXPORT_TIMEOUT": "20000", "UP_POSTER_QRCODE_PLACEHOLDER_FONT_SIZE": "12",
    },
    "UPNovelLayout": {
        "UP_NOVEL_DEFAULT_FONT_SIZE": "18", "UP_NOVEL_DEFAULT_PARAGRAPH_SPACING": "16",
        "UP_NOVEL_FONT_SIZE_MIN": "12", "UP_NOVEL_FONT_SIZE_MAX": "48",
        "UP_NOVEL_BOLD_WEIGHT": "600", "UP_NOVEL_STORAGE_VERSION": "1",
        "UP_NOVEL_VIEWPORT_INSET": "64", "UP_NOVEL_PERSIST_DELAY": "180",
        "UP_NOVEL_EXCERPT_BEFORE": "12", "UP_NOVEL_EXCERPT_AFTER": "28",
        "UP_NOVEL_ARTICLE_PADDING": "32",
    },
}

EXPORTS = (
    "UPCropper", "UPCropperProps", "UPCropperOptions", "UPCropperOpenOptions",
    "UPCropperConfirmEvent", "UPCropperInitEvent", "UPCropperFailureEvent",
    "UPCropperRect", "UPCropperPlacement", "UPCropperConstraint", "UPCropperTouch",
    "UPCropperPreview", "upCropperLength", "upCropperQuality", "upCropperConstraint",
    "upCropperSelection", "upCropperPlacement", "upCropperResize", "upCropperTranslate",
    "upCropperScale", "upCropperRotate", "upCropperSaturate", "upCropperPreviewPlacement",
    "UPPoster", "UPPosterProps", "UPPosterOptions", "UPPosterController",
    "UPPosterCommand", "UPPosterImage", "UPPosterConfig", "UPPosterView", "UPPosterStyle",
    "upPosterLength", "upPosterGradient", "upPosterWrapText", "upPosterEstimateWidth",
    "upPosterTypeSupported", "UPShortVideo", "UPShortVideoProps", "UPShortVideoOptions",
    "UPShortVideoItem", "UPShortVideoAuthor", "UPShortVideoActionEvent",
    "UPShortVideoProgressEvent", "UPShortVideoTimeEvent", "UPShortVideoSpeedEvent",
    "UP_SHORT_VIDEO_TABS", "UP_SHORT_VIDEO_SPEEDS", "upShortVideoRate",
    "upShortVideoProgress", "upShortVideoSpeedLabel", "upShortVideoTabbarItems",
    "UPNovelReader", "UPNovelReaderProps", "UPNovelReaderOptions",
    "UPNovelReaderController", "UPNovelReaderCommand", "UPNovelChapter",
    "UPNovelParagraph", "UPNovelPage", "UPNovelSettings", "UPNovelProgress",
    "UPNovelBookmark", "UPNovelStorage", "UPNovelTheme", "UPNovelPersistedState",
    "UP_NOVEL_MODES", "UP_NOVEL_THEMES", "upNovelPaginate", "upNovelWrapText",
    "upNovelMergeSettings", "upNovelToggleBookmark", "upNovelTheme", "upNovelTapZone",
)

RESERVED_HELPER_NAMES = ("overlay", "position", "margin", "offset", "rotate", "preview",
                         "toolbar", "clip", "align", "direction")


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

    internals: dict[str, str] = {}
    for name, required in INTERNAL_SOURCES.items():
        source = read(INTERNAL / f"{name}.ets")
        internals[name] = source
        for token in required:
            assert token in source, f"{name} missing {token}"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for name, required in CONTROLLER_TOKENS.items():
        source = read(CONTROLLERS / f"{name}.ets")
        assert f"export class {name}" in source
        for token in required:
            assert token in source, f"{name} missing {token}"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    for module, constants in INTERNAL_CONSTANTS.items():
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", internals[module]), (
                f"{module} constant {constant}={value} missing"
            )

    cropper_geometry = internals["UPCropperGeometry"]
    assert "0.005" in cropper_geometry, "UPCropperGeometry keeps the upstream pinch factor"
    assert "'x', 'y', 'long', 'short', 'longSel', 'shortSel'" in cropper_geometry, (
        "UPCropperGeometry keeps the upstream stretch whitelist"
    )
    # 阶段 26 起裁剪器文案改读语言包，断言随之锁定 i18n 键而非字面量
    for keyword in ("up.common.re-select", "up.common.close", "up.common.rotate",
                    "up.common.preview", "up.common.confirm", "up.cropper.emptyWidhtOrHeight"):
        assert keyword in cropper_geometry, f"UPCropperGeometry copy missing {keyword}"

    poster_layout = internals["UPPosterLayout"]
    assert "'750rpx'" in poster_layout and "'1114rpx'" in poster_layout, (
        "UPPosterLayout keeps the upstream default poster size"
    )
    assert "0.56" in poster_layout and "0.28" in poster_layout, (
        "UPPosterLayout keeps the upstream width estimation factors"
    )
    for angle in ("angle === 0", "angle === 90", "angle === 180", "angle === 270"):
        assert angle in poster_layout, f"UPPosterLayout gradient branch missing {angle}"

    novel_layout = internals["UPNovelLayout"]
    assert "'scroll', 'page'" in novel_layout, "UPNovelLayout keeps the upstream mode whitelist"
    assert "'day', 'paper', 'green', 'night', 'dark'" in novel_layout, (
        "UPNovelLayout keeps the five upstream themes"
    )
    for palette in ("'#f7f8fa'", "'#f3ead7'", "'#e7f1e4'", "'#202124'", "'#111214'"):
        assert palette in novel_layout, f"UPNovelLayout theme background missing {palette}"
    assert "uview-plus:novel-reader:" in novel_layout, (
        "UPNovelLayout keeps the upstream storage prefix"
    )
    assert "lineHeight <= 4" in novel_layout, (
        "UPNovelLayout keeps the upstream line-height multiplier rule"
    )

    cropper = sources["UPCropper"]
    for field in ("stretch", "lock", "chooseImage", "quality", "noTab", "imageWidth"):
        assert f"'{field}'" in cropper, f"UPCropper must report the {field} boundary"
    assert "'仅支持本地图片地址'" in cropper and "'裁剪结果导出失败'" in cropper

    poster = sources["UPPoster"]
    for field in ("views", "exportImage", "timeout", "blob", "src"):
        assert f"'{field}'" in poster, f"UPPoster must report the {field} boundary"
    assert "'海报导出失败'" in poster and "'画布尚未就绪'" in poster

    short_video = sources["UPShortVideo"]
    assert "[0.5, 0.75, 1, 1.25, 1.5, 2]" in short_video, "UPShortVideo speed options changed"
    assert "'推荐', '关注', '朋友', '本地'" in short_video, "UPShortVideo default tabs changed"
    for field in ("videoUrl", "enableProgressGesture", "createVideoContext", "playbackRate"):
        assert f"'{field}'" in short_video, f"UPShortVideo must report the {field} boundary"

    novel = sources["UPNovelReader"]
    for field in ("mode", "theme", "persist", "autoBack", "createSelectorQuery", "fontFamily", "storage"):
        assert f"'{field}'" in novel, f"UPNovelReader must report the {field} boundary"
    assert "'previous'" in novel and "'next'" in novel and "'catalog'" in novel

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components X" in catalog, "missing Phase 20 sample group Components X"
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
        "阶段 20", "UPCropper", "UPPoster", "UPShortVideo", "UPNovelReader",
        "Components X", "141 个组件", "144 条组件示例路由", "phase-20.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 20 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPCropper", "UPPoster", "UPPosterController",
        "UPShortVideo", "UPNovelReader", "UPNovelReaderController", "chooseImage",
        "toTempFilePath", "getImageInfo", "createVideoContext", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-20 note missing {phrase}"

    print("phase 20 media reader contract: PASS")


if __name__ == "__main__":
    main()
