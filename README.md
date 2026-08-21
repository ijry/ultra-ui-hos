# ultra-ui-hos

uview-plus 的 HarmonyOS NEXT 原生实现。仓库同时提供一个可复用的 HAR 组件库和一个中文 HAP 示例工程，组件使用 ArkTS/ArkUI 编写，不依赖 Vue/NVue、WebView、网络请求或业务路由运行时。

## 当前交付范围

当前包含阶段 1、阶段 2A、阶段 2B、阶段 2C、阶段 3A、阶段 3B 与阶段 4A，共 54 个已实现组件/控制器（53 个组件 + 1 个控制器），均从 HAR 公共入口导出。

### 阶段 1：交互与反馈基线

- `UPButton`：类型、尺寸、形状、朴素/细边框、图标、加载、禁用和点击节流
- `UPCellGroup`、`UPCell`：分组标题、标题/说明/值、必填、箭头、左右内容和点击事件
- `UPIcon`：内置图标、标签、标签方向、颜色/尺寸和图片或未知图标回退
- `UPLoadingIcon`：`spinner`、`semicircle`、`circle` 三种加载形态和文字
- `UPOverlay`：受控显示、透明度、层级和遮罩点击
- `UPPopup`：`top`、`bottom`、`left`、`right`、`center`、关闭按钮、遮罩和安全区
- `UPTag`：类型、朴素样式、尺寸、形状、禁用和关闭事件
- `UPToastHost`、`UPToastController`：命令式提示、位置、类型、加载、遮罩、替换和完成回调
- `UPModal`：标题、内容、确认/取消、遮罩、slot 内容和异步关闭

### 阶段 2A：基础展示组件

- `UPLine`：横线、竖线、细线、长度、颜色和虚线安全表现
- `UPGap`：高度、背景色、上下边距和透明间隔
- `UPLink`：文字、颜色、字号、下划线和点击回传；不自动打开网络地址
- `UPTitle`：主标题、副标题、前缀色条、类型色、字号、粗体和对齐
- `UPBadge`：数字、圆点、上限、隐藏零值、反色和偏移
- `UPDivider`：文本/圆点分隔、左右位置、颜色、细线和点击回传
- `UPSkeleton`：标题、头像、占位行、行宽、行高和静态安全占位
- `UPLineProgress`：百分比、进度色、背景色、高度、文字和条纹安全表现
- `UPLoadmore`：`loadmore`、`loading`、`nomore` 三状态、图标、文字和分隔线

### 阶段 2B：头像、表单输入与值控件

- `UPAvatar`：本地资源头像、文字/图标回退、圆形/方形、确定性背景色和点击回传
- `UPAvatarGroup`：头像列表、`maxCount`、间距和溢出数量提示；远程图片安全回退
- `UPInput`：单行文本/数字/密码输入、`value`/`modelValue`、清除、前后图标、字数限制、只读/禁用和提交事件
- `UPTextarea`：多行输入、`value`/`modelValue`、高度、计数、最大长度、边框和提交事件
- `UPSwitch`：布尔或自定义 active/inactive 值、加载/禁用、受控变更事件
- `UPRate`：星级、数量、最小值、半星字段、只读/禁用和评分变更事件
- `UPNumberBox`：加减按钮、最小/最大值、步长、整数/小数位、输入禁用和变更事件

### 阶段 2C：表单与选择组

- `UPForm`、`UPFormItem`：表单模型占位、标签布局、必填标记、错误信息和校验回调
- `UPCheckbox`、`UPCheckboxGroup`：方形/圆形勾选、禁用、布局、选项数组和多选变更回传
- `UPRadio`、`UPRadioGroup`：单项/单选组选中态、禁用、布局、选项数组和单选变更回传

### 阶段 3A：内容与输入组件

- `UPText`：文本模式、保守格式化、图标、行数、装饰与本地回调
- `UPImage`：本地资源图片、填充模式、形状/圆角和确定性占位回退
- `UPEmpty`：常见空状态图标、文字、尺寸和未知模式回退
- `UPLoadingPage`：受控加载页、原生加载图标、文字、层级和本地图片
- `UPSearch`：`value`/`modelValue`、`clearabled`、清除、搜索、焦点和操作区回调
- `UPCodeInput`：验证码格子、掩码、行/盒模式、长度限制和完成事件

