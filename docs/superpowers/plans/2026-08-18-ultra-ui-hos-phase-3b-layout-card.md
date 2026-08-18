# Phase 3B Layout and Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 HarmonyOS NEXT HAR 与中文 HAP 示例工程中交付 `UPRow`、`UPCol`、`UPGrid`、`UPGridItem`、`UPCard` 五个原生 ArkUI 组件，并让公开 API、示例路由、兼容文档和构建契约保持一致。

**Architecture:** 采用声明式父级上下文：`UPRow`/`UPGrid` 提供局部布局上下文，`UPCol`/`UPGridItem` 消费上下文并以原生 `Flex`/`Grid` 渲染；`UPCard` 使用原生 `Column` 分为头部、主体和底部。Props、Builder、样式解析和事件回调沿用当前 HOS 组件模式，所有兼容降级集中在内部布局辅助类和各组件的解析方法中。

**Tech Stack:** ArkTS/ArkUI、HarmonyOS API 24、产品/目标 SDK `5.0.0(12)`、HAR `@lingyun/ultra-ui-hos`、HAP 示例工程、Python 静态契约脚本、Hvigor。

## Global Constraints

- 在现有 checkout 中工作；不创建 worktree，不运行 `git reset`、`git clean`，不删除既有未跟踪文件。
- 库保持纯 ArkTS/ArkUI；不得引入 WebView、Vue/NVue、FastView、`.xyfv`、运行时代码生成、网络请求或业务状态存储。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入组件，禁止 `ultra-ui/src` 和其他内部源码路径。
- 组件只读取本地图片：`resource://`、`file://`、绝对路径和 `$rawfile:`；不增加远程图片加载器。
- 非法单位、颜色、枚举、形状和布局值必须安全回退，不得抛异常；不得把 `0`、`false`、空字符串或 `null` 当作缺失值。
- API 24 是最低兼容基线；不能无保护地依赖更高 API 的能力。
- 无连接 HarmonyOS 设备时，设备验证和截图必须输出 `skipped`，不得报告为通过。
- 每个任务只暂存自己负责的文件，避免把当前仓库已有阶段性未提交内容带入提交。

## File Map Before Editing

### New library files

- `ultra-ui/src/main/ets/internal/UPLayoutContexts.ets` — Row/Grid 的局部上下文、栅格索引和安全枚举/数值辅助，不从 `Index.ets` 导出。
- `ultra-ui/src/main/ets/components/UPRow.ets` — `UPRowOptions`、`UPRowProps`、`UPRow`。
- `ultra-ui/src/main/ets/components/UPCol.ets` — `UPColOptions`、`UPColProps`、`UPCol`。
- `ultra-ui/src/main/ets/components/UPGrid.ets` — `UPGridOptions`、`UPGridProps`、`UPGrid`。
- `ultra-ui/src/main/ets/components/UPGridItem.ets` — `UPGridItemOptions`、`UPGridItemProps`、事件类型和 `UPGridItem`。
- `ultra-ui/src/main/ets/components/UPCard.ets` — `UPCardOptions`、`UPCardProps`、区域类型/事件类型和 `UPCard`。

### New test/document files

- `scripts/test_phase_3b_layout_card_contract.py` — 分阶段扩展的静态契约测试，先覆盖 Row/Col，再覆盖 Grid/GridItem、Card、示例和文档。
- `docs/compatibility/phase-3b.md` — 布局与卡片的兼容范围、原生差异、资源限制和验证记录。
- `docs/superpowers/specs/2026-08-18-ultra-ui-hos-phase-3b-layout-card-design.md` — 已确认的设计基准，不在实现中改写其公开契约。

### Modified files

- `ultra-ui/Index.ets` — 增加五个组件及公开 Props/事件类型导出。
- `sample/entry/src/main/ets/catalog/SampleCatalog.ets` — 增加布局与卡片示例分组和五条路由。
- `sample/entry/src/main/ets/pages/SamplePage.ets` — 导入五个 Demo 并路由分发。
- `README.md` — 更新组件/路由计数和 Phase 3B 文档链接。

