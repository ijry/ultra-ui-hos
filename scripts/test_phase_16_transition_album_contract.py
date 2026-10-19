#!/usr/bin/env python3
"""Static contracts for Phase 16 transition, album, calendar strip, choose and guide."""
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
NOTE = ROOT / "docs/compatibility/phase-16.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo",
)

SOURCES = {
    "UPTransition": (
        "UPTransitionOptions", "UPTransitionProps", "UPTransitionFrame",
        "upTransitionModeSupported", "upTransitionHiddenFrame", "upTransitionCurve",
        "UP_TRANSITION_ENTER_DELAY", "beginEnter", "beginLeave", "finishTransition",
        "clearTimers", "transitionEnded", "durationValue", "modeName", "curveValue",
        "handleClick", "contentBuilder", "setTimeout", "clearTimeout",
        ".animation(", ".translate(", ".scale(", "Visibility.None",
    ),
    "UPAlbum": (
        "UPAlbumOptions", "UPAlbumProps", "UPAlbumItem", "UPAlbumPreviewEvent",
        "upAlbumSource", "upAlbumItems", "upAlbumKeySupported", "upAlbumRows",
        "isLocalAlbumSource", "albumFit", "emitAlbumWidth", "albumWidthValue",
        "showOverflow", "overflowText", "overflowFontSize", "cellMarginRight",
        "cellMarginBottom", "cellRadius", "cellSource", "cellFit", "handlePreview",
        "onAlbumWidth", "sizeValue", "图片占位", "暂无图片",
    ),
    "UPCalendarStrip": (
        "UPCalendarStripOptions", "UPCalendarStripProps", "UPCalendarStripDay",
        "UPCalendarStripChangeEvent", "UPCalendarStripToggleEvent",
        "upCalendarStripPad", "upCalendarStripFormatDate", "upCalendarStripFormatMonth",
        "upCalendarStripDaysInMonth", "upCalendarStripNormalizeDate",
        "upCalendarStripCompare", "upCalendarStripClamp", "upCalendarStripMonthLabel",
        "upCalendarStripWeekIndex", "UP_CALENDAR_STRIP_CELL_WIDTH",
        "UP_CALENDAR_STRIP_CELL_HEIGHT", "dayCells", "switchMonth", "switchPrevDisabled",
        "switchNextDisabled", "firstEnabledDate", "jumpToday", "toggleFull",
        "thresholdValue", "handleTouch", "hintText", "handleFullSelect", "emitChange",
        "selectDate", "syncViewToSelected", "UPCalendar", "TouchType.Down", "TouchType.Up",
    ),
    "UPChoose": (
        "UPChooseOptions", "UPChooseProps", "UPChooseItem", "UPChooseChangeEvent",
        "upChooseLabel", "upChooseValue", "upChooseKeySupported", "UPTag", "UPTagProps",
        "itemIndexes", "labelOf", "handleChange", "itemContent", "itemList",
        "onCustomClick", "FlexWrap.Wrap", "ScrollDirection.Horizontal", "暂无可选项",
    ),
    "UPGuide": (
        "UPGuideOptions", "UPGuideProps", "UPGuideItem", "UPGuideStorage",
        "UPGuideChangeEvent", "upGuideRemembered", "isLocalGuideImage", "bootstrap",
        "remembered", "remember", "forget", "emitShowChange", "pageIndexes", "lastPage",
        "handleSwiperChange", "handlePrimaryAction", "handleSkip", "closeGuide",
        "surfaceColor", "stackZIndex", "Swiper", "暂无引导图",
    ),
}

DEMOS_BY_ROUTE = {
    "transition": "TransitionDemo.ets",
    "album": "AlbumDemo.ets",
    "calendar-strip": "CalendarStripDemo.ets",
    "choose": "ChooseDemo.ets",
    "guide": "GuideDemo.ets",
}

