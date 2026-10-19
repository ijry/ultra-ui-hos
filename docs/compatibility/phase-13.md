# 阶段 13 兼容说明

阶段 13 增加 `UPTable`、`UPTr`、`UPTh`、`UPTd` 与 `UPTable2`，构成完整的表格体系。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPTable` 是表格容器，通过 `@Provide('UPTableStyleContext')` 向后代下发 `borderColor`、`align`、`padding`、`fontSize`、`color`、`bgColor` 与 `thStyle`。它支持两种用法：`contentBuilder` 插槽内自由组合 `UPTr`/`UPTh`/`UPTd`，或使用数据驱动的 `headers`/`rows`/`widths` 直接渲染。容器只画左、上边框，单元格补右、下边框，从而组成无重叠的完整网格线。
- `UPTr` 用 `Flex(FlexDirection.Row, ItemAlign.Stretch)` 保证同一行内所有单元格等高，支持 `bgColor` 覆盖行底色，并在 `aboutToAppear` 时向上下文登记行序号。
- `UPTh` 是表头单元格。`width` 为空时走 `layoutWeight(1)` 等分，填写后使用原生固定宽度；上游的 `flex: 0 0 <n>` CSS 字符串写法不再需要。表头默认底色 `#f5f6f8`、加粗、文字 `#303133`，`thStyle` 由容器下发，本地 `customStyle` 优先级更高。
- `UPTd` 是数据单元格。`width`、`textAlign`、`fontSize`、`borderColor`、`color` 留空即继承表格上下文，填写即就地覆盖，与上游"单元格属性覆盖表格属性"的行为一致。
- `UPTable2` 对应上游 `u-table2`：斑马纹、边框、固定表头、`height`/`maxHeight` 滚动、`highlightCurrentRow`、`rowKey`、`emptyText` 空态、列过滤、单列与 `multiSort` 多列排序（升序 → 降序 → 取消循环）、`type='selection'` 勾选列、`type='expand'` 展开列，以及基于行 `children` 字段的树形表格与 `mainCol` 缩进。行、单元格、表头、排序、勾选、展开各自派发具名事件对象。

## 边界

ArkTS 禁止索引签名与 `any`，因此 `UPTable2` 的行数据使用具名模型 `UPTable2Row { key, cells: Array<UPTable2Cell>, children, hasChildren, disabled, selected }`，而不是上游的任意对象。上游的 `treeProps` 仍被接受，但原生实现固定读取具名 `children`/`hasChildren` 字段，传入自定义映射时按 no-op 处理。

以下上游字段保留为 no-op 兼容位，仅为让上游代码原样迁移，不改变渲染结果，并全部通过 `UPCompatibilityDiagnostics.report()` 在传入时记录一条诊断：

- `spanMethod`：不支持跨行跨列合并单元格。
- `cellClassName`、`rowClassName`、`headerCellClassName`：CSS 类名无对应原生概念，请改用 `rowStyle` 或列级 `style`。
- `cellStyle`：全局单元格样式未接线，请改用列级 `style`。
- `lazy` 与 `load`：不做懒加载，`load()` 永不被调用；子节点请直接放进 `children`。
- `showOverflowTooltip`：不渲染溢出气泡提示。
- `column.fixed`：不支持列冻结，横向滚动时列随内容一起移动。

表格体系只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。排序与过滤都在组件内对当前数据副本执行，不回写宿主数据源；分页、远程排序和大数据虚拟化仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 13 静态契约覆盖五个组件的默认值、核心 Props/事件、上下文注入与消费、公共导出、Components Q 目录和五条 Demo 路由。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称固定表头吸顶、长列表滚动性能、树形展开动画的设备验证完成；这些表现需在真机复核。