## Task 1: Establish the Row/Col Contract in Red

**Files:**
- Create: `scripts/test_phase_3b_layout_card_contract.py`
- Test: `scripts/test_phase_3b_layout_card_contract.py`

**Interfaces:**
- The first test slice checks that `UPRow.ets` and `UPCol.ets` expose the Props class, Options interface, component struct, required fields, defaults, Builder field, and public export.
- Later tasks extend this same script; do not create a second overlapping contract script.

- [ ] **Step 1: Write the failing Row/Col assertions**

Create a Python script with the same `Path`/`read()` style as the existing Phase 3A contract. Use exact constants rather than broad directory existence checks:

```python
ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / "ultra-ui/Index.ets"
COMP = ROOT / "ultra-ui/src/main/ets/components"

ROW_COL_FIELDS = {
    "UPRow": ("gutter", "justify", "align", "customStyle", "contentBuilder", "onClick"),
    "UPCol": ("span", "offset", "justify", "align", "textAlign", "customStyle", "contentBuilder", "onClick"),
}

ROW_COL_DEFAULTS = {
    "UPRow": (("gutter", "0"), ("justify", "'start'"), ("align", "'center'")),
    "UPCol": (("span", "12"), ("offset", "0"), ("justify", "'start'"),
              ("align", "'stretch'"), ("textAlign", "'left'")),
}
```

For each component, assert the concrete declarations `class UPRowProps`, `export interface UPRowOptions`, and `export struct UPRow`, every required field, and a default declaration matching the repository convention `field: UPRawValue = value`. Assert `UPRow`, `UPRowProps`, `UPRowOptions`, `UPCol`, `UPColProps`, and `UPColOptions` appear in `Index.ets`.

Also assert every source string avoids the forbidden tokens `WebView`, `FastView`, `.xyfv`, `http://`, `https://`, `@ohos.net`, and `request(`.

