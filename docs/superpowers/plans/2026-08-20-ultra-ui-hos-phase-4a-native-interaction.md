# ultra-ui-hos Phase 4A Native Interaction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 HarmonyOS NEXT ArkTS/ArkUI HAR/HAP 中新增与关联 Android/iOS 对齐的十个原生交互、提示和环形进度组件，并提供可构建的中文示例路由。

**Architecture:** 组件继续以 `UP*Props` 类、`@Component` struct、`@BuilderParam` 和显式本地回调构成，所有公开符号从 `ultra-ui/Index.ets` 导出。页面持有 `show`、`modelValue`、`value`、打开索引和折叠值；折叠与下拉仅使用声明式局部上下文协调嵌套子项，不保存跨页面业务状态。原生 ArkUI 无稳定等价的动画、跑马灯、外部滚动和平台服务字段采用确定性静态表现或安全 no-op。

**Tech Stack:** HarmonyOS NEXT Stage 模型、ArkTS/ArkUI API 24、Hvigor/HAR/HAP、Python 静态契约、仓库现有 `UPUnit`/`UPColor`/`UPStyle`/`UPIcon` 核心。

---

## 文件地图

### 新增组件与内部上下文

- `ultra-ui/src/main/ets/components/UPCircleProgress.ets`：环形进度 Props、百分比回退、原生进度环和内容 Builder。
- `ultra-ui/src/main/ets/components/UPAlert.ets`：受控提示条、类型颜色、关闭事件。
- `ultra-ui/src/main/ets/components/UPNotify.ets`：受控顶部通知条和关闭请求。
- `ultra-ui/src/main/ets/components/UPNoticeBar.ets`：单行/列式公告、链接/关闭事件和安全静态轮播回退。
- `ultra-ui/src/main/ets/components/UPActionSheet.ets`：操作项类型、遮罩、底部操作面板和选择事件。
- `ultra-ui/src/main/ets/components/UPBackTop.ets`：滚动阈值显示、悬浮返回按钮和点击事件。
- `ultra-ui/src/main/ets/components/UPCollapse.ets`：折叠组 Props、值归一化、上下文和变更事件。
- `ultra-ui/src/main/ets/components/UPCollapseItem.ets`：折叠子项、标题区域、展开内容和子项事件。
- `ultra-ui/src/main/ets/components/UPDropdown.ets`：下拉菜单上下文、菜单标题、遮罩和打开状态。
- `ultra-ui/src/main/ets/components/UPDropdownItem.ets`：下拉选项、单选/多选值回退和选择事件。
- `ultra-ui/src/main/ets/internal/UPInteractionContexts.ets`：`UPCollapseContext`、`UPDropdownContext` 和组合期索引。

### 契约、入口与示例

- `scripts/test_phase_4a_native_interaction_contract.py`：十个组件的失败优先静态契约、入口导出、示例、文档和边界检查。
- `ultra-ui/Index.ets`：新增十个组件、Props、选项和事件的公共导出。
- `sample/entry/src/main/ets/demos/CircleProgressDemo.ets`、`AlertDemo.ets`、`NotifyDemo.ets`、`NoticeBarDemo.ets`、`ActionSheetDemo.ets`、`BackTopDemo.ets`、`CollapseDemo.ets`、`CollapseItemDemo.ets`、`DropdownDemo.ets`、`DropdownItemDemo.ets`：中文可交互示例。
- `sample/entry/src/main/ets/catalog/SampleCatalog.ets`、`sample/entry/src/main/ets/pages/SamplePage.ets`：新增 `Components F/G/H` 分组、导入、路由分发和标题。

### 文档与既有契约

- `docs/compatibility/phase-4a.md`：公开字段、原生差异、无网络边界和设备 `skipped` 规则。
- `README.md`：更新 54 个组件/控制器和 52 条路由，并链接 Phase 4A 文档。
- `scripts/test_documentation_contract.py`：加入 Phase 4A 文档和计数断言。
- `scripts/test_sample_contract.py`：加入十条新路由的公共入口和示例约束。
- `scripts/test_arkts_component_contract.py`：加入十个新组件的 ArkTS 安全检查（如现有脚本结构适用）。

## Task 1: Add the failing Phase 4A contract

**Files:**
- Create: `scripts/test_phase_4a_native_interaction_contract.py`

