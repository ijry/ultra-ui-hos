# ultra-ui-hos Phase 3B 设计：布局与卡片

**状态：已确认，待规格审阅**  
**范围：** `UPRow`、`UPCol`、`UPGrid`、`UPGridItem`、`UPCard`

## 1. 目标与边界

本批次在现有纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中增加五个布局与展示组件，并在中文 HAP 示例中提供可交互路由。组件的字段名、默认值与关键行为以关联 Android/iOS 实现及 uview-plus 兼容契约为准。

本批次只覆盖原生布局、外观、插槽式内容和本地事件回调；不引入 WebView、Vue/NVue、FastView、运行时代码生成、远程请求、远程图片加载或业务状态存储。示例工程继续只能从 `@lingyun/ultra-ui-hos` 导入公开 API。

不在本批次实现折叠面板、下拉菜单、通知/消息提示、导航类组件或其他独立交互状态机。

## 2. 选定架构

采用**声明式父级上下文 + 原生 ArkUI 布局**：

- `UPRow` 和 `UPGrid` 是布局所有者，向嵌套子项提供只读的布局信息。
- `UPCol` 和 `UPGridItem` 是自描述子项，只负责把自身 props 解析为原生尺寸、间距、外观和点击事件。
- `UPCard` 是独立分区容器，使用原生 `Column` 组织可选头部、固定主体和可选底部。
- 所有 slot-like 内容沿用仓库现有的 `@BuilderParam` / `UPBuilder` 模式；普通主体可使用 ArkUI 尾随 Builder，卡片命名区域通过 Props 中的 `headBuilder` 与 `footBuilder` 提供。

此方案保持 Android/iOS 的嵌套式使用方式，例如：

```ts
UPRow({ props: new UPRowProps({ gutter: 12 }) }) {
  UPCol({ props: new UPColProps({ span: 6 }) }) {
    Text('左侧')
  }
  UPCol({ props: new UPColProps({ span: 6 }) }) {
    Text('右侧')
  }
}
```

实现不得使用固定 `375vp` 作为列宽计算依据；列宽、偏移、网格列宽和间隙必须相对于实际父容器宽度进行原生布局。实现可以使用 ArkUI 支持的百分比尺寸与 `Flex` 换行，或等价的原生布局能力，但不得改变下述公开行为。

## 3. 共享兼容规则

所有五个组件遵循现有核心工具和降级策略：

- 尺寸、边距和内边距通过 `UPUnit` 解析；非法、空或不允许为负的值使用组件默认值。
- 颜色通过 `UPColor` 解析；非法颜色使用相应主题回退色。
- `customStyle`、`headStyle`、`bodyStyle`、`footStyle` 通过 `UPStyle` 解析；支持的 style 键按现有核心契约生效，未知键报告兼容诊断而不抛异常。
- 非法枚举值安全回退到各组件默认值，并在传入 `diagnostics` 时报告。
- 任意 `UPRawValue` 中的 `0`、`false`、空字符串和 `null` 的受控含义必须保留；构造 Props 时不能把它们错误地当作缺失值。
- 所有交互仅调用调用方提供的本地回调；组件不进行路由跳转、网络访问或其他隐式业务副作用。

## 4. 组件契约

### 4.1 `UPRow`

`UPRow` 提供 12 单位栅格的可换行行容器。

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `gutter` | `0` | 相邻列的总水平间距；小于零或非法时回退为 `0`。 |
| `justify` | `start` | 支持 `start`、`center`、`end`、`space-between`、`space-around`、`space-evenly`。 |
| `align` | `center` | 支持 `start`、`center`、`end`、`stretch`。 |
| `customStyle` | `undefined` | 应用于行根节点。 |
| `onClick` | `undefined` | 点击行容器时调用，无隐式业务行为。 |
| `contentBuilder` | 空 Builder | 默认插槽；支持尾随 ArkUI Builder。 |

容器宽度默认占满可用父宽度。子列按照 `span + offset` 顺序排布，超出一行时换行。`gutter` 只作用于由 `UPCol` 表示的列；普通嵌套内容可安全显示，但不获得列宽语义。

### 4.2 `UPCol`

