# 阶段 11 兼容说明

阶段 11 增加 `UPView`、`UPBox`、`UPSection`、`UPToolbar`、`UPSwiper`、`UPSwiperIndicator`、`UPTabbar` 与 `UPTabbarItem`，均使用 HarmonyOS NEXT API 24 原生 ArkUI 实现。

## 范围

- `UPView` 和 `UPBox` 提供本地容器、尺寸、边距、边框、标题和内容 Builder；样式字段通过 `UPStyle` 解析并在非法值时安全回退。
- `UPSection` 提供区块标题、辅助文案、左侧标识线、箭头和点击事件；`UPToolbar` 提供受控面板复用的取消/标题/确认操作。
- `UPSwiper` 使用原生 `Swiper` 呈现本地文本或本地资源图片，支持受控索引、循环、方向、自动播放、指示器和切换/点击事件。
- `UPSwiperIndicator` 支持点状和线状本地页码显示，并将点击索引回传给宿主。
- `UPTabbar` 与 `UPTabbarItem` 使用 `Row` 和受控按钮布局，支持禁用项、颜色、安全区、占位、徽标以及 `url`/`linkType` 元数据回传。

## 边界

这些组件只使用 ArkUI 原生布局和本地数据，不使用 WebView、网络请求、运行时 JSON 映射、Vue/NVue 或业务路由。`UPSwiper` 遇到远程图片地址时不发起请求，仅显示稳定的安全占位；`url`、`linkType` 等导航元数据不会在组件内部打开或修改路由。

未直接映射到 ArkUI 的字段保留在 Props/Options 中，并以安全回退、no-op 或诊断方式处理，不在组件内部抛出业务异常。固定定位、安全区和窗口层级语义由宿主页面布局负责。

## 验证

- 最低兼容 API：24；目标 SDK：`5.0.0(12)`。
- 阶段 11 静态契约覆盖八个组件的默认值、核心字段、事件、公共导出和 Components O 示例路由。
- HAR/HAP 构建、全量静态契约、边界检查和 `git diff --check` 在本机工具链中验证。
- `设备验证` 需要连接 HarmonyOS 目标；无设备时脚本输出 `skipped`，不视为失败。
