# 阶段 4A：原生交互与提示组件兼容性

## 1. 范围与基线

阶段 4A 在纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增 `UPCircleProgress`、`UPAlert`、`UPNotify`、`UPNoticeBar`、`UPActionSheet`、`UPBackTop`、`UPCollapse`、`UPCollapseItem`、`UPDropdown` 和 `UPDropdownItem`。最低兼容 API 为 API 24，产品目标与兼容 SDK 均为 `5.0.0(12)`。

十个组件及其 Props、选项和事件类型均从 `ultra-ui/Index.ets` 公共入口导出。示例工程只从 `@lingyun/ultra-ui-hos` 导入，不访问 HAR 内部源码。所有交互使用页面受控状态和本地回调，不保存跨页面业务数据，不自动导航，不发起网络请求，也不依赖 Vue/NVue、WebView 或外部运行时。

## 2. 进度与提示

| 组件 | 已实现的原生能力 | 兼容回退 |
| --- | --- | --- |
| `UPCircleProgress` | 百分比、环形前景/背景色、尺寸、线宽和内容 Builder | 百分比限制在 0 到 100；非法尺寸和颜色使用安全默认值 |
| `UPAlert` | 类型、明暗效果、标题、说明、图标、关闭按钮和点击/关闭回调 | `modelValue` 有值时优先于 `value`；关闭依次请求 `onVisibleChange(false)`、`onClose`、`onClosed` |
| `UPNotify` | 受控顶部通知、类型色、自定义前景/背景色和点击/关闭回调 | 关闭只发出 `onShowChange(false)` 请求；`duration` 保留输入，初版不在组件内部启动计时器 |
| `UPNoticeBar` | 单行或多条文本、图标、链接/关闭模式和本地事件 | `url`、`linkType` 仅随事件回传，不自动导航；跑马灯、速度和时长采用确定性静态表现 |

`UPAlert`、`UPNotify` 和 `UPNoticeBar` 不直接修改调用方状态。页面收到变更请求后决定是否写回，因此关闭按钮和业务状态始终保持单向数据流。公告的远程地址只是兼容字段，HAR 坚持无网络边界。

## 3. 操作容器与返回顶部

`UPActionSheet` 使用受控 `show`、原生遮罩和底部面板展示操作项。禁用或加载中的操作项不会触发选择；合法选择先发出 `onSelect`，并在 `closeOnClickAction` 为真时请求关闭。取消和遮罩分别使用 `cancel`、`overlay` 原因回调，`openType`、动态键名和部分跨端样式字段保留为兼容输入，不调用平台授权或业务服务。

`UPBackTop` 根据 `scrollTop >= top` 决定是否显示。点击时先调用 `onClick`，再通过 `onBackToTop` 回传规范化后的 `duration`；组件不持有外部 `Scroller`，页面负责执行真实的 `scrollTo`。`duration` 是回调参数而不是组件内部滚动动画承诺。

## 4. 折叠组件

`UPCollapse` 通过当前组合内的 `UPCollapseContext` 协调子项，但业务值仍由页面受控状态持有。`modelValue` 非空时优先于 `value`：手风琴模式回传单值或空字符串，普通模式回传值数组。切换时先发出 `onValueChange`，再发出包含 `value`、`name`、`open` 的 `onChange`。组级或项级 `disabled`、`clickable = false` 会阻止请求，但不会改写受控显示值。

`UPCollapseItem` 嵌套时从组上下文获得名称和展开状态；没有显式 `name` 时使用组合期索引。独立使用时安全回退到本地 `open`/`isOpen` 显示。`duration`、`cellCustomClass` 和无法映射的 CSS 动画字段在首版为安全 no-op，内容使用确定性显示或隐藏。

## 5. 下拉组件

`UPDropdown` 由页面持有 `openIndex`。标题点击、遮罩点击或单选完成时通过 `onOpenChange` 请求新索引，并按结果调用 `onOpen` 或 `onClose`。`closeOnClickOverlay` 优先于旧字段 `closeOnClickMask`；非法 `direction` 回退为 `down`。`duration` 和旧版 `menu` 字段保留兼容输入，首版不承诺跨端展开动画或动态菜单解析。

`UPDropdownItem` 的 `modelValue` 非空时优先于 `value`。单选回传一个值并请求父级关闭，多选回传增删后的数组并保持菜单打开；禁用项不触发事件。脱离 `UPDropdown` 时使用关闭的安全上下文，标题、选中标签和选项列表仍可预测渲染。

## 6. 原生差异与验证

跨端 `duration`、跑马灯、复杂过渡、CSS class、平台 `openType` 和外部滚动控制等字段，在 API 24 原生首版中可能是静态表现、回调参数或安全 no-op。非法枚举、数值和缺失上下文均使用确定性回退，不通过网络或平台服务补偿。

示例新增 `circle-progress`、`alert`、`notify`、`notice-bar`、`action-sheet`、`back-top`、`collapse`、`collapse-item`、`dropdown` 和 `dropdown-item` 十条中文路由，展示非默认状态和页面写回事件。

可执行静态契约：

```bash
python3 scripts/test_phase_4a_native_interaction_contract.py
python3 scripts/test_documentation_contract.py
python3 scripts/test_sample_contract.py
```

完整本机验证继续执行所有 Python 契约、边界检查、工具链检查、截图脚本和 HAR/HAP 构建。没有连接 HarmonyOS 真机或模拟器时，设备验证、点击、滚动、动画和截图输出为 `skipped`；`skipped` 不表示设备渲染通过。HAR/HAP 编译成功和静态契约通过也不能替代真机或模拟器验收。
