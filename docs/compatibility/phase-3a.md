# 阶段 3A：内容与输入组件兼容性

## 1. 范围与基线

阶段 3A 在纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增 `UPText`、`UPImage`、`UPEmpty`、`UPLoadingPage`、`UPSearch` 和 `UPCodeInput`。最低兼容 API 为 API 24，产品目标与兼容 SDK 均为 `5.0.0(12)`。

所有组件均由 `ultra-ui/Index.ets` 作为唯一公共入口导出；示例工程只从该 HAR 入口导入，不访问组件库内部源码。实现采用无网络边界，不引入网络能力、页面内置导航、运行时代码生成或跨端运行时。

## 2. 内容与状态组件

| 组件 | 已实现的本地能力 | 兼容回退 |
| --- | --- | --- |
| `UPText` | 文本、价格/手机号等保守格式化、前后图标、对齐、行数、装饰及点击回调 | `href`、`openType` 和拨号意图不会由组件自动执行，只回传 `onOpen`/`onCall` 事件 |
| `UPImage` | 尺寸、填充模式、圆角/圆形、加载/错误占位及点击回调 | 仅渲染本地资源；无效源稳定回退到图标占位 |
| `UPEmpty` | 数据、搜索、权限、订单等空状态图标、文字、尺寸与显示控制 | 未识别的 `mode` 回退为数据空状态 |
| `UPLoadingPage` | 受控 `loading` 显示、原生加载图标、文字、颜色、层级与本地图片 | 未识别的加载模式回退为圆形加载图标 |

`UPImage` 和 `UPLoadingPage.image` 只接受本地资源：`resource://`、`file://`、绝对本地路径或 `$rawfile:`。非本地资源不会加载，因而不会产生网络请求；组件显示确定性占位或原生加载图标。

## 3. 搜索与验证码输入

- `UPSearch` 保留上游的 `modelValue`、`value`、`clearabled`、焦点、图标、操作区、样式和输入事件字段。`clearabled` 是上游保留拼写，未改为其它名称。
- `UPSearch` 在 `modelValue` 不为 `null`/`undefined` 时优先于 `value`；空字符串是有效受控值。原生 `TextInput` 回传 `onInput`、`onChange`、`onFocus`、`onBlur`、`onSearch` 等本地事件，清除时先回传空值再触发 `onClear`。
- `UPCodeInput` 同样遵循 `modelValue` 优先于 `value`。它用透明的原生 `TextInput` 承接键盘输入，并使用确定性的格子显示 `box`/`line`、间距、焦点指示、掩码和粗体。
- `maxlength` 采用安全非负长度回退；`disabledDot` 开启时会过滤 `.`；`disabledKeyboard` 只禁用原生输入，不抛出异常。达到最大长度时仅触发本地 `onFinish` 回调。
- `adjustPosition`、动画、长按菜单、WebP 等平台差异字段保留 Props 兼容性，但在 API 24 本地实现中是安全 no-op 或通过兼容诊断记录，不会调用额外平台服务。

## 4. 示例、边界和验证

示例工程新增六条路由：`text`、`image`、`empty`、`loading-page`、`search`、`code-input`。图片示例使用 `$rawfile:` 本地资源；其余示例只使用固定中文文本、页面 `@State` 和类型化回调。

阶段静态契约可执行：

```bash
python3 scripts/test_phase_3a_content_input_contract.py
```

完整本机验证继续执行所有 Python 契约、边界检查、工具链检查、截图脚本和 HAR/HAP 构建。没有连接 HarmonyOS 真机或模拟器时，设备安装、点击和截图验证输出为 `skipped`；`skipped` 不是设备验证通过，只表示设备验证未执行。
