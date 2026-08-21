# ultra-ui-hos 首期实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 在 `ultra-ui-hos` 中交付一个可构建的 HarmonyOS NEXT ArkTS/ArkUI 组件库（HAR）和只通过公共入口使用它的中文 HAP 示例工程，覆盖设计文档定义的九个首期组件。

**Architecture:** 根工程使用 Hvigor 管理 `ultra-ui` HAR 与 `sample/entry` HAP。组件库只暴露 `ultra-ui/Index.ets`，共享核心负责主题、单位、颜色、样式和兼容诊断；组件使用受控 Props 与显式事件，不自动处理跨平台路由字段。示例应用使用 ArkUI 原生 `Navigation`/`NavPathStack`，按 Components A/B/C 组织九个页面。

**Tech Stack:** HarmonyOS NEXT Stage 模型、ArkTS、ArkUI、DevEco Studio 6.1.1、Hvigor 6.24.1、HarmonyOS SDK API 24、HAR、HAP、Hypium。

## Global Constraints

- 最低兼容 API 为 24，产品兼容版本为 `5.0.0(12)`；不得无保护使用更高 API。
- 组件库包名为 `@lingyun/ultra-ui-hos`，示例包名为 `net.lingyun.ultraui.hos.sample`。
- 示例只导入 `ultra-ui/Index.ets` 的公共导出，不导入库内部文件。
- 不实现 WebView、FastView、JSON 渲染器、网络请求、业务路由或运行时代码生成。
- Props 接受 `UPRawValue`/`UPStyleInput` 并安全回退；平台专有字段保留但只发兼容诊断。
- 所有可见组件提供稳定中文可访问文本；设备不可用时不得把设备级验证写成已通过。

### Task 1: 建立根工程、HAR/HAP 模块和验证脚本

**Files:**
- Create: `oh-package.json5`
- Create: `package.json`
- Create: `build-profile.json5`
- Create: `hvigorfile.ts`
- Create: `hvigor/hvigor-config.json5`
- Create: `AppScope/app.json5`
- Create: `AppScope/resources/base/element/string.json`
- Create: `ultra-ui/oh-package.json5`
- Create: `ultra-ui/build-profile.json5`
- Create: `ultra-ui/hvigorfile.ts`
- Create: `ultra-ui/src/main/module.json5`
- Create: `sample/entry/oh-package.json5`
- Create: `sample/entry/build-profile.json5`
- Create: `sample/entry/hvigorfile.ts`
- Create: `sample/entry/src/main/module.json5`
- Create: `sample/entry/src/main/resources/base/profile/main_pages.json`
- Create: `sample/entry/src/main/ets/entryability/EntryAbility.ets`
- Create: `scripts/verify-toolchain.sh`
- Create: `scripts/verify-boundaries.sh`
- Create: `.gitignore`
- Test: `scripts/test_project_contract.py`

- [ ] Step 1: 写一个失败的项目契约测试，断言根目录、HAR/HAP 模块、公共入口和包名均存在；运行 `python3 scripts/test_project_contract.py`，初始应因缺少工程文件失败。
- [ ] Step 2: 创建 API 24 Stage 模型工程配置。根 `build-profile.json5` 只声明 `ultra-ui` 与 `sample/entry`，HAR 使用 `harTasks`，HAP 使用 `hapTasks`，HAP 依赖本地 HAR。
- [ ] Step 3: 添加最小 `EntryAbility` 和 `main_pages.json`，让 HAP 在无组件实现时也可加载 `pages/Index`。
- [ ] Step 4: 添加工具链脚本：优先使用 `DEVECO_HOME`/`HVIGOR_BIN`/`OHPM_BIN`/`HDC_BIN`，缺失设备时明确输出 skipped；边界脚本扫描禁止的 WebView/FastView/`.xyfv`/JSON 渲染/网络业务关键字。
- [ ] Step 5: 运行 `python3 scripts/test_project_contract.py` 使契约测试通过，并执行 `git diff --check`。

### Task 2: 共享核心、公共导出与单元契约

