# ultra-ui-hos Phase 6 设计：列表与索引

**状态：已确认，待规格审阅**  
**范围：** `UPList`、`UPListItem`、`UPIndexList`、`UPIndexItem`、`UPIndexAnchor`、`UPScrollList`

## 1. 目标与边界

阶段 6 在现有纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增六个列表与索引组件，并为每个组件增加独立中文示例路由。字段名、默认值和关键事件以固定 uview-plus 上游、关联 iOS SwiftUI 实现和 Android Compose 实现为依据。

本阶段选择“Builder 容器 + ArkUI 原生滚动状态”方案：调用方继续用 ArkUI Builder 声明列表项与分组，HAR 负责滚动容器、索引上下文、阈值判断和指示器渲染。组件不解析 JSON，不新增泛型数据源协议，也不复制 Vue/NVue 运行时。

本阶段不实现下拉刷新动画、虚拟列表数据适配器、瀑布流、表格、复杂手势索引拖拽或窗口级全局 sticky。`UPPullRefresh`、`UPVirtualList`、`UPRefreshVirtualList`、`UPWaterfall` 与表格组件属于后续阶段。

## 2. 平台与工程约束

- HarmonyOS NEXT Stage 模型，最低兼容 API 为 24，产品兼容和目标 SDK 为 `5.0.0(12)`。
- 组件库包名保持 `@lingyun/ultra-ui-hos`；所有稳定 API 只从 `ultra-ui/Index.ets` 导出。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入，不允许访问 `ultra-ui/src` 内部路径。
- 不使用 WebView、FastView、Vue/NVue、网络请求、远程资源、运行时代码生成或 JSON 组件映射。
- 使用现有 `UPRawValue`、`UPStyleInput`、`UPUnit`、`UPColor`、`UPStyle` 和兼容诊断机制；非法值安全回退，不抛异常。
- 页面持有受控状态；组件可以持有滚动位置等瞬时原生状态，但不得形成与页面 Props 冲突的第二份业务状态。
- 无连接设备时，设备交互和截图验证必须标记为 `skipped`，不能写成通过。

## 3. 总体架构

### 3.1 文件职责

- `UPList.ets`：纵向滚动容器、滚动事件、上下边界判断和刷新请求。
- `UPListItem.ets`：带可选锚点标识的内容 Builder 容器。
- `UPIndexList.ets`：索引列表根容器、侧边索引、受控活动值和选择事件。
- `UPIndexItem.ets`：索引分组，连接分组索引、标题 Builder 和内容 Builder。
- `UPIndexAnchor.ets`：默认分组标题条，可独立使用。
- `UPScrollList.ets`：横向滚动容器、左右边界事件和比例指示器。
- `UPListContexts.ets`：阶段 6 内部上下文，只导出给 HAR 内部组合组件，不加入公共入口。

### 3.2 Builder 约定

只有一个默认内容区的组件使用一个 `@BuilderParam contentBuilder`，支持 ArkUI 尾随 Builder：`UPList`、`UPListItem`、`UPIndexList` 和 `UPScrollList`。

`UPIndexItem` 同时具有 `headerBuilder` 和 `contentBuilder`，因此不能使用尾随 Builder。调用方必须显式传入命名 Builder，例如：

```ts
UPIndexItem({
  props: new UPIndexItemProps({ index: 'A' }),
  headerBuilder: this.aHeader,
  contentBuilder: this.aContent
})
```

若未提供 `headerBuilder`，组件使用 `UPIndexAnchor` 显示 `props.index`。若未提供内容 Builder，安全渲染空区域。

### 3.3 滚动所有权

每个滚动根组件拥有独立的 ArkUI `Scroller`：

- `UPList` 只处理纵向滚动。
- `UPIndexList` 只处理索引分组滚动。
- `UPScrollList` 只处理横向滚动。

它们不共享全局 Scroller，不依赖示例页面导航，也不自动操纵外部滚动容器。嵌套滚动使用 ArkUI 默认行为；本阶段不增加跨容器协调器。

## 4. 公共类型与事件

### 4.1 滚动事件

`UPListScrollEvent` 使用稳定、可序列化的数值字段：

```ts
export interface UPListScrollEvent {
  offset: number;
  viewportSize: number;
  contentSize: number;
}
```

`offset` 小于零时按 `0` 回传；无法获得内容尺寸时使用 `0`，不伪造测量值。

### 4.2 索引事件

`UPIndexListSelectEvent` 同时保留原始索引值和位置：

```ts
export interface UPIndexListSelectEvent {
  value: UPRawValue;
  index: number;
}
```

索引列表使用 `String(value)` 作为内部锚点键，但回调中的 `value` 保留调用方传入的 `UPRawValue`。重复字符串键只使用第一次出现的位置；后续重复项不进入侧边索引，避免无法确定滚动目标。

