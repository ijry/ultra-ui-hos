#!/usr/bin/env python3
"""Static contract checks for public README and compatibility notes."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_json5(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    readme_path = ROOT / "README.md"
    phase1_path = ROOT / "docs/compatibility/phase-1.md"
    phase2a_path = ROOT / "docs/compatibility/phase-2a.md"
    phase2b_path = ROOT / "docs/compatibility/phase-2b.md"
    phase2c_path = ROOT / "docs/compatibility/phase-2c.md"
    phase3a_path = ROOT / "docs/compatibility/phase-3a.md"
    phase3b_path = ROOT / "docs/compatibility/phase-3b.md"
    phase4a_path = ROOT / "docs/compatibility/phase-4a.md"
    phase5_path = ROOT / "docs/compatibility/phase-5.md"
    phase6_path = ROOT / "docs/compatibility/phase-6.md"
    phase7_path = ROOT / "docs/compatibility/phase-7.md"
    phase9_path = ROOT / "docs/compatibility/phase-9.md"
    phase11_path = ROOT / "docs/compatibility/phase-11.md"
    phase12_path = ROOT / "docs/compatibility/phase-12.md"
    phase13_path = ROOT / "docs/compatibility/phase-13.md"
    phase14_path = ROOT / "docs/compatibility/phase-14.md"
    phase15_path = ROOT / "docs/compatibility/phase-15.md"
    phase16_path = ROOT / "docs/compatibility/phase-16.md"
    phase17_path = ROOT / "docs/compatibility/phase-17.md"
    phase18_path = ROOT / "docs/compatibility/phase-18.md"
    phase19_path = ROOT / "docs/compatibility/phase-19.md"
    phase20_path = ROOT / "docs/compatibility/phase-20.md"
    phase21_path = ROOT / "docs/compatibility/phase-21.md"
    phase22_path = ROOT / "docs/compatibility/phase-22.md"
    phase23_path = ROOT / "docs/compatibility/phase-23.md"
    phase24_path = ROOT / "docs/compatibility/phase-24.md"
    phase25_path = ROOT / "docs/compatibility/phase-25.md"
    phase26_path = ROOT / "docs/compatibility/phase-26.md"
    phase27_path = ROOT / "docs/compatibility/phase-27.md"
    phase28_path = ROOT / "docs/compatibility/phase-28.md"
    assert readme_path.is_file(), "README.md is required"
    assert phase1_path.is_file(), "phase-1 compatibility note is required"
    assert phase2a_path.is_file(), "phase-2a compatibility note is required"
    assert phase2b_path.is_file(), "phase-2b compatibility note is required"
    assert phase2c_path.is_file(), "phase-2c compatibility note is required"
    assert phase3a_path.is_file(), "phase-3a compatibility note is required"
    assert phase3b_path.is_file(), "phase-3b compatibility note is required"
    assert phase4a_path.is_file(), "phase-4a compatibility note is required"
    assert phase5_path.is_file(), "phase-5 compatibility note is required"
    assert phase6_path.is_file(), "phase-6 compatibility note is required"
    assert phase7_path.is_file(), "phase-7 compatibility note is required"
    assert phase9_path.is_file(), "phase-9 compatibility note is required"
    assert phase11_path.is_file(), "phase-11 compatibility note is required"
    assert phase12_path.is_file(), "phase-12 compatibility note is required"
    assert phase13_path.is_file(), "phase-13 compatibility note is required"
    assert phase14_path.is_file(), "phase-14 compatibility note is required"
    assert phase15_path.is_file(), "phase-15 compatibility note is required"
    assert phase16_path.is_file(), "phase-16 compatibility note is required"
    assert phase17_path.is_file(), "phase-17 compatibility note is required"
    assert phase18_path.is_file(), "phase-18 compatibility note is required"
    assert phase19_path.is_file(), "phase-19 compatibility note is required"
    assert phase20_path.is_file(), "phase-20 compatibility note is required"
    assert phase21_path.is_file(), "phase-21 compatibility note is required"
    assert phase22_path.is_file(), "phase-22 compatibility note is required"
    assert phase23_path.is_file(), "phase-23 compatibility note is required"
    assert phase24_path.is_file(), "phase-24 compatibility note is required"
    assert phase25_path.is_file(), "phase-25 compatibility note is required"
    assert phase26_path.is_file(), "phase-26 compatibility note is required"
    assert phase27_path.is_file(), "phase-27 compatibility note is required"
    assert phase28_path.is_file(), "phase-28 compatibility note is required"

    readme = readme_path.read_text(encoding="utf-8")
    compatibility = phase1_path.read_text(encoding="utf-8")
    phase2a = phase2a_path.read_text(encoding="utf-8")
    phase2b = phase2b_path.read_text(encoding="utf-8")
    phase2c = phase2c_path.read_text(encoding="utf-8")
    phase3a = phase3a_path.read_text(encoding="utf-8")
    phase3b = phase3b_path.read_text(encoding="utf-8")
    phase4a = phase4a_path.read_text(encoding="utf-8")
    phase5 = phase5_path.read_text(encoding="utf-8")
    phase6 = phase6_path.read_text(encoding="utf-8")
    phase7 = phase7_path.read_text(encoding="utf-8")
    phase9 = phase9_path.read_text(encoding="utf-8")
    phase11 = phase11_path.read_text(encoding="utf-8")
    phase12 = phase12_path.read_text(encoding="utf-8")
    phase13 = phase13_path.read_text(encoding="utf-8")
    phase14 = phase14_path.read_text(encoding="utf-8")
    phase15 = phase15_path.read_text(encoding="utf-8")
    phase16 = phase16_path.read_text(encoding="utf-8")
    phase17 = phase17_path.read_text(encoding="utf-8")
    phase18 = phase18_path.read_text(encoding="utf-8")
    phase19 = phase19_path.read_text(encoding="utf-8")
    phase20 = phase20_path.read_text(encoding="utf-8")
    phase21 = phase21_path.read_text(encoding="utf-8")
    phase22 = phase22_path.read_text(encoding="utf-8")
    phase23 = phase23_path.read_text(encoding="utf-8")
    phase24 = phase24_path.read_text(encoding="utf-8")
    phase25 = phase25_path.read_text(encoding="utf-8")
    phase26 = phase26_path.read_text(encoding="utf-8")
    phase27 = phase27_path.read_text(encoding="utf-8")
    phase28 = phase28_path.read_text(encoding="utf-8")
    for phrase in (
        "HarmonyOS NEXT",
        "@lingyun/ultra-ui-hos",
        "UPButton",
        "UPToastHost",
        "UPLineProgress",
        "UPLoadmore",
        "阶段 2A",
        "阶段 2B",
        "UPAvatar",
        "UPAvatarGroup",
        "UPInput",
        "UPTextarea",
        "UPSwitch",
        "UPRate",
        "UPNumberBox",
        "92 个已实现组件/控制器",
        "90 个组件 + 2 个控制器",
        "90 条组件示例路由",
        "阶段 6",
        "UPList",
        "UPIndexList",
        "UPScrollList",
        "阶段 7",
        "UPSlider",
        "UPPicker",
        "UPPickerController",
        "UPSelect",
        "phase-7.md",
        "phase-8.md",
        "阶段 9",
        "UPCountDown",
        "UPCountTo",
        "UPTimeline",
        "UPCalendar",
        "UPKeyboard",
        "UPFloatingBubble",
        "phase-9.md",
        "Components M",
        "阶段 10",
        "UPTreeSelect",
        "UPCascader",
        "UPDatePicker",
        "UPTimePicker",
        "UPUpload",
        "UPProgressButton",
        "phase-10.md",
        "Components N",
        "阶段 11",
        "UPView",
        "UPBox",
        "UPSection",
        "UPToolbar",
        "UPSwiper",
        "UPSwiperIndicator",
        "UPTabbar",
        "UPTabbarItem",
        "phase-11.md",
        "阶段 12",
        "UPAgreement",
        "UPCopy",
        "UPNoNetwork",
        "UPCode",
        "102 个组件",
        "102 条组件示例路由",
        "phase-12.md",
        "Components P",
        "阶段 13",
        "UPTable",
        "UPTable2",
        "UPTr",
        "UPTh",
        "UPTd",
        "107 个组件",
        "107 条组件示例路由",
        "phase-13.md",
        "Components Q",
        "阶段 14",
        "UPVirtualList",
        "UPPullRefresh",
        "UPRefreshVirtualList",
        "UPWaterfall",
        "UPDragSort",
        "112 个组件",
        "112 条组件示例路由",
        "phase-14.md",
        "Components R",
        "阶段 15",
        "UPCarKeyboard",
        "UPMessageInput",
        "UPCateTab",
        "UPCoupon",
        "UPTabsPro",
        "117 个组件",
        "117 条组件示例路由",
        "phase-15.md",
        "Components S",
        "阶段 16",
        "UPTransition",
        "UPAlbum",
        "UPCalendarStrip",
        "UPChoose",
        "UPGuide",
        "122 个组件",
        "122 条组件示例路由",
        "phase-16.md",
        "Components T",
        "阶段 17",
        "UPLazyLoad",
        "UPCanvas",
        "UPSignature",
        "UPColorPicker",
        "UPGoodsSku",
        "127 个组件",
        "127 条组件示例路由",
        "phase-17.md",
        "Components U",
        "阶段 18",
        "UPQrcode",
        "UPBarcode",
        "UPRowNotice",
        "UPColumnNotice",
        "UPNumberKeyboard",
        "132 个组件",
        "132 条组件示例路由",
        "phase-18.md",
        "Components V",
        "阶段 19",
        "UPParse",
        "UPMarkdown",
        "UPPickerColumn",
        "UPCityLocate",
        "UPPdfReader",
        "137 个组件",
        "137 条组件示例路由",
        "phase-19.md",
        "Components W",
        "阶段 20",
        "UPCropper",
        "UPPoster",
        "UPShortVideo",
        "UPNovelReader",
        "141 个组件",
        "144 条组件示例路由",
        "phase-20.md",
        "Components X",
        "Components Y",
        "阶段 21",
        "UPTriggerInput",
        "phase-21.md",
        "阶段 22",
        "phase-22.md",
        "阶段 23",
        "phase-23.md",
        "阶段 24",
        "phase-24.md",
        "阶段 25",
        "phase-25.md",
        "阶段 26",
        "phase-26.md",
        "阶段 27",
        "phase-27.md",
        "阶段 28",
        "phase-28.md",
        "Components J",
        "phase-6.md",
        "阶段 2C",
        "UPForm",
        "UPFormItem",
        "UPCheckboxGroup",
        "UPRadioGroup",
        "phase-2c.md",
        "phase-2b.md",
        "阶段 3A",
        "UPText",
        "UPImage",
        "UPEmpty",
        "UPLoadingPage",
        "UPSearch",
        "UPCodeInput",
        "phase-3a.md",
        "阶段 4A",
        "UPCircleProgress",
        "UPActionSheet",
        "UPCollapse",
        "UPDropdown",
        "phase-4a.md",
        "ohpm install",
        "assembleApp",
    ):
        assert phrase in readme, f"README missing {phrase}"
    for phrase in (
        "API 24",
        "已实现",
        "兼容诊断",
        "no-op",
        "设备验证",
        "skipped",
    ):
        assert phrase in compatibility, f"compatibility note missing {phrase}"

    for phrase in (
        "阶段 2A",
        "UPLine",
        "UPGap",
        "UPLink",
        "UPTitle",
        "UPBadge",
        "UPDivider",
        "UPSkeleton",
        "UPLineProgress",
        "UPLoadmore",
        "设备验证",
        "skipped",
    ):
        assert phrase in phase2a, f"phase-2a note missing {phrase}"

    for phrase in (
        "阶段 2B",
        "API 24",
        "5.0.0(12)",
        "UPAvatar",
        "UPAvatarGroup",
        "UPInput",
        "UPTextarea",
        "UPSwitch",
        "UPRate",
        "UPNumberBox",
        "modelValue",
        "maxlength",
        "远程地址",
        "确定性",
        "no-op",
        "设备验证",
        "skipped",
    ):
        assert phrase in phase2b, f"phase-2b note missing {phrase}"

    for phrase in (
        "阶段 2C",
        "API 24",
        "5.0.0(12)",
        "UPForm",
        "UPFormItem",
        "UPCheckbox",
        "UPCheckboxGroup",
        "UPRadio",
        "UPRadioGroup",
        "modelValue",
        "options",
        "no-op",
        "设备验证",
        "skipped",
    ):
        assert phrase in phase2c, f"phase-2c note missing {phrase}"

    for phrase in (
        "阶段 3A",
        "API 24",
        "5.0.0(12)",
        "UPText",
        "UPImage",
        "UPEmpty",
        "UPLoadingPage",
        "UPSearch",
        "UPCodeInput",
        "modelValue",
        "clearabled",
        "本地资源",
        "无网络",
        "no-op",
        "设备验证",
        "skipped",
    ):
        assert phrase in phase3a, f"phase-3a note missing {phrase}"

    for phrase in (
        "阶段 3B", "API 24", "5.0.0(12)", "UPRow", "UPCol", "UPGrid",
        "UPGridItem", "UPCard", "本地资源", "无网络", "设备验证", "skipped",
    ):
        assert phrase in phase3b, f"phase-3b note missing {phrase}"

    for phrase in (
        "阶段 4A", "API 24", "5.0.0(12)", "UPCircleProgress", "UPAlert",
        "UPNotify", "UPNoticeBar", "UPActionSheet", "UPBackTop", "UPCollapse",
        "UPCollapseItem", "UPDropdown", "UPDropdownItem", "页面受控状态",
        "无网络", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase4a, f"phase-4a note missing {phrase}"

    for phrase in (
        "阶段 5", "API 24", "5.0.0(12)", "UPStatusBar", "UPSafeBottom",
        "UPNavbar", "UPNavbarMini", "UPTabs", "UPTabsItem", "UPSubsection",
        "UPSteps", "UPStepsItem", "页面受控状态", "无网络", "no-op",
        "设备验证", "skipped",
    ):
        assert phrase in phase5, f"phase-5 note missing {phrase}"

    for phrase in (
        "阶段 6", "API 24", "5.0.0(12)", "UPList", "UPListItem",
        "UPIndexList", "UPIndexItem", "UPIndexAnchor", "UPScrollList",
        "无网络", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase6, f"phase-6 note missing {phrase}"

    for phrase in (
        "阶段 7", "API 24", "UPSlider", "UPPicker", "UPPickerController",
        "UPSelect", "UPPickerColumn", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase7, f"phase-7 note missing {phrase}"

    phase10 = phase9_path.parent.joinpath("phase-10.md").read_text(encoding="utf-8")
    for phrase in ("阶段 10", "API 24", "5.0.0(12)", "UPTreeSelect", "UPCascader", "UPDatePicker",
                   "UPTimePicker", "UPUpload", "UPProgressButton", "no-op", "设备验证", "skipped"):
        assert phrase in phase10, f"phase-10 note missing {phrase}"

    for phrase in (
        "阶段 9", "API 24", "5.0.0(12)", "UPCountDown", "UPCountTo", "UPTimeline",
        "UPCalendar", "UPKeyboard", "UPFloatingBubble", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase9, f"phase-9 note missing {phrase}"

    for phrase in (
        "阶段 11", "API 24", "5.0.0(12)", "UPView", "UPBox", "UPSection", "UPToolbar",
        "UPSwiper", "UPSwiperIndicator", "UPTabbar", "UPTabbarItem", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase11, f"phase-11 note missing {phrase}"

    for phrase in (
        "阶段 12", "API 24", "5.0.0(12)", "UPAgreement", "UPCopy", "UPNoNetwork", "UPCode",
        "宿主", "剪贴板", "网络监听", "UPCodeStorage", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase12, f"phase-12 note missing {phrase}"

    for phrase in (
        "阶段 13", "API 24", "5.0.0(12)", "UPTable", "UPTable2", "UPTr", "UPTh", "UPTd",
        "spanMethod", "treeProps", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase13, f"phase-13 note missing {phrase}"

    for phrase in (
        "阶段 14", "API 24", "5.0.0(12)", "UPVirtualList", "UPPullRefresh",
        "UPRefreshVirtualList", "UPRefreshVirtualListController", "UPWaterfall",
        "UPDragSort", "keyField", "idKey", "vibrate", "enableBackToTop", "no-op",
        "设备验证", "skipped",
    ):
        assert phrase in phase14, f"phase-14 note missing {phrase}"

    for phrase in (
        "阶段 15", "API 24", "5.0.0(12)", "UPCarKeyboard", "UPMessageInput",
        "UPCateTab", "UPCoupon", "UPTabsPro", "tabKeyName", "dotFill",
        "contentMode", "circle", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase15, f"phase-15 note missing {phrase}"

    for phrase in (
        "阶段 16", "API 24", "5.0.0(12)", "UPTransition", "UPAlbum",
        "UPCalendarStrip", "UPChoose", "UPGuide", "previewFullImage",
        "monthFormat", "stackLevel", "UPGuideStorage", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase16, f"phase-16 note missing {phrase}"

    for phrase in (
        "阶段 17", "API 24", "5.0.0(12)", "UPLazyLoad", "UPCanvas",
        "UPSignature", "UPColorPicker", "UPGoodsSku", "threshold", "canvasId",
        "disableScroll", "UP_GOODS_SKU_RESERVED_KEYS", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase17, f"phase-17 note missing {phrase}"

    for phrase in (
        "阶段 18", "API 24", "5.0.0(12)", "UPQrcode", "UPBarcode", "UPRowNotice",
        "UPColumnNotice", "UPNumberKeyboard", "toTempFilePath", "previewImage",
        "hover-class", "Marquee", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase18, f"phase-18 note missing {phrase}"

    for phrase in (
        "阶段 19", "API 24", "5.0.0(12)", "UPParse", "UPParseController", "UPMarkdown",
        "UPPickerColumn", "UPCityLocate", "UPPdfReader", "mp-html", "marked",
        "encodeURIComponent", "applyTheme", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase19, f"phase-19 note missing {phrase}"

    for phrase in (
        "阶段 20", "API 24", "5.0.0(12)", "UPCropper", "UPPoster", "UPPosterController",
        "UPShortVideo", "UPNovelReader", "UPNovelReaderController", "chooseImage",
        "toTempFilePath", "getImageInfo", "createVideoContext", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase20, f"phase-20 note missing {phrase}"

    for phrase in (
        "阶段 21", "API 24", "5.0.0(12)", "UPTriggerInput", "UPTreeSelect", "UPCalendar",
        "inputProps", "checkStrictly", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase21, f"phase-21 note missing {phrase}"

    for phrase in (
        "阶段 22", "API 24", "5.0.0(12)", "UPModal", "UPKeyboard", "UPTable2", "UPButton",
        "UPUpload", "open-type", "row-dblclick", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase22, f"phase-22 note missing {phrase}"

    for phrase in (
        "阶段 23", "API 24", "5.0.0(12)", "UPSlotRegion", "@BuilderParam", "UPCell",
        "UPNovelReader", "UPTable2", "UPWaterfall", "righticon", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase23, f"phase-23 note missing {phrase}"

    for phrase in (
        "阶段 24", "API 24", "5.0.0(12)", "UPValidate", "UPMath", "UPFormat", "UPGradient",
        "UPZIndex", "priceFormat", "timeFrom", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase24, f"phase-24 note missing {phrase}"

    for phrase in (
        "阶段 25", "API 24", "5.0.0(12)", "UPValidator", "UPFormController", "UPFormContext",
        "async-validator", "errorType", "triggers", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase25, f"phase-25 note missing {phrase}"

    for phrase in (
        "阶段 26", "API 24", "5.0.0(12)", "UPI18n", "UPLocaleCatalog", "registerLocale",
        "zh-Hans", "upWeekText", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase26, f"phase-26 note missing {phrase}"

    for phrase in (
        "阶段 27", "API 24", "5.0.0(12)", "UPThemeManager", "UPThemeTokens", "setPreference",
        "UPColor.token", "no-op", "设备验证", "skipped",
    ):
        assert phrase in phase27, f"phase-27 note missing {phrase}"

    for phrase in (
        "阶段 28", "API 24", "5.0.0(12)", "Templates", "tpl-login", "tpl-order",
        "tpl-address", "navigateTo", "设备验证", "skipped",
    ):
        assert phrase in phase28, f"phase-28 note missing {phrase}"

    profile = load_json5(ROOT / "build-profile.json5")
    product = profile["app"]["products"][0]
    assert product.get("targetSdkVersion") == product["compatibleSdkVersion"]

    print("documentation contract: PASS")


if __name__ == "__main__":
    main()
