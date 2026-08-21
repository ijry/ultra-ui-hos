# ultra-ui-hos Phase 6 List and Index Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 HarmonyOS NEXT 原生 HAR 中增加 `UPList`、`UPListItem`、`UPIndexList`、`UPIndexItem`、`UPIndexAnchor` 和 `UPScrollList`，并交付六个只通过公共 HAR 入口导入的本地示例页面。

**Architecture:** 采用 Builder 容器与 ArkUI 原生滚动状态。`UPList` 和 `UPIndexList` 使用独立 `Scroller` 的原生 `List`，由内部上下文为子项分配确定性顺序并处理锚点/索引请求；`UPScrollList` 使用横向 `Scroll` 并根据可获得的尺寸计算指示器。页面持有 `current`、刷新状态和提示文案，组件只通过可选回调发出请求。

**Tech Stack:** ArkTS V1、ArkUI NEXT Stage 模型、HarmonyOS API 24、目标/兼容 SDK `5.0.0(12)`、HAR 公共入口、Python 静态契约脚本、Hvigor。

## Global Constraints

- HarmonyOS NEXT Stage 模型，最低兼容 API 为 24，产品兼容和目标 SDK 为 `5.0.0(12)`。
- 组件库包名保持 `@lingyun/ultra-ui-hos`；所有稳定 API 只从 `ultra-ui/Index.ets` 导出。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入，不允许访问 `ultra-ui/src` 内部路径。
- 不使用 WebView、FastView、Vue/NVue、网络请求、远程资源、运行时代码生成或 JSON 组件映射。
- 使用现有 `UPRawValue`、`UPStyleInput`、`UPUnit`、`UPColor`、`UPStyle` 和兼容诊断机制；非法值安全回退，不抛异常。
- 页面持有受控状态；组件可以持有滚动位置等瞬时原生状态，但不得形成与页面 Props 冲突的第二份业务状态。
- `UPIndexItem` 同时具有 `headerBuilder` 与 `contentBuilder`，调用方必须使用显式命名 Builder，不能使用尾随 lambda。
- `UPList`、`UPListItem`、`UPIndexList`、`UPScrollList` 的单内容 Builder 支持 ArkUI 尾随 Builder。
- `UPIndexList` 中 `null`、`undefined` 和空字符串不进入侧边索引；数字 `0` 是有效索引；重复字符串键只保留第一次。
- 无连接设备时，设备交互和截图验证必须标记为 `skipped`，不能写成通过。
- 不修改阶段 1 至阶段 5 的组件行为，也不清理与本阶段无关的现有脏工作区文件。
- 不创建 commit 或新分支；每个任务以专项契约、`git diff --check` 或构建检查作为本地验收点。

## File Map

本阶段新增和修改的文件如下。实现者必须只在这些阶段 6 文件和必要的现有入口/文档文件中工作。

### New HAR source files

- Create: `ultra-ui/src/main/ets/internal/UPListContexts.ets`，定义 `UPListContext`、`UPIndexListContext`、索引事件和上下文安全默认行为。
- Create: `ultra-ui/src/main/ets/components/UPList.ets`，纵向原生 `List`、阈值、滚动事件、受控滚动请求和刷新兼容字段。
- Create: `ultra-ui/src/main/ets/components/UPListItem.ets`，列表项内容 Builder、锚点注册和独立安全回退。
- Create: `ultra-ui/src/main/ets/components/UPIndexList.ets`，索引列表原生滚动容器、右侧索引、受控选择和分组内容 Builder。
- Create: `ultra-ui/src/main/ets/components/UPIndexItem.ets`，显式标题/内容 Builder、索引注册和默认 `UPIndexAnchor`。
- Create: `ultra-ui/src/main/ets/components/UPIndexAnchor.ets`，独立可用的默认索引标题条。
- Create: `ultra-ui/src/main/ets/components/UPScrollList.ets`，横向原生 `Scroll`、尺寸近似、边界事件和比例指示器。

### New sample and documentation files

- Create: `sample/entry/src/main/ets/demos/ListDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ListItemDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IndexListDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IndexItemDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IndexAnchorDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ScrollListDemo.ets`
- Create: `docs/compatibility/phase-6.md`，记录原生实现、原生近似、保留字段、无网络边界和设备验证状态。
- Create: `scripts/test_phase_6_list_index_contract.py`，阶段 6 静态契约和示例分发检查。

### Existing files to modify

