# 阶段 3B：布局与卡片兼容性

## 1. 范围与基线

阶段 3B 在纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增 `UPRow`、`UPCol`、`UPGrid`、`UPGridItem` 和 `UPCard`。最低兼容 API 为 API 24，产品目标与兼容 SDK 均为 `5.0.0(12)`。

五个组件均由 `ultra-ui/Index.ets` 作为唯一公共入口导出。示例工程只从 `@lingyun/ultra-ui-hos` 导入公开 API，不访问 HAR 内部源码。实现遵循无网络边界，使用原生布局和本地事件回调，不引入 Vue/NVue、WebView、网络请求、远程图片加载、运行时代码生成或业务状态存储。

## 2. 布局组件

| 组件 | 已实现的本地能力 | 兼容回退 |
| --- | --- | --- |
| `UPRow` | 12 栅格行、gutter、主轴/交叉轴对齐、尾随 Builder 和点击回调 | 非法 gutter、justify 或 align 使用安全默认值；子列脱离行时 gutter 回退为 0 |
| `UPCol` | span、offset、换行、内容对齐、尾随 Builder 和点击回调 | span 限制在 1 到 12，offset 限制在 0 到 11；非法值使用默认值 |
| `UPGrid` | 原生 `Grid`、列模板、列/行间隙、边框上下文、末行对齐和尾随 Builder | `col` 限制在 1 到 12，gap 使用合法非负单位；非法 align 回退为 left |
| `UPGridItem` | 网格单元背景、边框、内容 Builder 和点击事件 | 没有 `name` 时，事件 `name` 回退为当前渲染项 `index`；脱离 Grid 时使用单项安全上下文 |

`UPRow`/`UPCol` 使用声明式局部上下文与原生 `Flex` 换行，列宽相对于实际父容器而不是固定屏幕宽度。`UPGrid`/`UPGridItem` 使用原生 `Grid`，索引分配只属于一次渲染组合，不使用全局可变布局状态。

## 3. 卡片组件

`UPCard` 使用原生 `Column` 组织可选头部、固定主体和可选底部。它支持标题、副标题、头部缩略图、内外边距、圆角、边框、阴影、头尾分隔线、显隐开关、通用 `onClick` 以及 `onHeadClick`、`onBodyClick`、`onFootClick` 分区事件。事件统一携带 `index` 与 `area`（`card`、`head`、`body`、`foot`）。普通主体使用尾随 Builder，命名头部和底部使用 `headBuilder`、`footBuilder`。

缩略图只接受本地资源：`resource://`、`file://`、绝对本地路径和 `$rawfile:`。空源、远程源或无法识别的源不会发起网络请求，并安全回退为确定性占位。`boxShadow`、部分 CSS 样式和平台特有动画字段在 API 24 原生实现中采用保守解析、无视觉效果或安全 no-op，不会调用额外平台服务。

## 4. 示例与验证

示例新增 `row`、`col`、`grid`、`grid-item` 和 `card` 五条中文路由，展示布局跨度/间隙、索引回退、本地缩略图、Builder 区域和分区点击。示例不承担隐式导航、网络加载或业务提交。

可执行静态契约：

```bash
python3 scripts/test_phase_3b_layout_card_contract.py
python3 scripts/test_documentation_contract.py
```

完整本机验证继续执行所有 Python 契约、边界检查、工具链检查、截图脚本和 HAR/HAP 构建。没有连接 HarmonyOS 真机或模拟器时，设备验证与截图输出为 `skipped`；`skipped` 不表示设备渲染已通过，只表示设备验证未执行。