**Files:**
- Create: `ultra-ui/Index.ets`
- Create: `ultra-ui/src/main/ets/core/UPTypes.ets`
- Create: `ultra-ui/src/main/ets/core/UPTheme.ets`
- Create: `ultra-ui/src/main/ets/core/UPConfig.ets`
- Create: `ultra-ui/src/main/ets/core/UPUnit.ets`
- Create: `ultra-ui/src/main/ets/core/UPColor.ets`
- Create: `ultra-ui/src/main/ets/core/UPStyle.ets`
- Create: `ultra-ui/src/main/ets/core/UPDiagnostics.ets`
- Create: `ultra-ui/src/main/ets/core/UPBuilders.ets`
- Test: `scripts/test_core_contract.py`

- [ ] Step 1: 先添加会失败的 Python 契约测试，检查九个主题色、`rpx`/`vp`/`px` 解析、颜色格式、诊断去重和公共导出符号；运行测试确认失败。
- [ ] Step 2: 实现无副作用的类型、默认主题和配置对象：`UPRawValue`、`UPStyleInput`、`UPCompatibilityEvent`、`UPCompatibilityDiagnostics`、`UPTheme`、`UPConfig`。
- [ ] Step 3: 实现 `UPUnit` 与 `UPColor` 的安全解析函数；所有非法值返回默认值/`undefined`，不抛异常。
- [ ] Step 4: 实现 `UPStyle` 支持设计文档列出的首期样式键，并以 `UPStyleResult` 供组件使用；未知键通过诊断器报告一次。
- [ ] Step 5: 实现公共 Builder 类型/安全文本辅助，并从 `Index.ets` 只导出稳定 API；运行核心契约测试与边界脚本。

### Task 3: 图标、加载图标、按钮、标签

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPIcon.ets`
- Create: `ultra-ui/src/main/ets/components/UPLoadingIcon.ets`
- Create: `ultra-ui/src/main/ets/components/UPButton.ets`
- Create: `ultra-ui/src/main/ets/components/UPTag.ets`
- Create: `ultra-ui/src/main/ets/internal/UPIconGlyphs.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/ButtonDemo.ets`
- Create: `sample/entry/src/main/ets/demos/IconDemo.ets`
- Create: `sample/entry/src/main/ets/demos/LoadingIconDemo.ets`
- Create: `sample/entry/src/main/ets/demos/TagDemo.ets`
- Test: `scripts/test_action_components.py`

- [ ] Step 1: 添加失败契约测试，锁定 Props 默认值、类型/尺寸回退、disabled/loading 点击抑制、按钮节流和 tag `name` 原样回传。
- [ ] Step 2: 实现图标名称映射和未知图标空占位；实现 `UPIcon` 的颜色、尺寸、标签方向与图片回退字段。
- [ ] Step 3: 实现 `UPLoadingIcon` 的三种模式、文字方向和动画状态；动画只使用 ArkUI 公共能力。
- [ ] Step 4: 实现 `UPButton` 的 type/size/shape/plain/hairline/loading/disabled/icon/customStyle 与显式 `onClick`，使用单调时间做节流。
- [ ] Step 5: 实现 `UPTag` 的 type/plain/size/shape/disabled/closable/name 与 `onClose`。
- [ ] Step 6: 在示例中把四个页面按上游案例顺序静态表达，所有交互只更新页面状态或触发系统 Toast；运行契约测试和 HAR 编译。

### Task 4: 遮罩层、弹出层、模态框

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPOverlay.ets`
- Create: `ultra-ui/src/main/ets/components/UPPopup.ets`
- Create: `ultra-ui/src/main/ets/components/UPModal.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/OverlayDemo.ets`
- Create: `sample/entry/src/main/ets/demos/PopupDemo.ets`
- Create: `sample/entry/src/main/ets/demos/ModalDemo.ets`
- Test: `scripts/test_overlay_contract.py`

