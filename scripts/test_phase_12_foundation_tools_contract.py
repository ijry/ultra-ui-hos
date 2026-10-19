#!/usr/bin/env python3
"""Static contracts for Phase 12 agreement, copy, network and code tools."""
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
NOTE = ROOT / "docs/compatibility/phase-12.md"

SOURCES = {
    "UPAgreement": (
        "UPAgreementOptions", "UPAgreementProps", "UPAgreementConfirmEvent",
        "UPAgreementLinkEvent", "onProtocolClick", "onPrivacyClick", "UPModal",
    ),
    "UPCopy": (
        "UPCopyOptions", "UPCopyProps", "UPCopyRequest", "UPCopySuccessEvent",
        "UPCopyFailureEvent", "UPCopyFailureReason", "clipboard", "onSuccess", "onFailure",
    ),
    "UPNoNetwork": (
        "UPNoNetworkOptions", "UPNoNetworkProps", "UPNoNetworkStatusEvent",
        "UPNoNetworkRetryEvent", "setConnected", "onConnected", "onDisconnected", "onRetry",
    ),
    "UPCode": (
        "UPCodeOptions", "UPCodeProps", "UPCodeStorage", "UPCodeChangeEvent",
        "UPCodeEndEvent", "start", "reset", "canGetCode", "displayText", "onStart",
        "onChange", "onEnd",
    ),
}

DEMOS_BY_ROUTE = {
    "agreement": "AgreementDemo.ets",
    "copy": "CopyDemo.ets",
    "no-network": "NoNetworkDemo.ets",
    "code": "CodeDemo.ets",
}

DEFAULTS = {
    "UPAgreement": {
        "show": "false", "confirmText": "'阅读并同意'", "cancelText": "'取消'",
        "showCancelButton": "true",
    },
    "UPCopy": {"content": "''", "alertStyle": "'toast'", "notice": "'复制成功'"},
    "UPNoNetwork": {
        "tips": "UPI18n.t('up.noNetwork.text')", "zIndex": "1000", "isConnected": "true",
        "networkType": "'none'", "retryText": "UPI18n.t('up.common.retry')",
    },
    "UPCode": {
        "seconds": "60", "startText": "UPI18n.t('up.code.send')",
        "changeText": "UPI18n.t('up.code.resendAfter')",
        "endText": "UPI18n.t('up.code.resend')", "keepRunning": "false", "uniqueKey": "''",
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
        for token in (
            "WebView", "@kit.NetworkKit", "http://", "https://", "JSON.parse",
            "setClipboardData", "openSystemSettings", "plus.runtime.quit", "navigateTo",
        ):
            assert token not in source, f"{name} contains forbidden boundary {token}"

    for component, fields in DEFAULTS.items():
        for field, value in fields.items():
            assert re.search(rf"\b{field}\b[^=;\n]*=\s*{re.escape(value)}\s*;", sources[component]), (
                f"{component} default {field}={value} missing"
            )

    assert "contentBuilder" in sources["UPAgreement"] and "onShowChange" in sources["UPAgreement"]
    assert "UPModalProps" in sources["UPAgreement"] and "urlProtocol" in sources["UPAgreement"]
    assert "copyText(this.props.content)" in sources["UPCopy"]
    assert "UPCopyFailureReason" in sources["UPCopy"] and "empty-content" in sources["UPCopy"]
    assert "clipboard" in sources["UPCopy"] and "onClick" in sources["UPCopy"]
    assert "isConnected" in sources["UPNoNetwork"] and "networkType" in sources["UPNoNetwork"]
    assert "retryText" in sources["UPNoNetwork"] and "UPButton" in sources["UPNoNetwork"]
    assert "setInterval" in sources["UPCode"] and "clearInterval" in sources["UPCode"]
    assert "keepRunning" in sources["UPCode"] and "uniqueKey" in sources["UPCode"]
    assert "replace" in sources["UPCode"] and "storage" in sources["UPCode"]

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "Components P" in catalog, "missing Phase 12 sample group Components P"
    for route, filename in DEMOS_BY_ROUTE.items():
        demo = read(DEMOS / filename)
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route {route}"
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from public HAR entry"
        assert route in page and filename.replace(".ets", "") in page, f"sample dispatch missing {route}"

    readme = read(README)
    note = read(NOTE)
    for phrase in (
        "阶段 12", "UPAgreement", "UPCopy", "UPNoNetwork", "UPCode", "Components P",
        "102 个组件", "102 条组件示例路由", "phase-12.md",
    ):
        assert phrase in readme or phrase in note, f"Phase 12 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "宿主", "剪贴板", "网络监听", "UPCodeStorage",
        "设备验证", "skipped", "no-op",
    ):
        assert phrase in note, f"phase-12 note missing {phrase}"

    print("phase 12 foundation-tools contract: PASS")


if __name__ == "__main__":
    main()
