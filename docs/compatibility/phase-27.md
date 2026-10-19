# 阶段 27 兼容说明

阶段 27 复刻上游 `libs/theme/theme.js` 的明暗主题系统：42 个主题令牌 × 2 套取值、模式与偏好状态机，并把 49 个组件文件里 96 处硬编码颜色改为按令牌取值。阶段 26 结束时主题是最后一块未复刻的上游能力——本端只有一份固定的浅色配色，暗色模式无从实现。所有改动仍面向 HarmonyOS NEXT API 24。

## 范围

### `UPThemeTokens`（对应 `theme.js` 的颜色映射表）

42 个令牌 × light/dark 两套取值，来源是上游的 `DEFAULT_LIGHT_THEME_COLORS`、`DEFAULT_DARK_THEME_COLORS` 与 `DEFAULT_THEME_EXTRA_VARS`，另加 `buildThemeCssVars()` 里派生的 `page-bg-color`、`card-bg-color`、`navbar-bg-color`、`hover-bg-color`。令牌表不手写：`tools/upstream/uview-plus-theme.js` 固定上游快照（提交 `cf27e4ef6`），`tools/generate_uptheme_tokens.py` 生成 ArkTS 文件，与 `UPIconGlyphs`、`UPLocaleCatalog` 走同一套「快照 + 生成器」模式。生成器会校验两套取值的令牌集合完全一致。

### `UPThemeManager`（对应 `theme.js` 的运行时）

`mode()`、`isDark()`、`preference()`、`snapshot()`（等价上游 `themeState`）、`setMode()`（上游 `setTheme`）、`setPreference()`、`systemModeChanged()`、`token()`、`tokenFor()`、`hasToken()`、`tokens()`、`setOverrides()`（上游 `syncThemeColorOverrideState`）、`clearOverrides()`、`theme()`、`addListener()`、`clearListeners()`。模式与偏好的收敛规则与上游 `normalizeThemeMode` / `normalizeThemePreference` 一致：非 `dark` 一律落到 `light`，非 `light`/`dark` 的偏好一律落到 `system`。`snapshot().version` 每次生效自增，对应上游 `themeState.version`。

令牌名接受三种写法：`main-color`、`up-main-color`、`--up-main-color`，也接受上游的 `u-` 前缀别名。上游为 `--up-` 与 `--u-` 维护两份同值 CSS 变量，本端归一到单一命名空间（离线比对已确认两份取值恒等）。

### `UPColor` 的令牌分支与中性色

`UPColor.parse()` 的解析顺序扩展为「主题色名 → 主题令牌 → 字面色值 → fallback」，因此 `'bg-color'`、`'up-border-color'` 这类上游变量名可以直接作为颜色 prop 传入。新增 `UPColor.token(name, fallback)` 供组件内部按令牌取色。

上游的 `main`/`content`/`tips`/`light` 四个中性色在明暗两套里取值不同（如 `main-color` 从 `#303133` 变为 `#f5f5f5`），而品牌色 `primary`/`success`/`warning`/`error`/`info` 在上游是模式无关的（`getThemeColorsByMode()` 在暗色分支里显式沿用浅色品牌值）。因此：

- 调用方沿用库默认主题 `UP_DEFAULT_THEME` 时，`UPColor.parse('main')` 这类中性色名在暗色模式下走令牌表；浅色模式保持 `UPTheme` 既有取值。品牌色名（`primary` 等）在任何模式下都取 `UPTheme` 既有值。
- 调用方显式传入自定义 `UPTheme` 时原样尊重，不做令牌替换。
- 新增 `UPColor.neutral(name, light)` 与 `UPColor.adaptive(light, token)`，语义统一为「浅色照旧、暗色查令牌」：组件内 21 处 `UP_DEFAULT_THEME.main` 直读替换为 `neutral()`，96 处字面色值与 12 处组件专属色（表格斑马纹、骨架屏底色、通知栏底色、导航栏背景等）替换为 `adaptive()`。契约脚本禁止再出现中性色字段直读形态。

