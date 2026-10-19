# 阶段 21 兼容说明

阶段 21 不新增组件，而是把上游 138 个 UI 目录的 props 与已实现的 ArkTS `Props` 类逐字段对齐：审计脚本原先报出 13 个组件共 28 个上游字段没有对应入口，本阶段全部补齐并接入渲染或行为，`scripts/test_upstream_prop_coverage.py` 现已归零。所有改动仍面向 HarmonyOS NEXT API 24，新增符号均从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `internal/UPTriggerInput.ets`（新增）承载上游 picker 家族的 `hasInput` 触发行：`UPTriggerInputProps` 是 `inputProps` 的具名子集（`border`/`placeholder`/`disabled`/`disabledColor`/`fontSize`/`color`/`inputAlign`/`shape`），`upTriggerInputStyle()` 复刻上游 `inputPropsInner` 的展开顺序（外层字段先落位、`inputProps` 覆盖同名键），`upTriggerBorderSupported()` 保留 `surround`/`bottom`/`none` 三种边框，`upTriggerBottomOnly()`/`upTriggerBorderWidth()`/`upTriggerRadius()`/`upTriggerTextAlign()` 负责外观映射，`upTriggerFormat()` 复刻上游 dayjs 的 `YYYY`/`MM`/`DD`/`HH`/`mm`/`ss` 令牌。触发行高 38、左右内边距 9、描边 `#dadbde`、占位色 `#c0c4cc`，默认占位文案取上游 i18n 的「请选择」。
- `UPPicker` 补齐 `hasInput`、`inputBorder`、`inputProps`、`placeholder`、`disabled`、`disabledColor`：`hasInput` 打开时在弹层上方渲染只读触发行，`triggerLabel()` 复刻上游 `inputLabel`（已确认的各列值以 `/` 连接），点击触发行走 `openByTrigger()` 并回传 `onShowChange(true)`，`disabled` 时不响应点击且底色落到 `disabledColor`。
- `UPDatePicker` 与 `UPTimePicker` 补齐同一组字段并各自新增 `format`：为空时分别按 `YYYY-MM-DD` 与 `HH:mm:ss` 兜底，与上游 `mode` 分支的默认格式一致；触发行点击回传新增的 `onTriggerClick`，由宿主决定是否展开面板。
- `UPTreeSelect` 从 8 个字段扩到 26 个，完整覆盖上游 `u-tree`：新增 `data`（与既有 `options` 并存）、`props`（上游的键名映射，本端别名为 `keys`）、`nodeKey`、`showCheckbox`、`defaultExpandAll`、`defaultExpandedKeys`、`defaultCheckedKeys`、`expandOnClickNode`、`checkOnClickNode`、`checkStrictly`、`accordion`、`highlightCurrent`、`currentNodeKey`、`indent`、`iconSize`、`checkboxSize`、`expandIcon`、`collapseIcon`。行为侧 `initTree()`/`collectVisibleNodes()`/`toggleExpand()`（含 `accordion` 折叠同级）/`setNodeChecked()`/`syncParentChecked()`/`emitCheck()`/`handleNodeClick()` 与上游逐函数对应，三态勾选（选中、半选、未选）由 `checkedKeys` 与 `halfCheckedKeys` 维护，`checkStrictly` 打开时不再联动父子。新增 `onNodeClick`、`onCheck`、`onCheckChange`、`onNodeExpand`、`onNodeCollapse`、`onCurrentChange` 六个事件，与上游 emits 一一对应；常量保留上游取值：缩进 32、图标 14、勾选框 16、展开图标 `play-right-fill`、折叠图标 `arrow-down-fill`、当前行底色 `#ecf5ff`、禁用透明度 0.55。
- `UPCalendar` 补齐 `forbidDays`、`forbidDaysToast`、`monthFormat`：`upCalendarForbidden()` 复刻 `isForbid()`，命中时不选中并回传新增的 `onForbid`（默认文案取上游 i18n 的「该日期已禁用」），禁用日期渲染为 `#c0c4cc`；`upCalendarMonthTitle()` 在 `monthFormat` 为空时按「YYYY年MM月」输出，否则按占位符替换。
- `UPCalendarStrip` 补齐 `fullCalendarProps`：`UPCalendarStripFullProps` 是展开面板的具名子集（`title`/`activeColor`/`monthFormat`/`forbidDays`/`forbidDaysToast`），由 `fullTitle()` 等五个私有方法覆盖内嵌 `UPCalendar` 的对应入参。
- `UPCropper` 补齐 `lockWidth`、`lockHeight`：上游只声明未消费，本端把它们视为强制锁定对应轴，落到 `upCropperConstraint()` 的结果上并记录诊断。
- `UPUpload` 补齐 `extension`、`videoPreviewObjectFit`：`upUploadExtensionAllowed()` 按后缀白名单过滤（空数组表示不限制），公开的 `accept(name)` 供宿主在选文件前自查；`UP_UPLOAD_OBJECT_FIT_MODES` 保留上游 `contain`/`fill`/`cover` 三种取值。
- `UPView` 补齐上游的 `backgroundColor`（既有 `bgColor` 保留为别名，显式设置 `backgroundColor` 时以它为准）与 `flex1`（非空即 `flexGrow(1)`）。
- `UPGuide` 补齐上游的 `zIndex`，`stackLevel` 保留为别名；显式设置 `stackLevel` 时以它为准，两者统一经 `stackZIndex()` 落到 `.zIndex()`。
- `UPFormItem` 补齐 `leftIconStyle` 并让 `leftIcon` 真正参与渲染，图标字号与颜色从该样式读取。
- `UPFloatingBubble` 补齐 `list` 与 `borderColor`，复刻上游的展开菜单：点击主气泡切换展开态，子项支持逐项 `color`/`backgroundColor`/`borderColor` 覆盖，选中回传新增的 `onItemClick`（对应上游 `item-click`）。
- `UPSelect` 补齐 `overlayStyle`，遮罩底色与透明度可被它覆盖。
- `UPTable2` 补齐 `sortBy`、`sortMethod`、`context`：`upTable2SortValue()` 复刻 `getSortValueBy()`（数组按顺序拼接多列、单键覆盖列字段、缺省回退列自身键），`upTable2ColumnSortBy()` 复刻 `getColumnSortBy()` 的列级优先，`sortMethod(left, right, key, context)` 命中时完全接管比较。
- `UPNovelReader` 补齐 `autoBack`，打开时通过诊断说明为何只回传 `onBack`。