- Modify: `ultra-ui/Index.ets`，从唯一公共入口导出六个组件、六个 Props/Options 类型和四个事件接口；不导出 `UPListContexts.ets`。
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`，加入 `Components J` 和六条固定路由。
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`，加入六个 Demo import、Builder 分发分支和标题映射。
- Modify: `README.md`，更新阶段 6 组件说明、目录分组、统计和兼容文档链接。
- Modify: `scripts/test_documentation_contract.py`，将阶段 6 组件、文档和 `69/67` 统计加入全量文档契约。
- Modify: `scripts/test_sample_contract.py` only when the existing shared route assertions require the new `Components J` routes; preserve all prior assertions.

## Public Interfaces

以下签名是任务间的唯一契约。实现时字段名、默认值和事件顺序必须与此处保持一致。

```ts
export interface UPListScrollEvent {
  offset: number;
  viewportSize: number;
  contentSize: number;
}

export interface UPIndexListSelectEvent {
  value: UPRawValue;
  index: number;
}

export type UPScrollListEdge = 'left' | 'right';

export interface UPScrollListEdgeEvent {
  edge: UPScrollListEdge;
  offset: number;
  maxOffset: number;
}

export interface UPScrollListScrollEvent {
  offset: number;
  maxOffset: number;
}
```

`UPListOptions`/`UPListProps` 必须包含：`showScrollbar`、`lowerThreshold`、`upperThreshold`、`scrollTop`、`offsetAccuracy`、`enableFlex`、`pagingEnabled`、`scrollable`、`scrollIntoView`、`scrollWithAnimation`、`enableBackToTop`、`height`、`width`、`preLoadScreen`、`refresherEnabled`、`refresherThreshold`、`refresherDefaultStyle`、`refresherBackground`、`refresherTriggered`、`customStyle`、`diagnostics?: UPCompatibilityDiagnostics`、`onScroll`、`onScrollToLower`、`onScrollToUpper`、`onRefresherRefresh` 和 `onRefresherTriggeredChange`。默认值必须分别为规格中的 `false`、`50`、`0`、`0`、`10`、`false`、`false`、`true`、`''`、`false`、`false`、`0`、`0`、`1`、`false`、`45`、`'black'`、`'#FFF'`、`false`、`undefined`、`undefined` 和未绑定回调。

`UPListItemOptions`/`UPListItemProps` 必须包含 `anchor`（默认 `''`）、`customStyle`（默认 `undefined`）和 `contentBuilder?: () => void`。

`UPIndexListOptions`/`UPIndexListProps` 必须包含 `inactiveColor`（`'#606266'`）、`activeColor`（`'#5677fc'`）、`indexList`（`[]`）、`current`（`undefined`）、`sticky`（`true`）、`showSidebar`（`true`）、`customNavHeight`（`0`）、`safeBottomFix`（`false`）、`itemMargin`（`'0rpx'`）、`customStyle`（`undefined`）、`diagnostics?: UPCompatibilityDiagnostics`（`undefined`）、`onSelect?: (event: UPIndexListSelectEvent) => void`、`onChange?: (event: UPIndexListSelectEvent) => void` 和 `onCurrentChange?: (value: UPRawValue) => void`。

`UPIndexItemOptions`/`UPIndexItemProps` 必须包含 `index`（默认 `''`）、`customStyle`（默认 `undefined`）、`headerBuilder?: () => void` 和 `contentBuilder?: () => void`。`UPIndexAnchorOptions`/`UPIndexAnchorProps` 必须包含 `text`（`''`）、`color`（`'#606266'`）、`size`（`14`）、`bgColor`（`'#f1f1f1'`）、`height`（`32`）和 `customStyle`（`undefined`）。

`UPScrollListOptions`/`UPScrollListProps` 必须包含 `indicatorWidth`（`50`）、`indicatorBarWidth`（`20`）、`indicator`（`true`）、`indicatorColor`（`'#f2f2f2'`）、`indicatorActiveColor`（`'#3c9cff'`）、`indicatorStyle`（`undefined`）、`customStyle`（`undefined`）、`diagnostics?: UPCompatibilityDiagnostics`（`undefined`）、`onLeft?: (event: UPScrollListEdgeEvent) => void`、`onRight?: (event: UPScrollListEdgeEvent) => void` 和 `onScroll?: (event: UPScrollListScrollEvent) => void`。普通滚动事件不包含伪造的 `edge` 字段。

### Task 1: Static contract and internal contexts

**Files:**
- Create: `scripts/test_phase_6_list_index_contract.py`
- Create: `ultra-ui/src/main/ets/internal/UPListContexts.ets`
- Read-only reference: `docs/superpowers/specs/2026-08-22-ultra-ui-hos-phase-6-list-index-design.md`
- Test against: the six component files, `ultra-ui/Index.ets`, `SampleCatalog.ets`, `SamplePage.ets`, `README.md`, and `docs/compatibility/phase-6.md`