- [ ] **Step 1: Write the first failing static contract.** Start with the progress/prompt sub-batch only: assert that `UPCircleProgress`, `UPAlert`, `UPNotify`, and `UPNoticeBar` each contain their `Props` class, options/event types, public struct, required fields and safe enum/default tokens. Assert `Index.ets` exports these four components and their four demos/routes use `@lingyun/ultra-ui-hos`. Reject `WebView`, `FastView`, `.xyfv`, `@ohos.net`, `request(` and remote URL literals in the checked component/demo sources. Tasks 3, 4, 5, and 6 extend the same `COMPONENTS`/`DEMOS` maps before implementing their production files.

  Final component field groups after all task-local extensions:

  ```python
  COMPONENTS = {
      "UPCircleProgress": ("percentage", "activeColor", "inactiveColor", "width", "borderWidth", "customStyle", "contentBuilder"),
      "UPAlert": ("title", "type", "description", "closable", "showIcon", "effect", "modelValue", "value", "customStyle"),
      "UPNotify": ("show", "message", "type", "color", "bgColor", "onShowChange", "customStyle"),
      "UPNoticeBar": ("text", "direction", "mode", "url", "linkType", "onShowChange", "customStyle"),
      "UPActionSheet": ("show", "actions", "cancelText", "closeOnClickAction", "closeOnClickOverlay", "customStyle"),
      "UPBackTop": ("mode", "scrollTop", "top", "bottom", "right", "onBackToTop", "customStyle"),
      "UPCollapse": ("value", "modelValue", "accordion", "onChange", "onValueChange", "contentBuilder"),
      "UPCollapseItem": ("title", "name", "disabled", "isOpen", "open", "contentBuilder"),
      "UPDropdown": ("openIndex", "closeOnClickMask", "direction", "onOpenChange", "contentBuilder"),
      "UPDropdownItem": ("modelValue", "value", "options", "multiple", "onValueChange", "onSelect"),
  }
  ```

- [ ] **Step 2: Run the contract and confirm the expected red state.**

  Run:

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  ```

  Expected: fail at the first missing Phase 4A source or public export, without changing any production file.

## Task 2: Implement progress and prompt components

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPCircleProgress.ets`
- Create: `ultra-ui/src/main/ets/components/UPAlert.ets`
- Create: `ultra-ui/src/main/ets/components/UPNotify.ets`
- Create: `ultra-ui/src/main/ets/components/UPNoticeBar.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/CircleProgressDemo.ets`
- Create: `sample/entry/src/main/ets/demos/AlertDemo.ets`
- Create: `sample/entry/src/main/ets/demos/NotifyDemo.ets`
- Create: `sample/entry/src/main/ets/demos/NoticeBarDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`

- [ ] **Step 1: Implement Props and defaults before render code.** Use existing constructor/options patterns. Preserve `modelValue ?? value` for Alert; use explicit `show` and callback fields for Notify/NoticeBar. Define `UPNoticeBarClickEvent { index, url, linkType }`; Alert, Notify, and NoticeBar visibility callbacks use `(show: boolean) => void`, while their close callbacks use `() => void`. Keep every demo callback explicitly typed with a `void` return.

- [ ] **Step 2: Implement minimal native rendering.** Use `Progress`/`Stack` for the circle, `Row`/`Column` for alerts and notices, and a top-aligned `Column` for Notify. Resolve colors through `UPColor.parse`, dimensions through `UPUnit.parse`, and invalid enums to documented defaults. Use `UPIcon` only with local glyph names. Do not add timers, network calls, or navigation.

- [ ] **Step 3: Add demos and routes.** Add `Components F` entries for the four routes. Circle demo shows 0/30/100 values; Alert demo toggles visibility and records close; Notify demo toggles `show` through `onShowChange`; NoticeBar demo exercises click and close while displaying `url`/`linkType` as text only.

