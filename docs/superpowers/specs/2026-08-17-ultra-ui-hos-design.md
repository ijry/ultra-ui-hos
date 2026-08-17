# ultra-ui-hos 设计文档：uview-plus HarmonyOS NEXT 原生版

## 1. 目标

在 `ultra-ui-hos` 仓库中交付一个纯 ArkTS/ArkUI 的 HarmonyOS NEXT 原生组件库，以及一个独立的中文示例应用。组件库必须可作为 HAR 静态库被其他 HarmonyOS 应用引用，示例应用必须只通过库的公开入口使用组件。

首个可运行里程碑以关联 Android 工程的首期范围为准，实现九个 uview-plus 兼容组件；工程、Props 契约、演示目录和测试边界必须支持后续扩展到 iOS 当前组件集及 uview-plus 3.x 完整目录。

## 2. 固定兼容基线

- 视觉、默认值、字段名、案例顺序和关键交互语义以 `uview-plus` `3.x` 提交 `96f14b06f857aeda011ae5baf9654bb4634dba9a` 为准。
- 上游源组件示例路径为：
  - `componentsA/button/button.nvue`
  - `componentsA/cell/cell.nvue`
  - `componentsA/icon/icon.nvue`
  - `componentsA/loading-icon/loading-icon.nvue`
  - `componentsA/overlay/overlay.nvue`
  - `componentsA/popup/popup.nvue`
  - `componentsB/tag/tag.nvue`
  - `componentsB/toast/toast.nvue`
  - `componentsC/modal/modal.nvue`
- 初始 HarmonyOS 产品兼容基线为 `5.0.0(12)`。开发和构建使用本机已安装的 DevEco Studio 6.1.1、Hvigor 6.24.1 与 HarmonyOS SDK API 24；实现不得无保护地依赖 API 12 之后才出现的系统能力。
- 库是纯 ArkTS/ArkUI 实现：不引入 WebView、JSON 渲染器、FastView、运行时代码生成、业务网络访问或业务状态存储。

## 3. 工程结构

```text
.
├── AppScope/
│   ├── app.json5
│   └── resources/
├── ultra-ui/                         # HAR 静态组件库
│   ├── Index.ets                      # 唯一公共导出入口
│   ├── hvigorfile.ts                  # harTasks
│   ├── oh-package.json5               # @lingyun/ultra-ui-hos
│   └── src/
│       ├── main/
│       │   ├── ets/
│       │   │   ├── core/
│       │   │   ├── components/
│       │   │   ├── controllers/
│       │   │   └── internal/
│       │   └── resources/
│       │       └── rawfile/upicon.ttf
│       └── ohosTest/
├── sample/
│   └── entry/                         # HAP 示例应用
│       ├── hvigorfile.ts              # hapTasks
│       ├── oh-package.json5
│       └── src/
│           ├── main/
│           │   ├── ets/
│           │   │   ├── entryability/
│           │   │   ├── pages/
│           │   │   ├── catalog/
│           │   │   ├── demos/
│           │   │   └── shared/
│           │   └── resources/
│           └── ohosTest/
├── scripts/
│   ├── verify-toolchain.sh
│   ├── verify-boundaries.sh
│   └── capture-screenshots.sh
├── tools/
│   └── generate_upicon_catalog.py
├── docs/
│   └── compatibility/
├── build-profile.json5
├── hvigorfile.ts
├── hvigor/
└── oh-package.json5
```

### 3.1 模块职责

| 模块 | 产物 | 职责 | 依赖规则 |
| --- | --- | --- | --- |
| `ultra-ui` | HAR | 公共 Props、ArkUI 组件、主题、解析器、图标字体、Toast 控制器 | 不依赖示例应用；不依赖网络或业务层 |
| `sample/entry` | HAP | 目录、导航、中文示例页面、本地占位资源、设备级测试入口 | 只能从 `ultra-ui/Index.ets` 导入库 API |
| `scripts` | Shell | 工具链检查、边界检查、可选截图采集 | 不参与应用运行时 |
| `tools` | Python | 从固定上游基线生成图标映射 | 生成结果提交到 HAR 源码或资源目录 |

公共包名固定为 `@lingyun/ultra-ui-hos`，示例应用包名固定为 `net.lingyun.ultraui.hos.sample`。

## 4. 公共 API 与兼容契约

### 4.1 公共导出

`ultra-ui/Index.ets` 是唯一受支持的导入入口，导出：

