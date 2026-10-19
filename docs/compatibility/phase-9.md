# 阶段 9 兼容说明

阶段 9 增加 `UPCountDown`、`UPCountTo`、`UPTimeline`、`UPCalendar`、`UPKeyboard` 与 `UPFloatingBubble`，均为 HarmonyOS NEXT API 24 的原生 ArkUI 实现。

## 范围

- `UPCountDown` 使用页面生命周期管理本地秒级计时，支持暂停、重置和 `onFinish`；组件销毁时清理定时器。
- `UPCountTo` 使用本地短间隔动画从起始值过渡到结束值，时长、精度和非法范围安全回退。
- `UPTimeline` 只负责节点布局、颜色、禁用态和本地点击回传，不连接业务数据源。
- `UPCalendar` 使用原生 `Date` 计算月份和日期网格，周起始、月份和日期值异常时回退到安全范围。
- `UPKeyboard` 是本地数字/证件号码面板，不接管系统输入法，不执行支付或业务提交。
- `UPFloatingBubble` 使用宿主布局中的本地悬浮按钮，不承担拖拽持久化、网络请求或业务路由。

## 边界

这些组件不使用 WebView、网络请求、运行时 JSON 映射或 Vue/NVue。未直接映射的字段保留在 Props 中作为兼容入口，并以 no-op 或诊断方式处理。

## 验证

- 最低兼容 API：24；目标 SDK：`5.0.0(12)`。
- HAR/HAP 构建和静态契约应在本机工具链中验证。
- `设备验证` 需要连接 HarmonyOS 目标；无设备时脚本输出 `skipped`，不视为失败。
