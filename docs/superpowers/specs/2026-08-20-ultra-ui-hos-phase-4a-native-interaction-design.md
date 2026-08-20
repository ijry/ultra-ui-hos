# ultra-ui-hos Phase 4A 设计：原生交互与环形进度

**状态：已确认**  
**范围：** `UPCircleProgress`、`UPAlert`、`UPNotify`、`UPNoticeBar`、`UPActionSheet`、`UPBackTop`、`UPCollapse`、`UPCollapseItem`、`UPDropdown`、`UPDropdownItem`

## 1. 目标与边界

Phase 4A 在现有纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中补齐关联 Android 工程已经实现的十个进度、提示和原生交互组件。公开字段、默认值、字符串枚举和值回调尽量保持 uview-plus 3.x、Android 和 iOS 生成端同名可用；具体渲染和状态流使用 HarmonyOS NEXT 原生能力实现。

本阶段继续以 API 24 和 `5.0.0(12)` 为最低兼容基线。示例 HAP 只能从 HAR 公共入口导入组件。组件不解析 JSON，不使用 Vue/NVue、WebView、FastView、网络请求、远程资源、运行时代码生成或业务路由。

本阶段采用页面受控状态：`show`、`modelValue`、`value`、展开项和选中项由页面 `@State` 持有，组件只根据 Props 渲染并通过显式回调提出状态变更。组件不得在内部永久覆盖调用方传入的受控值。

## 2. 分批架构

实现拆成三个可单独编译和验证的子批次：

1. **进度与提示：** `UPCircleProgress`、`UPAlert`、`UPNotify`、`UPNoticeBar`；
2. **操作容器：** `UPActionSheet`、`UPBackTop`；
3. **折叠与下拉：** `UPCollapse`、`UPCollapseItem`、`UPDropdown`、`UPDropdownItem`。

每个子批次均先扩展 Phase 4A 静态契约并确认缺失 API 导致失败，然后增加 ArkTS 实现、公共导出和中文示例。全部子批次完成后统一更新兼容文档、README 计数并执行 HAR/HAP 构建。

## 3. 共享数据与状态规则

- 所有 Props 接受 `UPRawValue` 和 `UPStyleInput`，构造函数必须保留合法的 `0`、`false`、空字符串和空数组语义。
- 颜色使用 `UPColor` 与主题色解析；尺寸使用 `UPUnit` 或组件专用非负数字解析；非法值安全回退而不抛异常。
- `modelValue` 在非 `null`/`undefined` 时优先于 `value`。单值比较使用字符串等价语义，以兼容生成端的数字/字符串值。
- 需要列表输入的 API 使用显式 ArkTS 结构，而不是把对象塞入 `UPRawValue`。操作项和下拉选项分别使用 `UPActionSheetAction` 与 `UPDropdownOption`。
- 组件可以使用短暂的视觉状态，例如按压效果或本次组合中的索引，但不能把它作为外部受控状态的替代来源。
- 动画、定时滚动和平台专有安全区字段在 API 24 无稳定等价能力时采用确定性静态呈现或安全 no-op，并在兼容文档中列出。
- 点击链接、返回顶部、关闭弹层和选择选项只发出本地回调。调用方负责导航、滚动容器控制、网络请求或其他业务副作用。

## 4. 进度与提示组件

### 4.1 `UPCircleProgress`

`UPCircleProgressProps` 保留 Android 当前 `percentage`、`customStyle` 基线，并补齐原生呈现所需且与 uview-plus 同名的 `activeColor`、`inactiveColor`、`width`、`borderWidth` 字段。主体支持唯一的尾随 `contentBuilder`，默认内容显示格式化百分比。

- `percentage` 默认 `30`，解析后限制在 `0...100`；
- `width` 默认 `100`，`borderWidth` 默认 `5`，均使用合法正数回退；
- 使用 ArkUI 原生环形 `Progress`，不手写定时动画；
- `activeColor` 默认 success 色，`inactiveColor` 默认边框灰；
- `customStyle` 可覆盖稳定支持的尺寸、外边距和透明度。

### 4.2 `UPAlert`

`UPAlertProps` 包含 `title`、`type`、`description`、`closable`、`showIcon`、`effect`、`center`、`fontSize`、`transitionMode`、`duration`、`icon`、`modelValue`、`value`、`customStyle`，以及 `onVisibleChange`、`onClick`、`onClose`、`onClosed`。

- `type` 支持 `primary`、`success`、`warning`、`error`、`info`，非法值回退 `warning`；
- `effect` 支持 `light`、`dark`，非法值回退 `light`；
- 可见性由 `modelValue ?? value` 决定，关闭按钮先调用 `onVisibleChange(false)`，再依次调用 `onClose` 和 `onClosed`；
- `transitionMode`、`duration` 保留生成端字段，但初版使用确定性显示/隐藏，不承诺跨端动画时序；
- 标题、描述和图标使用 ArkUI 原生 `Row`/`Column`/`Text`/`UPIcon`。