- 核心契约：`UPRawValue`、`UPStyleInput`、`UPCompatibilityEvent`、`UPCompatibilityDiagnostics`。
- 核心服务：`UPConfig`、`UPTheme`、`UPUnit`、`UPColor`、`UPStyle`。
- 首期组件及其 Props：`UPIcon` / `UPIconProps`、`UPLoadingIcon` / `UPLoadingIconProps`、`UPButton` / `UPButtonProps`、`UPTag` / `UPTagProps`、`UPOverlay` / `UPOverlayProps`、`UPPopup` / `UPPopupProps`、`UPModal` / `UPModalProps`、`UPToastHost` / `UPToastController` / `UPToastOptions`、`UPCellGroup` / `UPCellGroupProps`、`UPCell` / `UPCellProps`。
- 事件类型：`UPCellClickEvent`、`UPTagCloseEvent`、`UPModalAction`、`UPToastCompleteEvent`，以及必要的回调类型。

内部实现文件不得成为稳定导入路径。

### 4.2 Props 规则

每个 `UP*Props` 都是可直接构造的 ArkTS 数据对象，字段名与固定 uview-plus 基线保持 camelCase 一致。Props 必须：

1. 保留固定基线的全部公开字段和默认值。
2. 使用 `UPRawValue` 接纳生成端传入的数字、字符串、布尔值或空值。
3. 使用 `UPStyleInput` 接纳 `customStyle` 的对象形式和可安全解析的文本形式。
4. 保留鸿蒙上不适用的平台字段，以保证跨端生成代码仍能编译。
5. 对不适用字段只做非致命诊断，不执行模拟的小程序、Web 或路由行为。

组件采用 ArkUI `@Component` 形态。调用方可通过 `UPButton({ props: new UPButtonProps(...) })` 一类声明式写法使用组件；复杂内容通过命名的 `@BuilderParam` 扩展，事件通过显式 callback 传出。库内绝不根据 `url` 或 `linkType` 自动导航。

### 4.3 兼容诊断

`UPCompatibilityDiagnostics` 是可选的诊断接收器，事件包含 `component`、`property`、`value` 与 `reason`。默认实现静默。相同组件、字段和值导致的同类降级在一个渲染周期中只报告一次，避免污染日志或影响性能。

## 5. 共享核心

### 5.1 主题与默认值

`UPTheme` 使用固定基线的主题色：

| 名称 | 值 |
| --- | --- |
| `primary` | `#2979ff` |
| `warning` | `#ff9900` |
| `success` | `#19be6b` |
| `error` | `#fa3534` |
| `info` | `#909399` |
| `main` | `#303133` |
| `content` | `#606266` |
| `tips` | `#909399` |
| `light` | `#c0c4cc` |

`UPConfig` 保存首期全部 Props 的不可变默认对象。组件实例从 Props 读取默认值，不能在渲染过程中修改全局默认对象。

### 5.2 单位、颜色和样式

- `rpx` 以当前可用内容宽度（vp）除以 750 的比例解析；尺寸随窗口宽度变化而重新计算。
- 裸数字、`px` 和 `vp` 均按逻辑 vp 尺寸归一化，以保持与关联 Android 版本的一致视觉尺度。
- `UPColor` 支持主题键、`#RGB`、`#RGBA`、`#RRGGBB`、`#RRGGBBAA`、`rgb()` 和 `rgba()`。
- 按钮背景额外支持双颜色、从左到右的线性渐变；其他复杂渐变不支持且记录诊断。
- `UPStyle` 首期支持：`width`、`height`、`margin`、`padding`、`color`、`background`、`backgroundColor`、`border`、`borderColor`、`borderWidth`、`borderRadius`、`fontSize`、`fontWeight`、`textAlign`、`opacity` 和主/交叉轴对齐。
- 非法颜色、无穷数、负数尺寸、未知单位、未知样式键和不可用枚举不抛异常；解析器返回组件默认值或忽略该键并报告诊断。

### 5.3 图标资产

从固定上游基线复制 `u-icon` 字体文件至 HAR 的 rawfile 资源。`tools/generate_upicon_catalog.py` 从固定上游图标表生成完整 ArkTS glyph 映射；库不维护手工的部分图标清单。未知图标渲染为安全空占位并可记录诊断。

## 6. 第一阶段组件范围