**Interfaces:**
- Produces `UPListContext` with `beginComposition`, `itemIndex`, `registerAnchor`, `anchorIndex`, `requestScrollIntoView`, and `UPIndexListContext` with `beginComposition`, `itemIndex`, `normalizedItems`, `isActive`, `requestSelect`, and `requestScrollToIndex`.
- Produces `UPIndexListSelectEvent`, `UPScrollListEdgeEvent`, and `UPScrollListScrollEvent` for the public component files to re-export.
- Uses `UPRawValue`, `upBoolean`, `upNumber`, `upString`, `upValueKey`, `UPCompatibilityDiagnostics`, and `UP_SILENT_DIAGNOSTICS` only; it does not import ArkUI or own a page, route stack, or global singleton.

- [ ] **Step 1: Write the failing static contract.**

  Create `scripts/test_phase_6_list_index_contract.py` in the same style as `scripts/test_phase_5_navigation_contract.py`. Define `COMPONENTS`, `DEMOS`, `FORBIDDEN`, and `read(path)` helpers. Assert each component source contains its `Options`, `Props`, `export struct`, and required Builder/context/event tokens; assert each component has a matching `Index.ets` export; assert context tokens include `registerAnchor`, `normalizedItems`, `requestSelect`, duplicate handling, and safe defaults; assert all exact defaults listed in this plan; assert `UPIndexItem` contains two `@BuilderParam` fields; assert each route, Demo, `Components J`, and `SamplePage` branch exists; assert every Demo imports `@lingyun/ultra-ui-hos` and contains no `WebView`, `@kit.NetworkKit`, `http://`, `https://`, `vue`, `nvue`, or `ultra-ui/src`; assert README and phase 6 compatibility phrases include `69 个已实现组件/控制器`, `67 条组件示例路由`, `UPList`, `UPIndexList`, `UPScrollList`, `API 24`, `skipped`, and `no-op`.

  The first version must also check the explicit multi-Builder usage in `IndexItemDemo.ets` with `headerBuilder: this...` and `contentBuilder: this...`, and reject a trailing-lambda pattern after `UPIndexItem(...)`.

- [ ] **Step 2: Run the new contract before implementation.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  ```

  Expected: `AssertionError` for missing `UPList.ets` or another missing phase 6 artifact. Do not weaken the assertion to make this pre-implementation run pass.

- [ ] **Step 3: Implement deterministic safe-default contexts.**

  Add the following concrete behavior to `UPListContexts.ets`:

  ```ts
  export class UPListContext {
    grouped: boolean = false;
    private nextIndex: number = 0;
    private anchors: Map<string, number> = new Map<string, number>();
    private scrollRequest?: (index: number) => void;
    private pendingAnchor: string = '';
    private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

    beginComposition(scrollRequest?: (index: number) => void,
      diagnostics?: UPCompatibilityDiagnostics): void;
    itemIndex(): number;
    registerAnchor(anchor: UPRawValue, index: number): void;
    anchorIndex(anchor: UPRawValue): number;
    requestScrollIntoView(anchor: UPRawValue): void;
  }

  export class UPIndexListContext {
    grouped: boolean = false;
    private nextIndex: number = 0;
    private values: Array<UPRawValue> = [];
    private keys: Array<string> = [];
    private activeKey: string = '';
    private onSelect?: (event: UPIndexListSelectEvent) => void;
    private onChange?: (event: UPIndexListSelectEvent) => void;
    private onCurrentChange?: (value: UPRawValue) => void;
    private scrollRequest?: (index: number) => void;
    private diagnostics: UPCompatibilityDiagnostics = UP_SILENT_DIAGNOSTICS;

    beginComposition(values: Array<UPRawValue>, current: UPRawValue,
      onSelect?: (event: UPIndexListSelectEvent) => void,
      onChange?: (event: UPIndexListSelectEvent) => void,
      onCurrentChange?: (value: UPRawValue) => void,
      scrollRequest?: (index: number) => void,
      diagnostics?: UPCompatibilityDiagnostics): void;
    itemIndex(value: UPRawValue): number;
    normalizedItems(): Array<UPRawValue>;
    isActive(value: UPRawValue): boolean;
    requestSelect(index: number): void;
    requestScrollToIndex(value: UPRawValue): void;
  }
  ```

  `UPListContext.beginComposition` resets `nextIndex` and the anchor map, stores the parent diagnostics sink, and retains an unresolved `pendingAnchor` long enough for child registration. `itemIndex` returns the current value and then increments it. `registerAnchor` ignores nullish/empty anchors, keeps the first string key, reports duplicates through the injected diagnostics sink, and immediately executes/clears a matching pending request. `anchorIndex` returns `-1` when not found. `requestScrollIntoView` stores a non-empty unresolved key instead of dropping it; when already registered it scrolls immediately and clears any prior pending key. The safe default context never throws when no scroll callback exists.

  `UPIndexListContext.beginComposition` stores the injected diagnostics sink, filters nullish/empty values, preserves numeric `0`, converts keys with `String(value)`, keeps the first duplicate, reports duplicate keys once, and stores the current key only when it matches a normalized item. `requestSelect` ignores invalid indices, calls `onSelect` first, calls `onChange` only when the selected key differs from `activeKey`, calls `onCurrentChange` third, then calls `scrollRequest`. The default context remains safe when no parent provides it.

- [ ] **Step 4: Run the context-focused static checks.**

  Run:

  ```bash
  python3 -m py_compile scripts/test_phase_6_list_index_contract.py
  rg -n "UPListContext|UPIndexListContext|registerAnchor|normalizedItems|requestSelect|duplicate" ultra-ui/src/main/ets/internal/UPListContexts.ets scripts/test_phase_6_list_index_contract.py
  ```

  Expected: Python compilation succeeds and every required context token is present. The full contract remains failing until the component and sample files exist.

### Task 2: Vertical list containers

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPList.ets`
- Create: `ultra-ui/src/main/ets/components/UPListItem.ets`
- Create: `sample/entry/src/main/ets/demos/ListDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ListItemDemo.ets`
- Modify: `ultra-ui/src/main/ets/internal/UPListContexts.ets`

