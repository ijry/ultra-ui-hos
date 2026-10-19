# 阶段 23 兼容说明

阶段 23 不新增组件，而是把上游 138 个 UI 目录的 `<slot>` 与已实现的 ArkTS Builder 入口逐个对齐：审计脚本原先报出 61 个组件共 118 个上游插槽没有对应入口，本阶段全部补齐并接到真实渲染位置，`scripts/test_upstream_slot_coverage.py` 现已归零。所有改动仍面向 HarmonyOS NEXT API 24，新增作用域类型均从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

### 插槽承载方式

ArkTS 的 `@BuilderParam` 只能由 `@Builder` 函数初始化，不能接收可选回调，因此本阶段用两种方式承载上游插槽：

- **可选 `UPBuilder` 字段 + `UPSlotRegion` 子组件**：无作用域的具名插槽（上游 `<slot name="xxx">` 不带 `:prop`）声明为 `xxxBuilder?: UPBuilder`，渲染时交给 `src/main/ets/internal/UPSlotRegion.ets` 里的 `UPSlotRegion`（零尺寸兜底）或 `UPSlotBlock`（占满一行）。为规避 `@BuilderParam` 初始化告警，实例化统一包在宿主 struct 的 `@Builder private xxxRegion()` 里再调用。本阶段共落地 55 个组件、109 个此类入口。
- **保留 `@BuilderParam`**：上游把数据传进插槽的作用域插槽仍用 `@BuilderParam`，并配套单参数作用域接口（ArkTS `@Builder` 只接受 0 或 1 个参数）：`UPChoose.itemBuilder`（`UPChooseItemSlot`）、`UPSelect.optionItemBuilder`（`UPSelectOptionSlot`）、`UPTable2` 的 `headerBuilder` / `headerSortBuilder` / `cellBuilder`（`UPTable2HeaderSlot`、`UPTable2HeaderSortSlot`、`UPTable2CellSlot`）、`UPTreeSelect.nodeBuilder`（`UPTreeSelectFlatNode`）、`UPWaterfall.leftBuilder`（`UPWaterfallColumnSlot`）。

### 替换语义与追加语义

上游插槽分两类，本端按上游模板逐个确认后接线：

- **替换默认内容**：`UPButton`、`UPDivider`、`UPBackTop`、`UPSkeleton`（`loading` 结束后渲染真实内容）、`UPLineProgress`、`UPLoadingPage`、`UPDropdownItem`、`UPActionSheet`、`UPAvatar`、`UPTag`、`UPNumberBox` 的三个按钮/输入位、`UPToolbar.rightBuilder`、`UPModal.confirmButtonBuilder`、`UPCalendar.footerBuilder`、`UPReadMore.toggleBuilder` 等，宿主提供 Builder 时默认 UI 不再渲染。
- **追加到默认内容之后**：`UPEmpty`、`UPStatusBar`、`UPTabbar`、`UPKeyboard`、`UPOverlay`、`UPTitle`、`UPBox`、`UPSlider`、`UPSwiper.indicatorBuilder`、`UPPopup.bottomBuilder`、`UPModal.popupBottomBuilder`、`UPSwipeActionItem.buttonBuilder` 等，与上游同一容器内并列。

### 逐组件要点

- `UPCell` 补齐 `icon`、`title`、`label`、`value`、`right-icon`、`righticon` 六个入口。上游 `right-icon` 与 `righticon` 是两个不同插槽（前者替换箭头，后者是额外一列），本端保留两个独立字段 `rightIconBuilder` 与 `righticonBuilder`，命名与上游一致。
- `UPCollapseItem` 的 `icon` / `title` / `value` / `right-icon` 直接落在自绘表头行上，不经 `UPCell` 转发，避免上游备注里提到的小程序插槽嵌套问题。同时补上了此前缺失的 `value` 文案渲染。
- `UPNovelReader` 补齐 8 个插槽：`loading` / `error` / `empty` 覆盖三种状态块，`top` / `toolbar-extra` 进顶栏按钮组，`bottom` 进底栏按钮组，`catalog` / `settings` 整体替换目录与设置面板主体。
- `UPCoupon` 的 `unit` 按 `unitPosition` 决定挂在金额左侧还是右侧，与上游两处同名 `<slot name="unit">` 的 `v-if` 判定一致；`limit` / `title` / `desc` / `time` 各自替换对应文案。
- `UPTable2` 的 `header` / `headerSort` / `cell` 改为作用域 Builder，默认实现与原先自绘一致；`headerSort` 只在列可排序时渲染，`sortStatus` 回传 `ascending` / `descending` / 空串；`empty` 走可选字段替换空数据文案。
- `UPWaterfall` 新增 `useLeftSlot` 开关与 `leftBuilder`：上游 `left` 与 `column` 同为整列插槽，两者都提供时以 `column` 优先，与上游模板的 `v-if="!$slots['left'] && !$slots['column']"` 判定顺序保持一致。
- `UPPicker`、`UPDatePicker`、`UPTimePicker` 补齐 `trigger` / `toolbar-right` / `toolbar-bottom`；`UPPicker` 的 `default` 与 `trigger` 同为触发区插槽，`trigger` 优先。
- `UPUpload` 补齐 `default` / `trigger` / `playIcon` / `success`，`trigger` 优先于 `default`，两者都接到与默认「+」按钮相同的选择回调。
- `UPGoodsSku` 的 `trigger` 插槽点击只抛 `open` 事件（新增 `openByTrigger()`），面板显隐仍由宿主的 `show` 决定，与上游 `v-model:show` 的受控模型一致。
- `UPIndexList` 的 `header` / `footer` 包在 `ListItem` 里，仅在宿主提供 Builder 时才产生列表项，避免多出空白行。
- 其余单插槽组件：`UPAlert.closeBuilder`、`UPCellGroup.titleBuilder`、`UPNotify` / `UPRowNotice` / `UPColumnNotice` 的 `iconBuilder`、`UPCheckbox` / `UPRadio` 的 `icon` + `label`、`UPImage` 的 `loading` + `error`、`UPInput` 的 `prefix` + `suffix`、`UPSearch` 的 `label` + `inputRight`、`UPFormItem` 的 `label` + `error`、`UPTooltip` / `UPPopover` 的 `trigger` + `content`、`UPFloatingBubble` 的 `default` + `list`、`UPTabbarItem` 的 `active-icon` / `inactive-icon` / `text`、`UPCard.bodyBuilder`、`UPColorPicker.contentBuilder`。