输入与选择组件均为本地状态和事件桥接，不承担网络、业务提交或业务路由。`value` 与 `modelValue` 的选择规则、远程图片回退和 API 24 限制见 [`docs/compatibility/phase-2b.md`](docs/compatibility/phase-2b.md)、[`docs/compatibility/phase-2c.md`](docs/compatibility/phase-2c.md) 与 [`docs/compatibility/phase-3a.md`](docs/compatibility/phase-3a.md)。阶段 3A 的本地资源图片、`clearabled` 保留拼写、搜索和验证码输入限制见 [`docs/compatibility/phase-3a.md`](docs/compatibility/phase-3a.md)。

### 阶段 3B：布局与卡片

- `UPRow`、`UPCol`：12 栅格、间距、偏移、换行和对齐
- `UPGrid`、`UPGridItem`：原生网格列数、间隙、边框、末行对齐和索引事件
- `UPCard`：头部/主体/底部区域、本地缩略图、命名 Builder、显隐和分区事件

布局与卡片的原生差异、本地资源规则、无网络边界和非法值回退见 [`docs/compatibility/phase-3b.md`](docs/compatibility/phase-3b.md)。

### 阶段 4A：原生交互与提示组件

- `UPCircleProgress`：原生环形进度、百分比、颜色、尺寸和内容 Builder
- `UPAlert`、`UPNotify`、`UPNoticeBar`：受控提示、顶部通知、公告展示和本地关闭/点击事件
- `UPActionSheet`：受控遮罩、底部操作项、选择、取消和关闭原因
- `UPBackTop`：滚动阈值显示与由页面执行的返回顶部回调
- `UPCollapse`、`UPCollapseItem`：单开/多开受控值、嵌套上下文和独立安全回退
- `UPDropdown`、`UPDropdownItem`：受控打开索引、单选/多选值、禁用项和遮罩关闭

交互组件的页面受控状态、事件顺序、静态动画回退、无网络边界和设备验证限制见 [`docs/compatibility/phase-4a.md`](docs/compatibility/phase-4a.md)。

未列出的 uview-plus 组件不会伪装成已支持组件；后续组件按兼容性文档分阶段增加。

## 工程结构

```text
ultra-ui-hos/
├── ultra-ui/                  # @lingyun/ultra-ui-hos，HAR
│   ├── Index.ets              # 唯一公共导出入口
│   └── src/main/ets/          # 核心、组件和控制器
├── sample/entry/              # net.lingyun.ultraui.hos.sample，HAP
│   └── src/main/ets/          # 目录、原生 Navigation 和示例页面
├── scripts/                   # 契约、边界、工具链和截图脚本
├── docs/compatibility/        # 阶段兼容范围和验证记录
└── build-profile.json5        # 根 Hvigor 工程配置
```

示例应用只从 `@lingyun/ultra-ui-hos` 导入组件，不访问 HAR 内部文件。首页使用 ArkUI 原生 `Navigation`/`NavPathStack`，按 `Components A/B/C/D/E/F/G/H` 分组展示已完成路由，当前包含 52 条组件示例路由。

## 基线和要求

- HarmonyOS NEXT Stage 模型
- 最低兼容 API：24
- 产品兼容/目标 SDK：`5.0.0(12)`
- DevEco Studio：6.1.1（本机工具链基线）
- Hvigor：6.24.1（本机工具链基线）
- Node、ohpm、HarmonyOS SDK 和 JDK 由 DevEco Studio 提供

运行工具链检查（脚本支持通过环境变量覆盖默认路径）：

```bash
./scripts/verify-toolchain.sh
```

没有连接 HarmonyOS 模拟器或真机时，工具链脚本和截图脚本会明确输出 `skipped`；这不等同于设备交互验证通过。

## 构建 HAR 和示例 HAP

推荐在仓库根目录执行统一构建脚本：

```bash
./scripts/build.sh
```

脚本按依赖顺序执行（实际调用 `assembleHar` 和 `assembleApp`）：

1. 先构建 `ultra-ui/build/default/outputs/default/ultra_ui.har`；
2. 用 `ohpm install --all --no-link` 刷新示例的本地 HAR 依赖；
3. 再构建示例 HAP 和 App；
4. 检查 `upicon.ttf` 同时存在于 HAR 和最终 HAP。

这样做是必要的：示例依赖的是已打包的 HAR，而不是 `ultra-ui` 源码目录；只有 HAR 依赖的 `rawfile` 资源才会被 Hvigor 正确合并到 HAP。脚本支持通过 `DEVECO_HOME`、`JAVA_HOME`、`DEVECO_SDK_HOME`、`OHPM_BIN` 和 `HVIGOR_BIN` 覆盖本机默认路径。

