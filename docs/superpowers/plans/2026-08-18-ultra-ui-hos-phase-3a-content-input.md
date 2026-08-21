# HarmonyOS NEXT UltraUI Phase 3A Content and Input Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在纯 ArkTS/ArkUI 的 HarmonyOS NEXT HAR 中实现 `UPText`、`UPImage`、`UPEmpty`、`UPLoadingPage`、`UPSearch` 和 `UPCodeInput`，并为每个组件提供可运行的示例和兼容性说明。

**Architecture:** 每个组件使用独立的 `Props`/`Options` 接口和 `@Component export struct`，复用现有 `UPTypes`、`UPStyle`、`UPUnit`、`UPColor`、`UPIcon`、`UPLoadingIcon` 与原生 `TextInput`/`Image`/`Progress`。所有状态由 ArkUI `@State`/`@Prop` 管理；远程图片、网络请求、WebView、运行时代码生成均不引入，无法在当前平台还原的字段保留接口并安全回退或通过诊断记录。

**Tech Stack:** HarmonyOS NEXT API 24、目标/兼容 SDK `5.0.0(12)`、ArkTS、ArkUI、Hvigor、Python 静态契约脚本。

## Global Constraints

- HAR 包名：`@lingyun/ultra-ui-hos`；示例 HAP：`net.lingyun.ultraui.hos.sample`。
- 组件必须是原生 ArkTS/ArkUI，不得出现 `WebView`、Vue、FastView、`.xyfv`、网络请求或远程资源加载器。
- `modelValue` 优先于 `value`；非法颜色、尺寸、形状、布局和枚举值必须安全回退，不抛异常。
- 图片只允许本地资源形式（`resource://`、`file://`、绝对路径、`$rawfile:`）；其他地址显示确定性占位内容。
- 所有新公开符号必须从 `ultra-ui/Index.ets` 导出，示例只能从 HAR 公共入口导入。
- 完成前必须运行阶段契约、全部既有契约、边界/工具链检查、截图脚本、`git diff --check` 和 `./scripts/build.sh`。

### Task 1: Add the failing phase 3A contract

**Files:**
- Create: `scripts/test_phase_3a_content_input_contract.py`
- Create: `docs/compatibility/phase-3a.md` (skeleton is added only after the red test is established)
- Reference: existing `scripts/test_phase_2c_form_selection_contract.py`

**Interfaces:**
- The contract checks public source shape, required props/events, local-image and no-network boundaries, six demo files, catalog routes, page dispatch, public exports, and compatibility-note phrases.

- [ ] **Step 1: Write the failing static contract**

  Assert the six component files and public `Props`/`Options` types exist, required fields and event names are present, each route has a catalog item and `SamplePage` branch, and each demo imports `@lingyun/ultra-ui-hos`. Assert forbidden strings (`WebView`, `FastView`, `.xyfv`, `http://`, `https://`, `@ohos.net`, `request(`) are absent. Assert default values that are part of the cross-platform contract are represented in source.

- [ ] **Step 2: Run the contract before implementations**

  Run:

  ```bash
  python3 scripts/test_phase_3a_content_input_contract.py
  ```

  Expected: FAIL because the six component files, public exports, routes, demos and phase note do not yet exist.

### Task 2: Implement text, media and loading state components

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPText.ets`
- Create: `ultra-ui/src/main/ets/components/UPImage.ets`
- Create: `ultra-ui/src/main/ets/components/UPEmpty.ets`
- Create: `ultra-ui/src/main/ets/components/UPLoadingPage.ets`
- Modify: `ultra-ui/Index.ets`

**Interfaces:**
- `UPTextProps` preserves `type`, `show`, `text`, `prefixIcon`, `suffixIcon`, `mode`, `href`, `format`, `call`, `openType`, `bold`, `block`, `lines`, `color`, `size`, `iconStyle`, `decoration`, `margin`, `lineHeight`, `align`, `wordWrap`, `flex1`, `customStyle`, and callbacks `onClick`, `onOpen`, `onCall`.
- `UPImageProps` preserves `src`, `mode`, `width`, `height`, `shape`, `radius`, `lazyLoad`, `showMenuByLongpress`, `loadingIcon`, `errorIcon`, `showLoading`, `showError`, `fade`, `webp`, `duration`, `bgColor`, `customStyle`, and `onClick`.
- `UPEmptyProps` preserves `icon`, `text`, `textColor`, `textSize`, `iconColor`, `iconSize`, `mode`, `width`, `height`, `show`, `marginTop`, `customStyle`.
- `UPLoadingPageProps` preserves `loadingText`, `image`, `loadingMode`, `loading`, `bgColor`, `color`, `fontSize`, `iconSize`, `loadingColor`, `zIndex`, `customStyle`.

- [ ] **Step 1: Add explicit ArkTS props and safe conversion helpers**

  Use the existing `UPRawValue`/`UPStyleInput` types and constructors. Resolve text/value fields with deterministic string conversion, dimensions through `UPUnit`, colors through `UPColor`, and style overrides through `UPStyle.parse`.

- [ ] **Step 2: Render `UPText` natively**

  Hide when `show` is false. Format `price`/`phone`/`name`/`date` modes conservatively, map alignment/decoration/word-wrap to ArkUI, cap line count, render optional prefix/suffix `UPIcon`, and invoke callbacks without opening URLs or placing calls automatically. Report unsupported `openType`/unsupported enum values through diagnostics.

- [ ] **Step 3: Render `UPImage` with local-only source handling**

  Render a local `Image` for approved source prefixes; otherwise render a deterministic background plus error/placeholder icon. Honor dimensions, aspect mode, square/circle/round shape and radius, loading/error visibility, background color, style dimensions and click callback. Never attempt network access.

- [ ] **Step 4: Render `UPEmpty` and `UPLoadingPage`**

  `UPEmpty` renders mode-aware local icon fallback and text, and collapses to zero size when hidden. `UPLoadingPage` renders only while loading, fills its parent with a safe background, uses `UPLoadingIcon`/`Progress`, preserves loading text and safe mode fallback, and reports image/network limitations.

- [ ] **Step 5: Export all public symbols and compile the HAR**

  Add all props/options/events to `ultra-ui/Index.ets`, then run `./scripts/build.sh`. Fix only compiler-confirmed ArkTS issues while retaining explicit types and avoiding undeclared object literals.

### Task 3: Implement search and code input components

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPSearch.ets`
- Create: `ultra-ui/src/main/ets/components/UPCodeInput.ets`
- Modify: `ultra-ui/Index.ets`

