# 阶段 12 兼容说明

阶段 12 增加 `UPAgreement`、`UPCopy`、`UPNoNetwork` 与 `UPCode`，均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPAgreement` 复用 `UPModal` 的受控弹窗能力，提供协议正文、用户协议/隐私政策链接回调、确认/取消事件和 `contentBuilder`。链接只把 URL 回传给宿主，不自动导航。
- `UPCopy` 提供复制触发、成功/失败事件和 `alertStyle`/`notice` 兼容字段。实际剪贴板写入通过 `clipboard(content)` 由宿主注入，组件不直接调用系统剪贴板，也不自动弹出 Toast。
- `UPNoNetwork` 提供无网络占位、网络类型、层级、重试按钮和连接状态事件。`isConnected`/`networkType` 由宿主控制，组件不执行系统网络监听；重试回调本身是 no-op 边界，不代表网络已恢复。
- `UPCode` 提供本地验证码倒计时、开始/变化/结束事件、文本占位替换、重置和可获取状态。`keepRunning` 只在传入 `UPCodeStorage` 时保存结束时间，短信发送和业务请求由宿主完成。

## 边界

这些组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue、系统设置跳转或业务路由。协议 URL、复制能力和网络监听均保留为宿主接入点；没有宿主能力时以安全回退、失败事件或 no-op 处理。

`UPCodeStorage` 是可选的最小存储适配器，示例中的内存实现不代表持久化能力。需要跨页面或进程恢复倒计时的应用，应由宿主提供持久化实现，并自行处理验证码发送、失效和安全策略。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 12 静态契约覆盖四个组件的默认值、核心 Props/事件、公共导出、Components P 目录和四条 Demo 路由。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称短信、系统剪贴板、网络监听或协议页面的设备验证完成；这些能力仍由宿主接入和验证。