产物位于 `ultra-ui/build/default/outputs/default/ultra_ui.har`、`sample/entry/build/default/outputs/default/entry-default-unsigned.hap` 和根工程的 App 输出目录（构建目录默认被 `.gitignore` 忽略）。

示例的本地依赖声明为：

```json5
"@lingyun/ultra-ui-hos": "file:../../ultra-ui/build/default/outputs/default/ultra_ui.har"
```

修改 HAR 源码后不要直接先执行 `ohpm clean`；运行 `./scripts/build.sh` 会先重新生成 HAR，再刷新本地依赖，避免示例继续使用旧快照或丢失字体等库资源。也可以在 DevEco Studio 中打开根目录的 `build-profile.json5`，选择 `entry` 模块运行示例工程；在全新检出目录中，需先运行一次构建脚本生成并安装本地 HAR。

## 作为 HAR 使用

消费者在 `oh-package.json5` 中添加本地 HAR 或已发布包后，从公共入口导入：

```ts
import {
  UPButton,
  UPButtonProps,
  UPLineProgress,
  UPLineProgressProps,
  UPPopup,
  UPPopupProps,
  UPToastController,
  UPToastHost
} from '@lingyun/ultra-ui-hos';

@Component
struct DemoCard {
  build() {
    Stack() {
      Column({ space: 12 }) {
        UPButton({
          props: new UPButtonProps({
            type: 'primary',
            text: '保存',
            onClick: (): void => {
              UPToastController.shared().show({ message: '保存成功', type: 'success' });
            }
          })
        })
        UPLineProgress({ props: new UPLineProgressProps({ percentage: 68, activeColor: 'success' }) })
      }
      UPToastHost()
    }
  }
}
```

`UPToastHost()` 通常只在应用根页面挂载一次。`UPButton`、`UPTag`、`UPCell`、`UPBadge` 等组件通过 `props` 接收跨端风格原始值，并在鸿蒙侧安全回退非法值。

受控弹层的状态由页面持有：

```ts
@State private showPopup: boolean = false;

UPPopup({
  props: new UPPopupProps({
    show: this.showPopup,
    mode: 'bottom',
    closeable: true,
    onShowChange: (show: boolean): void => {
      this.showPopup = show;
    }
  })
})
```

`UPModal` 的确认/取消回调提供 `done()` 完成函数；需要异步处理时保持 `show`，在工作完成后调用一次 `done()`。`UPCell` 的 `url`、`linkType` 和小程序跳转字段会保留在 Props 中，但不会在 HAR 内自动导航，而是通过 `onClick` 由调用方决定。`UPLink` 同样只回传 `href`，不在组件库内打开外部地址。

## 验证命令

静态契约和源码边界检查：

```bash
python3 scripts/test_project_contract.py
python3 scripts/test_har_dependency_contract.py
python3 scripts/test_core_contract.py
python3 scripts/test_action_components.py
python3 scripts/test_foundation_display_contract.py
python3 scripts/test_icon_catalog.py
python3 scripts/test_overlay_contract.py
python3 scripts/test_feedback_contract.py
python3 scripts/test_sample_contract.py
python3 scripts/test_form_entry_contract.py
python3 scripts/test_arkts_component_contract.py
python3 scripts/test_phase_3a_content_input_contract.py
python3 scripts/test_phase_3b_layout_card_contract.py
python3 scripts/test_phase_4a_native_interaction_contract.py
python3 scripts/test_documentation_contract.py
python3 scripts/test_device_script_contract.py
./scripts/verify-boundaries.sh
git diff --check
```

设备截图（无连接设备时会输出 `screenshots: skipped`）：

```bash
./scripts/capture-screenshots.sh
```

更具体的组件范围、兼容回退、no-op 字段、设备验证限制和后续扩展路线见 [`docs/compatibility/phase-1.md`](docs/compatibility/phase-1.md)、[`docs/compatibility/phase-2a.md`](docs/compatibility/phase-2a.md)、[`docs/compatibility/phase-2b.md`](docs/compatibility/phase-2b.md)、[`docs/compatibility/phase-2c.md`](docs/compatibility/phase-2c.md)、[`docs/compatibility/phase-3a.md`](docs/compatibility/phase-3a.md)、[`docs/compatibility/phase-3b.md`](docs/compatibility/phase-3b.md) 和 [`docs/compatibility/phase-4a.md`](docs/compatibility/phase-4a.md)。