**Interfaces:**
- Consumes `UPListContext` from Task 1 and the exact `UPListOptions`/`UPListProps`, `UPListItemOptions`/`UPListItemProps`, and `UPListScrollEvent` signatures defined above.
- Produces `@Provide('UPListContext')` from `UPList` and `@Consume('UPListContext')` from `UPListItem`; both components render safely when the context is not grouped.
- `UPList` invokes `onScroll`, `onScrollToUpper`, `onScrollToLower`, `onRefresherRefresh`, and `onRefresherTriggeredChange` only when the corresponding condition is reached; no callback is required for rendering.

- [ ] **Step 1: Extend the static contract for vertical defaults and event tokens.**

  Add assertions for every `UPListProps` default, the five callback names, `Scroller`, `List`, `scrollTo`, `scrollToIndex`, `onScroll`, `onReachStart`, `onReachEnd`, `enableScrollInteraction`, `UPListContext`, and `UPListItem` anchor registration. Add assertions for `ListDemo.ets` state variables and `ListItemDemo.ets` anchor/content Builder usage.

- [ ] **Step 2: Run the vertical contract and record the expected failure.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  ```

  Expected: failure naming the missing `UPList.ets` or `UPListProps` default. The test must fail because implementation is absent, not because of an invalid Python expression.

- [ ] **Step 3: Implement `UPListProps` and `UPList`.**

  Follow existing `Options -> Props -> @Component` patterns. Parse numeric thresholds with finite, non-negative fallbacks (`50`, `0`, `10`, `45`), dimensions with `UPUnit.parse`, colors/styles with `UPColor`/`UPStyle`, and booleans with `upBoolean`. Preserve `enableFlex`, `pagingEnabled`, `enableBackToTop`, `preLoadScreen`, and refresher visual fields; report `pagingEnabled`, `enableBackToTop`, `preLoadScreen`, and unsupported refresher visual behavior through the optional diagnostics sink without throwing.

  Render one `List({ scroller: this.scroller })` and invoke `contentBuilder()` directly inside it; do not wrap the complete Builder in one `ListItem`. Apply `scrollBar(BarState.On/Off)`, `enableScrollInteraction`, vertical list layout, width/height/style, and `onScroll`/`onReachStart`/`onReachEnd`. Keep `lastOffset`, `lastUpperState`, and `lastLowerState` as transient component fields solely for offset filtering and threshold de-duplication. Build each `UPListScrollEvent` with non-negative `offset`, measured `viewportSize` when available, and `contentSize` or `0` when unavailable.

  Put initial `scrollTop` and `scrollIntoView` requests in the mounted List callback, because the SDK declaration warns that `Scroller` calls before the scrollable child exists are ineffective. Use `scroller.scrollTo({ xOffset: 0, yOffset: value, animation: props.scrollWithAnimation })` for `scrollTop`; route `scrollIntoView` through `UPListContext.requestScrollIntoView`. If the parent callback occurs before child registration, the context retains the pending anchor and `registerAnchor` later calls `scroller.scrollToIndex(index, smooth)` before clearing it. The context callback must not access page state.

  Use `List` reach callbacks as native signals and gate them by entering/leaving the configured threshold state. `onRefresherRefresh` is a request-only compatibility path: it calls the page callback and `onRefresherTriggeredChange(true)` when enabled, and never mutates `props.refresherTriggered` internally. A `scrollable: false` list still renders all Builder content.

- [ ] **Step 4: Implement `UPListItem`.**

  Define `UPListItemProps` with `anchor` and `customStyle`, inject `@Consume('UPListContext')` with `new UPListContext()` fallback, assign `index` in `aboutToAppear`, and register the anchor after assignment. When `context.grouped` is true, render one native `ListItem` containing `Column() { this.contentBuilder() }`; only the standalone fallback renders the `Column` directly. Apply parsed width/padding in both paths. The standalone path must show content without attempting to scroll or emit events.

  Use exactly one `@BuilderParam contentBuilder: () => void` with an empty Builder fallback. Do not add a data array, JSON parser, generic item callback, global registry, or route dependency.

- [ ] **Step 5: Add vertical demos using page-owned state.**

  `ListDemo` must import only `UPList`, `UPListItem`, and public Props/events from `@lingyun/ultra-ui-hos`; keep fixed local rows, `@State` message, and `@State` refresher flag. Show `scrollTop`, `scrollIntoView`, thresholds, `onScroll`, upper/lower callbacks, and request-only refresh status. `ListItemDemo` must show a standalone item and a grouped `UPList` with non-empty anchors, using a trailing Builder only for the single-content components.

- [ ] **Step 6: Run the vertical checks and formatting check.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  git diff --check
  ```

  Expected: all vertical assertions pass; any failure must identify a missing interface/default/route token. The command must not report whitespace errors.

