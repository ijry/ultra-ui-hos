#!/usr/bin/env python3
"""Static contracts for the Phase 23 slot-level parity pass."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"
DEMOS = ROOT / "sample/entry/src/main/ets/demos"
INDEX = ROOT / "ultra-ui/Index.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-23.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

# component -> slot builders declared as optional props and rendered through a region method
PROP_BUILDERS = {
    "UPActionSheet": ("contentBuilder",),
    "UPAlert": ("closeBuilder",),
    "UPAvatar": ("contentBuilder",),
    "UPBackTop": ("contentBuilder",),
    "UPBox": ("leftBuilder", "rightTopBuilder", "rightBottomBuilder"),
    "UPButton": ("contentBuilder",),
    "UPCalendar": ("footerBuilder",),
    "UPCell": ("iconBuilder", "titleBuilder", "labelBuilder", "valueBuilder",
               "rightIconBuilder", "righticonBuilder"),
    "UPCellGroup": ("titleBuilder",),
    "UPCheckbox": ("iconBuilder", "labelBuilder"),
    "UPCollapseItem": ("iconBuilder", "titleBuilder", "valueBuilder", "rightIconBuilder"),
    "UPColorPicker": ("contentBuilder",),
    "UPColumnNotice": ("iconBuilder",),
    "UPCountDown": ("contentBuilder",),
    "UPCoupon": ("unitBuilder", "limitBuilder", "titleBuilder", "descBuilder", "timeBuilder"),
    "UPDatePicker": ("triggerBuilder", "toolbarRightBuilder", "toolbarBottomBuilder"),
    "UPDivider": ("contentBuilder",),
    "UPDropdownItem": ("contentBuilder",),
    "UPEmpty": ("contentBuilder",),
    "UPFloatingBubble": ("contentBuilder", "listBuilder"),
    "UPFormItem": ("labelBuilder", "errorBuilder"),
    "UPGoodsSku": ("headerBuilder", "triggerBuilder"),
    "UPImage": ("loadingBuilder", "errorBuilder"),
    "UPIndexList": ("headerBuilder", "footerBuilder"),
    "UPInput": ("prefixBuilder", "suffixBuilder"),
    "UPKeyboard": ("contentBuilder",),
    "UPLineProgress": ("contentBuilder",),
    "UPLoadingPage": ("contentBuilder",),
    "UPModal": ("confirmButtonBuilder", "popupBottomBuilder"),
    "UPNotify": ("iconBuilder",),
    "UPNovelReader": ("loadingBuilder", "errorBuilder", "emptyBuilder", "topBuilder",
                      "toolbarExtraBuilder", "bottomBuilder", "catalogBuilder", "settingsBuilder"),
    "UPNumberBox": ("minusBuilder", "plusBuilder", "inputBuilder"),
    "UPOverlay": ("contentBuilder",),
    "UPPicker": ("contentBuilder", "triggerBuilder", "toolbarRightBuilder", "toolbarBottomBuilder"),
    "UPPopover": ("triggerBuilder",),
    "UPPopup": ("triggerBuilder", "bottomBuilder"),
    "UPRadio": ("iconBuilder", "labelBuilder"),
    "UPReadMore": ("toggleBuilder",),
    "UPRowNotice": ("iconBuilder",),
    "UPSearch": ("labelBuilder", "inputRightBuilder"),
    "UPSelect": ("textBuilder", "iconBuilder", "optionsBuilder"),
    "UPSkeleton": ("contentBuilder",),
    "UPSlider": ("contentBuilder", "minBuilder", "maxBuilder"),
    "UPStatusBar": ("contentBuilder",),
    "UPSwipeActionItem": ("buttonBuilder",),
    "UPSwiper": ("indicatorBuilder",),
    "UPTabbar": ("contentBuilder",),
    "UPTabbarItem": ("activeIconBuilder", "inactiveIconBuilder", "textBuilder"),
    "UPTable2": ("emptyBuilder",),
    "UPTag": ("contentBuilder", "defaultBuilder", "iconBuilder"),
    "UPTimePicker": ("triggerBuilder", "toolbarRightBuilder", "toolbarBottomBuilder"),
    "UPTitle": ("contentBuilder", "prefixBuilder"),
    "UPToolbar": ("rightBuilder",),
    "UPTooltip": ("contentBuilder", "triggerBuilder"),
    "UPUpload": ("contentBuilder", "triggerBuilder", "playIconBuilder", "successBuilder"),
}

# component -> scoped slots that stay `@BuilderParam` because upstream hands data to the slot
SCOPED_BUILDER_PARAMS = {
    "UPChoose": ("itemBuilder",),
    "UPSelect": ("optionItemBuilder",),
    "UPTable2": ("headerBuilder", "headerSortBuilder", "cellBuilder"),
    "UPTreeSelect": ("nodeBuilder",),
    "UPWaterfall": ("leftBuilder",),
}

# scope interfaces introduced for the new scoped slots
SCOPE_TYPES = {
    "UPChoose": "UPChooseItemSlot",
    "UPSelect": "UPSelectOptionSlot",
    "UPTreeSelect": "UPTreeSelectFlatNode",
}

# component -> render tokens proving the slot actually replaces or joins the default body
BEHAVIOUR = {
    "UPButton": ("if (this.props.contentBuilder === undefined) {",),
    "UPCard": ("UPCardBuilderRegion({ contentBuilder: this.props.bodyBuilder })",),
    "UPCell": ("} else if (this.props.rightIconBuilder !== undefined) {",),
    "UPCoupon": ("if (slot.unitPosition === 'left' && this.props.unitBuilder !== undefined) {",),
    "UPGoodsSku": ("private openByTrigger(): void {",),
    "UPIndexList": ("if (this.props.headerBuilder !== undefined) {", "ListItem() {"),
    "UPNovelReader": ("if (upBoolean(this.props.loading, false) && this.props.loadingBuilder !== undefined) {",),
    "UPNumberBox": ("if (this.props.inputBuilder !== undefined) {",),
    "UPSkeleton": ("if (!upBoolean(this.props.loading, true)) {\n      this.slotRegion()",),
    "UPTable2": ("this.cellBuilder(slot)", "this.headerBuilder(this.headerSlot(columnIndex))",
                 "this.headerSortBuilder(this.headerSortSlot(columnIndex))"),
    "UPTabbarItem": ("} else if (upBoolean(this.props.active, false) && this.props.activeIconBuilder !== undefined) {",),
    "UPWaterfall": ("} else if (this.useLeftSlotValue()) {", "useLeftSlot"),
}

# demo -> tokens proving the sample工程 exercises the new slot entries
DEMOS_WIRED = {
    "CellDemo.ets": ("iconBuilder: this.slotIcon", "titleBuilder: this.slotTitle",
                     "labelBuilder: this.slotLabel", "valueBuilder: this.slotValue",
                     "rightIconBuilder: this.slotRightIcon", "righticonBuilder: this.slotRightIconExtra"),
    "TitleDemo.ets": ("prefixBuilder: this.slotPrefix", "contentBuilder: this.slotContent"),
    "NumberBoxDemo.ets": ("minusBuilder: this.slotMinus", "plusBuilder: this.slotPlus",
                          "inputBuilder: this.slotInput"),
    "SelectDemo.ets": ("UPSelectOptionSlot", "optionItemBuilder: this.slotOptionItem"),
    "Table2Demo.ets": ("UPTable2HeaderSlot", "UPTable2HeaderSortSlot", "UPTable2CellSlot",
                       "headerBuilder: this.slotHeader", "headerSortBuilder: this.slotHeaderSort",
                       "cellBuilder: this.slotCell", "emptyBuilder: this.slotEmpty"),
}

EXPORTS = (
    "UPSlotRegion", "UPSlotBlock", "UPSelectOptionSlot", "UPChooseItemSlot",
    "UPTable2CellSlot", "UPTable2HeaderSlot", "UPTable2HeaderSortSlot",
)


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    region = read(INTERNAL / "UPSlotRegion.ets")
    for token in ("export struct UPSlotRegion", "export struct UPSlotBlock",
                  "@BuilderParam contentBuilder: () => void = this.emptySlot;"):
        assert token in region, f"UPSlotRegion.ets is missing {token}"

    sources: dict[str, str] = {}
    declared = 0
    for name, builders in PROP_BUILDERS.items():
        source = read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        options = re.search(rf"export interface {name}Options \{{(.*?)\n\}}", source, re.S)
        props = re.search(rf"export class {name}Props \{{(.*?)\n\}}", source, re.S)
        assert options is not None and props is not None, f"{name} is missing its Options/Props pair"
        for builder in builders:
            declared += 1
            assert re.search(rf"\b{builder}\?\s*:\s*UPBuilder;", options.group(1)), (
                f"{name}Options is missing {builder}"
            )
            assert re.search(rf"\b{builder}\?\s*:\s*UPBuilder;", props.group(1)), (
                f"{name}Props is missing {builder}"
            )
            assert f"this.{builder} = options.{builder};" in source, (
                f"{name} never assigns {builder} from options"
            )
            # the builder must reach a UPSlotRegion child, either inline inside a @Builder
            # method or through a dedicated region helper that is rendered at least once
            handoff = f"UPSlotRegion({{ contentBuilder: this.props.{builder} }})"
            assert handoff in source, f"{name} never hands {builder} to UPSlotRegion"
            region_method = re.search(
                r"@Builder\s*\n\s*private ([A-Za-z_][A-Za-z0-9_]*)\(\) \{\s*\n"
                rf"\s*{re.escape(handoff)}",
                source,
            )
            if region_method is not None:
                method = region_method.group(1)
                assert len(re.findall(rf"this\.{method}\(\)", source)) >= 1, (
                    f"{name} never renders the {method}() region"
                )
        for token in FORBIDDEN:
            assert token not in source, f"{name} contains forbidden boundary {token}"

    scoped = 0
    for name, builders in SCOPED_BUILDER_PARAMS.items():
        source = sources.get(name) or read(COMPONENTS / f"{name}.ets")
        sources[name] = source
        for builder in builders:
            scoped += 1
            assert re.search(rf"@BuilderParam {builder}: \(slot: [A-Za-z0-9_]+\) => void", source) \
                or re.search(rf"@BuilderParam {builder}: \(flat: [A-Za-z0-9_]+\) => void", source), (
                f"{name} is missing the scoped @BuilderParam {builder}"
            )
            assert f"this.{builder}(" in source, f"{name} never renders {builder}"

    for name, scope in SCOPE_TYPES.items():
        assert f"export interface {scope}" in sources[name] or f"export class {scope}" in sources[name], (
            f"{name} must export the scope type {scope}"
        )

    for name, tokens in BEHAVIOUR.items():
        source = sources.get(name) or read(COMPONENTS / f"{name}.ets")
        for token in tokens:
            assert token in source, f"{name} does not wire {token}"

    for filename, tokens in DEMOS_WIRED.items():
        demo = read(DEMOS / filename)
        assert "@lingyun/ultra-ui-hos" in demo, f"{filename} must import from the public HAR entry"
        assert not re.search(r"=>\s*this\.", demo), f"{filename} must use explicit void block bodies"
        for token in tokens:
            assert token in demo, f"{filename} does not demonstrate {token}"

    index = read(INDEX)
    for symbol in EXPORTS:
        assert symbol in index, f"public entry missing {symbol}"

    assert declared >= 100, f"expected at least 100 slot props, counted {declared}"
    assert scoped >= 7, f"expected at least 7 scoped builders, counted {scoped}"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 23", "phase-23.md"):
        assert phrase in readme or phrase in note, f"Phase 23 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPSlotRegion", "@BuilderParam", "UPCell", "UPNovelReader",
        "UPTable2", "UPWaterfall", "righticon", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-23 note missing {phrase}"

    print(f"phase 23 slot parity contract: PASS ({declared} slot props, {scoped} scoped builders, "
          f"{len(DEMOS_WIRED)} demos)")


if __name__ == "__main__":
    main()