`UPCol` 是 `UPRow` 的 12 栅格列项，同时可脱离 `UPRow` 安全渲染。

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `span` | `12` | 解析为整数并钳制到 `0…12`；决定列占宽。 |
| `offset` | `0` | 解析为整数并钳制到 `0…12`；在自身前保留相同栅格单位宽度。 |
| `justify` | `start` | 控制列内部内容的主轴对齐。 |
| `align` | `stretch` | 控制列内部内容的交叉轴对齐。 |
| `textAlign` | `left` | 支持 `left`、`center`、`right`；优先决定文本/子内容水平锚点。 |
| `customStyle` | `undefined` | 应用于列根节点，支持的值覆盖对应默认外观。 |
| `onClick` | `undefined` | 点击列时调用。 |
| `contentBuilder` | 空 Builder | 默认插槽；支持尾随 ArkUI Builder。 |

当 `UPCol` 位于 `UPRow` 内时，它继承父行的 `gutter`，各列以半间距内边距保持与 Android/iOS 一致的视觉间隔。脱离父行时使用 `gutter = 0` 的安全回退，并仍按自身 `span` 表现为可预测的百分比列。

### 4.3 `UPGrid`

`UPGrid` 提供可换行的均分网格容器。

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `col` | `3` | 解析为正整数；非法或小于 `1` 时回退为 `3`。 |
| `border` | `false` | 决定子 `UPGridItem` 是否绘制主题边框。 |
| `align` | `left` | 支持 `left`、`center`、`right`，控制不足一行时子项组的水平锚点。 |
| `gap` | `0px` | 子项之间的水平与垂直间距；非法或负值回退为 `0`。 |
| `customStyle` | `undefined` | 应用于网格根节点。 |
| `contentBuilder` | 空 Builder | 默认插槽；支持尾随 ArkUI Builder。 |

网格布局信息仅在嵌套的 `UPGridItem` 中消费。网格列数、边框和间隙必须在同一次原生渲染中一致；不能依赖跨页面、跨组件实例或跨重组持久化的全局计数器。

### 4.4 `UPGridItem`

`UPGridItem` 是 `UPGrid` 的均分子项，也允许脱离网格单独安全显示。

| 字段 | 默认值 | 行为 |
| --- | --- | --- |
| `name` | `null` | 点击标识；提供时原样用于事件。 |
| `bgColor` | `transparent` | 子项背景色；无效值透明回退。 |
| `customStyle` | `undefined` | 应用于子项根节点。 |
| `onClick` | `undefined` | 点击子项时返回 `UPGridItemClickEvent`。 |
| `contentBuilder` | 空 Builder | 默认插槽；支持尾随 ArkUI Builder。 |

公开点击事件为：

```ts
export interface UPGridItemClickEvent {
  name: UPRawValue;
  index: number;
}
```

`index` 是当前 `UPGrid` 内从 `0` 开始的视觉顺序，不跨重组持久化。事件中的 `name` 在 props 明确提供时保留该值；未提供时使用该视觉 `index`。脱离 `UPGrid` 时 `index` 安全回退为 `0`。这使常见的无 `name` 网格仍有确定性回调值，同时不向上游 Props 添加不兼容的 `index` 字段。

### 4.5 `UPCard`

`UPCard` 提供由头部、主体和底部构成的卡片容器。主体始终渲染；头部与底部由显隐字段控制。默认头部在没有 `headBuilder` 时呈现本地缩略图、标题和副标题。

| 字段 | 默认值 |
| --- | --- |
| `full` | `false` |
| `title` | `''` |
| `titleColor` | `#303133` |
| `titleSize` | `15px` |
| `subTitle` | `''` |
| `subTitleColor` | `#909399` |
| `subTitleSize` | `13px` |
| `border` | `true` |
| `index` | `''` |
| `margin` | `15px` |
| `borderRadius` | `8px` |
| `headStyle` / `bodyStyle` / `footStyle` | `undefined` |
| `headBorderBottom` | `true` |
| `footBorderTop` | `true` |
| `thumb` | `''` |
| `thumbWidth` | `30px` |
| `thumbCircle` | `false` |
| `padding` | `15px` |
| `paddingHead` / `paddingBody` / `paddingFoot` | `''` |
| `showHead` | `true` |
| `showFoot` | `true` |
| `boxShadow` | `none` |
| `customStyle` | `undefined` |

额外的卡片 Builder 字段为 `contentBuilder`、`headBuilder`、`footBuilder`。`contentBuilder` 是主体默认插槽；当 `headBuilder` 或 `footBuilder` 存在时，分别替换对应默认区域内容。尾随 ArkUI Builder 等价于 `contentBuilder`。当 `showHead` 为 `true` 但没有头部 Builder 且标题、副标题、缩略图均为空时，不渲染空头部；当 `showFoot` 为 `true` 但没有 `footBuilder` 时，不渲染空底部。