- [ ] **Step 4: Run the focused red-to-green verification.**

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  python3 scripts/test_sample_contract.py
  ./scripts/build.sh
  ```

  Expected: Phase 4A and sample contracts pass; HAR/HAP build produces the existing HAR/HAP paths.

- [ ] **Step 5: Commit only this sub-batch.**

  ```bash
  git add ultra-ui/Index.ets ultra-ui/src/main/ets/components/UPCircleProgress.ets ultra-ui/src/main/ets/components/UPAlert.ets ultra-ui/src/main/ets/components/UPNotify.ets ultra-ui/src/main/ets/components/UPNoticeBar.ets sample/entry/src/main/ets/demos/CircleProgressDemo.ets sample/entry/src/main/ets/demos/AlertDemo.ets sample/entry/src/main/ets/demos/NotifyDemo.ets sample/entry/src/main/ets/demos/NoticeBarDemo.ets sample/entry/src/main/ets/catalog/SampleCatalog.ets sample/entry/src/main/ets/pages/SamplePage.ets scripts/test_phase_4a_native_interaction_contract.py
  git commit -m "feat: add phase 4a progress and prompt components"
  ```

## Task 3: Implement action sheet and back-top

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPActionSheet.ets`
- Create: `ultra-ui/src/main/ets/components/UPBackTop.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/ActionSheetDemo.ets`
- Create: `sample/entry/src/main/ets/demos/BackTopDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `scripts/test_phase_4a_native_interaction_contract.py`

- [ ] **Step 1: Extend the contract with action and back-top fields.** Add `UPActionSheet` and `UPBackTop` to the `COMPONENTS`/`DEMOS` maps; require `UPActionSheetAction`, `UPActionSheetSelectEvent`, disabled/loading action guards, cancel/overlay callbacks, `scrollTop` threshold, `mode` fallback and `onBackToTop`. Run the contract and confirm it fails for missing sources.

- [ ] **Step 2: Implement action sheet.** Normalize action entries from explicit typed objects and safe primitive values. Render only when `show` is true, with a local overlay and scrollable bottom panel. Disabled/loading rows do not emit selection; close behavior emits the state request before close completion. `openType` and safe-area fields remain no-op compatibility inputs.

- [ ] **Step 3: Implement back-top.** Render only when `scrollTop >= top`, clamp positions to non-negative dimensions, map invalid mode to `circle`, and invoke `onClick` then `onBackToTop` without touching an external `Scroller`.

- [ ] **Step 4: Add demos and routes.** Add `Components G` entries. Action sheet demo keeps `show` in `@State` and writes selected index/message. Back-top demo displays a local `scrollTop` steppers and describes that the caller owns scrolling.

- [ ] **Step 5: Verify and commit.**

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  ./scripts/build.sh
  git add ultra-ui/Index.ets ultra-ui/src/main/ets/components/UPActionSheet.ets ultra-ui/src/main/ets/components/UPBackTop.ets sample/entry/src/main/ets/demos/ActionSheetDemo.ets sample/entry/src/main/ets/demos/BackTopDemo.ets sample/entry/src/main/ets/catalog/SampleCatalog.ets sample/entry/src/main/ets/pages/SamplePage.ets scripts/test_phase_4a_native_interaction_contract.py
  git commit -m "feat: add phase 4a action containers"
  ```

## Task 4: Implement collapse context and components

**Files:**
- Create: `ultra-ui/src/main/ets/internal/UPInteractionContexts.ets`
- Create: `ultra-ui/src/main/ets/components/UPCollapse.ets`
- Create: `ultra-ui/src/main/ets/components/UPCollapseItem.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/CollapseDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CollapseItemDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `scripts/test_phase_4a_native_interaction_contract.py`

- [ ] **Step 1: Extend the contract before implementation.** Add `UPCollapse` and `UPCollapseItem` to the `COMPONENTS`/`DEMOS` maps. Assert the collapse context methods `beginComposition`, `itemName`, `isOpen`, `requestToggle`, and `itemCount`, plus `accordion`, `modelValue` priority, `onChange`, item content Builder and standalone fallback. Run the contract and observe the missing-context failure.

- [ ] **Step 2: Implement the context.** Keep `UPCollapseContext` composition-local; `UPCollapse` initializes it from normalized Props and provides it with `@Provide`. `requestToggle` computes the next scalar or array value and invokes callbacks, but does not mutate the incoming Props.

- [ ] **Step 3: Implement group and item rendering.** `UPCollapse` renders its Builder and supplies the context. `UPCollapseItem` uses `@Consume` with a safe standalone context, allocates a visual index in `aboutToAppear`, renders title/label/arrow/content, and applies disabled/clickable guards.

- [ ] **Step 4: Add demos and routes.** Collapse demo covers accordion and multi-open state; item demo covers standalone `open`/`isOpen` fallback and a content Builder. All callbacks use explicit event types and page state.

- [ ] **Step 5: Verify and commit.**

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  ./scripts/build.sh
  git add ultra-ui/Index.ets ultra-ui/src/main/ets/internal/UPInteractionContexts.ets ultra-ui/src/main/ets/components/UPCollapse.ets ultra-ui/src/main/ets/components/UPCollapseItem.ets sample/entry/src/main/ets/demos/CollapseDemo.ets sample/entry/src/main/ets/demos/CollapseItemDemo.ets sample/entry/src/main/ets/catalog/SampleCatalog.ets sample/entry/src/main/ets/pages/SamplePage.ets scripts/test_phase_4a_native_interaction_contract.py
  git commit -m "feat: add phase 4a collapse components"
  ```

## Task 5: Implement dropdown context and components