### Task 3: Index list, groups, and anchors

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPIndexList.ets`
- Create: `ultra-ui/src/main/ets/components/UPIndexItem.ets`
- Create: `ultra-ui/src/main/ets/components/UPIndexAnchor.ets`
- Create: `sample/entry/src/main/ets/demos/IndexListDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IndexItemDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IndexAnchorDemo.ets`
- Modify: `ultra-ui/src/main/ets/internal/UPListContexts.ets`

**Interfaces:**
- Consumes `UPIndexListContext` and `UPIndexListSelectEvent` from Task 1, plus the exact index component Props/Options signatures above.
- Produces `@Provide('UPIndexListContext')` from `UPIndexList`, `@Consume('UPIndexListContext')` from `UPIndexItem`, and standalone `UPIndexAnchor` rendering.
- Preserves raw callback values while using `String(value)` only for matching and duplicate detection.

- [ ] **Step 1: Extend the static contract for index defaults and Builder rules.**

  Assert all `UPIndexListProps`, `UPIndexItemProps`, and `UPIndexAnchorProps` defaults. Assert `UPIndexListSelectEvent` fields `value` and `index`, context calls `requestSelect`/`requestScrollToIndex`, `showSidebar`, `sticky`, `safeBottomFix`, `customNavHeight`, `itemMargin`, and index normalization tokens. Assert each index Demo contains local A/B/C data, controlled `current` where appropriate, and no trailing lambda following `UPIndexItem(...)`.

- [ ] **Step 2: Run the index contract and record the expected failure.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  ```

  Expected: failure naming the first missing index file or default. Keep the assertions strict so a component cannot pass by merely defining a name without behavior tokens.

- [ ] **Step 3: Implement `UPIndexAnchor`.**

  Render a full-width `Row` with left-aligned text, parsed `height`, parsed `size`, `color`, `bgColor`, and custom style. Use `32` for invalid or non-positive height and `14` for invalid size. Convert nullish text to `''`; preserve numeric `0` as `'0'`. The component must not consume an index context and must be independently renderable.

- [ ] **Step 4: Implement `UPIndexItem` with explicit named Builders.**

  Define `headerBuilder` and `contentBuilder` as separate `@BuilderParam` fields with empty Builder fallbacks. Consume `UPIndexListContext`, assign a stable group index in `aboutToAppear`, and call `itemIndex(this.props.index)` to register the normalized group value. Resolve a `CustomBuilder` that renders `UPIndexAnchor({ props: new UPIndexAnchorProps({ text: this.props.index }) })` when no custom header Builder is supplied and otherwise invokes the named header Builder. When `context.grouped` is true, render `ListItemGroup({ header: this.resolvedHeaderBuilder }) { ListItem() { Column() { this.contentBuilder() } } }`; the header must be passed through `ListItemGroupOptions.header`, and the content Builder must be wrapped by one native `ListItem`. Only the standalone fallback renders an ordinary `Column` containing the resolved header and content. Sticky behavior is configured by the parent `List.sticky`, not on `ListItemGroup` itself.