- [ ] **Step 2: Run the contract and verify the failure is for missing implementation**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
```

Expected result: a direct assertion failure naming the missing `UPRow.ets` or `UPCol.ets`, not a Python syntax/import error. Fix only the test script if the failure is caused by the test itself.

- [ ] **Step 3: Commit the red contract**

```bash
git add scripts/test_phase_3b_layout_card_contract.py
git commit -m "test: add phase 3b row and col contract"
```

## Task 2: Implement Row/Col and the Shared Layout Context

**Files:**
- Create: `ultra-ui/src/main/ets/internal/UPLayoutContexts.ets`
- Create: `ultra-ui/src/main/ets/components/UPRow.ets`
- Create: `ultra-ui/src/main/ets/components/UPCol.ets`
- Modify: `ultra-ui/Index.ets`
- Test: `scripts/test_phase_3b_layout_card_contract.py`

**Interfaces:**
- `UPLayoutContexts.ets` provides internal `UPRowLayoutContext` and `UPGridLayoutContext` classes. The Row context carries resolved gutter and the Grid context carries resolved columns, gap, border, alignment, and a render-local item index allocator.
- `UPRowOptions` fields are `gutter?: UPRawValue`, `justify?: UPRawValue`, `align?: UPRawValue`, `customStyle?: UPStyleInput`, `contentBuilder?: UPBuilder`, and `onClick?: () => void`.
- `UPColOptions` fields are `span?: UPRawValue`, `offset?: UPRawValue`, `justify?: UPRawValue`, `align?: UPRawValue`, `textAlign?: UPRawValue`, `customStyle?: UPStyleInput`, `contentBuilder?: UPBuilder`, and `onClick?: () => void`.
- `UPRow` publishes a row context with `@Provide`; `UPCol` consumes it with a zero-gutter fallback. No global mutable layout state is allowed.

- [ ] **Step 1: Add the smallest context classes and parsers needed by Row/Col**

In `UPLayoutContexts.ets`, define constants for 12 grid units and functions that:

```ts
export function upLayoutInt(value: UPRawValue, fallback: number, min: number, max: number): number
export function upLayoutEnum(value: UPRawValue, allowed: string[], fallback: string): string
export class UPRowLayoutContext {
  gutter: number;
  constructor(gutter: number) { this.gutter = Math.max(0, gutter); }
}
```

Use `UPUnit.parse` at the component boundary, not `Number()` on arbitrary strings. Keep the context file internal and avoid changing the public `UPTypes` contract.

- [ ] **Step 2: Add Row/Col Props classes before component rendering code**

Implement constructors with nullish assignment so valid falsy values survive:

```ts
this.gutter = options.gutter ?? this.gutter;
this.justify = options.justify ?? this.justify;
this.align = options.align ?? this.align;
this.customStyle = options.customStyle;
this.contentBuilder = options.contentBuilder;
this.onClick = options.onClick;
```

Use equivalent assignments for all `UPColProps` fields. Set `contentBuilder` to the passed `UPBuilder` and keep the empty Builder as the component’s runtime fallback.

- [ ] **Step 3: Implement the native Row root**

Use `Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap })` as the root and preserve the 12 栅格 behavior defined by the design. Resolve `gutter` through `UPUnit.parse(this.props.gutter, 375, 0)`, normalize `justify` and `align`, apply `UPStyle.parse(this.props.customStyle)`, and call `onClick` only from the root click handler. Provide the resolved row context around the Builder content. The root must fill the available width and must not hard-code child widths in `375vp`.

- [ ] **Step 4: Implement the native Col root**

Use `Column` as the child root. Resolve `span` and `offset` through `upLayoutInt` with `0…12` bounds; map `span` to a percentage of the containing Row and `offset` to a percentage leading space. Consume the Row gutter and apply half-gutter horizontal padding. Map `justify`, `align`, and `textAlign` to native `Column`/`Text` alignment values with safe defaults. Run `UPStyle.parse` once per relevant helper and let explicit supported style values override defaults.

When no Row context exists, use gutter `0`, still render the column at its resolved percentage width, and keep `onClick` local to the column.

- [ ] **Step 5: Export the Row/Col public API**

Append exports to `ultra-ui/Index.ets` without removing or reordering existing exports:

```ts
export { UPRow, UPRowProps, UPRowOptions } from './src/main/ets/components/UPRow';
export { UPCol, UPColProps, UPColOptions } from './src/main/ets/components/UPCol';
```

- [ ] **Step 6: Run the contract and build the HAR**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
./scripts/build.sh
```

Expected: the Phase 3B contract prints `PASS`; the HAR build reaches `ultra-ui/build/default/outputs/default/ultra_ui.har`. If compilation fails, inspect the exact ArkUI API signature before changing the design or widening types.

- [ ] **Step 7: Commit Row/Col**

```bash
git add ultra-ui/src/main/ets/internal/UPLayoutContexts.ets \
  ultra-ui/src/main/ets/components/UPRow.ets \
  ultra-ui/src/main/ets/components/UPCol.ets \
  ultra-ui/Index.ets \
  scripts/test_phase_3b_layout_card_contract.py
git commit -m "feat: add native row and col layout components"
```

## Task 3: Extend the Contract and Implement Grid/GridItem

**Files:**
- Modify: `scripts/test_phase_3b_layout_card_contract.py`
- Modify: `ultra-ui/src/main/ets/internal/UPLayoutContexts.ets`
- Create: `ultra-ui/src/main/ets/components/UPGrid.ets`
- Create: `ultra-ui/src/main/ets/components/UPGridItem.ets`
- Modify: `ultra-ui/Index.ets`
- Test: `scripts/test_phase_3b_layout_card_contract.py`