这一步是必要的收口：仅替换 `fontColor('#303133')` 这类字面量还不够——`UPColor.parse()` 的调用点与字段直读在暗色模式下仍会取到浅色值。

**「浅色照旧」是刻意的**：上游同一语义颜色在 `config.js` 与 `theme.js` 里偶有取值差异（如 `up-tips-color` 是 `#909399`、`theme.js` 的 `tips-color` 是 `#909193`；`border-color` 本端历史用 `#ebeef5`/`#eeeeee`/`#dcdfe6`，令牌浅色是 `#dadbde`）。若无条件改用令牌浅色值会悄悄改变既有浅色观感，因此 `neutral()` / `adaptive()` 固定「浅色返回传入的既有字面值、仅暗色查令牌」，保证暗色可用且浅色零回归。

### 组件接入

49 个组件/内部文件的 96 处硬编码颜色改为 `UPColor.token(token, 原字面值)`，映射按上游 light 取值一一对应：

- `backgroundColor('#ffffff')` → `card-bg-color`（暗色 `#1c1c1e`）
- `backgroundColor('#f3f4f6')` → `bg-color`（暗色 `#1f1f1f`）
- `fontColor('#303133')` → `main-color`（暗色 `#f5f5f5`）
- `fontColor('#606266')` → `content-color`（暗色 `#d1d5db`）
- `fontColor('#909399')` → `tips-color`（暗色 `#9ca3af`）
- `fontColor('#c0c4cc')` → `light-color`（暗色 `#6b7280`）
- `borderColor('#ebeef5')` / `('#eeeeee')` / `('#dcdfe6')` → `border-color`（暗色 `#3a3a3c`）

fallback 保留原字面值，因此令牌缺失时渲染结果与阶段 26 完全一致。

## 边界

- **不探测平台主题**：上游 `getSystemTheme()` 读 `uni.getAppBaseInfo().theme` / `uni.getSystemInfoSync().theme`，并用 `uni.onThemeChange()` 跟随系统。本 HAR 不引入 `@ohos.configuration`，`setPreference('system', systemMode)` 的系统模式由宿主传入，系统切换需宿主调用 `systemModeChanged()` 转发。这属于 no-op 兼容位：入口存在但不主动探测。
- **不持久化偏好**：上游用 `uni.setStorageSync('u-theme-mode')` 记住偏好。本端不写存储，偏好只存在于内存，重启后回到 `system`；需要记忆时由宿主自己存取后在启动时调用 `setPreference()`。
- **没有 CSS 变量层**：上游把令牌注入 CSS 自定义属性，靠层叠自动作用于所有后代节点，业务代码写 `var(--up-main-color)` 即可。ArkTS 没有样式表与层叠，令牌只能显式读取，因此本端是「组件内主动查表」而非「样式继承」。上游浅色值外层还包了 `var(--up-light-x, fallback)` 桥接变量以支持运行时覆盖，本端没有这一层，直接用 fallback 值并通过 `setOverrides()` 覆盖。
- **模式切换不自动重渲染**：ArkTS 的静态方法调用不是响应式数据源，`setMode()` 后已挂载组件不会自动刷新。`ThemeDemo` 用 `addListener()` + `@State` 触发重绘，业务侧需要同样的接线，或把 `UPThemeManager.mode()` 的结果存进自己的 `@State`。这与上游借 CSS 变量即时生效的机制有本质差异，是本阶段最主要的行为边界。
- **覆盖跨模式生效**：上游 `config.color` 只有一份，覆盖同时影响明暗两套；本端 `setOverrides()` 保持同一语义，不区分模式。
- **未复刻的上游导出**：`libs/theme/runtime.js` 的 12 个函数全部依赖 uni 运行时（`setNavigationBarColor`、`setTabBarStyle`、`getCurrentPages`、H5 的 `document.documentElement`），在 ArkTS 里没有等价形态，属于宿主职责：HarmonyOS 的导航栏与状态栏由 `UIAbility` 的窗口 API 控制，不在组件库范围内。上游 `applyNativeThemeUI()` 本身也受 `config.nativeThemeSync` 开关保护，默认关闭。
- **`libs/css/*.scss`（512 行）不复刻**：SCSS 变量与工具类在 ArkTS 里没有对应概念，其中的颜色值已经通过令牌表覆盖。
- 本阶段改动只使用 ArkTS 语言能力与本地查表，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 示例工程