- [ ] Step 1: 添加失败契约测试，锁定受控 `show`、遮罩关闭开关、Popup placement、Modal confirm/cancel/close 原因和异步完成一次性语义。
- [ ] Step 2: 实现 `UPOverlay`：不可见时不占用交互层；可见时提供遮罩点击事件、透明度和 zIndex。
- [ ] Step 3: 实现 `UPPopup`：支持 top/bottom/left/right/center、圆角、安全区、closeable、遮罩和 `@BuilderParam` 内容。
- [ ] Step 4: 实现 `UPModal`：标题/正文/slot、确认/取消按钮反转、zoom、遮罩关闭和 `done()` 异步关闭保护。
- [ ] Step 5: 添加三个示例页面，页面状态始终是可见性唯一真相；运行契约测试、HAR/HAP 编译。

### Task 5: Toast 控制器与单元格

**Files:**
- Create: `ultra-ui/src/main/ets/controllers/UPToastController.ets`
- Create: `ultra-ui/src/main/ets/components/UPToastHost.ets`
- Create: `ultra-ui/src/main/ets/components/UPCellGroup.ets`
- Create: `ultra-ui/src/main/ets/components/UPCell.ets`
- Modify: `ultra-ui/Index.ets`
- Create: `sample/entry/src/main/ets/demos/ToastDemo.ets`
- Create: `sample/entry/src/main/ets/demos/CellDemo.ets`
- Test: `scripts/test_feedback_contract.py`

- [ ] Step 1: 添加失败契约测试，锁定 Toast 替换、duration=-1、不重复完成回调、位置回退、遮罩阻断，以及 Cell 字段/name 事件。
- [ ] Step 2: 实现 `UPToastController` 的单例/实例安全状态机与定时器清理；实现 `UPToastHost` 的受控渲染和一次性完成事件。
- [ ] Step 3: 实现 `UPCellGroup` 与 `UPCell`，支持标题、说明、值、必填、图标/右侧 Builder、箭头、边框、url/linkType no-op 诊断和点击回传。
- [ ] Step 4: 添加 Toast/Cell 示例页面和根 Host 挂载；运行契约测试、HAR/HAP 编译。

### Task 6: 导航示例、资源、测试入口与文档

**Files:**
- Create: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Create: `sample/entry/src/main/ets/pages/Index.ets`
- Create: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Create: `sample/entry/src/main/ets/shared/SampleScaffold.ets`
- Create: `sample/entry/src/main/resources/base/element/string.json`
- Create: `sample/entry/src/main/resources/base/media/*`（确定性占位资源）
- Create: `README.md`（更新）
- Modify: `sample/entry/src/main/module.json5`
- Test: `scripts/test_sample_contract.py`

- [ ] Step 1: 添加失败导航契约测试，要求九个路由、三级分组、公共入口导入和根 Toast Host 均存在。
- [ ] Step 2: 实现 `SampleCatalog`、目录首页和通用返回/标题脚手架；用 `NavPathStack` 在目录和演示页之间导航。
- [ ] Step 3: 让每个演示页仅通过 `@lingyun/ultra-ui-hos` 公开入口引用组件；加入固定中文标题、案例标签和无障碍文本。
- [ ] Step 4: 更新 README，记录实际支持的九个组件、HAR 接入、Toast Host 挂载、受控 show、no-op 字段和工具链命令。
- [ ] Step 5: 运行导航契约、边界检查、`git diff --check`。

### Task 7: 全量验证与交付记录

**Files:**
- Modify: `scripts/verify-toolchain.sh`
- Create: `scripts/capture-screenshots.sh`
- Create: `docs/compatibility/phase-1.md`

- [ ] Step 1: 运行 `scripts/verify-toolchain.sh`，记录 DevEco/Hvigor/ohpm/SDK/HDC 状态。
- [ ] Step 2: 运行 Hvigor 的 HAR/HAP 构建任务（至少 `assembleHap`、`assembleHar` 或本机对应任务），保存失败日志并修复编译错误。
- [ ] Step 3: 运行全部 Python 契约测试、边界脚本和 `git diff --check`。
- [ ] Step 4: 有设备时运行截图脚本和可运行测试；无设备时输出明确 skipped，并在兼容性记录中列出未执行项。
- [ ] Step 5: 复查设计文档逐项覆盖，查看 `git diff --stat`/`git status`，只在有新鲜命令证据后报告完成状态。