DEFAULTS = {
    "UPTransition": {
        "show": "false", "mode": "'fade'", "duration": "'300'",
        "timingFunction": "'ease-out'",
    },
    "UPAlbum": {
        "urls": r"\[\]", "keyName": "''", "singleSize": "180", "multipleSize": "70",
        "space": "6", "singleMode": "'scaleToFill'", "multipleMode": "'aspectFill'",
        "maxCount": "9", "previewFullImage": "true", "rowCount": "3", "showMore": "true",
        "shape": "'square'", "radius": "0", "autoWrap": "false", "unit": "'px'",
        "stop": "true",
    },
    "UPCalendarStrip": {
        "modelValue": "null", "minDate": "0", "maxDate": "0", "color": "'#3c9cff'",
        "fullCalendar": "true", "fullMonthNum": "24", "pullDownThreshold": "40",
        "collapseAfterSelect": "true", "readonly": "false", "showToday": "true",
        "monthFormat": "''",
    },
    "UPChoose": {
        "options": r"\[\]", "type": "'radio'", "itemWidth": "'auto'",
        "itemHeight": "'50px'", "itemPadding": "'8px'", "labelName": "'title'",
        "valueName": "'value'", "customClick": "false", "wrap": "true",
    },
    "UPGuide": {
        "show": "false", "list": r"\[\]", "storageKey": "'up-guide-default'",
        "once": "true", "showSkip": "true", "indicator": "true", "bgColor": "'#111111'",
        "stackLevel": "10075",
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

    transition = sources["UPTransition"]
    for mode in (
        "none", "fade", "fade-up", "fade-down", "fade-left", "fade-right",
        "slide-up", "slide-down", "slide-left", "slide-right", "zoom", "fade-zoom",
    ):
        assert f"'{mode}'" in transition, f"UPTransition mode {mode} missing"
    for curve in ("Curve.Linear", "Curve.Ease", "Curve.EaseIn", "Curve.EaseOut", "Curve.EaseInOut"):
        assert curve in transition, f"UPTransition timing function {curve} missing"
    assert re.search(r"UP_TRANSITION_ENTER_DELAY:\s*number\s*=\s*20\s*;", transition), (
        "UPTransition must keep the upstream 20ms enter delay as a constant"
    )
    assert "?? Curve.EaseOut" in transition, "UPTransition must fall back to ease-out"
    for event in ("onBeforeEnter", "onEnter", "onAfterEnter", "onBeforeLeave", "onLeave", "onAfterLeave"):
        assert event in transition, f"UPTransition event {event} missing"

    album = sources["UPAlbum"]
    assert "'resource://'" in album and "'$rawfile:'" in album, (
        "UPAlbum must only render local image sources"
    )
    assert "`+${" in album, "UPAlbum must keep the upstream +N overflow label"
    assert "* 0.3" in album, "UPAlbum overflow label follows multipleSize * 0.3"
    assert "this.cellWidth() / 2" in album, "UPAlbum circle shape needs a half-width radius"
    assert "'rpx'" in album, "UPAlbum must honour the unit prop"
    for field in ("previewFullImage", "stop", "keyName", "singleSize"):
        assert f"'{field}'" in album, f"UPAlbum must report the {field} boundary"

    strip = sources["UPCalendarStrip"]
    for scene in ("tap", "switch", "full", "auto", "pull-down", "pull-up", "button", "hint"):
        assert f"'{scene}'" in strip, f"UPCalendarStrip scene {scene} missing"
    assert "weekStart: 1" in strip, "UPCalendarStrip expanded panel reuses UPCalendar with Monday start"
    assert re.search(r"UP_CALENDAR_STRIP_CELL_WIDTH:\s*number\s*=\s*54\s*;", strip)
    assert re.search(r"UP_CALENDAR_STRIP_CELL_HEIGHT:\s*number\s*=\s*62\s*;", strip)
    assert "Math.abs(deltaY) <= Math.abs(deltaX)" in strip, (
        "UPCalendarStrip must ignore drags dominated by the horizontal axis"
    )
    assert "onModelValueChange" in strip and "onConfirm" in strip and "onMonthChange" in strip
    for field in ("monthFormat", "fullMonthNum"):
        assert f"'{field}'" in strip, f"UPCalendarStrip must report the {field} no-op"

    choose = sources["UPChoose"]
    assert "'primary'" in choose and "'info'" in choose and "'large'" in choose, (
        "UPChoose renders the upstream tag row through UPTag"
    )
    assert "plain: !this.selected(slot.index)" in choose, "UPChoose unselected tags stay plain"
    assert "'type'" in choose, "UPChoose must report the type no-op"
    assert "customClick" in choose and "return;" in choose, (
        "UPChoose customClick must skip the internal selection"
    )

    guide = sources["UPGuide"]
    assert "private zIndex(" not in guide, "UPGuide must not shadow the CommonAttribute zIndex method"
    assert "stackLevel" in guide and "stackZIndex" in guide and "zIndex: UPRawValue" in guide, (
        "UPGuide exposes the upstream zIndex prop and keeps stackLevel as the alias"
    )
    assert "'storage'" in guide, "UPGuide must report the missing storage boundary"
    assert "onShowChange" in guide and "onSkip" in guide and "onFinish" in guide and "onClose" in guide
    assert "this.closing" in guide, "UPGuide must deduplicate close calls"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components T" in catalog, "missing Phase 16 sample group Components T"
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
        "阶段 16", "UPTransition", "UPAlbum", "UPCalendarStrip", "UPChoose",
        "UPGuide", "Components T", "122 个组件", "122 条组件示例路由", "phase-16.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 16 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPTransition", "UPAlbum", "UPCalendarStrip",
        "UPChoose", "UPGuide", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-16 note missing {phrase}"

    print("phase 16 transition album contract: PASS")


if __name__ == "__main__":
    main()