**Files:**
- Modify: `ultra-ui/src/main/ets/internal/UPInteractionContexts.ets`
- Create: `ultra-ui/src/main/ets/components/UPDropdown.ets`
- Create: `ultra-ui/src/main/ets/components/UPDropdownItem.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/DropdownDemo.ets`
- Create: `sample/entry/src/main/ets/demos/DropdownItemDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `scripts/test_phase_4a_native_interaction_contract.py`

- [ ] **Step 1: Extend the contract before implementation.** Add `UPDropdown` and `UPDropdownItem` to the `COMPONENTS`/`DEMOS` maps. Assert `UPDropdownContext` methods `openIndex`, `requestOpen`, `close`, and `isOpen`; assert option fields, model/value priority, disabled selection, single-select close request and multiple-select retention. Run the contract and confirm it fails for the missing dropdown sources.

- [ ] **Step 2: Implement dropdown context and menu.** `UPDropdown` provides an initial `openIndex` context and renders title children plus an optional content Builder. Mask/self click behavior must be explicit and all open state changes go through `onOpenChange`.

- [ ] **Step 3: Implement dropdown item.** Normalize options into `UPDropdownOption` values, compute the selected label, render a deterministic option list, and emit `UPDropdownItemSelectEvent`. Use `@Consume` default context when rendered alone.

- [ ] **Step 4: Add demos and routes.** Dropdown demo shows two menu items, controlled open index, disabled option and selection feedback. Item demo shows standalone single-select and multiple-select behavior.

- [ ] **Step 5: Verify and commit.**

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  ./scripts/build.sh
  git add ultra-ui/Index.ets ultra-ui/src/main/ets/internal/UPInteractionContexts.ets ultra-ui/src/main/ets/components/UPDropdown.ets ultra-ui/src/main/ets/components/UPDropdownItem.ets sample/entry/src/main/ets/demos/DropdownDemo.ets sample/entry/src/main/ets/demos/DropdownItemDemo.ets sample/entry/src/main/ets/catalog/SampleCatalog.ets sample/entry/src/main/ets/pages/SamplePage.ets scripts/test_phase_4a_native_interaction_contract.py
  git commit -m "feat: add phase 4a dropdown components"
  ```

## Task 6: Add Phase 4A documentation and update counts

**Files:**
- Create: `docs/compatibility/phase-4a.md`
- Modify: `README.md`
- Modify: `scripts/test_documentation_contract.py`
- Modify: `scripts/test_sample_contract.py`
- Modify: `scripts/test_arkts_component_contract.py` when the existing generic assertions need new component names

- [ ] **Step 1: Extend documentation/sample assertions and run red.** Add the final full-catalog assertions to the Phase 4A contract. Assert `phase-4a.md` contains API 24, `5.0.0(12)`, all ten component names, `页面受控状态`, `无网络`, `设备验证`, and `skipped`; assert README contains `54 个已实现组件/控制器`, `52 条组件示例路由`, and the phase link. Assert F/G/H catalog groups and all ten demo filenames. Run the Phase 4A and documentation contracts and confirm they fail because the compatibility note/count changes do not exist yet.

- [ ] **Step 2: Write the compatibility note.** Document public exports, default values, event order, model/value rules, context fallback, local-only callbacks, native no-op fields and device `skipped` semantics. State that HAR/HAP build does not replace device rendering verification.

- [ ] **Step 3: Update README and existing contracts.** Update component and route totals, add F/G/H route descriptions and Phase 4A link. Keep existing phase totals and no-device wording intact.

- [ ] **Step 4: Run documentation and sample contracts.**

  ```bash
  python3 scripts/test_phase_4a_native_interaction_contract.py
  python3 scripts/test_documentation_contract.py
  python3 scripts/test_sample_contract.py
  git diff --check
  ```

- [ ] **Step 5: Commit documentation.**

  ```bash
  git add docs/compatibility/phase-4a.md README.md scripts/test_documentation_contract.py scripts/test_sample_contract.py scripts/test_arkts_component_contract.py scripts/test_phase_4a_native_interaction_contract.py
  git commit -m "docs: document phase 4a native interaction compatibility"
  ```

## Task 7: Full verification and boundary review

**Files:**
- Modify only files required by a fresh verification failure; do not stage unrelated existing worktree files.

- [ ] **Step 1: Run every Python contract.**

  ```bash
  for f in scripts/test_*.py; do python3 "$f" || exit 1; done
  ```

  Expected: every script exits zero and prints its `PASS` line.

- [ ] **Step 2: Run boundaries, toolchain, screenshots, whitespace and build.**

  ```bash
  ./scripts/verify-boundaries.sh
  ./scripts/verify-toolchain.sh
  ./scripts/capture-screenshots.sh
  git diff --check
  ./scripts/build.sh
  ```

  Expected: boundary check passes; toolchain check passes; no-device scripts report `skipped`; HAR/HAP build succeeds and confirms `upicon.ttf` in both outputs.

- [ ] **Step 3: Review requirements against the design.** Confirm all ten public exports, every required default and event, the collapse/dropdown context paths, component Builder paths, ten routes, README counts, local-only behavior and no forbidden dependency. Review `git diff --stat` and `git status --short`.

- [ ] **Step 4: Commit only verification-driven corrections.** Re-run the affected contract and full verification after any correction; do not commit generated build output or unrelated pre-existing files.