### 4.3 `UPNotify`

`UPNotifyProps` 包含 Android 基线字段 `top`、`type`、`color`、`bgColor`、`message`、`duration`、`fontSize`、`safeAreaInsetTop`、`customStyle`，并增加明确的 `show`、`onShowChange`、`onClick`、`onClose`。

- `show` 默认 `false`，由页面受控；
- `type` 与 `UPAlert` 使用相同安全枚举和主题色；显式 `color`/`bgColor` 优先；
- `top` 只控制组件在调用方容器内的顶部外边距，不抢占系统窗口；
- `duration` 保留但 HAR 不自行持有跨页面计时器，自动关闭由页面控制；
- 点击只回调，关闭请求通过 `onShowChange(false)` 和 `onClose` 发出。

### 4.4 `UPNoticeBar`

`UPNoticeBarProps` 包含 `text`、`direction`、`step`、`icon`、`mode`、`color`、`bgColor`、`speed`、`fontSize`、`duration`、`disableTouch`、`url`、`linkType`、`justifyContent`、`customStyle`，以及 `show`、`onClick`、`onClose`、`onShowChange`。

- `text` 接受单个 `UPRawValue` 或显式 `Array<UPRawValue>`，归一化为空项已过滤的字符串数组；
- `direction` 支持 `row`、`column`；`mode` 支持空字符串、`link`、`closable`；
- `row` 将消息以固定分隔符连接，`column`/`step` 初版确定性显示第一条，不运行不可控定时轮播；
- `speed`、`duration`、`disableTouch` 保留兼容输入，初版不承诺连续跑马灯或触摸拖动；
- `url`、`linkType` 只随 `UPNoticeBarClickEvent` 回传，组件不自动导航；
- `closable` 模式调用 `onShowChange(false)` 和 `onClose`，由页面隐藏组件。

## 5. 操作容器

### 5.1 `UPActionSheet`

`UPActionSheetAction` 定义 `name`、`subname`、`color`、`fontSize`、`disabled`、`loading`。`UPActionSheetProps` 包含 `show`、`title`、`description`、`actions`、`nameKey`、`subnameKey`、`cancelText`、`closeOnClickAction`、`safeAreaInsetBottom`、`openType`、`closeOnClickOverlay`、`round`、`wrapMaxHeight`、`index`、`customStyle`，以及 `onShowChange`、`onSelect`、`onCancel`、`onClose`、`onClickOverlay`。

- 使用原生全屏 `Stack`、半透明遮罩和底部 `Column`；不依赖业务页面路由；
- 操作列表使用 `Scroll`，高度由 `wrapMaxHeight` 和稳定上限共同约束；
- 禁用项和加载项不可选择；`UPActionSheetSelectEvent` 回传 `index` 与完整 action；
- 选中合法项后先发 `onSelect`，`closeOnClickAction` 为真时再请求 `onShowChange(false)` 和 `onClose`；
- 取消按钮发出 `onCancel` 后请求关闭；遮罩只有在 `closeOnClickOverlay` 为真时请求关闭；
- `openType` 只作为兼容字段保留，不调用系统授权或分享服务。

### 5.2 `UPBackTop`

`UPBackTopProps` 包含 `mode`、`icon`、`text`、`duration`、`scrollTop`、`top`、`bottom`、`right`、`zIndex`、`iconStyle`、`customStyle`、`onClick`、`onBackToTop`。

- 当解析后的 `scrollTop >= top` 时显示，否则不占布局；
- `mode` 支持 `circle`、`square`，非法值回退 `circle`；
- 组件只渲染悬浮按钮的外观并回调 `onClick`、`onBackToTop`；
- 调用方在回调中使用自己的 `Scroller.scrollTo`，HAR 不搜索或控制外部滚动容器；
- `bottom`、`right`、`zIndex` 应用于组件自身定位修饰；`duration` 仅随事件语义保留。

## 6. 折叠组件

`UPCollapse` 是状态契约和上下文提供者，`UPCollapseItem` 是自描述子项。新增内部 `UPCollapseContext`，保存当前组合的受控打开值、手风琴模式、组级禁用/可点击规则，并向子项提供统一的 `requestToggle(name)` 回调。上下文不在组件库内永久修改打开集合。

### 6.1 `UPCollapse`

`UPCollapseProps` 包含 `value`、`modelValue`、`accordion`、`border`、`arrow`、`disabled`、`clickable`、`customStyle`、`onChange`、`onValueChange` 和唯一尾随 `contentBuilder`。

- `accordion = true` 时值归一化为单个 `UPRawValue` 或空字符串；再次点击已打开项请求关闭；
- 非手风琴模式使用 `Array<UPRawValue>`；点击项生成增删后的新数组；
- `onValueChange` 回传生成端可直接写回的值，`onChange` 回传 `UPCollapseChangeEvent { value, name, open }`；
- 组级 `disabled` 或 `clickable = false` 阻止所有切换，但内容仍按受控值渲染。