**Interfaces:**
- `UPSearchProps` preserves `modelValue`, `value`, `shape`, `bgColor`, `placeholder`, `clearabled`, `onlyClearableOnFocused`, `focus`, `showAction`, `actionText`, `label`, `inputAlign`, `disabled`, `animation`, `borderColor`, `searchIconColor`, `searchIconSize`, `color`, `placeholderColor`, `searchIcon`, `margin`, `iconPosition`, `maxlength`, `height`, `adjustPosition`, `autoBlur`, `inputStyle`, `actionStyle`, `customStyle`; events: `onInput`, `onChange`, `onClear`, `onSearch`, `onCustom`, `onFocus`, `onBlur`, `onClick`, `onClickIcon`.
- `UPCodeInputProps` preserves `adjustPosition`, `maxlength`, `dot`, `mode`, `hairline`, `space`, `modelValue`, `value`, `focus`, `bold`, `color`, `fontSize`, `size`, `disabledKeyboard`, `borderColor`, `disabledDot`, `customStyle`; events: `onInput`, `onChange`, `onFinish`.

- [ ] **Step 1: Add explicit props, event types and source-value resolution**

  Resolve controlled values with `modelValue ?? value`, enforce `maxlength`, and retain exact upstream spelling `clearabled`. Use local state only for user edits and emit string payloads.

- [ ] **Step 2: Render `UPSearch` with native input controls**

  Compose icon, label, `TextInput`, clear affordance and optional action button in ArkUI. Respect disabled/focus/alignment/shape/height/margins, use safe enum fallbacks, and emit every declared callback at the corresponding interaction. `autoBlur` may clear focus; `adjustPosition` remains a compatibility field and must not trigger unsupported APIs.

- [ ] **Step 3: Render `UPCodeInput` as native hidden input plus cells**

  Use a hidden/native `TextInput` for keyboard input and a deterministic `ForEach` of cells for display. Support `box`/`line`, spacing, hairline, bold, color, active focus indicator, dot masking and `disabledDot`; emit input/change and finish exactly at max length. `disabledKeyboard` disables the native input without throwing.

- [ ] **Step 4: Build the HAR and resolve ArkTS diagnostics**

  Run `./scripts/build.sh`, inspect full compiler output, and adjust syntax/types only where required by the HarmonyOS compiler.

### Task 4: Add examples, routes and compatibility documentation

**Files:**
- Create: `sample/entry/src/main/ets/demos/TextDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ImageDemo.ets`
- Create: `sample/entry/src/main/ets/demos/EmptyDemo.ets`
- Create: `sample/entry/src/main/ets/demos/LoadingPageDemo.ets`
- Create: `sample/entry/src/main/ets/demos/SearchDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CodeInputDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `README.md`
- Create: `docs/compatibility/phase-3a.md`
- Modify: `scripts/test_documentation_contract.py`

**Interfaces:**
- Routes: `text`, `image`, `empty`, `loading-page`, `search`, `code-input`.
- Each demo uses only public HAR imports and demonstrates controlled state/events plus at least one safe fallback or disabled state.

- [ ] **Step 1: Add demos and catalog entries**

  Follow existing `@Component`/`build()` patterns, use explicit callback return types, and avoid imports from `ultra-ui/src`.

- [ ] **Step 2: Add route dispatch branches**

  Import the six demos into `SamplePage` and render the matching demo for each route.

- [ ] **Step 3: Add compatibility note and update README/documentation contract**

  Document API 24/SDK `5.0.0(12)`, implemented props, local-only image behavior, no-op/diagnostic limitations, and the fact that device screenshots remain `skipped` without a connected device. Update component count and route/component list.

- [ ] **Step 4: Run the phase contract**

  Run:

  ```bash
  python3 scripts/test_phase_3a_content_input_contract.py
  python3 scripts/test_documentation_contract.py
  ```

  Expected: both PASS.

### Task 5: Full verification

**Files:**
- No additional source files; verify all files above.

- [ ] **Step 1: Run every Python contract**

  ```bash
  for f in scripts/test_*.py; do python3 "$f" || exit 1; done
  ```

- [ ] **Step 2: Run boundary, toolchain, screenshot and whitespace checks**

  ```bash
  ./scripts/verify-boundaries.sh
  ./scripts/verify-toolchain.sh
  ./scripts/capture-screenshots.sh
  git diff --check
  ```

- [ ] **Step 3: Build HAR and HAP**

  ```bash
  ./scripts/build.sh
  ```

  Confirm the resource contract still finds `upicon.ttf` in both outputs. Record any expected unsigned-signing or no-device warnings without calling them device verification.

- [ ] **Step 4: Review the final diff against the requirements**

  Check public exports, exact upstream spellings, no network/WebView strings, route coverage, docs count, and compiler output before reporting status.
