# Phase 8 兼容说明：导航与更多组件

## 范围

本阶段新增 `UPPopover`、`UPTooltip`、`UPSticky`、`UPSwipeAction`、`UPSwipeActionItem`、`UPReadMore` 和 `UPPagination`，并在 Components L 中加入七条中文路由。

实现基线为 HarmonyOS NEXT、API 24 和 `5.0.0(12)`；所有组件只从 `@lingyun/ultra-ui-hos` 公共入口导出，不引入网络请求。

## 原生映射与降级

- Popover 和 Tooltip 使用页面内 Stack 承载；窗口级定位、全局 singleton 和系统剪贴板写入不由组件库执行，只提供回调。
- Sticky 在原生 sticky ListItem 外作为安全容器；动态滚动吸附由宿主滚动上下文驱动，并通过诊断说明。
- 滑动操作使用水平 PanGesture 和组合上下文协调；`threshold`、`closeOnClick`、禁用和 `autoClose` 已生效。
- ReadMore 通过最大高度和裁切近似折叠高度；Pagination 对当前页做边界钳制并支持单页隐藏。

## 设备验证状态

- 阶段 8 静态契约、全量构建和边界验证见交付记录。
- HarmonyOS 真机/模拟器交互与截图验证在无连接设备环境中为 `skipped`。
