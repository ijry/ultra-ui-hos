# Ultra UI HarmonyOS NEXT 阶段 11 设计：容器、轮播与底部导航

- 日期：2026-08-30
- 上游参考：uview-plus 3.x 及关联 iOS/Android 原生实现
- 目标：在不引入运行时模板、网络或业务路由的前提下，补齐一批可复用的原生展示与导航组件。

## 范围

本阶段新增以下八个公开组件：

- `UPView`：通用内容容器，保留 flex、尺寸、颜色、边距、边框和点击回调。
- `UPBox`：本地信息面板，支持背景色、圆角、标题和内容 Builder。
- `UPSection`：带左侧标识线、标题、辅助文案和箭头的区块标题。
- `UPToolbar`：Picker 等受控面板复用的取消/标题/确认工具栏。
- `UPSwiper`：本地轮播容器，支持受控索引、自动播放、循环、方向、指示器和点击/切换事件。
- `UPSwiperIndicator`：可独立使用的页码指示器，支持点状、线状和点击索引回调。
- `UPTabbar`：受控底部导航栏，支持 String/Number 风格值、禁用项、颜色、安全区和占位。
- `UPTabbarItem`：可独立呈现的底部导航项，供宿主按子项方式组合。

## 原生映射

- 容器组件使用 `Column`、`Row`、`Flex`、`Stack` 和 `UPStyle`；非法尺寸、颜色、枚举和样式回退到稳定默认值。
- `UPSwiper` 使用 ArkUI `Swiper`，只呈现本地文本或本地资源图片；远程图片地址不发起请求，而是显示稳定占位。
- `UPSwiper` 的 `current` 由页面持有，自动播放由原生 `Swiper` 控制；切换事件提供索引、条目和来源字段。
- `UPTabbar` 使用 `Row` 与受控按钮布局，不主动修改宿主路由栈；`url`、`linkType` 等跨端元数据只通过事件回传。
- `UPToolbar` 和 `UPTabbar` 的安全区、固定定位及窗口层级采用宿主布局语义；不模拟 DOM 定位或全局单例。

## API 约束

- 每个组件提供 `Options`、`Props`、公开 `@Component` 和 `Index.ets` 导出。
- 事件回调全部可选；未提供回调时组件只渲染，不发生隐式业务副作用。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入，固定使用本地数据和中文文案。
- 不使用 WebView、网络请求、运行时 JSON 映射、Vue/NVue 或业务路由。

## 验收

- 阶段 11 静态契约覆盖八个组件的默认值、核心字段、事件和公共导出。
- Components O 增加八条示例路由，并由 `SamplePage` 分发。
- README 统计更新为 100 个组件/控制器（98 个组件 + 2 个控制器）和 98 条组件示例路由，同时保留历史统计短语。
- HAR/HAP 构建、全量静态契约、边界检查和 `git diff --check` 通过；无设备时截图验证明确输出 `skipped`。
