#!/usr/bin/env python3
"""Static contracts for Phase 10 advanced selection and media components."""
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
NOTE = ROOT / "docs/compatibility/phase-10.md"

SOURCES = {
    "UPTreeSelect": ("UPTreeSelectOptions", "UPTreeSelectProps", "UPTreeSelectNode", "onChange"),
    "UPCascader": ("UPCascaderOptions", "UPCascaderProps", "UPCascaderOption", "onConfirm"),
    "UPDatePicker": ("UPDatePickerOptions", "UPDatePickerProps", "UPDatePickerChangeEvent", "selectedDate"),
    "UPTimePicker": ("UPTimePickerOptions", "UPTimePickerProps", "UPTimePickerChangeEvent", "selectedTime"),
    "UPUpload": ("UPUploadOptions", "UPUploadProps", "UPUploadFile", "onChoose"),
    "UPProgressButton": ("UPProgressButtonOptions", "UPProgressButtonProps", "UPProgressButtonState", "progress"),
}

DEMOS_BY_ROUTE = {
    "tree-select": "TreeSelectDemo.ets",
    "cascader": "CascaderDemo.ets",
    "date-picker": "DatePickerDemo.ets",
    "time-picker": "TimePickerDemo.ets",
    "upload": "UploadDemo.ets",
    "progress-button": "ProgressButtonDemo.ets",
}

DEFAULTS = {
    "UPTreeSelect": {"multiple": "false", "max": "0", "expanded": "true"},
    "UPCascader": {"value": "''", "visible": "false", "column": "0"},
    "UPDatePicker": {"year": "-1", "month": "-1", "day": "-1", "visible": "false"},
    "UPTimePicker": {"hour": "0", "minute": "0", "second": "0", "minuteStep": "1", "visible": "false"},
    "UPUpload": {"files": "[]", "maxCount": "9", "disabled": "false"},
    "UPProgressButton": {"text": "'提交'", "progress": "0", "state": "'normal'", "disabled": "false"},
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
        assert name in index, f"{name} not exported from Index.ets"
        for token in ("WebView", "@kit.NetworkKit", "http://", "https://"):
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    assert "ForEach" in sources["UPTreeSelect"] and "disabled" in sources["UPTreeSelect"]
    assert "this.props.modelValue.length > 0 ? this.props.modelValue : this.props.value" in sources["UPTreeSelect"], (
        "UPTreeSelect keeps modelValue ahead of the legacy value prop"
    )
    assert "Math.max" in sources["UPCascader"] and "Math.min" in sources["UPCascader"]
    assert "ForEach" in sources["UPCascader"] and "onCancel" in sources["UPCascader"]
    assert "Date(" in sources["UPDatePicker"] and "onSelect" in sources["UPDatePicker"]
    assert "selectedTime" in sources["UPTimePicker"] and "minuteStep" in sources["UPTimePicker"]
    assert "onDelete" in sources["UPUpload"] and "local" in sources["UPUpload"].lower()
    assert "Math.max" in sources["UPUpload"] and "onRetry" in sources["UPUpload"]
    assert "onClick" in sources["UPProgressButton"] and "onStateChange" in sources["UPProgressButton"]

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components N" in catalog, "missing Phase 10 sample group Components N"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{route}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("92 个已实现组件/控制器", "90 个组件 + 2 个控制器", "90 条组件示例路由",
                   "阶段 10", "UPTreeSelect", "UPCascader", "UPDatePicker", "UPTimePicker",
                   "UPUpload", "UPProgressButton", "phase-10.md", "Components N"):
        assert phrase in readme or phrase in note, f"Phase 10 documentation missing {phrase}"
    for phrase in ("阶段 10", "API 24", "5.0.0(12)", "设备验证", "skipped", "no-op"):
        assert phrase in note, f"phase-10 note missing {phrase}"
    print("phase 10 advanced-selection-media contract: PASS")


if __name__ == "__main__":
    main()