### 4.3 横向滚动事件

`UPScrollListEdgeEvent` 表示触达边界时的滚动信息：

```ts
export interface UPScrollListEdgeEvent {
  edge: 'left' | 'right';
  offset: number;
  maxOffset: number;
}
```

边界回调只在从非边界区进入边界区时触发一次；停留在边界时连续滚动事件不重复触发。离开后再次进入可重新触发。

普通横向滚动回调不伪造边界，使用独立事件：

```ts
export interface UPScrollListScrollEvent {
  offset: number;
  maxOffset: number;
}
```

## 5. 组件契约

### 5.1 `UPList`

`UPList` 是 Builder 驱动的纵向滚动容器。

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `showScrollbar` | `false` | 控制原生滚动条显示。 |
| `lowerThreshold` | `50` | 距底部不大于该值时请求 `onScrollToLower`；非法或负值回退为 `50`。 |
| `upperThreshold` | `0` | 距顶部不大于该值时请求 `onScrollToUpper`；非法或负值回退为 `0`。 |
| `scrollTop` | `0` | 外部请求的纵向滚动偏移；变化时调用 Scroller。 |
| `offsetAccuracy` | `10` | 事件偏移变化至少达到该值才发送下一次 `onScroll`；非法或非正值回退为 `10`。 |
| `enableFlex` | `false` | 保留兼容字段；ArkUI Builder 本身负责布局，不额外改变语义。 |
| `pagingEnabled` | `false` | 保留并诊断为近似；本阶段不实现分页吸附。 |
| `scrollable` | `true` | 为 `false` 时禁用用户滚动，内容仍显示。 |
| `scrollIntoView` | `''` | 非空时尝试滚动到具有相同 `UPListItem.anchor` 的项。 |
| `scrollWithAnimation` | `false` | 控制 `scrollTop` 和 `scrollIntoView` 请求是否使用原生动画。 |
| `enableBackToTop` | `false` | 平台无等价标题栏双击语义，保留字段并记录降级。 |
| `height` | `0` | 大于零时限制容器高度；`0` 表示由父布局决定。 |
| `width` | `0` | 大于零时限制容器宽度；`0` 表示 `100%`。 |
| `preLoadScreen` | `1` | Builder 容器无法保证上游预渲染屏数，保留并诊断。 |
| `refresherEnabled` | `false` | 开启刷新请求判定，但不提供下拉动画。 |
| `refresherThreshold` | `45` | 顶部负向拖动达到阈值时请求刷新；无法取得负向偏移时只保留字段并诊断。 |
| `refresherDefaultStyle` | `black` | 支持 `black`、`white`、`none`；当前不渲染系统刷新器。 |
| `refresherBackground` | `#FFF` | 刷新区域背景兼容字段。 |
| `refresherTriggered` | `false` | 页面控制刷新状态；组件不自行改写。 |
| `customStyle` | `undefined` | 应用于根容器。 |
| `diagnostics` | `undefined` | 可选兼容诊断接收器；缺失时静默。 |
| `onScroll` | `undefined` | 返回 `UPListScrollEvent`。 |
| `onScrollToLower` | `undefined` | 进入底部阈值区时调用一次。 |
| `onScrollToUpper` | `undefined` | 进入顶部阈值区时调用一次。 |
| `onRefresherRefresh` | `undefined` | 满足刷新请求条件时调用。 |
| `onRefresherTriggeredChange` | `undefined` | 请求页面更新刷新状态，不直接修改 Props。 |

边界事件采用进入区间触发策略，避免每个滚动帧重复回调。`scrollIntoView` 找不到锚点时不抛异常，并记录一次兼容诊断。

### 5.2 `UPListItem`

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `anchor` | `''` | 非空时向最近的 `UPList` 注册锚点和顺序。 |
| `customStyle` | `undefined` | 应用于项根容器。 |
| `contentBuilder` | 空 Builder | 项内容；支持尾随 Builder。 |

组件脱离 `UPList` 时仍安全显示。重复锚点只保留第一次注册项，避免不确定滚动目标。