**Interfaces:**
- `UPGridOptions` fields are `col?: UPRawValue`, `border?: UPRawValue`, `align?: UPRawValue`, `gap?: UPRawValue`, `customStyle?: UPStyleInput`, and `contentBuilder?: UPBuilder`.
- `UPGridItemOptions` fields are `name?: UPRawValue`, `bgColor?: UPRawValue`, `customStyle?: UPStyleInput`, `contentBuilder?: UPBuilder`, and `onClick?: (event: UPGridItemClickEvent) => void`.
- `UPGridItemClickEvent` is `{ name: UPRawValue; index: number }`.
- The item payload follows the explicit `name ?? index` rule: `name` when supplied and the render-local visual index otherwise; the index starts at zero for each Grid render and is never stored globally.

- [ ] **Step 1: Extend the test with Grid/GridItem expectations and run it red**

Add exact component maps and defaults:

```python
GRID_DEFAULTS = {
    "UPGrid": (("col", "3"), ("border", "false"), ("align", "'left'"), ("gap", "'0px'")),
    "UPGridItem": (("name", "null"), ("bgColor", "'transparent'")),
}
```

Assert `UPGridItemClickEvent`, `name ?? index` semantics, `Grid`/`GridItem` context names, and the four new public export groups. Run the script and confirm it fails because the new files/symbols are not present.

- [ ] **Step 2: Complete the Grid context without global state**

Extend `UPGridLayoutContext` with `columns`, `border`, `align`, `gap`, and an `allocateIndex()` method. Reset its counter at the beginning of each Grid render/build pass. Keep the context instance owned by the `UPGrid` component, supplied through `@Provide`, and make the standalone Item fallback use `index = 0`, `border = false`, `columns = 1`, and `gap = 0`.

- [ ] **Step 3: Implement the native Grid root**

Resolve `col` to at least one column, parse `gap` with `UPUnit`, normalize `align` to `left|center|right`, and parse `border` with `upBoolean`. Prefer native ArkUI `Grid`/`GridItem` with a generated columns template and native row/column gaps; if the API requires a Flex equivalent, keep the same public behavior and calculate item width from the actual parent layout rather than a fixed viewport. Apply `customStyle` to the Grid root and invoke no click callback from the Grid itself.

- [ ] **Step 4: Implement GridItem and its event payload**

Render as a native `GridItem` when the Grid context is present; otherwise render a standalone `Column`. Apply `UPColor.parse(bgColor, UP_DEFAULT_THEME, '#00000000')`, the context border, centered content alignment, and `customStyle`. The click handler must construct one event and pass it to `onClick`:

```ts
const index: number = this.gridContext.allocateIndex();
const name: UPRawValue = this.props.name === null || this.props.name === undefined
  ? index
  : this.props.name;
this.props.onClick?.({ name, index });
```

Do not allocate an index from a module-level variable or persist it across pages.

- [ ] **Step 5: Export Grid/GridItem**

Add these exact public exports:

```ts
export { UPGrid, UPGridProps, UPGridOptions } from './src/main/ets/components/UPGrid';
export {
  UPGridItem,
  UPGridItemProps,
  UPGridItemOptions,
  UPGridItemClickEvent,
} from './src/main/ets/components/UPGridItem';
```

- [ ] **Step 6: Run the focused contract and HAR build**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
./scripts/build.sh
```

Expected: the expanded static contract passes and the HAR/HAP build reaches the normal unsigned HAP output. No device claim is made.

- [ ] **Step 7: Commit Grid/GridItem**

```bash
git add scripts/test_phase_3b_layout_card_contract.py \
  ultra-ui/src/main/ets/internal/UPLayoutContexts.ets \
  ultra-ui/src/main/ets/components/UPGrid.ets \
  ultra-ui/src/main/ets/components/UPGridItem.ets \
  ultra-ui/Index.ets