- `full = true` 时默认外边距为 `0`；否则使用 `margin`。显式的 `customStyle.margin` 仍可覆盖根节点的默认外边距。
- `paddingHead`、`paddingBody`、`paddingFoot` 为空或非法时回退到 `padding`；有效的分区 style `padding` 可以覆盖该分区默认内边距。
- `boxShadow` 为非空且不等于 `none` 时使用保守的原生阴影；不尝试解析 CSS 阴影字符串。
- `thumb` 通过 `UPImage` 渲染，只接受既有允许的本地资源形式（`resource://`、`file://`、绝对路径、`$rawfile:`）。远程或不允许的源使用 `UPImage` 的确定性回退，不发起网络加载。

公开点击事件为：

```ts
export type UPCardArea = 'card' | 'head' | 'body' | 'foot';

export interface UPCardClickEvent {
  index: UPRawValue;
  area: UPCardArea;
}
```

回调字段是 `onClick`、`onHeadClick`、`onBodyClick` 和 `onFootClick`。点击某一可见分区时，组件先调用通用 `onClick`（其 `area` 为命中的分区），再调用匹配的分区回调；这样保留 uview 卡片的整体点击语义，同时允许调用方区分区域。未提供任一回调时不产生副作用。

## 5. 默认值与公开导出

每个组件均新增 `Options` 接口和可变字段 Props 类，构造函数以 `??` 复制字段，从而保留 `false`、`0`、空字符串与 `null`。上游标量字段统一使用 `UPRawValue`（回调、Builder 和 `UPStyleInput` 除外），因此字符串数字和字符串布尔值仍可安全接入并在渲染边界解析。计划导出的公共符号为：

```ts
UPRow, UPRowProps, UPRowOptions,
UPCol, UPColProps, UPColOptions,
UPGrid, UPGridProps, UPGridOptions,
UPGridItem, UPGridItemProps, UPGridItemOptions, UPGridItemClickEvent,
UPCard, UPCardProps, UPCardOptions, UPCardArea, UPCardClickEvent
```

必要时 `UPConfig` 只增加与这五个组件默认值有关的不可变默认配置；不改变既有 `UPConfig` 构造器和主题配置 API。

## 6. 样例、文档与测试

新增五个中文示例文件和路由：

- `row`：12 栅格、`gutter`、偏移、换行和对齐。
- `col`：独立列和内部对齐回退。
- `grid`：列数、间隙、末行对齐与边框。
- `grid-item`：`name` 与无 `name` 的点击事件值。
- `card`：默认头部、本地缩略图、命名头/底 Builder、分区点击与显隐。

示例全部只从 `@lingyun/ultra-ui-hos` 导入。新增 `docs/compatibility/phase-3b.md`，说明与 Android/iOS 的对齐点、ArkUI 原生布局差异、局部资源限制、无操作/保守降级字段以及设备验证策略。

新增 `scripts/test_phase_3b_layout_card_contract.py`，至少验证：

1. 五个组件文件、Props 默认值、公开导出和事件类型存在；
2. 必需的布局/分区 props、Builder 字段、回调字段和安全回退逻辑存在；
3. GridItem 的 `name ?? index` 事件语义和 Card 分区事件语义存在；
4. 五个中文样例、目录条目、路由和仅公开包导入存在；
5. README 组件/路由计数与 Phase 3B 文档链接更新；本批次在当前 `39 个已实现组件/控制器（38 个组件 + 1 个控制器）`、`37 条组件示例路由` 的基线上，目标为 `44 个已实现组件/控制器（43 个组件 + 1 个控制器）`、`42 条组件示例路由`；
6. 不引入禁用的 WebView、网络、远程加载或内部源码导入。

最终验证序列包括所有 `scripts/test_*.py`、边界检查、工具链检查、截图脚本、`git diff --check` 与 `./scripts/build.sh`。如果没有连接 HarmonyOS 设备，设备和截图结果必须报告为 `skipped`，不得宣称通过。

## 7. 验收标准

本批次完成的条件是：

1. HAR 公开入口可导入五个组件及所有列出的 Props/事件类型；
2. 栅格、网格和卡片的默认值、受控 props、局部 Builder 和回调行为符合本设计；
3. 无效颜色、单位、枚举和尺寸不会抛出异常，并按规定回退；
4. 卡片缩略图不会触发远程加载；
5. 五条样例路由可由示例目录进入，且没有内部源路径导入；
6. 静态契约、边界、工具链与 HAR/HAP 构建均有新的成功证据；设备不可用时明确标为跳过。
