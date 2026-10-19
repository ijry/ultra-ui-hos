# 阶段 10 兼容说明

阶段 10 增加 `UPTreeSelect`、`UPCascader`、`UPDatePicker`、`UPTimePicker`、`UPUpload` 与 `UPProgressButton`，均使用 HarmonyOS NEXT API 24 原生 ArkUI 实现。

## 范围

- `UPTreeSelect` 支持本地树节点、单选/多选、最大数量、禁用节点和展开状态。
- `UPCascader` 支持本地多级选项、列联动、受控初始值、确认和取消事件。
- `UPDatePicker` 与 `UPTimePicker` 使用原生日期/时间值计算列数据，非法年份、月份、日期和步长安全回退。
- `UPUpload` 只提供本地文件列表占位和选择/删除/重试回调，不执行网络上传。
- `UPProgressButton` 提供 normal、loading、success 和 error 四种本地视觉状态及进度回传。

## 边界

这些组件不使用 WebView、网络请求、运行时 JSON 映射、Vue/NVue 或业务路由。`UPUpload` 的 `localOnly` 默认值为 `true`；真实文件选择和上传由宿主应用自行接入。

未直接映射到 ArkUI 的字段保留在 Props 中，并以安全回退、no-op 或诊断方式处理，不在组件内部抛出业务异常。

## 验证

- 最低兼容 API：24；目标 SDK：`5.0.0(12)`。
- HAR/HAP 构建、静态契约和边界检查在本机工具链中验证。
- `设备验证` 需要连接 HarmonyOS 目标；无设备时脚本输出 `skipped`，不视为失败。