git commit -m "feat: add native grid components"
```

## Task 4: Extend the Contract and Implement Card

**Files:**
- Modify: `scripts/test_phase_3b_layout_card_contract.py`
- Create: `ultra-ui/src/main/ets/components/UPCard.ets`
- Modify: `ultra-ui/Index.ets`
- Test: `scripts/test_phase_3b_layout_card_contract.py`

**Interfaces:**
- `UPCardOptions` contains the complete field set from the design: `full`, `title`, `titleColor`, `titleSize`, `subTitle`, `subTitleColor`, `subTitleSize`, `border`, `index`, `margin`, `borderRadius`, `headStyle`, `bodyStyle`, `footStyle`, `headBorderBottom`, `footBorderTop`, `thumb`, `thumbWidth`, `thumbCircle`, `padding`, `paddingHead`, `paddingBody`, `paddingFoot`, `showHead`, `showFoot`, `boxShadow`, `customStyle`, `contentBuilder`, `headBuilder`, `footBuilder`, `onClick`, `onHeadClick`, `onBodyClick`, and `onFootClick`.
- `UPCardArea` is the string union `'card' | 'head' | 'body' | 'foot'`.
- `UPCardClickEvent` is `{ index: UPRawValue; area: UPCardArea }`.
- Generic `onClick` receives every hit visible region before that region’s specialized callback.

- [ ] **Step 1: Extend the test with Card props, defaults, events, and exports; run it red**

Add assertions for every required Card field and these defaults:

```python
CARD_DEFAULTS = (
    ("full", "false"), ("title", "''"), ("titleColor", "'#303133'"), ("titleSize", "'15px'"),
    ("subTitle", "''"), ("subTitleColor", "'#909399'"), ("subTitleSize", "'13px'"),
    ("border", "true"), ("index", "''"), ("margin", "'15px'"), ("borderRadius", "'8px'"),
    ("headBorderBottom", "true"), ("footBorderTop", "true"), ("thumb", "''"),
    ("thumbWidth", "'30px'"), ("thumbCircle", "false"), ("padding", "'15px'"),
    ("paddingHead", "''"), ("paddingBody", "''"), ("paddingFoot", "''"),
    ("showHead", "true"), ("showFoot", "true"), ("boxShadow", "'none'"),
)
```

Assert the event type declarations, Builder fields, `UPImage` usage, local-source guard, and public export line. Run the test and verify the failure names the absent Card source or export.

- [ ] **Step 2: Implement Card Props and safe value helpers**

Use `UPRawValue` for upstream scalar values and `UPStyleInput` for section styles. Copy every option with `??`, including `false`, `0`, `''`, and `null`. Add helpers for text conversion, colors, dimensions, edges, border radius, visibility, and `boxShadow !== 'none'`; each helper must return a safe fallback on invalid input.

- [ ] **Step 3: Implement the default header and named Builder regions**

Use `Column` for the root and render in this order:

1. header only when `showHead` is true and a head Builder or non-empty `title`/`subTitle`/`thumb` exists;
2. optional header separator when `headBorderBottom` is true;
3. body Builder with body padding/style;
4. optional footer separator and footer Builder when `showFoot` is true and `footBuilder` exists.

When no `headBuilder` exists, render `thumb` through `UPImage` with local-only behavior, then title and subtitle with their parsed colors and sizes. Apply `headStyle`, `bodyStyle`, and `footStyle` independently after resolving base padding props.

- [ ] **Step 4: Implement Card root appearance and click dispatch**

Apply `full`/`margin`, `border`, `borderRadius`, `customStyle`, white default background, and a conservative native shadow only for a non-empty, non-`none` `boxShadow`. Attach click handlers to root and each visible section. Dispatch the same `{ index, area }` shape, call `onClick` first, then the matching area callback, and do not navigate or perform network work.

- [ ] **Step 5: Export Card**

Add:

```ts
export {
  UPCard,
  UPCardProps,
  UPCardOptions,
  UPCardArea,
  UPCardClickEvent,
} from './src/main/ets/components/UPCard';
```

- [ ] **Step 6: Run the focused contract and build**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
./scripts/build.sh
```