新增 `theme` 路由（`ThemeDemo`，归入 `Components Y`），示例路由数从 143 增至 144：

- 模式段用三个按钮切换 `light` / `dark` / 跟随系统，实时显示 `mode` / `preference` / `version`。
- 令牌对照表并排展示 9 个令牌在「light / dark / 当前」下的取值，当前列渲染成色块。
- 组件段挂 `UPCellGroup`、`UPCell`、`UPSection`、`UPTag`，切换模式即可看到背景与文字色跟随变化；整页背景用 `bg-color` 令牌。
- 覆盖段演示 `setOverrides()` 把主色换成 `#7d5fff` 与 `clearOverrides()` 撤销。
- 页面本身用 `addListener()` 订阅变更并写进 `@State`，演示「模式切换不自动重渲染」这一边界的正确接法。

## 剩余颜色审计

新增 `scripts/audit_theme_colors.py`（信息性审计，非门禁）把组件里剩余的字面颜色分桶，方便设计侧定位暗色缺口：

- **已明暗自适应**：`adaptive()` 108 处 + `neutral()` 21 处 + 43 处 `parse()` 中性/表面色 fallback（浅色照旧、暗色查令牌），合计 172 处。
- **命中已知令牌但仍是字面值**：272 处，浅色取值与令牌浅色不完全一致（多为品牌色 `#2979ff`/`#909399` 与既有分隔线色），保守起见未强行改写。
- **无上游令牌**：147 个不同色值、约 397 处，属组件专属色（如输入框底 `#f2f3f5`、分隔线 `#ebeef5`、纯黑遮罩 `#000000`），暗色取值需设计侧定义后再接，不自行编造。

这一步刻意只自动化零回归的部分：`neutral()` / `adaptive()` 在浅色下返回传入的既有字面值，因此这 172 处的浅色渲染与阶段 26 逐像素一致，仅暗色启用令牌。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_phase_27_theme_contract.py`：校验上游快照与生成器在位、生成文件带「Do not edit manually」标记、令牌总数为 42、16 组关键令牌的明暗取值逐值正确、`UPThemeManager` 的 16 个运行时方法与默认模式、不出现任何平台主题 API 探测、`UPColor` 的令牌分支与 `token()` / `neutral()` 助手及四条中性色映射、组件侧至少 90 处颜色已令牌化且不再残留对应字面量、任何组件不得再直读 `UP_DEFAULT_THEME` 的中性色字段、Demo 与路由接线、公共导出。当前输出 `PASS (42 tokens, 93 tokenised sites, 47 files)`。
- 离线差分验证：用 `node --experimental-strip-types` 跑三组比对。`UPThemeTokens` 与上游 `getThemeVars('light')` / `getThemeVars('dark')` 的 42 个 `--up-*` 变量逐值比对（浅色需先剥掉 `var(--up-light-x, …)` 桥接层），并确认 `--u-` 别名与 `--up-` 恒等，输出 `parity: OK (84 token values)`；`UPThemeManager` 比对默认状态、模式与偏好收敛规则、system 偏好跟随、手动偏好锁定、三种令牌拼写、覆盖与撤销、`tokenFor` 无副作用、version 自增与 `theme()` 对象，输出 `parity: OK`。第三组比对中性色与品牌色的模式行为：四个中性色名在两种模式下都要等于上游对应模式的取值，五个品牌色名必须模式无关，显式自定义主题必须原样返回，字面色值与令牌名分支不受影响，输出 `UPColor neutral parity: OK`。
- 既有 43 个契约脚本全部通过。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约与离线差分通过不等于设备验证通过。当前未宣称暗色模式下的实际观感、对比度是否达标、模式切换的重绘时机与闪烁在真机上的表现的设备验证完成；这些表现需在真机复核，暗色配色也需要设计侧确认。
