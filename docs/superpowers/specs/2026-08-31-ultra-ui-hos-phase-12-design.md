# Ultra UI HarmonyOS NEXT 阶段 12 设计：协议、复制、无网与验证码提示

- 日期：2026-08-31
- 上游参考：uview-plus 3.8.113（本地提交 `cf27e4ef6`）
- 目标：补齐四个依赖宿主能力边界、但仍可由 ArkUI 原生渲染和受控回调表达的基础组件。

## 背景

阶段 12 处理 `u-agreement`、`u-copy`、`u-no-network` 和 `u-code`。它们在上游中分别依赖模态框、系统剪贴板、网络监听/系统设置以及本地存储和定时器。HarmonyOS NEXT 版本不把这些系统或业务副作用藏在组件内部，而是将需要宿主决定的能力改成显式 Props、回调或能力注入。

## 范围

### `UPAgreement`

- 通过 `UPModal` 复用受控显示、确认和取消按钮。
- 默认呈现协议说明文本，支持 `content` 覆盖默认文案。
- `urlProtocol` 和 `urlPrivacy` 只作为协议元数据传给 `onProtocolClick`、`onPrivacyClick`，不在组件内部导航。
- 确认事件返回 `{ accepted: true }`；取消、显示状态变化继续由宿主持有。
- 不执行退出应用、关闭窗口、打开 URL 或业务路由。

### `UPCopy`

- `content` 接受字符串、数字和布尔值，并在复制前统一转为字符串。
- `clipboard` 是宿主注入的 `(content: string) => boolean` 能力；返回 `true` 才触发成功事件。
- 空内容、未注入能力或能力返回失败均触发失败事件，并带稳定的失败原因。
- 保留上游 `alertStyle` 和 `notice` 作为兼容 Props，但不自动调用 Toast、Modal 或系统剪贴板。
- 默认使用“复制”文本渲染，也支持 ArkUI Builder 形式的内容区域。

### `UPNoNetwork`

- `isConnected` 和 `networkType` 由宿主提供；组件仅显示受控无网占位页。
- `setConnected` 公开给网络监听适配器，用于更新状态并派发 `onConnected`/`onDisconnected`。
- `onRetry` 只通知宿主重新检测网络；组件不主动调用网络 API。
- `image` 仅支持本地资源或安全占位，远程地址不发起请求。
- 不打开系统设置、不申请权限、不修改页面路由。

### `UPCode`

- 支持上游 `seconds`、`startText`、`changeText`、`endText`、`keepRunning` 和 `uniqueKey`。
- `start()`、`reset()`、`canGetCode()` 和 `displayText()` 作为公开控制边界；组件内部只管理秒级定时器。
- `onStart`、`onChange` 和 `onEnd` 分别覆盖开始、每秒变化和结束事件。
- 默认渲染当前提示文本，也支持 Builder 覆盖展示区域；因此既能按上游“无固定 UI”方式取提示语，也能直接放进 ArkUI 页面。
- `keepRunning` 的跨页面续计时通过可选 `UPCodeStorage` 注入；未注入时仍可运行普通倒计时，但不伪造跨页面持久化。

## 公共接口

每个组件均提供 `Options`、`Props` 和公开 `@Component`。事件均为可选回调，未配置回调时不产生隐式业务副作用。

| 组件 | 关键 Props | 关键事件/方法 | 兼容边界 |
| --- | --- | --- | --- |
| `UPAgreement` | `show`、`title`、`content`、`urlProtocol`、`urlPrivacy`、`confirmText`、`cancelText` | `onConfirm`、`onCancel`、`onProtocolClick`、`onPrivacyClick`、`onShowChange` | 协议跳转由宿主处理 |
| `UPCopy` | `content`、`alertStyle`、`notice`、`clipboard` | `onSuccess`、`onFailure`、`onClick` | 剪贴板由宿主注入 |
| `UPNoNetwork` | `tips`、`image`、`zIndex`、`isConnected`、`networkType`、`retryText` | `setConnected`、`onRetry`、`onConnected`、`onDisconnected` | 网络监听与系统设置由宿主处理 |
| `UPCode` | `seconds`、`startText`、`changeText`、`endText`、`keepRunning`、`uniqueKey`、`storage` | `start`、`reset`、`canGetCode`、`displayText`、`onStart`、`onChange`、`onEnd` | 持久化由 `UPCodeStorage` 注入 |

## 原生映射

- 协议弹窗使用 `UPModal`，协议链接使用 `Text.onClick`，避免引入 WebView 或系统 URL API。
- 复制组件使用 `Text`/Builder 和宿主能力回调，不依赖 `@kit.NetworkKit`、系统剪贴板单例或全局 Toast。
- 无网组件使用 `Stack`、`Column`、`UPImage`/`UPIcon` 和本地按钮，状态层级由 `zIndex` 表达。
- 验证码组件使用 `setInterval`，在 `aboutToDisappear` 清理计时器；显示文案中的第一个 `x`/`X` 替换为剩余秒数。

## 非目标

- 不实现二维码、条形码、裁剪器、PDF、定位、短视频等平台能力组件。
- 不在本阶段新增系统权限、网络请求、业务路由或应用退出逻辑。
- 不把未连接真机/模拟器时的静态检查描述为设备视觉或交互验证。

## 验收

- 阶段 12 静态契约覆盖四个组件的默认值、核心 Props、事件、方法、边界字符串和公共导出。
- Components P 增加四条 Demo 路由，并由 `SamplePage` 分发。
- 兼容文档明确记录宿主能力注入、无隐式副作用和设备验证边界。
- `PROGRESS.md` 更新四个上游目录、Demo 状态和统计；上游目录总数仍为 141，新增公开组件和 Demo 各 4 个。
- 阶段契约、文档契约和 `git diff --check` 通过；无设备时设备验证保持 `skipped`。