Expected: the Card contract and HAR/HAP build pass. Any ArkUI shadow or Builder API mismatch must be resolved by using the API available in the API 24 toolchain, while preserving the public behavior and fallback semantics.

- [ ] **Step 7: Commit Card**

```bash
git add scripts/test_phase_3b_layout_card_contract.py \
  ultra-ui/src/main/ets/components/UPCard.ets \
  ultra-ui/Index.ets
git commit -m "feat: add native card component"
```

## Task 5: Add Five Chinese Samples and Navigation Routes

**Files:**
- Create: `sample/entry/src/main/ets/demos/RowDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ColDemo.ets`
- Create: `sample/entry/src/main/ets/demos/GridDemo.ets`
- Create: `sample/entry/src/main/ets/demos/GridItemDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CardDemo.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Modify: `scripts/test_phase_3b_layout_card_contract.py`
- Test: `scripts/test_phase_3b_layout_card_contract.py`

**Interfaces:**
- Each Demo is an `@Component` with a `build()` method and imports all library symbols exclusively from `@lingyun/ultra-ui-hos`.
- Routes are exactly `row`, `col`, `grid`, `grid-item`, and `card`.

- [ ] **Step 1: Add the five sample route assertions and run red**

Extend the contract with:

```python
DEMOS = {
    "row": "RowDemo.ets",
    "col": "ColDemo.ets",
    "grid": "GridDemo.ets",
    "grid-item": "GridItemDemo.ets",
    "card": "CardDemo.ets",
}
```

For each route, assert the catalog route, a concrete `route === 'row'`-style branch in `SamplePage.ets`, a public-package import, `@Component`, and `build()`. Run the test and verify it fails because the demo files/routes are absent.

- [ ] **Step 2: Add Row/Col demos**

`RowDemo` must show two half-width columns, a nonzero gutter, an offset column, wrapping, and a click message. `ColDemo` must show standalone safe fallback plus `span`, `offset`, `justify`, `align`, and `textAlign`. Use only local Text/Column content and no internal library path.

- [ ] **Step 3: Add Grid/GridItem demos**

`GridDemo` must show three columns, a gap, borders, last-row alignment, and local click feedback. `GridItemDemo` must show one item with `name` and one without `name`, displaying both `event.name` and `event.index` in the page state.

- [ ] **Step 4: Add Card demo**

`CardDemo` must use `$rawfile:app_icon.png` for a local thumbnail, show a title/subtitle, provide body content, provide head/foot Builders, toggle `showHead`/`showFoot`, and display generic/area click feedback. It must not use a remote URL.

- [ ] **Step 5: Register catalog and page branches**

Add a new `Components E` group after `Components D` with five `SampleItem` entries, import the five Demo structs at the top of `SamplePage.ets`, and add five explicit branches in `demo()`.

- [ ] **Step 6: Run the contract and build the sample HAP**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
./scripts/build.sh
```

Expected: the route/source checks pass and the sample HAP is generated from the freshly built HAR.

- [ ] **Step 7: Commit samples and routes**

```bash
git add sample/entry/src/main/ets/demos/RowDemo.ets \
  sample/entry/src/main/ets/demos/ColDemo.ets \
  sample/entry/src/main/ets/demos/GridDemo.ets \
  sample/entry/src/main/ets/demos/GridItemDemo.ets \
  sample/entry/src/main/ets/demos/CardDemo.ets \
  sample/entry/src/main/ets/catalog/SampleCatalog.ets \
  sample/entry/src/main/ets/pages/SamplePage.ets \
  scripts/test_phase_3b_layout_card_contract.py
git commit -m "feat: add phase 3b layout and card samples"
```

## Task 6: Add Compatibility Documentation and README Counts

