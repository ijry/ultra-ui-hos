#!/usr/bin/env python3
"""Static contracts for the Phase 21 field-level parity pass."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
INDEX = ROOT / "ultra-ui/Index.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-21.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

# component -> newly added upstream fields that must now exist
NEW_FIELDS = {
    "UPPicker": ("hasInput", "inputBorder", "inputProps", "placeholder", "disabled", "disabledColor"),
    "UPDatePicker": ("hasInput", "inputBorder", "inputProps", "placeholder", "disabled", "disabledColor", "format"),
    "UPTimePicker": ("hasInput", "inputBorder", "inputProps", "placeholder", "disabled", "disabledColor", "format"),
    "UPTreeSelect": ("data", "props", "nodeKey", "showCheckbox", "defaultExpandAll", "defaultExpandedKeys",
                     "defaultCheckedKeys", "expandOnClickNode", "checkOnClickNode", "checkStrictly",
                     "accordion", "highlightCurrent", "currentNodeKey", "indent", "iconSize",
                     "checkboxSize", "expandIcon", "collapseIcon"),
    "UPCalendar": ("forbidDays", "forbidDaysToast", "monthFormat"),
    "UPCalendarStrip": ("fullCalendarProps",),
    "UPCropper": ("lockWidth", "lockHeight"),
    "UPUpload": ("extension", "videoPreviewObjectFit"),
    "UPView": ("backgroundColor", "flex1"),
    "UPGuide": ("zIndex",),
    "UPFormItem": ("leftIconStyle",),
    "UPFloatingBubble": ("list", "borderColor"),
    "UPSelect": ("overlayStyle",),
    "UPTable2": ("sortBy", "sortMethod", "context"),
    "UPNovelReader": ("autoBack",),
}

# component -> helpers or render paths the new fields must actually reach
BEHAVIOUR = {
    "UPPicker": ("triggerRow", "triggerStyle", "triggerLabel", "openByTrigger", "upTriggerInputStyle"),
    "UPDatePicker": ("triggerRow", "triggerLabel", "upTriggerFormat", "YYYY-MM-DD"),
    "UPTimePicker": ("triggerRow", "triggerLabel", "upTriggerFormat", "HH:mm:ss"),
    "UPTreeSelect": ("keyMap", "visibleNodes", "syncCheckedState", "toggleExpand", "setChecked",
                     "emitCheck", "handleNodeClick", "accordion", "checkboxMark", "halfCheckedKeys",
                     "upTreeIndent", "upTreeLabel", "upTreeKey"),
    "UPCalendar": ("upCalendarForbidden", "upCalendarMonthTitle", "isForbidden", "onForbid"),
    "UPCalendarStrip": ("fullTitle", "fullActiveColor", "fullMonthFormat", "fullForbidDays", "fullForbidToast"),
    "UPCropper": ("constraint.lockWidth", "constraint.lockHeight"),
    "UPUpload": ("upUploadExtensionAllowed", "UP_UPLOAD_OBJECT_FIT_MODES", "accept"),
    "UPView": ("viewFlexGrow", "flexGrow"),
    "UPGuide": ("stackZIndex",),
    "UPFormItem": ("leftIconStyle",),
    "UPFloatingBubble": ("handleItemClick", "listVisible", "mainBubble", "itemBackground"),
    "UPSelect": ("overlayStyle",),
    "UPTable2": ("upTable2SortValue", "upTable2ColumnSortBy", "sortKeys"),
    "UPNovelReader": ("autoBack",),
}

TRIGGER_TOKENS = (
    "UP_TRIGGER_BORDER_MODES", "UP_TRIGGER_DEFAULT_BORDER", "UP_TRIGGER_PLACEHOLDER",
    "UP_TRIGGER_DISABLED_COLOR", "UP_TRIGGER_HEIGHT", "UP_TRIGGER_PADDING",
    "UP_TRIGGER_BORDER_COLOR", "UP_TRIGGER_PLACEHOLDER_COLOR", "UPTriggerInputProps",
    "UPTriggerInputStyle", "upTriggerBorderSupported", "upTriggerInputStyle",
    "upTriggerBorderWidth", "upTriggerBottomOnly", "upTriggerRadius", "upTriggerTextAlign",
    "upTriggerFormat",
)

EXPORTS = (
    "UPTriggerInputProps", "UPTriggerInputStyle", "UP_TRIGGER_BORDER_MODES",
    "UP_TRIGGER_DEFAULT_BORDER", "UP_TRIGGER_PLACEHOLDER", "upTriggerInputStyle",
    "upTriggerFormat", "UPTreeSelectKeys", "UPTreeSelectCheckEvent", "UPTreeSelectCheckState",
    "UPTreeSelectCheckChangeEvent", "UPTreeSelectCurrentChangeEvent", "UP_TREE_EXPAND_ICON",
    "UP_TREE_COLLAPSE_ICON", "UP_TREE_INDENT", "upTreeLabel", "upTreeKey", "upTreeIndent",
    "UPCalendarForbidEvent", "UP_CALENDAR_FORBID_TOAST", "upCalendarMonthTitle",
    "upCalendarForbidden", "UPCalendarStripFullProps", "UP_UPLOAD_OBJECT_FIT_MODES",
    "upUploadExtensionAllowed", "upTable2SortValue", "upTable2ColumnSortBy",
    "UPFloatingBubbleItem", "UPFloatingBubbleItemClickEvent",
)

DEFAULTS = {
    "UPTreeSelect": {
        "showCheckbox": "false", "defaultExpandAll": "false", "expandOnClickNode": "true",
        "checkOnClickNode": "false", "checkStrictly": "false", "accordion": "false",
        "highlightCurrent": "false", "indent": "UP_TREE_INDENT", "iconSize": "UP_TREE_ICON_SIZE",
        "checkboxSize": "UP_TREE_CHECKBOX_SIZE", "expandIcon": "UP_TREE_EXPAND_ICON",
        "collapseIcon": "UP_TREE_COLLAPSE_ICON",
    },
    "UPCalendar": {"forbidDaysToast": "UP_CALENDAR_FORBID_TOAST", "monthFormat": "''"},
    "UPUpload": {"videoPreviewObjectFit": "'contain'"},
    "UPCropper": {"lockWidth": "''", "lockHeight": "''"},
    "UPNovelReader": {"autoBack": "false"},
}

INTERNAL_CONSTANTS = {
    "UPTriggerInput": {"UP_TRIGGER_HEIGHT": "38", "UP_TRIGGER_PADDING": "9"},
}

TREE_CONSTANTS = {"UP_TREE_INDENT": "32", "UP_TREE_ICON_SIZE": "14", "UP_TREE_CHECKBOX_SIZE": "16"}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    trigger = read(INTERNAL / "UPTriggerInput.ets")
    for token in TRIGGER_TOKENS:
        assert token in trigger, f"UPTriggerInput missing {token}"
    for token in FORBIDDEN:
        assert token not in trigger, f"UPTriggerInput contains forbidden boundary {token}"
    assert "'surround', 'bottom', 'none'" in trigger, "UPTriggerInput keeps the upstream border modes"
    assert "up.common.pleaseChoose" in trigger, "UPTriggerInput reads the upstream placeholder key"

    sources: dict[str, str] = {}
    for name, fields in NEW_FIELDS.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        for field in fields:
            assert re.search(rf"^\s*{field}\??\s*[:=]", source, re.M) or f" {field}" in source, (
                f"{name} is missing the upstream field {field}"
            )
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for name, tokens in BEHAVIOUR.items():
        for token in tokens:
            assert token in sources[name], f"{name} does not wire {token}"

    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    for module, constants in INTERNAL_CONSTANTS.items():
        text = read(INTERNAL / f"{module}.ets")
        for constant, value in constants.items():
            assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", text), (
                f"{module} constant {constant}={value} missing"
            )

    tree = sources["UPTreeSelect"]
    for constant, value in TREE_CONSTANTS.items():
        assert re.search(rf"{constant}:\s*number\s*=\s*{value}\s*;", tree), (
            f"UPTreeSelect constant {constant}={value} missing"
        )
    assert "'play-right-fill'" in tree and "'arrow-down-fill'" in tree, (
        "UPTreeSelect keeps the upstream switcher icons"
    )
    assert "'#ecf5ff'" in tree, "UPTreeSelect keeps the upstream current-row highlight"
    assert "0.55" in tree, "UPTreeSelect keeps the upstream disabled opacity"

    calendar = sources["UPCalendar"]
    assert "up.calendar.disabled" in calendar, "UPCalendar reads the upstream forbidden-day key"

    view = sources["UPView"]
    assert "backgroundColor is upstream" in view or "backgroundColor` 是上游名" in view, (
        "UPView documents which background field is upstream"
    )

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 21", "hasInput", "u-tree", "phase-21.md"):
        assert phrase in readme or phrase in note, f"Phase 21 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPTriggerInput", "UPTreeSelect", "UPCalendar", "UPCropper",
        "UPUpload", "UPView", "UPGuide", "UPFormItem", "UPFloatingBubble", "UPSelect",
        "UPTable2", "UPNovelReader", "inputProps", "checkStrictly", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-21 note missing {phrase}"

    print("phase 21 prop parity contract: PASS")


if __name__ == "__main__":
    main()
