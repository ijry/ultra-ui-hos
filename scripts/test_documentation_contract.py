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
    assert readme_path.is_file(), "README.md is required"
    assert phase1_path.is_file(), "phase-1 compatibility note is required"
    assert phase2a_path.is_file(), "phase-2a compatibility note is required"
    assert phase2b_path.is_file(), "phase-2b compatibility note is required"
    assert phase2c_path.is_file(), "phase-2c compatibility note is required"
    assert phase3a_path.is_file(), "phase-3a compatibility note is required"
    assert phase3b_path.is_file(), "phase-3b compatibility note is required"
    assert phase4a_path.is_file(), "phase-4a compatibility note is required"

    readme = readme_path.read_text(encoding="utf-8")
    compatibility = phase1_path.read_text(encoding="utf-8")
    phase2a = phase2a_path.read_text(encoding="utf-8")
    phase2b = phase2b_path.read_text(encoding="utf-8")
    phase2c = phase2c_path.read_text(encoding="utf-8")
    phase3a = phase3a_path.read_text(encoding="utf-8")
    phase3b = phase3b_path.read_text(encoding="utf-8")
    phase4a = phase4a_path.read_text(encoding="utf-8")
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
        "54 个已实现组件/控制器",
        "52 条组件示例路由",
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

    profile = load_json5(ROOT / "build-profile.json5")
    product = profile["app"]["products"][0]
    assert product.get("targetSdkVersion") == product["compatibleSdkVersion"]

    print("documentation contract: PASS")


if __name__ == "__main__":
    main()
