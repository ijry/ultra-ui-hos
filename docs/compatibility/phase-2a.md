# ultra-ui-hos 阶段 2A 兼容性与验证记录

## 1. 目标和基线

阶段 2A 在阶段 1 可构建 HAR/HAP 基线上补齐首批基础展示组件，继续遵守 HarmonyOS NEXT 原生实现约束：ArkTS/ArkUI、API 24、产品兼容版本 `5.0.0(12)`、公共入口 `ultra-ui/Index.ets`，不引入 Vue/NVue、WebView、FastView、JSON 渲染器、网络请求或业务路由运行时。

组件字段与默认语义参考固定 uview-plus 3.x 提交 `96f14b06f857aeda011ae5baf9654bb4634dba9a` 以及关联 iOS/Android 工程。HarmonyOS 不适用能力采用安全 no-op 或稳定静态表现。

## 2. 已实现组件

| 组件 | 阶段 2A 行为 | 兼容注意事项 |
| --- | --- | --- |
| `UPLine` | 横向/纵向线条、长度、颜色、细线、边距、虚线安全表现 | `dashed` 在 API 24 原生实现中保持静态透明度表现，不模拟复杂路径绘制 |
| `UPGap` | 高度、背景色、上/下边距和透明间隔 | `transparent` 映射为透明背景，非法颜色回退为透明 |
| `UPLink` | 文本、颜色、字号、下划线、`href`、`onTap`/`onClick` 事件 | 不自动打开网络或业务路由；只回传 `href` 与文本，由调用方处理 |
| `UPTitle` | 主标题、副标题、类型色、前缀色条、字号、粗体和对齐 | 前缀为原生静态色块，slot/自定义前缀留待后续批次扩展 |
| `UPBadge` | 数字、文本、圆点、最大值溢出、隐藏零值、反色、偏移 | `absolute` 字段保留但由调用布局决定定位，组件本身不强制脱离布局流 |
| `UPDivider` | 分割线、文本、圆点、文本位置、颜色、细线和点击事件 | `dashed` 采用安全静态表现；点击统一回传文本 |
| `UPSkeleton` | 加载占位、标题、头像、行数、行宽、行高、背景色 | `animate` 字段保留，当前 API 24 交付为稳定静态占位，避免依赖高版本动画能力 |
| `UPLineProgress` | 百分比、进度色、底色、高度、文字、条纹字段 | 百分比钳制到 0..100；`striped`/`stripedActive` 为安全静态表现 |
| `UPLoadmore` | `loadmore`、`loading`、`nomore` 三状态、图标、文字、分隔线 | `loading` 状态复用 `UPLoadingIcon`；未知状态回退到 `loadmore` |

## 3. 示例工程验收面

示例目录在 `Components A` 中新增九个路由：

- `line`：线条 Line
- `gap`：间隔槽 Gap
- `link`：超链接 Link
- `title`：标题 Title
- `badge`：徽标 Badge
- `divider`：分割线 Divider
- `skeleton`：骨架屏 Skeleton
- `line-progress`：线形进度条 LineProgress
- `loadmore`：加载更多 Loadmore

所有新增示例页只从 `@lingyun/ultra-ui-hos` 导入组件，不访问 HAR 内部文件；示例使用本地确定性文本和状态，不包含远程 URL、网络图片、业务请求或不稳定时间数据。

## 4. Props、回退和 no-op 规则

- 尺寸字段继续通过 `UPUnit` 解析数字、`vp`、`px` 与 `rpx`，非法值回退到组件默认值。
- 颜色字段继续通过 `UPColor` 解析主题键、十六进制、`rgb()` 和 `rgba()`，非法值回退到默认色或透明色。
- `customStyle` 仅支持已有安全样式子集，未知键被忽略；组件不因未知字段崩溃。
- `UPLink.href`、`UPBadge.absolute`、`UPSkeleton.animate`、`UPLineProgress.striped` 等跨端字段保留源码兼容性，但不会触发网络、脱离布局或高版本动画依赖。

## 5. 构建和静态验证

推荐构建命令仍为：

```bash
./scripts/build.sh
```

阶段 2A 新增静态契约测试：

```bash
python3 scripts/test_foundation_display_contract.py
```

完整本机验证应继续执行所有 `scripts/test_*.py`、`scripts/verify-boundaries.sh`、`scripts/verify-toolchain.sh`、`./scripts/build.sh` 与 `git diff --check`。构建脚本会确认 `upicon.ttf` 仍同时存在于 HAR 与最终 HAP。

## 6. 设备验证状态

当前脚本支持通过 `scripts/capture-screenshots.sh` 在存在 HarmonyOS 真机或模拟器时采集截图。没有连接设备时脚本会输出 `screenshots: skipped`，这只表示设备级截图和交互验证未执行，不代表通过。

因此阶段 2A 可在无设备环境确认的是：源码契约、公共导出、示例路由、禁止网络/运行时边界、本机 HAR/HAP 构建和资源打包。新增展示组件的点击、导航、动画和截图对比仍需在连接 HarmonyOS 模拟器或真机后执行。

## 7. 后续扩展

阶段 2B 已在本仓库交付，具体兼容范围和验证记录见 [`phase-2b.md`](phase-2b.md)。阶段 2C 可继续补齐 `UPForm`、`UPFormItem`、`UPCheckbox`/`UPCheckboxGroup`、`UPRadio`/`UPRadioGroup`。
