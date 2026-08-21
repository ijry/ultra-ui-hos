# ultra-ui-hos 阶段 2B 设计：头像与独立输入

## 目标

在阶段 2A 的 HAR/HAP 基线上，补齐与关联 Android/iOS 工程对齐的头像、输入和轻量交互组件：`UPAvatar`、`UPAvatarGroup`、`UPInput`、`UPTextarea`、`UPSwitch`、`UPRate`、`UPNumberBox`，并为每个组件提供可导航的中文示例。

## 约束

- 继续使用 ArkTS/ArkUI 原生实现，最低 API 24、产品 SDK `5.0.0(12)`。
- 所有公共 API 从 `ultra-ui/Index.ets` 导出；示例只从 `@lingyun/ultra-ui-hos` 导入。
- 不引入网络请求、WebView、FastView、JSON 动态渲染、业务路由或运行时代码生成。
- 远程头像/图片地址不自动加载；不可安全解析的地址回退到本地文本、首字母、图标或颜色。
- 受控值同时保留 `value`/`modelValue` 兼容字段；事件使用显式类型的回调对象或值回调。

## 设计决策

### 1. 原生控件优先

`UPInput` 使用 `TextInput`，`UPTextarea` 使用 `TextArea`，`UPSwitch` 使用 `Toggle`。这样可获得系统输入法、焦点、提交和无障碍基础行为，组件只负责兼容字段、样式和事件桥接。

### 2. 可预测的本地回退

`UPAvatar` 仅对本地资源形式渲染 `Image`；当 `src`、`defaultUrl` 为空或不受支持时，优先显示 `icon`，其次显示 `text`/`name` 的首字符，最后显示稳定背景色。`randomBgColor` 不使用随机数，而由文本或 `colorIndex` 计算固定色板索引，保证示例和截图稳定。

### 3. 输入事件契约

- 输入过程中触发 `onInput` 和 `onChange`，值统一为字符串。
- 清除按钮触发 `onClear`，并同步发出空字符串输入/变更事件。
- 提交触发 `onConfirm`，回传 `{ value, key }`。
- `maxlength` 在组件侧截断，`showWordLimit`/`count` 显示当前长度。
- `password`、`clearable`、`readonly`、`disabled` 等字段只影响本地控件，不触发外部副作用。

### 4. 轻量状态组件

`UPSwitch` 以 `activeValue`/`inactiveValue` 表示跨端值，点击后通过 `onChange` 回传；`loading`、`disabled`、`asyncChange` 在鸿蒙侧安全阻止或保持稳定视觉状态。`UPRate` 使用本地星形图标/字符，支持整数和半星的安全近似；`UPNumberBox` 通过加减按钮处理步长、边界、整数和小数位，输入框可按 `disabledInput` 禁用。

## 验收标准

- 2B 静态契约测试覆盖七个组件、Props 字段、公共导出、事件类型、路由和示例导入边界。
- 全部 Python 契约、边界检查和工具链检查通过。
- HAR、HAP 构建成功，`upicon.ttf` 同时存在于两个产物。
- 无设备时截图脚本明确输出 `screenshots: skipped`，不伪造设备验证结果。
