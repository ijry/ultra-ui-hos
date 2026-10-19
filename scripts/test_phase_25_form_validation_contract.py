#!/usr/bin/env python3
"""Static contracts for the Phase 25 form-validation pass."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "ultra-ui/src/main/ets/core"
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
CONTROLLERS = ROOT / "ultra-ui/src/main/ets/controllers"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
DEMO = ROOT / "sample/entry/src/main/ets/demos/FormDemo.ets"
INDEX = ROOT / "ultra-ui/Index.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-25.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

# upstream rule fields the ArkTS rule interface must expose
RULE_FIELDS = ("type", "required", "message", "min", "max", "len", "pattern",
               "enumValues", "whitespace", "triggers", "validator", "transform")

# upstream `types` probes that must be implemented
RULE_TYPES = ("string", "boolean", "integer", "float", "array", "number",
              "email", "url", "hex", "date", "regexp")

# upstream message templates kept verbatim
MESSAGES = (
    "%s is required",
    "%s must be one of %s",
    "%s cannot be empty",
    "%s is not a %s",
    "%s is not an %s",
    "%s is not a valid %s",
    "%s value %s does not match pattern %s",
    "%s must be exactly %s characters",
    "%s must be at least %s characters",
    "%s cannot be longer than %s characters",
    "%s must be between %s and %s characters",
    "%s must equal %s",
    "%s cannot be less than %s",
    "%s cannot be greater than %s",
    "%s must be between %s and %s",
    "%s must be exactly %s in length",
    "%s cannot be less than %s in length",
    "%s cannot be greater than %s in length",
    "%s must be between %s and %s in length",
)

# upstream u-form instance methods that must live on the controller
CONTROLLER_METHODS = ("setRules", "setValue", "setValues", "validate", "validateField",
                      "clearValidate", "resetFields", "resetValues", "currentErrors", "errorOf")


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    validator = read(CORE / "UPValidator.ets")
    controller = read(CONTROLLERS / "UPFormController.ets")
    context = read(INTERNAL / "UPFormContexts.ets")
    form = read(COMPONENTS / "UPForm.ets")
    item = read(COMPONENTS / "UPFormItem.ets")

    for source, name in ((validator, "UPValidator.ets"), (controller, "UPFormController.ets"),
                         (context, "UPFormContexts.ets"), (form, "UPForm.ets"), (item, "UPFormItem.ets")):
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"
        for banned in ("Record<", ": any", ": unknown", "async ", "await ", "Promise<"):
            assert banned not in source, f"{name} must not use {banned.strip()}"

    for symbol in ("UPValidator", "UPValidateRule", "UPValidateValue", "UPValidateFieldValue",
                   "UPValidateError", "UPValidateResult", "UPValidateMessages", "UPFieldRules",
                   "UP_DEFAULT_VALIDATE_MESSAGES", "upFieldRule", "upValueEmpty"):
        assert re.search(rf"export (?:function|class|interface|type|const) {symbol}\b", validator), (
            f"UPValidator.ets must export {symbol}"
        )

    rules_block = re.search(r"export interface UPValidateRule \{(.*?)\n\}", validator, re.S)
    assert rules_block is not None, "UPValidateRule interface missing"
    for field in RULE_FIELDS:
        assert re.search(rf"\b{field}\?\s*:", rules_block.group(1)), (
            f"UPValidateRule is missing the upstream field {field}"
        )

    for rule_type in RULE_TYPES:
        assert f"case '{rule_type}'" in validator, f"UPValidator must probe the {rule_type} type"

    for template in MESSAGES:
        assert template in validator, f"UPValidator must keep the upstream message {template!r}"

    # the upstream regex patterns are mirrored, not re-derived
    assert "UP_EMAIL_PATTERN" in validator and "UP_URL_PATTERN" in validator and "UP_HEX_PATTERN" in validator, (
        "UPValidator must mirror the upstream email/url/hex patterns"
    )
    assert "UP_SURROGATE_PATTERN" in validator and "isNativeStringType" in validator, (
        "UPValidator must keep the surrogate-pair fix and the native-string-type probe"
    )
    assert "static format(" in validator and "%[sdj%]" in validator, (
        "UPValidator must implement the upstream positional formatter"
    )
    assert "matchesTrigger" in validator, "UPValidator must honour rule triggers"

    for method in CONTROLLER_METHODS:
        assert re.search(rf"\b{method}\(", controller), f"UPFormController is missing {method}()"
    assert "mount(" in controller and "unmount(" in controller, (
        "UPFormController must follow the mount/unmount lifecycle"
    )
    assert "captureSnapshot" in controller and "snapshotTaken" in controller, (
        "UPFormController must snapshot the first values for resetFields()"
    )

    # errorType is honoured by the shared context rather than a global toast
    assert "UPFormErrorType" in context and "'border-bottom'" in context, (
        "UPFormContext must model the upstream errorType values"
    )
    assert "@Provide('UPFormContext')" in form, "UPForm must provide the shared form context"
    assert "@Consume('UPFormContext')" in item, "UPFormItem must consume the shared form context"
    assert "onErrorToast" in form and "upFormErrorType" in form, (
        "UPForm must expose the toast bridge and the errorType narrowing helper"
    )
    assert "showsErrorBorder" in item and "showsMessage" in item, (
        "UPFormItem must branch on the upstream errorType"
    )
    assert "labelOnTop" in item and "labelTextAlign" in item, (
        "UPFormItem must honour the inherited label layout"
    )
    assert "this.formContext.errorOf(this.props.prop)" in item, (
        "UPFormItem must prefer the form-level error for its prop"
    )

    index = read(INDEX)
    for symbol in ("UPValidator", "UPValidateRule", "UPFieldRules", "UPFormController",
                   "UPFormContext", "UPFormErrorType", "UPFormErrorToastEvent", "upFormErrorType",
                   "UP_DEFAULT_VALIDATE_MESSAGES"):
        assert symbol in index, f"public entry missing {symbol}"

    demo = read(DEMO)
    assert "@lingyun/ultra-ui-hos" in demo, "FormDemo must import from the public HAR entry"
    assert not re.search(r"=>\s*this\.", demo), "FormDemo must use explicit void block bodies"
    for token in ("UPFormController", "rules()", "validateField", "resetFields", "clearValidate",
                  "triggers: ['blur'", "type: 'email'", "type: 'enum'", "enumValues", "onErrorToast"):
        assert token in demo, f"FormDemo does not demonstrate {token}"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 25", "phase-25.md"):
        assert phrase in readme or phrase in note, f"Phase 25 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPValidator", "UPFormController", "async-validator",
        "errorType", "triggers", "resetFields", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-25 note missing {phrase}"

    print(f"phase 25 form validation contract: PASS ({len(RULE_FIELDS)} rule fields, "
          f"{len(RULE_TYPES)} types, {len(MESSAGES)} messages)")


if __name__ == "__main__":
    main()
