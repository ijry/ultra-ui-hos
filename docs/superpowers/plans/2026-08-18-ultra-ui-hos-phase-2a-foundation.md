# ultra-ui-hos 阶段 2A 基础展示组件实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 1 可构建 HAR/HAP 基线上，新增阶段 2A 基础展示组件并提供示例入口：`UPLine`、`UPGap`、`UPLink`、`UPTitle`、`UPBadge`、`UPDivider`、`UPSkeleton`、`UPLineProgress`、`UPLoadmore`。

**Architecture:** 组件继续采用 ArkTS/ArkUI 原生实现，所有 public API 通过 `ultra-ui/Index.ets` 导出；每个组件以 `Props` 类封装兼容字段、默认值和事件回调。示例工程只从 `@lingyun/ultra-ui-hos` 导入组件，并在 `Components A` 中追加静态可导航示例页。

**Tech Stack:** HarmonyOS NEXT Stage 模型、ArkTS、ArkUI、DevEco Studio 6.1.1、Hvigor 6.24.1、HarmonyOS SDK API 24、HAR、HAP、Python 静态契约测试。

## Global Constraints

- 最低兼容 API 为 24，产品兼容版本为 `5.0.0(12)`；不得无保护使用更高 API。
- 组件库包名为 `@lingyun/ultra-ui-hos`，示例包名为 `net.lingyun.ultraui.hos.sample`。
- 示例只导入 `ultra-ui/Index.ets` 的公共导出，不导入库内部文件。
- 不实现 WebView、FastView、JSON 渲染器、网络请求、业务路由或运行时代码生成。
- Props 保留 uview-plus/iOS/Android 已有兼容字段；不适合 HarmonyOS 的字段必须安全 no-op 或稳定回退。
- 组件默认值、中文示例标题和主要字段命名参考固定 uview-plus 3.x 提交 `96f14b06f857aeda011ae5baf9654bb4634dba9a` 以及关联 iOS/Android 工程。

---

### Task 1: 失败契约测试锁定阶段 2A 范围

**Files:**
- Create: `scripts/test_foundation_display_contract.py`

**Interfaces:**
- Consumes: existing `ultra-ui/Index.ets`, `sample/entry/src/main/ets/catalog/SampleCatalog.ets`, and demo routing pattern.
- Produces: a static contract that fails until all 2A components, public exports, sample routes, and no-network fallbacks exist.

- [x] **Step 1: Write the failing test**
  - Assert component source files exist for all nine 2A components.
  - Assert each file defines `UP<Component>Props` and `UP<Component>`.
  - Assert `Index.ets` exports every component and props type.
  - Assert sample catalog contains routes: `line`, `gap`, `link`, `title`, `badge`, `divider`, `skeleton`, `line-progress`, `loadmore`.
  - Assert each new demo imports from `@lingyun/ultra-ui-hos` only.
- [x] **Step 2: Run test to verify RED**
  - Run: `python3 scripts/test_foundation_display_contract.py`
  - Expected: FAIL with missing component/demo/export assertions.

### Task 2: Implement simple visual primitives

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPLine.ets`
- Create: `ultra-ui/src/main/ets/components/UPGap.ets`
- Create: `ultra-ui/src/main/ets/components/UPLink.ets`
- Create: `ultra-ui/src/main/ets/components/UPTitle.ets`
- Modify: `ultra-ui/Index.ets`
- Test: `scripts/test_foundation_display_contract.py`

**Interfaces:**
- Produces: `UPLineProps`, `UPGapProps`, `UPLinkProps`, `UPTitleProps`, `UPLinkClickEvent`.
- Consumes: `UPUnit`, `UPColor`, `UPStyle`, and existing safe callback style.

- [x] **Step 1: Implement `UPLine`**
  - Support `color`, `length`, `direction`, `hairline`, `margin`, `dashed`, `customStyle`.
  - `direction='row'` renders horizontal; all other values render vertical.
- [x] **Step 2: Implement `UPGap`**
  - Support `bgColor`, `height`, `marginTop`, `marginBottom`, `customStyle`.
  - Treat `transparent` as clear background; invalid color falls back safely.
- [x] **Step 3: Implement `UPLink`**
  - Support `color`, `fontSize`, `underLine`, `href`, `mpTips`, `lineColor`, `text`, `customStyle`, `onTap`, `onClick`.
  - Do not open network URLs; emit typed click payload instead.
- [x] **Step 4: Implement `UPTitle`**
  - Support `title`, `subTitle`, `type`, `color`, `size`, `bold`, `align`, `prefix`, `prefixColor`, `prefixWidth`, `prefixHeight`, `customStyle`.
  - Keep prefix visual local and deterministic.
- [x] **Step 5: Run contract test**
  - Run: `python3 scripts/test_foundation_display_contract.py`
  - Expected: still FAIL until all Task 3 components and demos exist.

### Task 3: Implement badges, separators, loading placeholders and progress

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPBadge.ets`
- Create: `ultra-ui/src/main/ets/components/UPDivider.ets`
- Create: `ultra-ui/src/main/ets/components/UPSkeleton.ets`
- Create: `ultra-ui/src/main/ets/components/UPLineProgress.ets`
- Create: `ultra-ui/src/main/ets/components/UPLoadmore.ets`
- Modify: `ultra-ui/Index.ets`
- Test: `scripts/test_foundation_display_contract.py`