| 组件批次 | 公开组件 | 核心行为 | 示例路由 |
| --- | --- | --- | --- |
| 图标 | `UPIcon` | 图标字体、标签、标签方向、颜色、尺寸、图片/未知图标回退 | `icon` |
| 加载 | `UPLoadingIcon` | `spinner`、`semicircle`、`circle`、颜色、文字、动画时长与缓动 | `loading-icon` |
| 按钮 | `UPButton` | 类型、尺寸、圆角、plain、hairline、图标、loading、disabled、点击节流 | `button` |
| 标签 | `UPTag` | 类型、plain、size、shape、disabled、可关闭与 `name` 回传 | `tag` |
| 遮罩 | `UPOverlay` | 受控可见性、透明度、zIndex、遮罩点击 | `overlay` |
| 弹出层 | `UPPopup` | 上下左右/居中、圆角、关闭按钮、安全区、遮罩与 slot 内容 | `popup` |
| 模态框 | `UPModal` | 标题、内容、确认/取消、slot、异步关闭、受控状态 | `modal` |
| 提示 | `UPToastHost`、`UPToastController` | 命令式展示、位置、类型、加载、图标、时长、遮罩、完成回调 | `toast` |
| 单元格 | `UPCellGroup`、`UPCell` | 分组、标题/说明/值、必填、箭头、左右 slot、点击回传 | `cell` |

`UPCell` 与 `UPCellGroup` 作为同一批次和同一路由验收，但各自具有独立 Props 与组件测试。

## 7. 受控状态和事件语义

### 7.1 通用原则

示例应用持有导航与业务演示状态，HAR 只根据 Props 渲染并发出事件。组件内部允许维护动画和瞬时手势状态，但不维护与外部 `show` 冲突的第二份可见性真相。

### 7.2 弹层

Overlay、Popup 与 Modal 的流向固定为：

```text
页面 @State.show
    ↓
UP*Props.show
    ↓ 用户点击关闭/遮罩/确认/取消
组件回调 onShowChange(false) / onClose(...)
    ↓
页面更新 @State.show
```

- `closeOnClickOverlay` 为 `false` 时，遮罩点击不请求关闭。
- Popup 和 Modal 的关闭按钮、取消、确认和遮罩点击分别保留原因信息。
- Modal 的异步关闭使用显式完成回调：事件处理器在需要异步工作时保留可见性并在完成后调用 `done()`；重复调用或组件已卸载时安全忽略。

### 7.3 Toast

根页面只挂载一个 `UPToastHost`。`UPToastController.show(options)` 将当前可见提示替换为新提示；`duration = -1` 表示不自动关闭；其他正数时长结束后只触发一次完成回调。Toast 遮罩可阻断下层交互；未知位置回退到 `center`。系统 Toast 不作为视觉实现。

### 7.4 点击与路由

- Button 在 `disabled` 或 `loading` 时不触发点击；`throttleTime` 使用单调时间执行，零或非法值表示不节流。
- Tag 关闭事件与 Cell 点击事件回传未强制字符串化的 `UPRawValue name`。
- Cell 的 `url`、`linkType`、小程序跳转字段只保存在 Props 中；库报告其鸿蒙 no-op 状态，示例应用通过 `onClick` 显式导航。

## 8. 示例应用

### 8.1 目录与导航

示例首页复刻固定基线的三级分组，仅显示已完成路由：

- `Components A`：按钮、单元格、图标、加载中图标、遮罩层、弹出层。
- `Components B`：标签、提示消息。
- `Components C`：模态框。

页面使用 ArkUI 原生导航。手机竖屏是主要验收视口；较宽窗口中目录与内容区域采用最大阅读宽度和居中布局，不能出现溢出、不可点击或不可返回的问题。

### 8.2 页面内容

每个页面使用固定上游示例中的中文标题、分段标题、案例顺序和关键交互状态。任何网络图片、远程数据或不稳定时间数据必须替换为本地确定性占位资源。示例不直接复制上游 Vue/NVue 运行时逻辑，而是通过 HAR 的公开 ArkTS API 表达等价场景。

### 8.3 可访问性

可交互控件必须提供可读文本或无障碍说明；图标按钮、关闭按钮、弹层操作和示例目录必须可以通过自动化测试定位。语义标签优先复用示例中可见的中文文本。

## 9. 错误处理与非目标

### 9.1 安全回退

以下情况不能使页面崩溃：

- 非法或不支持的颜色、单位、样式、图标名、动画模式和图片路径。
- Props 中的平台专有字段、生成端传入的空值或错误原始值类型。
- Toast/Modal 的重复关闭、过期异步完成、Popup 已隐藏时的关闭请求。

相应行为为：采用组件默认值、忽略不可用字段、显示稳定空占位或安全关闭当前层，并向可选诊断接收器发送一次事件。

### 9.2 明确不做

- 不实现 uview-plus 的 Vue/NVue 运行时、模板编译、JSON 动态渲染或 WebView 兼容层。
- 不实现业务路由、后端请求、登录、缓存、远程图片下载或权限请求。
- 不在阶段 1 宣称支持未完成的 uview-plus 组件。
- 不将 HSP 动态共享包作为首期产物。