- [ ] **Step 5: Implement `UPIndexList`.**

  Normalize `indexList` in the context, start a native vertical `List({ scroller: this.scroller })`, and invoke its single `contentBuilder()` directly inside the list so each grouped child is a native `ListItemGroup`. Use the context's `requestScrollToIndex` callback to locate the first matching `UPIndexItem` and call `scrollToIndex(groupIndex, false/true, ..., extraOffset)` when `customNavHeight > 0`; clamp negative compensation to `0`. Do not claim automatic visible-group tracking or index drag gestures.

  Render the right sidebar only when `showSidebar` is true and normalized items are non-empty. Each item is a stable-height clickable `Text` using `activeColor`/`inactiveColor`, parsed `itemMargin`, and optional bottom safe spacing. A click uses the context's fixed event order: `onSelect`, conditional `onChange`, `onCurrentChange`, then scroll. An unresolved controlled `current` is not highlighted and does not trigger an implicit page update; with no `current`, the first normalized item may display as the initial visual activity without mutating the caller.

  Apply `List.sticky(StickyStyle.Header)` when `sticky` is true and `StickyStyle.None` when false; `UPIndexItem` remains responsible only for the native `ListItemGroup`. Retain `customStyle` width/padding. `safeBottomFix` is a layout-only spacing request; when no system safe-area metric is available, use zero extra inset and document the fallback.

- [ ] **Step 6: Add index demos with explicit multi-Builder calls.**

  `IndexListDemo` must use fixed local A/B/C groups, a page-owned `@State current: UPRawValue`, and `UPIndexList({ props: ... }) { ... }` with `UPIndexItem` calls that pass `headerBuilder: this...` and `contentBuilder: this...` explicitly. Show selected value/index in local text and update `current` only from `onCurrentChange`.

  `IndexItemDemo` must show one standalone/default-header group and one grouped item with explicit `headerBuilder` and `contentBuilder` properties. `IndexAnchorDemo` must show default values plus custom color, font size, background, height, and local style. None of the three pages may use network content or internal library imports.

- [ ] **Step 7: Run index checks and inspect Builder syntax.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  rg -n "UPIndexItem\(|headerBuilder:|contentBuilder:" sample/entry/src/main/ets/demos/Index*.ets
  git diff --check
  ```

  Expected: all index static checks pass, every multi-Builder call uses named bindings, and `git diff --check` is clean.

### Task 4: Horizontal scroll list and indicator

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPScrollList.ets`
- Create: `sample/entry/src/main/ets/demos/ScrollListDemo.ets`

**Interfaces:**
- Consumes `UPScrollListOptions`/`UPScrollListProps`, `UPScrollListScrollEvent`, `UPScrollListEdgeEvent`, `UPStyle`, `UPUnit`, and the ArkUI `Scroller`/`Scroll` declarations.
- Produces one `@BuilderParam contentBuilder`, an `onScroll` callback with the scroll event shape, and `onLeft`/`onRight` callbacks with the edge event shape.

- [ ] **Step 1: Extend the static contract for horizontal behavior.**

  Assert all indicator defaults, `Scroller`, horizontal `ScrollDirection.Horizontal`, `indicator`, `indicatorColor`, `indicatorActiveColor`, `onScroll`, `onLeft`, `onRight`, `contentSize`, `currentOffset`, and the clamped progress formula tokens. Assert `ScrollListDemo` includes fixed local cards and both edge callbacks.