**Interfaces:**
- Produces: `UPBadgeProps`, `UPDividerProps`, `UPSkeletonProps`, `UPLineProgressProps`, `UPLoadmoreProps`, `UPDividerClickEvent`.
- Consumes: existing `UPLoadingIcon`, `UPIcon`, `UPUnit`, `UPColor`, `UPStyle`.

- [x] **Step 1: Implement `UPBadge`**
  - Support `isDot`, `value`, `modelValue`, `show`, `max`, `type`, `showZero`, `bgColor`, `color`, `shape`, `numberType`, `offset`, `inverted`, `absolute`, `customStyle`.
  - Clamp numeric display to `max+`; hide zero when `showZero=false`.
- [x] **Step 2: Implement `UPDivider`**
  - Support `dashed`, `hairline`, `dot`, `textPosition`, `text`, `textSize`, `textColor`, `lineColor`, `customStyle`, `onTap`, `onClick`.
- [x] **Step 3: Implement `UPSkeleton`**
  - Support `loading`, `rows`, `title`, `avatar`, `avatarShape`, `avatarSize`, `titleWidth`, `rowWidth`, `rowHeight`, `animate`, `bgColor`, `customStyle`.
  - Use stable placeholder bars; animation may be static no-op on API 24 if needed.
- [x] **Step 4: Implement `UPLineProgress`**
  - Support `percentage`, `activeColor`, `inactiveColor`, `height`, `showText`, `striped`, `stripedActive`, `duration`, `customStyle`.
  - Clamp percentage to 0..100.
- [x] **Step 5: Implement `UPLoadmore`**
  - Support `status`, `loadingText`, `loadmoreText`, `nomoreText`, `icon`, `iconSize`, `fontSize`, `color`, `line`, `customStyle`.
  - Render stable `loadmore`/`loading`/`nomore` states and reuse `UPLoadingIcon` only for loading.

### Task 4: Add sample routes and demo pages

**Files:**
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Create: `sample/entry/src/main/ets/demos/LineDemo.ets`
- Create: `sample/entry/src/main/ets/demos/GapDemo.ets`
- Create: `sample/entry/src/main/ets/demos/LinkDemo.ets`
- Create: `sample/entry/src/main/ets/demos/TitleDemo.ets`
- Create: `sample/entry/src/main/ets/demos/BadgeDemo.ets`
- Create: `sample/entry/src/main/ets/demos/DividerDemo.ets`
- Create: `sample/entry/src/main/ets/demos/SkeletonDemo.ets`
- Create: `sample/entry/src/main/ets/demos/LineProgressDemo.ets`
- Create: `sample/entry/src/main/ets/demos/LoadmoreDemo.ets`
- Test: `scripts/test_foundation_display_contract.py`, `scripts/test_sample_contract.py`

**Interfaces:**
- Consumes: newly exported 2A components and existing sample scaffold.
- Produces: visible Chinese examples under `Components A` without direct library internals imports.

- [x] **Step 1: Add catalog items**
  - Append deterministic Chinese titles/descriptions for all 2A routes.
- [x] **Step 2: Add route switch cases**
  - Extend `SamplePage.ets` so every new route renders its matching demo.
- [x] **Step 3: Add demos**
  - Each demo imports only from `@lingyun/ultra-ui-hos`, uses explicit typed callbacks, and avoids remote images/network behavior.
- [x] **Step 4: Run sample contracts**
  - Run: `python3 scripts/test_foundation_display_contract.py && python3 scripts/test_sample_contract.py`.

### Task 5: Documentation and full verification

**Files:**
- Modify: `README.md`
- Create/Modify: `docs/compatibility/phase-2a.md`
- Modify: `docs/compatibility/phase-1.md` only if cross-phase wording needs clarification.

**Interfaces:**
- Consumes: final source tree and fresh verification output.
- Produces: user-facing list of actually completed 2A components and honest device validation status.

- [x] **Step 1: Update docs**
  - Add `阶段 2A` component list, build command, HAR dependency note, and device screenshot limitation.
- [x] **Step 2: Run static contracts**
  - Run all Python scripts in `scripts/test_*.py`, `scripts/verify-boundaries.sh`, `scripts/verify-toolchain.sh`, and `git diff --check`.
- [x] **Step 3: Run build**
  - Run `./scripts/build.sh`; inspect HAR/HAP packaging for `resources/rawfile/upicon.ttf` still present.
- [x] **Step 4: Report evidence**
  - Only claim passing/complete with fresh command outputs and list any skipped device-only checks.
