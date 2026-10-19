# Phase 7 兼容说明：滑块与选择组件

## 范围

本阶段新增 `UPSlider`、`UPPicker`、`UPPickerController` 和 `UPSelect`，并在示例 HAP 中加入 `slider`、`picker`、`picker-cascade`、`select` 四条中文路由。四个示例只从 `@lingyun/ultra-ui-hos` 公共 HAR 入口导入。

实现基线为 HarmonyOS NEXT、API 24 和 `5.0.0(12)`，组件使用 ArkTS/ArkUI 原生能力。

## 原生映射

- `UPSlider` 使用 ArkUI 原生 `Slider`，保留 `min`、`max`、`step`、方向、禁用、颜色和变更事件；小数值在步长边界内量化并归一精度。
- `UPPicker` 使用 ArkUI 原生 `TextPicker`，支持单列/多列、工具栏、确认/取消、遮罩关闭、即时变更和受控索引；`immediateChange: false` 在 API 12 上安全回退到 `onChange` 时机并报告诊断。
- `UPPickerController` 保存多列值与 `indexs`，通过 `setColumnValues` 支持级联列更新，并在非法列索引时报告诊断而不抛异常。
- `UPSelect` 使用 ArkUI `Stack`、`Scroll` 和本地受控下拉面板实现，选项禁用、遮罩和当前值回调均由页面控制。

## 降级与 no-op

- `UPSlider.isRange` 当前安全降级为单个原生滑块，并通过 `UPCompatibilityDiagnostics` 报告；`useNative` 已经是原生实现，因此作为 no-op 报告。
- `UPPicker.popupMode` 当前只实现 `bottom`，其它值安全回退到底部面板并报告；`isRange`、`useNative` 等非本阶段字段不扩展为运行时映射。
- `UPPickerColumn` 不纳入本阶段；本阶段的多列联动通过 `UPPickerController` 明确建模，独立的列容器组件在阶段 19 补齐。
- 非法数字、颜色、布尔值和索引使用组件默认值或边界值，不抛出业务异常；组件库不发起网络请求、不使用 `WebView`。

## 设备验证状态

- 阶段 7 静态契约：`passed`。
- 全量静态契约、边界检查、工具链检查与 HAR/HAP 构建：`passed`。
- HarmonyOS 真机/模拟器交互与截图验证：`skipped`，当前环境未提供已连接设备。