- [ ] **Step 2: Run the horizontal contract and record the expected failure.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  ```

  Expected: failure for missing `UPScrollList.ets` or its required default. Do not mark horizontal work complete from a route-only placeholder.

- [ ] **Step 3: Implement `UPScrollListProps` and horizontal scrolling.**

  Parse `indicatorWidth` as a non-negative number with fallback `50`, clamp `indicatorBarWidth` to `0...indicatorWidth` with fallback `20`, and parse colors/styles through existing helpers. Render a root `Stack` containing a horizontal `Scroll({ scroller: this.scroller })` with `contentBuilder` and an optional indicator track. Apply `scrollBar(BarState.Off)`, `enableScrollInteraction(true)`, and width/height/style from `customStyle`.

  On scroll, read `scroller.currentOffset().xOffset` and `scroller.contentSize().width` when the SDK returns them; clamp offset and max offset to non-negative values, compute `progress = maxOffset > 0 ? clamp(offset / maxOffset, 0, 1) : 0`, and compute `barOffset = progress * Math.max(indicatorWidth - indicatorBarWidth, 0)`. Store only these transient measurements for rendering. If measurement is unavailable, use `0` and leave the indicator at its origin.

  Keep a transient edge state. Entering `offset <= 0` calls `onLeft` once with `{ edge: 'left', offset, maxOffset }`; entering `maxOffset > 0 && offset >= maxOffset` calls `onRight` once with `{ edge: 'right', offset, maxOffset }`; staying at an edge does not repeat; moving into the middle clears the edge state. `onScroll` receives only `{ offset, maxOffset }` on each accepted scroll callback. All callbacks are optional and never cause implicit navigation.

- [ ] **Step 4: Add the horizontal demo.**

  `ScrollListDemo` must use a fixed local array of card labels, a page-owned status string, `UPScrollList` with a trailing content Builder, and `onScroll`/`onLeft`/`onRight` callbacks. Display the status below the component so indicator movement and edge requests are observable without test-only UI.

- [ ] **Step 5: Run the horizontal checks.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  git diff --check
  ```

  Expected: the phase 6 static contract passes for all six components and all six demos; no whitespace errors are reported.

### Task 5: Public exports, sample routing, documentation, and compatibility

