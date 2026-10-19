# Ultra UI HarmonyOS NEXT 阶段 12 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 HarmonyOS NEXT 原生 ArkUI 组件库补齐 `UPAgreement`、`UPCopy`、`UPNoNetwork` 和 `UPCode`，并同步公共导出、示例工程、兼容文档和进度表。

**Architecture:** 四个组件都采用 `Props` 类承载跨端值和可选回调。协议弹窗复用 `UPModal`；复制、网络状态和跨页面倒计时分别通过宿主注入的剪贴板函数、状态更新方法和 `UPCodeStorage` 表达，组件本身不执行系统或业务副作用。

**Tech Stack:** HarmonyOS NEXT API 24、ArkTS、ArkUI、Python 静态契约脚本、Markdown 文档。

**Spec:** `docs/superpowers/specs/2026-08-31-ultra-ui-hos-phase-12-design.md`

## Global Constraints

- 最低兼容 API：24。
- 产品兼容/目标 SDK：`5.0.0(12)`。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入，不访问 HAR 内部文件。
- 不使用 WebView、网络请求、运行时 JSON 映射、Vue/NVue、系统设置跳转或应用退出逻辑。
- 必须保留当前阶段 7–11 未提交改动，不执行 reset、回滚、commit 或创建分支。
- 生产代码必须先有失败的静态契约测试，再按最小实现变绿。

### Task 1: Add Phase 12 Contract

**Files:**
- Create: `scripts/test_phase_12_foundation_tools_contract.py`
- Modify: none

**Interfaces:**
- Consumes: existing `Path`-based static contract style from `scripts/test_phase_11_container_swiper_tabbar_contract.py`.
- Produces: one executable contract covering four component files, `Index.ets`, Components P demos, compatibility documentation and progress wording.

- [ ] **Step 1: Write the failing test**

  Assert that each component has `Options`, `Props`, public `@Component`, required defaults and required events/methods. Assert that each demo imports the public HAR entry, each route exists in `SampleCatalog.ets` and `SamplePage.ets`, and forbidden boundary tokens are absent.

- [ ] **Step 2: Run test to verify it fails**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: FAIL because the four component files, Components P routes and phase 12 note do not exist yet.

### Task 2: Implement Agreement and Copy

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPAgreement.ets`
- Create: `ultra-ui/src/main/ets/components/UPCopy.ets`
- Modify: `ultra-ui/Index.ets`

**Interfaces:**
- Consumes: `UPModal`, `UPButton`-compatible ArkUI callbacks, `UPRawValue`, `UPStyleInput`, `UPBuilder`, `UPUnit`, `UPColor` and `UPStyle`.
- Produces: `UPAgreementProps`, `UPAgreementOptions`, `UPAgreementConfirmEvent`, `UPAgreementLinkEvent`, `UPAgreement`, `UPCopyProps`, `UPCopyOptions`, `UPCopyRequest`, `UPCopySuccessEvent`, `UPCopyFailureEvent`, `UPCopyFailureReason`, `UPCopy`.

- [ ] **Step 1: Write the failing test**

  Extend the phase 12 contract with agreement defaults (`confirmText`, `cancelText`, `showCancelButton`) and copy defaults (`alertStyle`, `notice`), plus `UPModal` reuse, `onProtocolClick`, `onPrivacyClick`, `clipboard`, `onSuccess` and `onFailure` tokens.

- [ ] **Step 2: Run test to verify it fails**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: FAIL with missing `UPAgreement.ets` or `UPCopy.ets`.

- [ ] **Step 3: Write minimal implementation**

  Render agreement content inside `UPModal`; call `onConfirm` only with `{ accepted: true }`, forward protocol metadata to callbacks, and never navigate or close the application. Render copy content through a Builder fallback; convert non-empty values to text, call the injected clipboard function, and emit success or stable failure reasons without Toast/Modal side effects.

- [ ] **Step 4: Run test to verify it passes**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: the agreement/copy assertions pass while the no-network/code/demo assertions remain the next failing surface.

### Task 3: Implement No-Network and Code

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPNoNetwork.ets`
- Create: `ultra-ui/src/main/ets/components/UPCode.ets`
- Modify: `ultra-ui/Index.ets`

