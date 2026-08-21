# 阶段 5：导航核心组件兼容性

## 1. 范围与基线

阶段 5 在纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增九个导航核心组件：`UPStatusBar`、`UPSafeBottom`、`UPNavbar`、`UPNavbarMini`、`UPTabs`、`UPTabsItem`、`UPSubsection`、`UPSteps` 和 `UPStepsItem`。最低兼容版本为 API 24，产品目标与兼容 SDK 均为 `5.0.0(12)`。

组件 Props、Options、事件类型和 `UPNavigationAdapter` 均从 `ultra-ui/Index.ets` 公共入口导出。示例工程只从 `@lingyun/ultra-ui-hos` 导入组件，导航状态由页面持有并通过回调写回。HAR 不依赖 Vue/NVue、WebView、网络请求或业务路由运行时。

## 2. 系统区域与导航栏

| 组件 | 已实现的原生能力 | 兼容回退 |
| --- | --- | --- |
| `UPStatusBar` | 顶部系统区域背景、显隐和高度变化回调 | 安全区能力不可用时高度回退为 `0`，不伪造固定设备高度 |
| `UPSafeBottom` | 底部安全区域背景和内容 Builder | 安全区能力不可用时底部插入高度为 `0` 的安全区域 |
| `UPNavbar` | 标题、左右文本/图标、边框、占位、顶部安全区和返回事件 | `fixed` 使用稳定的顶部布局近似；`autoBack` 只在注入 `UPNavigationAdapter` 时执行返回 |
| `UPNavbarMini` | 返回箭头、首页图标、透明背景和首页重启事件 | `homeUrl` 只传给实例级 `relaunch` 适配器，不在组件库内解析业务路由 |

`UPNavbar` 左侧操作先发出 `onLeftClick`，再调用 `navigateBack`。`UPNavbarMini` 首页操作先发出 `onHomeClick`，再调用 `relaunch`。适配器是实例级可选能力，缺失时组件仍可渲染并安全结束，不访问全局导航栈。

## 3. 标签与分段导航

`UPTabs` 使用列表驱动的受控 `current` 索引。合法且未禁用的条目点击时，组件先回传 `onClick`，再请求 `onCurrentChange` 并回传 `onChange`；长按通过 `onLongPress` 回传同一条目事件。`scrollable` 使用原生横向滚动近似，滚动居中和复杂指示器动画不作为首版行为承诺。`leftBuilder`、`rightBuilder` 和 `contentBuilder` 用于本地内容组合，不进行动态模板解析。

`UPTabsItem` 可作为独立内容组件使用，通过 `contentBuilder` 展示内容；脱离父级上下文时保持确定性安全呈现。`UPSubsection` 支持 `button` 与 `subsection` 两种模式，非法模式回退为 `button`，禁用条目不会提出索引变更，页面仍负责写回 `current`。

## 4. 步骤导航

`UPSteps` 通过 `UPStepsContext` 协调组合内的 `UPStepsItem`。页面持有 `current`，组件根据索引计算 `finish`、`process`、`wait` 和 `error` 状态；`direction` 支持 `row` 与 `column`，非法值回退为 `row`。点状模式、连接线颜色和标题/描述/icon Builder 均使用 ArkUI 原生布局实现。

`UPStepsItem` 点击时仅回传索引请求，不直接修改父页面状态。没有 `UPSteps` 上下文时，步骤项使用独立安全状态和传入 Builder；连接线、复杂过渡和跨端 CSS 类字段在首版为近似表现或安全 no-op。

## 5. 原生差异与验证

所有组件遵循页面受控状态和单向事件桥接。固定定位、动态尺寸、滚动居中、复杂动画、CSS class、业务 URL 解析和平台路由字段不被伪装成完整跨端能力；无法映射的字段采用稳定静态表现或安全 no-op。实现无网络，不读取远程资源，不通过运行时代码生成补偿。

本阶段可在本机确认公共导出、示例路由、源码边界、资源契约和 HAR/HAP 编译。没有连接 HarmonyOS 真机或模拟器时，设备验证和截图输出为 `skipped`；`skipped` 不表示设备渲染、点击、返回、重启、滚动或安全区行为已经通过设备验收。

专项静态契约：

```bash
python3 scripts/test_phase_5_navigation_contract.py
python3 scripts/test_sample_contract.py
python3 scripts/test_documentation_contract.py
```