**Files:**
- Modify: `ultra-ui/Index.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `README.md`
- Create: `docs/compatibility/phase-6.md`
- Modify: `scripts/test_documentation_contract.py`
- Modify: `scripts/test_sample_contract.py` only if route-count/shared-route assertions need phase 6 entries

**Interfaces:**
- Exports all public Phase 6 Props/Options/components/events from `ultra-ui/Index.ets` and no internal contexts.
- Adds exactly these routes and demo filenames: `list`/`ListDemo.ets`, `list-item`/`ListItemDemo.ets`, `index-list`/`IndexListDemo.ets`, `index-item`/`IndexItemDemo.ets`, `index-anchor`/`IndexAnchorDemo.ets`, and `scroll-list`/`ScrollListDemo.ets`.
- Produces the documentation contract phrases and final statistics: `69 个已实现组件/控制器（68 个组件 + 1 个控制器）` and `67 条组件示例路由`.

- [ ] **Step 1: Add public HAR exports.**

  Add named exports in `ultra-ui/Index.ets` for:

  ```ts
  UPList, UPListProps, UPListOptions, UPListScrollEvent,
  UPListItem, UPListItemProps, UPListItemOptions,
  UPIndexList, UPIndexListProps, UPIndexListOptions, UPIndexListSelectEvent,
  UPIndexItem, UPIndexItemProps, UPIndexItemOptions,
  UPIndexAnchor, UPIndexAnchorProps, UPIndexAnchorOptions,
  UPScrollList, UPScrollListProps, UPScrollListOptions,
  UPScrollListEdge, UPScrollListEdgeEvent, UPScrollListScrollEvent
  ```

  Do not export `UPListContext` or `UPIndexListContext`. Preserve the existing export order and style.

- [ ] **Step 2: Add catalog routes and SamplePage dispatch.**

  Append `Components J` to `SAMPLE_GROUPS` with six `SampleItem` entries and fixed Chinese descriptions. Import all six Demo structs in `SamplePage.ets`; add six `else if` Builder branches; add six `title()` cases. Keep the existing route behavior and default fallback unchanged.

- [ ] **Step 3: Write the phase 6 compatibility note.**

  Document API 24 and SDK `5.0.0(12)`, the six components, Builder-only content ownership, page-controlled state, local deterministic sample data, and the following capability table:

  | Capability | Status |
  | --- | --- |
  | `UPList` vertical scrolling, thresholds, `scrollTop`, `scrollIntoView` | native ArkUI List/Scroller or native approximation where item measurement is unavailable |
  | `UPList` refresher fields and visuals | request-only compatibility path; animation is no-op |
  | `UPIndexList` click selection and first-match scroll | native List/Scroller approximation |
  | `UPIndexList` sticky group header | native `List.sticky(StickyStyle.Header)` with `ListItemGroup` headers; ordinary header fallback otherwise |
  | continuous index drag/bubble/haptics | no-op and explicitly outside this phase |
  | `UPScrollList` horizontal scrolling and indicator | native Scroll with measured-size approximation; zero-size fallback keeps indicator at origin |
  | network, WebView, Vue/NVue, runtime JSON mapping | prohibited |

  Include `no-op`, `设备验证`, and `skipped` wording. State that no connected device means interaction and screenshots are `skipped`, not passing.

- [ ] **Step 4: Update README statistics and links.**

  Change the top summary from 63 to 69 components/controllers with the exact breakdown `68 个组件 + 1 个控制器`; change the sample count from 61 to 67; add the `Components J` list and link `docs/compatibility/phase-6.md`. Keep prior phase links and all build/toolchain instructions intact.

- [ ] **Step 5: Extend documentation/sample contracts.**

  Add phase 6 paths and required phrases to `scripts/test_documentation_contract.py`, preserving earlier phase assertions. Add only the new routes to `scripts/test_sample_contract.py` if its existing count or group assertions require them; do not remove or relax checks for previous samples.

- [ ] **Step 6: Run the complete static validation suite.**

  Run:

  ```bash
  python3 scripts/test_phase_6_list_index_contract.py
  for f in scripts/test_*.py; do python3 "$f" || exit 1; done
  ./scripts/verify-boundaries.sh
  ./scripts/verify-toolchain.sh
  git diff --check
  ```

  Expected: every Python contract and boundary check passes. Toolchain checks may print `skipped` only when the documented local tool/device prerequisite is absent; this is not a reason to alter source code or call the check passed as device validation.

- [ ] **Step 7: Build HAR and sample app.**

  Run:

  ```bash
  ./scripts/build.sh
  ```

  Expected: HAR and sample HAP ArkTS compilation succeeds; only documented unsigned/signing warnings may remain. Fix compilation errors, missing exports, resource errors, and dependency-boundary errors before proceeding. Do not fix unrelated pre-existing failures.

- [ ] **Step 8: Run screenshot/device verification with explicit status.**

  Run:

  ```bash
  ./scripts/capture-screenshots.sh
  ```

  With a connected device or simulator, manually verify vertical scrolling, upper/lower one-shot callbacks, index sidebar clicks, group scroll, sticky approximation, horizontal indicator movement, and left/right one-shot callbacks. Without a device or simulator, record each interaction and screenshot result as `skipped` in the handoff; never describe it as passed.

## Self-Review Before Execution Handoff

- [ ] Scan the complete plan for `TBD`, `TODO`, `Similar to Task`, `implement later`, and vague instructions such as `add appropriate handling`; replace every occurrence with a concrete file, token, signature, command, or expected result.
- [ ] Compare every default in `Public Interfaces` with sections 5.1 through 5.6 of `docs/superpowers/specs/2026-08-22-ultra-ui-hos-phase-6-list-index-design.md`.
- [ ] Verify event type consistency: `UPListScrollEvent` contains three numeric fields; `UPIndexListSelectEvent` contains raw `value` plus numeric `index`; `UPScrollListScrollEvent` contains only `offset` and `maxOffset`; `UPScrollListEdgeEvent` additionally contains `edge`; index event ordering remains `onSelect`, conditional `onChange`, `onCurrentChange`, then scroll.
- [ ] Verify Builder consistency: one trailing `contentBuilder` for `UPList`, `UPListItem`, `UPIndexList`, and `UPScrollList`; two explicitly named BuilderParams for `UPIndexItem` in every sample call.
- [ ] Verify native child consistency: `UPList` and `UPIndexList` invoke content directly; grouped `UPListItem` renders `ListItem`; grouped `UPIndexItem` renders `ListItemGroup({ header: ... })` with one inner `ListItem` wrapping its content Builder; standalone paths render `Column`; sticky uses parent `List.sticky`.
- [ ] Verify diagnostics consistency: `UPList`, `UPIndexList`, and `UPScrollList` expose optional `diagnostics`; parent contexts use the injected sink; all other paths fall back to `UP_SILENT_DIAGNOSTICS`.
- [ ] Verify all spec sections have a task: file responsibilities (Tasks 1-4), props/events (Tasks 1-4), contexts and fallbacks (Tasks 1-3), six demos and routes (Tasks 2-4/5), compatibility note and statistics (Task 5), static/build/device validation (Task 5), and non-goals/global constraints (header and Task 5).
- [ ] Verify no task asks for a commit, branch, destructive cleanup, network resource, runtime JSON mapping, virtual list, waterfall, table, or unrelated phase change.

Plan complete and saved to `docs/superpowers/plans/2026-08-22-ultra-ui-hos-phase-6-list-index.md`. Two execution options:

1. **Subagent-Driven (recommended)** - dispatch a fresh worker per task and review between tasks.
2. **Inline Execution** - execute this plan in the current session with checkpoints.

Choose one execution approach before any Phase 6 implementation code is written.