**Interfaces:**
- Consumes: `UPImage`, `UPIcon`, `UPButton`, `UPRawValue`, `UPStyleInput`, `UPUnit`, `UPStyle`, `UPColor` and `UPCodeStorage` host callbacks.
- Produces: `UPNoNetworkProps`, `UPNoNetworkOptions`, `UPNoNetworkStatusEvent`, `UPNoNetworkRetryEvent`, `UPNoNetwork`, `UPCodeStorage`, `UPCodeChangeEvent`, `UPCodeEndEvent`, `UPCodeProps`, `UPCodeOptions`, `UPCode`.

- [ ] **Step 1: Write the failing test**

  Add assertions for no-network defaults (`tips`, `zIndex`, `isConnected`, `networkType`, `retryText`) and code defaults (`seconds`, `startText`, `changeText`, `endText`, `keepRunning`, `uniqueKey`), plus `setConnected`, `start`, `reset`, `displayText`, `canGetCode`, `setInterval`, `clearInterval`, `onConnected`, `onDisconnected`, `onStart`, `onChange` and `onEnd`.

- [ ] **Step 2: Run test to verify it fails**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: FAIL because the no-network/code source files and public exports are still absent.

- [ ] **Step 3: Write minimal implementation**

  Make no-network rendering controlled by local connection state and expose `setConnected`; make retry only emit a host event. Make code render the current text, replace the first `x`/`X`, guard duplicate timers, reset after completion, and persist an end timestamp only through the optional storage adapter.

- [ ] **Step 4: Run test to verify it passes**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: component, export and forbidden-boundary assertions pass before demos and docs are added.

### Task 4: Add Components P Demos

**Files:**
- Create: `sample/entry/src/main/ets/demos/AgreementDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CopyDemo.ets`
- Create: `sample/entry/src/main/ets/demos/NoNetworkDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CodeDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`

**Interfaces:**
- Consumes: public exports from `@lingyun/ultra-ui-hos` and `SampleScaffold` routing conventions.
- Produces: `agreement`, `copy`, `no-network` and `code` sample routes grouped under Components P.

- [ ] **Step 1: Write the failing test**

  Assert the four demo files exist, use the public HAR import, and have catalog and page dispatch entries.

- [ ] **Step 2: Run test to verify it fails**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: FAIL with missing Components P routes or demo files.

- [ ] **Step 3: Write minimal implementation**

  Build deterministic Chinese examples: agreement callbacks display status, copy injects a local success handler, no-network toggles through `setConnected` semantics exposed by Props, and code displays the countdown API boundary without claiming device persistence.

- [ ] **Step 4: Run test to verify it passes**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py`

  Expected: phase 12 component/demo contract passes.

### Task 5: Document Compatibility and Progress

**Files:**
- Create: `docs/compatibility/phase-12.md`
- Modify: `PROGRESS.md`
- Modify: `README.md`
- Modify: `scripts/test_documentation_contract.py`
- Modify: none otherwise

**Interfaces:**
- Consumes: phase 12 implementation and route names.
- Produces: explicit host-capability boundaries, updated counts, four completed rows and documentation-contract coverage.

- [ ] **Step 1: Write the failing test**

  Require phase 12 wording, Components P, four public component names, host injection/no-op boundary terms, and updated 102-component/102-route totals.

- [ ] **Step 2: Run test to verify it fails**

  Run: `python3 scripts/test_documentation_contract.py`

  Expected: FAIL because phase 12 documentation and current statistics are absent.

- [ ] **Step 3: Write minimal implementation**

  Update the baseline date to `2026-08-31`, increase public components and Demo routes by four, move the four progress rows from “未开始” to “基础可用” or “占位实现” according to their boundaries, add Components P wording and link the phase note.

- [ ] **Step 4: Run test to verify it passes**

  Run: `python3 scripts/test_documentation_contract.py`

  Expected: documentation contract passes.

### Task 6: Run Full Verification

**Files:**
- Modify: none

- [ ] **Step 1: Run focused contracts**

  Run: `python3 scripts/test_phase_12_foundation_tools_contract.py && python3 scripts/test_documentation_contract.py && python3 scripts/test_sample_contract.py`

  Expected: all commands exit 0 and print PASS.

- [ ] **Step 2: Run repository checks**

  Run: `python3 scripts/test_upstream_inventory.py && git diff --check`

  Expected: upstream inventory remains complete and `git diff --check` prints no errors. If the repository names the inventory script differently, run the existing inventory command found under `scripts/` and record the exact result.

- [ ] **Step 3: Review the final diff**

  Run: `git status --short && git diff --stat`

  Expected: only phase 12 files plus intentional progress/documentation updates appear; prior stage 7–11 changes remain untouched.