### 5.3 `UPIndexList`

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `inactiveColor` | `#606266` | 未激活侧边索引颜色。 |
| `activeColor` | `#5677fc` | 激活侧边索引颜色。 |
| `indexList` | `[]` | 侧边索引原始值数组。 |
| `current` | `undefined` | 受控活动索引值；缺失时显示第一项但不改写页面。 |
| `sticky` | `true` | 使用 ArkUI 分组标题吸顶近似；不可用时退化为普通标题。 |
| `showSidebar` | `true` | 是否显示右侧索引。该字段来自关联原生端扩展。 |
| `customNavHeight` | `0` | 滚动目标顶部补偿；负值回退为 `0`。 |
| `safeBottomFix` | `false` | 为 `true` 时为侧边索引增加底部安全间距；系统能力不可用时回退为 `0`。 |
| `itemMargin` | `0rpx` | 相邻侧边索引的垂直间距。 |
| `customStyle` | `undefined` | 应用于根容器。 |
| `diagnostics` | `undefined` | 接收重复索引和平台降级诊断；缺失时静默。 |
| `onSelect` | `undefined` | 用户点击侧边索引时始终调用。 |
| `onChange` | `undefined` | 选择值与当前值不同时调用。 |
| `onCurrentChange` | `undefined` | 请求页面更新受控活动值。 |

选择事件顺序固定为 `onSelect`、`onChange`（仅变化时）、`onCurrentChange`，随后执行滚动请求。无效索引不发事件。侧边索引只处理点击；上游连续拖拽手势不在本阶段实现，并在兼容文档中说明。

滚动过程中自动识别当前可见分组若需要布局测量与稳定回调；本阶段只保证用户选择驱动的活动值和滚动定位，不把自动可见分组跟踪伪装成已支持。

### 5.4 `UPIndexItem`

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `index` | `''` | 分组索引值，与 `UPIndexList.indexList` 的字符串形式对应。 |
| `customStyle` | `undefined` | 应用于分组根容器。 |
| `headerBuilder` | 默认标题 | 缺失时渲染 `UPIndexAnchor(text=index)`。 |
| `contentBuilder` | 空 Builder | 分组内容。 |

组件向最近的 `UPIndexList` 注册索引与顺序。脱离父列表时使用普通 Column 呈现默认标题和内容，不触发选择事件。

### 5.5 `UPIndexAnchor`

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `text` | `''` | 标题文本，保留 `UPRawValue`。 |
| `color` | `#606266` | 标题颜色。 |
| `size` | `14` | 标题字号。 |
| `bgColor` | `#f1f1f1` | 标题背景色。 |
| `height` | `32` | 标题高度；非法或非正值回退为 `32`。 |
| `customStyle` | `undefined` | 应用于根容器。 |

默认标题左对齐并提供稳定可读文本。组件可独立使用，不依赖索引上下文。

### 5.6 `UPScrollList`

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `indicatorWidth` | `50` | 指示器轨道宽度。 |
| `indicatorBarWidth` | `20` | 活动滑块宽度，钳制到 `0…indicatorWidth`。 |
| `indicator` | `true` | 是否显示指示器。 |
| `indicatorColor` | `#f2f2f2` | 指示器轨道颜色。 |
| `indicatorActiveColor` | `#3c9cff` | 活动滑块颜色。 |
| `indicatorStyle` | `undefined` | 应用于指示器容器。 |
| `customStyle` | `undefined` | 应用于根容器。 |
| `diagnostics` | `undefined` | 接收尺寸测量近似诊断；缺失时静默。 |
| `onLeft` | `undefined` | 从中间区域进入左边界时回调。 |
| `onRight` | `undefined` | 从中间区域进入右边界时回调。 |
| `onScroll` | `undefined` | 返回 `UPScrollListScrollEvent`，供页面展示偏移和最大偏移。 |

指示器位移公式为：

```text
progress = clamp(offset / maxOffset, 0, 1)
barOffset = progress * max(indicatorWidth - indicatorBarWidth, 0)
```

当 `maxOffset = 0` 时，进度和位移均为 `0`，只认为处于左边界，不触发右边界。内容宽度测量不可用时，指示器保持起点并记录近似说明。

## 6. 内部上下文

`UPListContexts.ets` 定义两个独立上下文：

- `UPListContext`：为 `UPListItem` 分配顺序、注册锚点并提供滚动定位请求。
- `UPIndexListContext`：保存归一化索引、活动键、颜色、sticky 配置、分组顺序和选择请求。

上下文实例由父组件通过 `@Provide` 提供，子组件通过 `@Consume` 使用。默认上下文必须能让子组件脱离父组件安全渲染。上下文不持有页面对象、路由栈或全局单例。

由于 ArkUI 组合期动态注册与布局测量存在限制，注册表只用于确定性顺序和目标映射；若运行时无法可靠取得节点偏移，滚动定位可使用组件顺序的原生 `scrollToIndex` 近似，并在兼容说明中记录。

