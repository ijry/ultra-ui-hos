#!/usr/bin/env python3
"""Static contracts for the baseline sample catalog and navigation."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLE = ROOT / "sample/entry/src/main/ets"
DEMO = SAMPLE / "demos"

ROUTES = (
    "button", "cell", "icon", "loading-icon", "overlay", "popup",
    "tag", "toast", "modal", "circle-progress", "alert", "notify",
    "notice-bar", "action-sheet", "back-top", "collapse", "collapse-item",
    "dropdown", "dropdown-item",
)

DEMO_FILES = {
    "loading-icon": "LoadingIconDemo.ets",
    "circle-progress": "CircleProgressDemo.ets",
    "notice-bar": "NoticeBarDemo.ets",
    "action-sheet": "ActionSheetDemo.ets",
    "back-top": "BackTopDemo.ets",
    "collapse-item": "CollapseItemDemo.ets",
    "dropdown-item": "DropdownItemDemo.ets",
}


def text(path: Path) -> str:
    assert path.is_file(), f"missing sample file: {path}"
    return path.read_text(encoding="utf-8")



def assert_arkts_safe_sample_callbacks() -> None:
    """Keep the sample source compatible with ArkTS' strict callback rules."""
    scaffold = text(SAMPLE / "shared/SampleScaffold.ets")
    page = text(SAMPLE / "pages/SamplePage.ets")
    index = text(SAMPLE / "pages/Index.ets")

    assert "@Prop onBack" not in scaffold, "function callbacks cannot be decorated with @Prop"
    assert "@Prop onBack" not in page, "function callbacks cannot be decorated with @Prop"
    assert "class SampleScaffoldProps" in scaffold
    assert "@Prop props: SampleScaffoldProps" in scaffold
    assert "class SamplePageProps" in page
    assert "@Prop props: SamplePageProps" in page
    assert "unknown" not in index, "sample ArkTS source must not spell unknown"

    expected_callbacks = {
        "CellDemo.ets": ("UPCellClickEvent", r"onClick:\s*\(event:\s*UPCellClickEvent\)\s*:\s*void\s*=>\s*\{"),
        "IconDemo.ets": ("UPRawValue", r"onClick:\s*\(index:\s*UPRawValue\)\s*:\s*void\s*=>\s*\{"),
        "OverlayDemo.ets": ("UPOverlayClickEvent", r"onShowChange:\s*\(show:\s*boolean\)\s*:\s*void\s*=>\s*\{"),
        "PopupDemo.ets": ("UPPopupCloseEvent", r"onClose:\s*\(event:\s*UPPopupCloseEvent\)\s*:\s*void\s*=>\s*\{"),
        "ModalDemo.ets": ("UPModalAction", r"onAction:\s*\(event:\s*UPModalAction\)\s*:\s*void\s*=>\s*\{"),
        "ToastDemo.ets": ("UPToastCompleteEvent", r"onComplete:\s*\(event:\s*UPToastCompleteEvent\)\s*:\s*void\s*=>\s*\{"),
    }
    for filename, (type_name, callback_pattern) in expected_callbacks.items():
        source = text(DEMO / filename)
        assert type_name in source, f"{filename} must import/use {type_name} from the public HAR entry"
        assert re.search(callback_pattern, source), f"{filename} must use an explicit typed void callback"

    for source in [text(path) for path in DEMO.glob("*.ets")]:
        assert not re.search(r"=>\s*this\.", source), "sample callbacks must use explicit void block bodies"


def main() -> None:
    catalog = text(SAMPLE / "catalog/SampleCatalog.ets")
    index = text(SAMPLE / "pages/Index.ets")
    page = text(SAMPLE / "pages/SamplePage.ets")
    scaffold = text(SAMPLE / "shared/SampleScaffold.ets")

    for group in ("Components A", "Components B", "Components C", "Components F", "Components G", "Components H"):
        assert group in catalog, f"missing sample group: {group}"
    for route in ROUTES:
        assert re.search(rf"['\"]{re.escape(route)}['\"]", catalog), f"missing route: {route}"
        demo = text(DEMO / DEMO_FILES.get(route, route.title().replace("-", "") + "Demo.ets"))
        assert "@lingyun/ultra-ui-hos" in demo, f"demo does not use public HAR entry: {route}"
        assert "../src/main" not in demo and "ultra-ui/src" not in demo

    for symbol in ("Navigation", "NavPathStack", "SampleCatalog", "UPToastHost"):
        assert symbol in index, f"missing {symbol} in index"
    assert index.count("UPToastHost(") == 1, "root page must mount one UPToastHost"
    assert "SampleScaffold" in page and "route" in page
    assert "返回" in scaffold and "示例" in scaffold

    module = text(ROOT / "sample/entry/src/main/module.json5")
    ability = text(ROOT / "sample/entry/src/main/ets/entryability/EntryAbility.ets")
    assert "loadContent('pages/Index'," in ability, "EntryAbility should use the loadContent callback"
    assert "err.code" in ability, "EntryAbility should handle loadContent errors"
    assert "pages/Index" in text(ROOT / "sample/entry/src/main/resources/base/profile/main_pages.json")
    assert "Navigation" in index
    assert "@lingyun/ultra-ui-hos" in index
    assert "../ultra-ui" not in index and "../../ultra-ui/src" not in index
    assert "net.lingyun.ultraui.hos.sample" not in module or "EntryAbility" in module

    assert_arkts_safe_sample_callbacks()

    print("sample contract: PASS")


if __name__ == "__main__":
    main()