### 6.2 `UPCollapseItem`

`UPCollapseItemProps` 包含 `title`、`titleStyle`、`value`、`label`、`disabled`、`isLink`、`clickable`、`border`、`align`、`name`、`icon`、`duration`、`showRight`、`iconStyle`、`rightIconStyle`、`cellCustomStyle`、`cellCustomClass`、`customStyle`、`isOpen`、`open`、`onClick` 和尾随 `contentBuilder`。

- 嵌套在 `UPCollapse` 时，打开状态由组上下文决定；独立渲染时 `open` 优先于 `isOpen`；
- `name` 缺失时使用组合期视觉索引作为稳定回退；
- 标题区域点击时先向组请求切换，再回调 `UPCollapseItemClickEvent { name, open }`；
- `disabled`、`clickable = false` 阻止切换；`isLink` 只影响箭头表现，不自动导航；
- `duration` 与 `cellCustomClass` 保留为兼容字段，初版内容采用确定性显示/隐藏和样式 no-op。

## 7. 下拉组件

`UPDropdown` 负责菜单外观、当前打开项索引和遮罩关闭契约，`UPDropdownItem` 负责标题、选项列表、受控选择值和回调。新增内部 `UPDropdownContext`，只在当前组合中协调打开请求，不保存业务选中值。

### 7.1 `UPDropdown`

`UPDropdownProps` 包含 `activeColor`、`inactiveColor`、`closeOnClickMask`、`closeOnClickSelf`、`duration`、`height`、`borderBottom`、`titleSize`、`borderRadius`、`menuIcon`、`menuIconSize`、`customStyle`、`closeOnClickOverlay`、`direction`、`menu`、`bgColor`、`openIndex`、`onOpenChange`、`onOpen`、`onClose` 和尾随 `contentBuilder`。

- `openIndex` 默认 `-1`，由页面持有；子项标题点击请求新索引或 `-1`；
- `closeOnClickOverlay` 非空时优先于 `closeOnClickMask`；
- `direction` 支持 `down`、`up`，非法值回退 `down`；
- 打开状态变化先调用 `onOpenChange(index)`，再按结果调用 `onOpen(index)` 或 `onClose()`；
- `duration` 和旧版 `menu` 字段保留兼容输入，初版不承诺跨端动画或动态菜单解析。

### 7.2 `UPDropdownItem`

`UPDropdownOption` 定义 `label`、`value`、`disabled`。`UPDropdownItemProps` 包含 `modelValue`、`value`、`title`、`options`、`disabled`、`height`、`closeOnClickOverlay`、`customStyle`、`multiple`、`onValueChange`、`onChange`、`onSelect`。

- `modelValue` 非空时优先于 `value`；`multiple = false` 使用单值，`multiple = true` 使用数组；
- `title` 为空时使用当前选中选项的 label，仍为空时显示确定性中文回退；
- 禁用项不触发事件；合法选择发出 `UPDropdownItemSelectEvent { index, option, value }`；
- 单选后请求父级关闭；多选保持打开，并回传增删后的数组；
- 子项脱离 `UPDropdown` 时使用关闭的安全上下文，标题和当前值仍可预测渲染。

## 8. 示例、文档与计数

示例新增 10 条中文路由，并按能力拆成三个新分组：

- `Components F`：`circle-progress`、`alert`、`notify`、`notice-bar`；
- `Components G`：`action-sheet`、`back-top`；
- `Components H`：`collapse`、`collapse-item`、`dropdown`、`dropdown-item`。

每条路由至少展示一个默认状态、一个非默认状态和一个真实本地回调。操作菜单、通知、折叠和下拉示例使用页面 `@State` 写回组件请求的值；返回顶部示例持有自己的 `Scroller`。示例不复制组件实现，不访问 HAR 内部文件。

Phase 4A 完成后 README 计数从 `44 个已实现组件/控制器`、`42 条组件示例路由` 更新为 `54 个已实现组件/控制器`（53 个组件 + 1 个控制器）、`52 条组件示例路由`。新增 `docs/compatibility/phase-4a.md`，记录字段、事件、安全回退和设备验证限制。

## 9. 验证策略

新增 `scripts/test_phase_4a_native_interaction_contract.py`，静态检查十个组件文件、Props 字段、事件类型、公共导出、上下文、十条示例路由、文档计数和禁止依赖。现有文档和示例契约同步扩展。

最终验证必须包含：

```bash
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/capture-screenshots.sh
./scripts/build.sh
git diff --check
```

无连接 HarmonyOS 真机或模拟器时，设备安装、点击、动画、滚动和截图验证必须报告为 `skipped`。HAR/HAP 编译成功和静态契约通过不能替代真机或模拟器的渲染验收。
