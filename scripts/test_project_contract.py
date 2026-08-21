#!/usr/bin/env python3
"""Static contract checks for the HarmonyOS project skeleton."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_json5(path: Path) -> dict:
    # The initial project contract uses JSON-compatible JSON5 files only.
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    required = [
        "oh-package.json5",
        "package.json",
        "build-profile.json5",
        "hvigorfile.ts",
        "AppScope/app.json5",
        "ultra-ui/oh-package.json5",
        "ultra-ui/build-profile.json5",
        "ultra-ui/hvigorfile.ts",
        "ultra-ui/src/main/module.json5",
        "ultra-ui/Index.ets",
        "sample/entry/oh-package.json5",
        "sample/entry/build-profile.json5",
        "sample/entry/hvigorfile.ts",
        "sample/entry/src/main/module.json5",
        "sample/entry/src/main/resources/base/profile/main_pages.json",
        "sample/entry/src/main/ets/entryability/EntryAbility.ets",
    ]
    missing = [item for item in required if not (ROOT / item).is_file()]
    assert not missing, f"missing project files: {missing}"

    root_package = load_json5(ROOT / "oh-package.json5")
    assert root_package["modelVersion"] == "5.0.0"

    root_profile = load_json5(ROOT / "build-profile.json5")
    module_names = {module["name"] for module in root_profile["modules"]}
    assert module_names == {"ultra_ui", "entry"}
    assert any(module["srcPath"] == "./sample/entry" for module in root_profile["modules"])

    library_package = load_json5(ROOT / "ultra-ui/oh-package.json5")
    assert library_package["name"] == "@lingyun/ultra-ui-hos"
    assert library_package["main"] == "Index.ets"

    sample_app = load_json5(ROOT / "AppScope/app.json5")
    assert sample_app["app"]["bundleName"] == "net.lingyun.ultraui.hos.sample"

    entry_module = load_json5(ROOT / "sample/entry/src/main/module.json5")
    assert entry_module["module"]["name"] == "entry"
    assert entry_module["module"]["type"] == "entry"
    assert entry_module["module"]["mainElement"] == "EntryAbility"

    print("project contract: PASS")


if __name__ == "__main__":
    main()