**Files:**
- Create: `docs/compatibility/phase-3b.md`
- Modify: `README.md`
- Modify: `scripts/test_phase_3b_layout_card_contract.py`
- Modify: `scripts/test_documentation_contract.py`
- Test: `scripts/test_phase_3b_layout_card_contract.py`, `scripts/test_documentation_contract.py`

**Interfaces:**
- The compatibility note names all five components, API 24, `5.0.0(12)`, native layout behavior, local image sources, invalid-value fallbacks, no-op/side-effect boundaries, and `skipped` device semantics.
- README changes preserve the existing Chinese style and update the documented baseline from 39 implemented components/controllers and 37 routes to 44 implemented components/controllers and 42 routes.

- [ ] **Step 1: Add the documentation assertions and run red**

Extend the Phase 3B contract to read `phase-3b.md` and `README.md`, then assert these exact phrases occur:

```python
for phrase in (
    "阶段 3B", "API 24", "5.0.0(12)", "UPRow", "UPCol", "UPGrid",
    "UPGridItem", "UPCard", "本地资源", "无网络", "设备验证", "skipped",
):
    assert phrase in note, f"phase-3b note missing {phrase}"
for phrase in ("phase-3b.md", "44 个已实现组件/控制器", "42 条组件示例路由"):
    assert phrase in readme, f"README missing {phrase}"
```

Run both contract scripts and confirm the new documentation assertion fails before the files exist.

- [ ] **Step 2: Write the compatibility note**

Document the public exports, default values, Row/Col 12-unit behavior, GridItem event index fallback, Card section events, local thumbnail rule, unsupported CSS/native differences, no implicit navigation/network, and device verification as `skipped` when no target is connected.

- [ ] **Step 3: Update README counts and links**

Change the component summary and route count to the Phase 3B totals, add the `Components E` route description, and link `docs/compatibility/phase-3b.md` alongside the existing phase notes. Do not claim device rendering verification.

- [ ] **Step 4: Run documentation contracts**

Run:

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
python3 scripts/test_documentation_contract.py
```

Expected: both scripts print `PASS`.

- [ ] **Step 5: Commit documentation**

```bash
git add docs/compatibility/phase-3b.md README.md \
  scripts/test_phase_3b_layout_card_contract.py \
  scripts/test_documentation_contract.py
git commit -m "docs: document phase 3b layout and card compatibility"
```

## Task 7: Full Verification and Boundary Review

**Files:**
- Modify only files that require a verification-driven correction; do not broaden scope.
- Test: all existing `scripts/test_*.py`, shell boundary/toolchain/build scripts.

- [ ] **Step 1: Run every Python static contract**

```bash
for f in scripts/test_*.py; do
  python3 "$f"
done
```

Expected: every script exits zero and prints its `PASS` line.

- [ ] **Step 2: Run dependency and toolchain boundaries**

```bash
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
```

Expected: boundary check passes; toolchain check passes or reports only the documented no-device `skipped` state.

- [ ] **Step 3: Run screenshot collection without overstating device coverage**

```bash
./scripts/capture-screenshots.sh
```

Expected with the current environment: `screenshots: skipped (no connected HarmonyOS device)`.

- [ ] **Step 4: Run whitespace and build verification**

```bash
git diff --check
./scripts/build.sh
```

Expected: no whitespace errors, HAR and HAP outputs exist, and the existing `upicon.ttf` resource contract remains valid.

- [ ] **Step 5: Review the final diff against the design**

Check each design section: all five public exports, every default, Builder path, event payload, invalid-value fallback, local image rule, five routes, documentation totals, and no forbidden dependencies. Use `git diff --stat` and `git status --short`; do not stage unrelated pre-existing files.

- [ ] **Step 6: Commit only verification-driven corrections**

If a correction was necessary, run the affected test and the full verification sequence again, then use a focused commit such as:

```bash
git add scripts/test_phase_3b_layout_card_contract.py
git commit -m "fix: align phase 3b contract"
```

Do not report completion until the fresh verification output has been read and the device state has been reported accurately.
