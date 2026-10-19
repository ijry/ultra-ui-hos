# 阶段 22 兼容说明

阶段 22 不新增组件，而是把上游 138 个 UI 目录的 `emits` 与已实现的 ArkTS `on*` 回调逐个对齐：审计脚本原先报出 47 个组件共 99 个上游事件没有对应入口，本阶段全部补齐并接到真实触发点，`scripts/test_upstream_event_coverage.py` 现已归零。所有改动仍面向 HarmonyOS NEXT API 24，新增载荷类型均从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

### 反馈与容器

- `UPModal` 补齐 `onConfirm`、`onCancel`、`onCancelOnAsync`：上游按动作分派三个事件，本端在 `dispatchAction()` 里按 `confirm` / `cancel` 分流，异步取消时先抛 `cancelOnAsync`；`done()` 的等待条件同步扩展为「`onAction`、`onConfirm` 或 `onCancel` 任一被接管」。
- `UPCollapse` 补齐 `onOpen`、`onClose`：上游 `this.$emit(target.expanded ? 'open' : 'close', target.name)`，本端在 `dispatchChange()` 里按展开态分派。
- `UPPopover` 与 `UPTooltip` 补齐 `onClick`、`onOpen`、`onClose`：切换显隐时先抛 `click`，再按结果抛 `open` 或 `close`；Tooltip 的按钮点击同时抛 `onButtonClick` 与 `onClick`。
- `UPPopup` 补齐 `onClosed` 与面板 `onClick`；`UPOverlay` 补齐 `onClick`（上游只有一个 `click`，`onClickOverlay` 是本端别名）。
- `UPGrid` 补齐 `onClick`：子项点击经 `UPGridLayoutContext.onItemClick` 冒泡到表格级；`UPGridItem` 另加 `onGridItemBroadcast`。
- `UPImage` 补齐 `onLoad`、`onError`：接到 ArkUI `Image` 的 `onComplete` 与 `onError`，远端地址回落占位时也抛一次 `onError`。
- `UPKeyboard` 补齐 `onChange`、`onBackspace`、`onCancel`、`onClose`、`onClosed`，并新增 `showCancel` / `cancelText` 以承载取消按钮。
- `UPLoadmore` 补齐 `onLoadmore`，保留上游「仅 `status === 'loadmore'` 时才抛」的判定。
- `UPCountTo` 补齐 `onEnd`（上游事件名），`UPCountDown` 补齐 `onChange`（逐秒回传 `days`/`hours`/`minutes`/`seconds`）。
- `UPAvatarGroup` 补齐 `onShowMore`，点击「+N」提示时回传隐藏数量与总数；`UPCropper` 补齐 `onAvtinit`（上游事件名，`onInit` 为本端别名）。

### 表单与数据

- `UPPagination` 补齐 `onCurrentChange`、`onSizeChange`，并在 `layout` 含 `sizes` 时渲染页长切换入口。
- `UPTable2` 补齐 `onSelect`、`onSelectAll`、`onFilterChange`、`onRowDblclick`：勾选先抛 `select` 再抛 `selection-change`，新增命令式 `toggleSelectAll()` 与 `notifyFilterChange()`，双击按 `UP_TABLE2_DOUBLE_CLICK_INTERVAL = 300` 毫秒内两次单击判定。
- `UPCalendar` 补齐 `onConfirm`、`onClose`、`onClosed`；`UPReadMore` 补齐 `onOpen`、`onClose`。
- `UPSwipeAction` 补齐 `onOpendItemUpdate`（上游 `opendItem:update`）；`UPSwipeActionItem` 补齐 `onClick` 与 `onScrolling`（接到 `PanGesture` 的起止）。
- `UPSwiper` 补齐 `onCurrentChange`、`UPTabbarItem` 补齐 `onChange`、`UPQrcode` 补齐 `onLongpressCallback`、`UPCascader` 补齐 `onShowChange`、`UPAlert` 补齐 `onModelValueChange`、`UPWaterfall` 补齐 `onInput`。
- `UPList` 补齐 `onRefresherPulling`、`onRefresherRestore`、`onRefresherAbort`，共用 `UPListRefresherEvent`。
- `UPParse` 补齐 `onClick` 与 `onTap`（上游同一条 `onClick` 消息抛出两个事件）。
- `UPNumberBox` 补齐 `onFocus` 与 `onOverlimit`（越界时只抛事件不改值）。
- `UPInput` 补齐 `onKeyboardHeightChange`、`onNicknameReview`；`UPTextarea` 补齐 `onKeyboardHeightChange`、`onLineChange`。
- `UPButton` 补齐 open-type 五个回调与 `onError`，`UP_BUTTON_OPEN_TYPES` 保留上游取值白名单。
- `UPUpload` 补齐 `onBeforeRead`、`onAfterRead`、`onOversize`、`onError`、`onClickPreview`、`onAfterAutoUpload`，串成上游的读取流水线。
- `UPDatePicker` 与 `UPTimePicker` 补齐 `onChange`、`onInput`、`onModelValueChange`、`onClose`、`onClosed`：滚动即抛 `change`，确认时抛 `confirm` + `input` + 模型值并关闭面板。

