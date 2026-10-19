#!/usr/bin/env python3
"""Static contracts for the Phase 22 event-level parity pass."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
INDEX = ROOT / "ultra-ui/Index.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-22.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

# component -> callbacks added by this phase
NEW_CALLBACKS = {
    "UPModal": ("onConfirm", "onCancel", "onCancelOnAsync"),
    "UPCollapse": ("onOpen", "onClose"),
    "UPPopover": ("onClick", "onOpen", "onClose"),
    "UPTooltip": ("onClick", "onOpen", "onClose"),
    "UPPopup": ("onClosed", "onClick"),
    "UPOverlay": ("onClick",),
    "UPGrid": ("onClick",),
    "UPGridItem": ("onGridItemBroadcast",),
    "UPImage": ("onLoad", "onError"),
    "UPKeyboard": ("onChange", "onBackspace", "onCancel", "onClose", "onClosed"),
    "UPLoadmore": ("onLoadmore",),
    "UPCountTo": ("onEnd",),
    "UPCountDown": ("onChange",),
    "UPAvatarGroup": ("onShowMore",),
    "UPCropper": ("onAvtinit",),
    "UPPagination": ("onCurrentChange", "onSizeChange"),
    "UPTable2": ("onRowDblclick", "onSelect", "onSelectAll", "onFilterChange"),
    "UPCalendar": ("onConfirm", "onClose", "onClosed"),
    "UPReadMore": ("onOpen", "onClose"),
    "UPSwipeAction": ("onOpendItemUpdate",),
    "UPSwipeActionItem": ("onClick", "onScrolling"),
    "UPSwiper": ("onCurrentChange",),
    "UPTabbarItem": ("onChange",),
    "UPQrcode": ("onLongpressCallback",),
    "UPCascader": ("onShowChange",),
    "UPAlert": ("onModelValueChange",),
    "UPWaterfall": ("onInput",),
    "UPList": ("onRefresherPulling", "onRefresherRestore", "onRefresherAbort"),
    "UPParse": ("onClick", "onTap"),
    "UPNumberBox": ("onFocus", "onOverlimit"),
    "UPInput": ("onKeyboardHeightChange", "onNicknameReview"),
    "UPTextarea": ("onKeyboardHeightChange", "onLineChange"),
    "UPButton": ("onGetPhoneNumber", "onGetUserInfo", "onOpenSetting", "onLaunchApp",
                 "onAgreePrivacyAuthorization", "onError"),
    "UPUpload": ("onBeforeRead", "onAfterRead", "onOversize", "onError", "onClickPreview",
                 "onAfterAutoUpload"),
    "UPDatePicker": ("onChange", "onInput", "onModelValueChange", "onClose", "onClosed"),
    "UPTimePicker": ("onChange", "onInput", "onModelValueChange", "onClose", "onClosed"),
}

# component -> dispatch helpers or render paths the new callbacks must actually reach
BEHAVIOUR = {
    "UPModal": ("onCancelOnAsync?.()", "handled"),
    "UPCollapse": ("dispatchChange",),
    "UPPopover": ("this.props.onOpen?.()", "this.props.onClose?.()"),
    "UPTooltip": ("toggle(", "this.props.onOpen?.()"),
    "UPPopup": ("onClosed?.({ reason })",),
    "UPOverlay": ("onClick?.({ source: 'overlay' })",),
    "UPGrid": ("beginComposition((name",),
    "UPGridItem": ("onItemClick?.(name, index)", "onGridItemBroadcast?.(index)"),
    "UPImage": ("onComplete(", "图片解码失败"),
    "UPKeyboard": ("backspace()", "dismiss()", "cancel()"),
    "UPLoadmore": ("requestMore",),
    "UPCountTo": ("onEnd?.({ value: to })",),
    "UPCountDown": ("emitChange",),
    "UPAvatarGroup": ("hiddenCount:",),
    "UPCropper": ("onAvtinit?.(ready)",),
    "UPPagination": ("changeSize", "onCurrentChange?.(bounded)"),
    "UPTable2": ("detectDoubleClick", "toggleSelectAll", "notifyFilterChange",
                 "UP_TABLE2_DOUBLE_CLICK_INTERVAL"),
    "UPCalendar": ("confirm()", "dismiss()"),
    "UPReadMore": ("this.props.onOpen?.(this.props.name)",),
    "UPSwipeAction": ("onOpendItemUpdate?.(true)", "onOpendItemUpdate?.(false)"),
    "UPSwipeActionItem": ("setScrolling", "onActionStart"),
    "UPSwiper": ("onCurrentChange?.(index)",),
    "UPTabbarItem": ("onChange?.(event)",),
    "UPQrcode": ("onLongpressCallback",),
    "UPCascader": ("dismiss()", "confirm()"),
    "UPAlert": ("onModelValueChange?.(false)",),
    "UPWaterfall": ("onInput?.(next)",),
    "UPList": ("trackRefresher", "UPListRefresherEvent"),
    "UPParse": ("handleRootClick",),
    "UPNumberBox": ("onOverlimit?.(type)", "onFocus?.({"),
    "UPInput": ("nickname", "onKeyboardHeightChange?.({ height: 0"),
    "UPTextarea": ("trackLineChange", "lastLineCount"),
    "UPButton": ("dispatchOpenType", "UP_BUTTON_OPEN_TYPES"),
    "UPUpload": ("onBeforeRead", "previewFile", "before-read", "max-count"),
    "UPDatePicker": ("publishSelect", "publishConfirm", "dismiss()"),
    "UPTimePicker": ("publishSelect", "publishConfirm", "dismiss()"),
}

EXPORTS = (
    "UPImageLoadEvent", "UPImageErrorEvent", "UPGridClickEvent", "UPTable2FilterEvent",
    "UP_TABLE2_DOUBLE_CLICK_INTERVAL", "UPCalendarForbidEvent", "UPCountDownChangeEvent",
    "UPAvatarGroupShowMoreEvent", "UPListRefresherEvent", "UPInputKeyboardEvent",
    "UPTextareaKeyboardEvent", "UPTextareaLineEvent", "UPButtonOpenTypeEvent",
    "UP_BUTTON_OPEN_TYPES", "UPUploadReadEvent", "UPUploadErrorEvent",
    "UPUploadFailureReason", "UPFloatingBubbleItemClickEvent",
)


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    index = read(INDEX)
    sources: dict[str, str] = {}
    for name, callbacks in NEW_CALLBACKS.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        options = re.search(rf"export interface {name}Options \{{(.*?)\n\}}", source, re.S)
        props = re.search(rf"export class {name}Props \{{(.*?)\n\}}", source, re.S)
        assert options is not None and props is not None, f"{name} is missing its Options/Props pair"
        for callback in callbacks:
            assert re.search(rf"\b{callback}\?\s*:", options.group(1)), (
                f"{name}Options is missing {callback}"
            )
            assert re.search(rf"\b{callback}\?\s*:", props.group(1)), (
                f"{name}Props is missing {callback}"
            )
            assert f"options.{callback}" in source, f"{name} never assigns {callback} from options"
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for name, tokens in BEHAVIOUR.items():
        for token in tokens:
            assert token in sources[name], f"{name} does not wire {token}"

    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

    # the grid-level click travels through the shared layout context
    contexts = read(INTERNAL / "UPLayoutContexts.ets")
    assert "onItemClick" in contexts, "UPGridLayoutContext must forward the grid-level click"

    table2 = sources["UPTable2"]
    assert re.search(r"UP_TABLE2_DOUBLE_CLICK_INTERVAL:\s*number\s*=\s*300\s*;", table2), (
        "UPTable2 keeps a 300ms double-tap window"
    )

    button = sources["UPButton"]
    for open_type in ("'getPhoneNumber'", "'getUserInfo'", "'openSetting'", "'launchApp'",
                      "'agreePrivacyAuthorization'"):
        assert open_type in button, f"UPButton open type {open_type} missing"

    upload = sources["UPUpload"]
    for reason in ("'extension'", "'oversize'", "'before-read'", "'max-count'"):
        assert reason in upload, f"UPUpload failure reason {reason} missing"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 22", "phase-22.md"):
        assert phrase in readme or phrase in note, f"Phase 22 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPModal", "UPKeyboard", "UPTable2", "UPButton", "UPUpload",
        "UPList", "open-type", "row-dblclick", "refresherpulling", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-22 note missing {phrase}"

    print("phase 22 event parity contract: PASS")


if __name__ == "__main__":
    main()