## 边界

- `UPSlotRegion` 与 `UPSlotBlock` 是本端为承载可选插槽引入的内部子组件，上游没有对应节点，会在渲染树里多出一层容器；未提供 Builder 时渲染零尺寸 `Row`，不参与布局。
- ArkTS `@Builder` 最多接受一个参数，因此上游多参数作用域插槽（如 `u-table2` 的 `cell` 同时给出 `row`、`column`、`prow`、`rowIndex`、`columnIndex`、`level`、`context`）被折叠成单个作用域对象；`context` 这类组件实例引用不对外暴露。
- `UPWaterfall` 的 `useColumnSlot` / `useLeftSlot` 是本端开关：上游靠 `$slots` 运行时判定走哪条渲染分支，ArkTS 无法探测 `@BuilderParam` 是否被赋值，只能由宿主显式声明。
- `UPCell` 的 `righticon` 与 `right-icon` 在上游是两个键名不同但语义相近的插槽，本端按原名保留两个入口，不做归一，属于命名层面的 no-op 兼容位。
- `UPTabbarItem` 的 `active-icon` / `inactive-icon` 只在 `icon`、`activeIcon` 都为空时生效，与上游 `v-else` 的判定顺序一致。
- `UPPicker` 与 `UPUpload` 的 `default` 插槽在上游是 `trigger` 的兼容别名，本端保留两个字段但同一位置只渲染其一。
- 上游 `u-novel-reader` 的插槽经 `reader-content` / `reader-toolbar` / `reader-catalog` / `reader-settings` 四个子组件层层转发，本端是单文件实现，插槽直接落在对应区域，中间层的 `#default` 转发不复现。
- 本阶段改动只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 示例工程

阶段 23 不新增 Demo 路由（141 条保持不变），在 5 个既有页面里追加插槽演示段：

- `CellDemo`：一条单元格同时接入 `icon` / `title` / `label` / `value` / `right-icon` / `righticon` 六个 Builder，并标注两个右侧插槽的差别。
- `TitleDemo`：`prefix` 换成自定义色条，`default` 追加标签行。
- `NumberBoxDemo`：`minus` / `input` / `plus` 三个位置换成自绘按钮与只读数值，加减判定仍由组件负责。
- `SelectDemo`：`optionItem` 作用域插槽渲染带序号的选项行。
- `Table2Demo`：`header` / `headerSort` / `cell` 作用域插槽 + `empty` 空态插槽，`headerSort` 直接展示 `sortStatus` 回传值。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_upstream_slot_coverage.py`：遍历上游 138 个 UI 目录，解析主 `.vue` 的 `<slot>` 声明，逐插槽核对 `name-with-dash` → `nameWithDashBuilder` 的 ArkTS 入口（默认插槽额外接受 `contentBuilder` / `defaultBuilder` 与作用域命名），任何缺口即失败；当前输出 `PASS (138 directories)`。
- 新增 `scripts/test_phase_23_slot_parity_contract.py`：锁定 55 个组件的 109 个可选插槽字段必须同时出现在 `Options`、`Props` 与构造函数赋值中，并校验每个字段都交给了 `UPSlotRegion`、7 个作用域 `@BuilderParam` 及其作用域类型存在、关键替换/追加判定 token 到位、新增类型已从公共入口导出、5 个 Demo 页面确实接入了新插槽入口。
- 既有 37 个契约脚本全部通过。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。当前未宣称插槽内容在真机上的布局、滚动与手势表现的设备验证完成；`UPSlotRegion` 多出的一层容器对复杂嵌套布局的影响需在真机复核。