## 边界

以下字段虽已具备入口，但在 HarmonyOS 上保留为 no-op 兼容位或改由宿主承担，传入时通过 `UPCompatibilityDiagnostics.report()` 记录一条诊断：

- `inputProps`：上游用对象展开透传给 `up-input`，ArkTS 禁止索引签名，因此只转发建模的八个字段；其余键会被忽略并记录诊断。
- `UPTreeSelect` 的 `props`/`keys`：`children` 始终从具名 `children` 字段读取，键名映射只影响标签、节点键与禁用位的取值来源；越界键名回落默认字段并记录诊断。
- `UPUpload` 的 `extension`：组件不打开系统文件选择器，白名单只对宿主提供的文件名生效；`videoPreviewObjectFit` 不渲染视频预览，仅作信息透传。
- `UPCropper` 的 `lockWidth`/`lockHeight`：上游声明后从未读取，本端赋予「强制锁轴」语义，属于有意的行为增强而非等价复刻。
- `UPCalendarStrip` 的 `fullCalendarProps`：只转发建模的五个面板字段。
- `UPNovelReader` 的 `autoBack`：`uni.navigateBack` 不可用，页面返回由宿主处理。
- `UPGuide` 与 `UPView` 的别名字段：`stackLevel` 与 `bgColor` 是本端早期命名，保留以免破坏既有调用；与上游同名字段同时存在时以显式设置的那个为准。私有方法不能命名为 `zIndex`，否则与 ArkUI `CommonAttribute` 冲突。

本阶段改动只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_upstream_prop_coverage.py`：遍历上游 138 个 UI 目录，解析 `props.js` 与主 `.vue` 的 props 块，逐字段核对对应 ArkTS `Props`/`Options`，任何缺口即失败；当前输出 `PASS (138 directories)`。
- 新增 `scripts/test_phase_21_prop_parity_contract.py`：锁定本阶段 15 个组件的新增字段、默认值、行为接线（触发行、三态勾选、禁用日期、排序取值、展开菜单等）、`UPTriggerInput` 常量与公共导出。
- 既有 33 个契约脚本全部通过；`scripts/test_phase_10_advanced_selection_media_contract.py` 与 `scripts/test_phase_16_transition_album_contract.py` 因 `UPTreeSelect` 重写与 `UPGuide` 新增 `zIndex` 同步更新了断言。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。当前未宣称触发行的键盘与焦点行为、树形三态勾选的大数据量性能、悬浮按钮展开动画的设备验证完成；这些表现需在真机复核。