## 10. 测试与验证

### 10.1 覆盖要求

每个组件批次在实现前先添加对应的失败测试，并在实现后至少覆盖：

1. **核心与 Props 测试**：默认值、字段保留、颜色/单位/样式解析、枚举回退和诊断去重。
2. **交互测试**：点击、节流、disabled/loading 抑制、Popup/Overlay/Modal 关闭路径、Modal 异步完成、Tag name 事件、Cell 点击事件、Toast 超时与遮罩。
3. **导航测试**：阶段 1 的九个路由都可从目录访问；示例只使用 HAR 公共导出。
4. **视觉资产**：示例资源和输入数据确定化，设备截图在相同模拟器配置下可比较。

### 10.2 工具链与脚本

- `scripts/verify-toolchain.sh` 验证 DevEco、Hvigor、ohpm、SDK、Node 与可选 HDC 设备；所有路径可由环境变量覆盖。
- `scripts/verify-boundaries.sh` 失败于 `ultra-ui` 或 `sample` 源码中的 WebView、FastView、`.xyfv`、JSON 渲染器或网络业务实现。
- `scripts/capture-screenshots.sh` 在存在连接模拟器或真机时采集固定路由截图并与已提交参考图比较。
- 构建脚本必须在生成项目后调用 Hvigor 的实际 HAR/HAP/ohosTest 任务；脚本不依赖开发者机器上的硬编码绝对路径。

没有可用设备时，HAR/HAP 构建、静态检查和所有可运行的非设备测试必须通过；脚本必须清晰报告设备级交互和截图验证为“未执行”，不能将其记为通过。

### 10.3 完成标准

阶段 1 完成时必须同时满足：

- HAR 与 HAP 在指定工具链下可构建。
- 九个示例路由全部可访问，且使用库公开 API。
- 每个首期 Props 的默认值和字段集合与固定基线相符。
- 所有核心、Props、交互、导航和可执行视觉检查通过。
- 设备不可用时，README 与交付说明明确列出未执行的设备级验证。
- `git diff --check` 与源码边界检查通过。
- README 仅列出实际完成组件、基线提交、构建方式、库接入方式、Toast Host 挂载方式、受控 `show` 模式和鸿蒙 no-op 字段规则。

## 11. 分阶段扩展路线

### 阶段 1：首期九组件

实现本设计第 6 节所列组件、核心兼容层、HAR/HAP、确定性中文示例和验证基础设施。

### 阶段 2：追齐 iOS 当前组件集

按相同 Props、事件、slot、回退和测试规则增加：

- 基础与展示：`UPLine`、`UPGap`、`UPLink`、`UPTitle`、`UPBadge`、`UPAvatar`、`UPAvatarGroup`、`UPDivider`、`UPSkeleton`、`UPLineProgress`、`UPLoadmore`。
- 表单与输入：`UPForm`、`UPFormItem`、`UPInput`、`UPTextarea`、`UPCheckbox`、`UPCheckboxGroup`、`UPRadio`、`UPRadioGroup`、`UPSwitch`、`UPRate`、`UPNumberBox`。

### 阶段 3：uview-plus 3.x 完整目录

按能力域拆分独立兼容批次：布局与导航、数据展示与列表、表单与选择、反馈与弹层、媒体与上传、复杂/高级组件。每批次重新固定对应上游组件与示例文件、Props 字段、交互矩阵、无障碍要求和截图基线；未完成组件不得出现在“已支持”列表中。

## 12. 设计决定记录

| 决定 | 结论 | 原因 |
| --- | --- | --- |
| 库形式 | HAR 静态库 | 支持独立复用、单独测试和 ohpm 发布，避免 HSP 分发复杂度 |
| 示例形式 | HAP | 与可复用组件库保持单向依赖并可直接演示原生交互 |
| 兼容策略 | 完整 Props + 安全 no-op | 让跨端生成代码保留可编译性，同时避免模拟不属于鸿蒙的能力 |
| 可见性 | 外部受控 `show` | 避免状态竞争，便于示例和消费者统一管理 |
| Toast | 自定义 Host + Controller | 需要复现位置、遮罩、加载、图标和生命周期而非系统默认样式 |
| 测试策略 | 核心、交互、导航、视觉分层 | 同时锁定契约、行为和视觉，且在无设备时诚实报告限制 |
| 完整路线 | 分阶段扩展 | 先交付可验证基线，避免将未实现的全量目录伪装为已支持 |