## 边界

以下事件在 HarmonyOS 上没有等价平台能力，改由近似判定或宿主承担，触发时通过 `UPCompatibilityDiagnostics.report()` 记录一条诊断：

- `UPButton` 的 open-type：`getphonenumber`、`getuserinfo`、`opensetting`、`launchapp`、`agreeprivacyauthorization` 全部来自小程序与 App 平台，HarmonyOS 没有对应入口，因此只把请求原样转发给宿主回调；白名单外的取值直接走 `onError`。
- `UPUpload` 的读取流水线：组件不打开系统文件选择器，`beforeRead` 的放行结果、`oversize` 的判定与 `afterAutoUpload` 的时机都基于本地占位条目；真实文件读取与上传仍由宿主完成。
- `UPTable2` 的 `row-dblclick`：ArkUI 没有原生双击事件，按 300 毫秒内两次单击判定，与平台原生双击的判定阈值可能有差异。
- `UPList` 的三个下拉阶段事件：ArkUI `List` 没有独立的下拉手势回调，`refresherpulling` / `refresherrestore` / `refresherabort` 由滚动位移与 `refresherThreshold` 推断，触发时机与上游 `scroll-view` 的原生回调不完全一致。
- `UPTextarea` 的 `linechange`：平台不上报行数变化，改按换行符数量推断，自动折行导致的行数变化不会触发。
- `UPInput` 与 `UPTextarea` 的 `keyboardheightchange`：ArkUI 不暴露键盘高度，只在收起编辑态时给出 `height: 0`，用于让宿主收尾布局。
- `UPGridItem` 的 `$uGridItem`：上游用 `uni.$emit` 全局事件总线广播来清理兄弟项按下态，本端不引入全局总线，改为 `onGridItemBroadcast` 交给宿主。
- `closed` 与 `close` 这一对事件：上游 `closed` 是退场动画结束后的回调，ArkUI 的显隐切换是立即完成的，因此两者同帧触发（`UPPopup`、`UPKeyboard`、`UPCalendar`、`UPAlert`、`UPDatePicker`、`UPTimePicker`）。
- `input` 与 `update:modelValue` 这一对事件：上游同时抛出两者表示同一次值变更，本端保留两个回调以便宿主按习惯选用，触发时机相同。

上表中的 open-type 五个回调、`$uGridItem` 广播与 `keyboardheightchange` 的高度值都属于 no-op 兼容位：入口存在且会被调用，但组件本身不具备对应的平台能力，实际结果取决于宿主实现。

本阶段改动只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_upstream_event_coverage.py`：遍历上游 138 个 UI 目录，解析 `emits` 数组与 `$emit(...)` 调用，逐事件核对对应 ArkTS `Options`/`Props` 上的 `on*` 回调（含 `input`/`update:x`、`close`/`closed`、`open` 等成对事件的等价映射），任何缺口即失败；当前输出 `PASS (138 directories)`。
- 新增 `scripts/test_phase_22_event_parity_contract.py`：锁定本阶段 36 个组件的新增回调必须同时出现在 `Options`、`Props` 与构造函数赋值中，并校验分派助手、双击窗口常量、open-type 白名单与失败原因枚举。
- 既有 35 个契约脚本全部通过。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。当前未宣称下拉刷新三阶段事件的跟手时机、表格双击判定阈值、输入法高度回调在真机上的表现的设备验证完成；这些表现需在真机复核。