`UPList` 和 `UPIndexList` 必须把内容 Builder 直接放入原生 `List`。父上下文存在时，`UPListItem` 渲染原生 `ListItem`；`UPIndexItem` 渲染一个通过 `ListItemGroup({ header: resolvedHeaderBuilder })` 传入标题 Builder 的原生分组，并在分组内部用一个原生 `ListItem` 包裹 `Column() { contentBuilder() }`。脱离父上下文时二者才使用普通 `Column`。这样既满足 `ListItemGroup` 内容必须由 `ListItem` 组成的节点约束，也使 `scrollToIndex`、分组索引和父 `List.sticky` 作用于正确的原生子节点。

`UPListContext` 保存尚未匹配的锚点请求。若请求发生在子项注册之前，后续 `registerAnchor` 注册匹配锚点时立即调用滚动回调并清除请求，避免父 `onAppear` 早于子项注册时丢失初始 `scrollIntoView`。

## 7. 示例工程

新增 `Components J` 分组与六条路由：

| 路由 | 页面 | 重点场景 |
| --- | --- | --- |
| `list` | `ListDemo.ets` | 固定高度列表、上下阈值、滚动事件和刷新请求状态。 |
| `list-item` | `ListItemDemo.ets` | 独立列表项、锚点字段和 Builder 内容。 |
| `index-list` | `IndexListDemo.ets` | A/B/C 分组、受控索引、侧边点击和滚动定位。 |
| `index-item` | `IndexItemDemo.ets` | 独立分组、默认标题与显式命名 Builder。 |
| `index-anchor` | `IndexAnchorDemo.ets` | 默认和自定义颜色、字号、背景、高度。 |
| `scroll-list` | `ScrollListDemo.ets` | 横向卡片、滚动比例指示器和左右边界事件。 |

阶段完成后 README 统计更新为 69 个组件/控制器（68 个组件 + 1 个控制器）和 67 条组件示例路由。目录分组说明更新到 `Components A/B/C/D/E/F/G/H/I/J`。

示例数据必须本地、固定且可重复，不使用远程图片、网络请求或系统通讯录。示例页面持有 `current`、刷新显示文字和边界消息等状态，组件只回调请求。

## 8. 错误处理与兼容降级

- 非法尺寸、颜色、布尔值和数组项使用组件默认值或跳过无效项，不抛异常。
- `indexList` 中 `null`、`undefined` 和空字符串不进入侧边索引；数字 `0` 是有效索引。
- 重复索引只保留第一次出现项，并通过兼容诊断报告一次。
- 无法解析的 `current` 不高亮、不滚动；用户选择合法项后由页面更新 Props。
- `pagingEnabled`、`preLoadScreen`、系统标题栏回顶、完整下拉刷新视觉和连续索引拖拽属于平台降级项。
- `sticky`、`scrollIntoView`、列表阈值和横向指示器必须在兼容文档中区分“原生实现”“原生近似”和“保留字段”。
- 所有事件处理器均为可选；缺失回调时组件只渲染，不发生隐式业务副作用。

## 9. 测试与验收

### 9.1 静态契约

新增 `scripts/test_phase_6_list_index_contract.py`，至少检查：

- 六个组件均具有 `Options`、`Props`、公开 `@Component` 和 HAR 导出。
- Props 默认值与本规格一致。
- `UPListContexts.ets` 包含锚点注册、索引选择、重复项处理和安全默认上下文。
- `UPIndexItem` 使用两个显式 `@BuilderParam`，示例不得使用尾随 Builder。
- 六条路由、六个 Demo、`Components J` 和 `SamplePage` 分发完整。
- Demo 只导入公共 HAR，不含网络、WebView、Vue/NVue 或库内部路径。
- README、阶段兼容文档和 69/67 统计一致。

### 9.2 构建验证

实现完成后依次执行：

```bash
python3 scripts/test_phase_6_list_index_contract.py
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/capture-screenshots.sh
git diff --check
./scripts/build.sh
```

HAR 与示例 HAP 必须通过 ArkTS 编译。构建产生的未签名警告可以记录，但编译错误、资源缺失或依赖边界错误必须修复。

### 9.3 设备验证

有设备或模拟器时验证：纵向滚动、上下边界只触发一次、侧边索引点击、分组滚动、sticky 标题、横向滚动、指示器移动和左右边界事件。无设备时明确报告这些项目和截图为 `skipped`。

## 10. 非目标

- 不增加数据驱动泛型列表 API，不替代调用方的 `ForEach` 或 Builder。
- 不实现运行时 JSON 到 ArkUI 组件转换。
- 不新增网络、数据库、权限、文件或通讯录依赖。
- 不承诺百万级数据虚拟化；大数据集由后续专用虚拟列表组件处理。
- 不实现复杂索引拖拽气泡、触觉反馈、窗口级 sticky 或跨嵌套滚动协调。
- 不修改阶段 1 至阶段 5 的组件行为，也不整理与本阶段无关的现有脏工作区文件。
