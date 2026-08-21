# ultra-ui-hos 阶段 1 兼容性与验证记录

## 1. 目标和基线

阶段 1 的目标是交付一个纯 ArkTS/ArkUI 的 HarmonyOS NEXT 原生 HAR，以及只通过 HAR 公共入口使用它的中文 HAP 示例工程。当前工程基线如下：

| 项目 | 基线 |
| --- | --- |
| 产品兼容版本 | `5.0.0(12)` |
| 最低兼容 API | API 24 |
| 工程模型 | Stage |
| 库产物 | `@lingyun/ultra-ui-hos`（HAR） |
| 示例包名 | `net.lingyun.ultraui.hos.sample` |
| 示例导航 | ArkUI `Navigation` + `NavPathStack` |
| 依赖方向 | `sample/entry` → `ultra-ui` |

组件库不实现 Vue/NVue 运行时、WebView/FastView、JSON 动态渲染、网络请求、业务路由、远程图片下载或 HSP 动态共享包。

## 2. 已实现组件

| 组件 | 阶段 1 行为 | 兼容注意事项 |
| --- | --- | --- |
| `UPButton` | 类型、尺寸、形状、plain、hairline、图标、loading、disabled、节流 | `openType` 等跨端平台字段保留；鸿蒙不自动模拟小程序能力 |
| `UPCellGroup` | 标题、圆角、边框和 slot 容器 | 内容由 `@BuilderParam` 提供 |
| `UPCell` | 标题、说明、值、必填、箭头、左右图标、点击事件 | `url`/`linkType` 只保留并诊断，不负责导航 |
| `UPIcon` | 图标字体、标签、标签方向、颜色/尺寸和回退 | 未知图标显示稳定占位并可记录诊断 |
| `UPLoadingIcon` | `spinner`、`semicircle`、`circle`、颜色、文字、时长 | 未知模式回退为 `spinner` |
| `UPOverlay` | 受控 `show`、透明度、zIndex、遮罩点击 | 可通过 `onShowChange` 由页面关闭 |
| `UPPopup` | 五种位置、关闭按钮、遮罩、安全区、打开/关闭事件 | `show` 由调用方持有；未知位置回退 `center` |
| `UPModal` | 标题、内容、确认/取消、slot、遮罩和异步关闭 | `done()` 每个动作最多生效一次；过期完成安全忽略 |
| `UPToastHost` + `UPToastController` | 命令式展示、位置、类型、loading、图标、遮罩、替换、完成回调 | 根页面只挂载一个 Host；`duration = -1` 不自动关闭 |
| `UPTag` | 类型、plain、尺寸、形状、disabled、closable、`name` 回传 | 关闭事件保留原始 `UPRawValue` |

所有公开 Props 和事件类型从 `ultra-ui/Index.ets` 导出。示例页面不导入 `ultra-ui/src` 内部路径。

## 3. Props、回退和兼容诊断规则

- 跨端生成端可传入的基础值使用 `UPRawValue`（字符串、数字、布尔值、`null` 或 `undefined`）；组件先校验再渲染。
- `UPUnit` 负责 `vp`、`px`、`rpx`、百分比和数字回退；负尺寸、无穷数和未知单位不会抛异常。
- `UPColor` 支持主题键、短/长十六进制、`rgb()` 和 `rgba()`；非法颜色回退到组件默认色。
- `UPStyle` 支持首期组件所需的尺寸、间距、颜色、背景、边框、圆角、字体、透明度和对齐属性；未知键被忽略。
- `UPCompatibilityDiagnostics` 是可选接收器，默认静默。同一组件、字段和值的同类降级在一个诊断周期内去重。
- `UPCell` 的 `url`、`linkType` 以及小程序跳转相关字段只作为兼容输入保留，并报告 HarmonyOS no-op；业务页面必须在 `onClick` 中自行调用 `NavPathStack` 或其他原生导航 API。
- Popup、Modal、Overlay 的可见性采用外部受控模式：页面的 `@State.show` → Props → 回调 → 页面更新，不在组件内维护第二份可见性真相。
- Toast 新 `show()` 会替换当前提示；正数时长只完成一次，`duration = -1` 表示不自动关闭；未知位置回退到 `center`。

## 4. 示例工程验收面

阶段 1 验收时，示例首页固定显示三个分组和九条路由：

- `Components A`：`button`、`cell`、`icon`、`loading-icon`、`overlay`、`popup`
- `Components B`：`tag`、`toast`
- `Components C`：`modal`

每个页面提供稳定中文标题和可读交互文本。根页面只挂载一个 `UPToastHost`；网络图片、远程数据和不稳定时间数据均未作为示例依赖。示例路由由原生 `Navigation` 管理，组件库不参与业务导航。

## 5. 构建和静态验证

在仓库根目录执行统一构建脚本：

```bash
./scripts/build.sh
```

脚本先运行 `assembleHar`，再运行 `ohpm install --all --no-link`，最后运行 `assembleApp`，并确认 `upicon.ttf` 从 HAR 合并到了 HAP。示例依赖固定的本地 HAR 文件：

```json5
"@lingyun/ultra-ui-hos": "file:../../ultra-ui/build/default/outputs/default/ultra_ui.har"
```

不能把示例改回 `file:../../ultra-ui` 源码目录依赖：源码快照可以参与 ArkTS 编译，但其 `rawfile` 不会可靠进入最终 HAP。修改 HAR 源码后应重新运行 `scripts/build.sh`，不要只刷新源码快照。

如果 DevEco 工具没有加入 `PATH`，使用构建脚本支持的 `DEVECO_HOME`、`JAVA_HOME`、`DEVECO_SDK_HOME`、`OHPM_BIN` 和 `HVIGOR_BIN` 环境变量，或在 DevEco Studio 打开根 `build-profile.json5` 构建。

阶段 1 的静态检查包括：

```bash
python3 scripts/test_project_contract.py
python3 scripts/test_har_dependency_contract.py
python3 scripts/test_core_contract.py
python3 scripts/test_action_components.py
python3 scripts/test_overlay_contract.py
python3 scripts/test_feedback_contract.py
python3 scripts/test_sample_contract.py
python3 scripts/test_documentation_contract.py
python3 scripts/test_device_script_contract.py
scripts/verify-boundaries.sh
git diff --check
```

## 6. 设备验证状态

当前仓库未提交任何“已在真机/模拟器完成交互”的结论。执行 `scripts/verify-toolchain.sh` 和 `scripts/capture-screenshots.sh` 时，如果 `hdc list targets` 没有设备，脚本会明确输出：

```text
screenshots: skipped (no connected HarmonyOS device)
```

因此当前交付可确认的是：源码契约、边界检查和本机 HAR/HAP 构建；设备级点击、返回、动画、截图对比仍需在连接 HarmonyOS 模拟器或真机后执行。不得把 `skipped` 记为通过。

## 7. 后续扩展

阶段 2A 与阶段 2B 已分别补齐基础展示、头像、表单输入和值控件，具体范围见对应兼容性文档。阶段 2C 再按能力域扩展 uview-plus 3.x 完整目录。每次扩展必须新增对应失败契约测试、公共入口导出、示例路由和设备/视觉验证记录；未实现组件不加入“已实现组件”列表。
