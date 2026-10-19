# 阶段 16 兼容说明

阶段 16 增加 `UPTransition`、`UPAlbum`、`UPCalendarStrip`、`UPChoose` 与 `UPGuide`，补齐过渡动画、图片集合、横向日期条、标签选择与首次引导五类能力。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPTransition` 复刻上游过渡容器：`mode` 覆盖上游 `nvue-ani-map` 的 12 种取值 `none`、`fade`、`fade-up`、`fade-down`、`fade-left`、`fade-right`、`slide-up`、`slide-down`、`slide-left`、`slide-right`、`zoom` 与 `fade-zoom`，`upTransitionHiddenFrame()` 给出每种模式的「隐藏端」不透明度、位移与缩放，显示端恒为 `opacity 1`、无位移、`scale 1`。`timingFunction` 白名单为 `linear`、`ease`、`ease-in`、`ease-out`、`ease-in-out`，经 `upTransitionCurve()` 映射到 `Curve`，白名单外回落 `Curve.EaseOut` 并记录一条诊断；`mode` 越界回落 `fade`。组件内部维持 `inited`（是否挂载）、`display`（是否占位）、`entered`（是否已到显示端）三态，`UP_TRANSITION_ENTER_DELAY = 20` 对应上游进入前的 `sleep(20)`，事件顺序与上游一致：`beforeEnter → enter → afterEnter` 与 `beforeLeave → leave → afterLeave`，`transitionEnded` 保证一次过渡只收口一次。动画由 `.opacity()`/`.translate()`/`.scale()` 配 `.animation({ duration, curve })` 驱动，`duration` 允许字符串数字。
- `UPAlbum` 复刻相册栅格：`upAlbumRows(total, rowCount, maxCount, autoWrap)` 对应上游 `showUrls` 计算，`autoWrap` 打开时排成单行，否则按 `rowCount` 分行且总数受 `maxCount` 限制。单图使用 `singleSize` 见方并按 `singleMode` 取 `ImageFit`，多图使用 `multipleSize` 与 `multipleMode`；`space` 只在行间与列间生效，末行不带下外边距、末列不带右外边距。`showMore` 打开且实际数量超过 `maxCount` 时，`+N` 罩层只叠在最后一行最后一格上，文案为 `+${urls.length - maxCount}`，字号取 `multipleSize * 0.3` 且不低于 10。`shape` 为 `circle` 时圆角取格子宽度的一半，否则用 `radius`；`unit` 为 `rpx` 时所有数值型尺寸按 750 设计稿换算。`albumWidth` 事件由 `onAlbumWidth` 回传，宽度按 `列数 × multipleSize + space × (列数 - 1)` 计算并去重，点击任意格子回传 `onPreview`（`urls` + `currentIndex`）。
- `UPCalendarStrip` 复刻横向日期条：日期计算不依赖 dayjs，`upCalendarStripFormatDate()`/`upCalendarStripFormatMonth()`/`upCalendarStripDaysInMonth()`/`upCalendarStripNormalizeDate()`/`upCalendarStripCompare()`/`upCalendarStripClamp()`/`upCalendarStripMonthLabel()`/`upCalendarStripWeekIndex()` 用 `YYYY-MM-DD` 字符串与 `Date` 自实现。`modelValue` 经 `@Watch` 双向同步并被 `minDate`/`maxDate` 钳制，`scene`/`source` 取值覆盖 `tap`（点击日期）、`switch`（月份切换）、`full`（展开态选择）、`auto`（选中后自动收起）、`pull-down`/`pull-up`（拖拽展开收起）、`button`（回到今天）与 `hint`（点击提示行）。事件顺序为 `onModelValueChange → onChange → onConfirm`，跨月时再补一次 `onMonthChange`；`onToggleFull` 回传展开态与来源。日格固定 `54 × 62`、`marginRight 8`、圆角 8，选中格填 `color` 主色，今日格在未选中时描主色边框；展开态直接复用已实现的 `UPCalendar`（`weekStart: 1`）。`readonly` 打开后所有选择被忽略。
- `UPChoose` 复刻标签选择：选项渲染复用 `UPTag`，选中项用 `type='primary'` 且 `plain=false`，未选项用 `type='info'` 且 `plain=true`，尺寸固定 `size='large'`，`itemHeight`/`itemPadding` 透传给标签。`wrap` 为 `true` 时用 `Flex(FlexWrap.Wrap)` 自动换行，为 `false` 时用横向 `Scroll` 单行滚动。`modelValue` 是选中项的**下标**（与上游一致），越界或非数值回落未选中；`labelName`/`valueName` 经白名单读取，`upChooseLabel()` 只认 `title`/`label`/`name`，`upChooseValue()` 只认 `value`/`id`。`customClick` 打开后点击只回传 `onCustomClick` 而不改动内部选中态，供宿主自行拦截；未打开时回传 `onChange`（`index` + `item`）。
- `UPGuide` 复刻首次引导：`list` 为具名 `UPGuideItem` 数组（`image`、`title`、`desc`、`backgroundColor`），用 `Swiper` 翻页并在底部渲染指示点、跳过按钮与主按钮，主按钮末页文案取 `finishText`、其余取 `nextText`。`aboutToAppear` 的 `bootstrap()` 对应上游启动判定：`once` 打开且已记忆时不展示，并在宿主请求展示的情况下回传一次 `onShowChange(false)`。翻页回传 `onChange`，跳过回传 `onSkip`，末页主按钮回传 `onFinish`，两者随后都走 `closeGuide(remember)` 写入记忆、回传 `onShowChange(false)` 与 `onClose`，`closing` 标记保证一次关闭只触发一次。尺寸全部经私有 `rpx()` 按 750 设计稿换算，缺少本地图片时渲染 `560 × 560rpx` 的「暂无引导图」占位。

## 边界

ArkTS 禁止索引签名与 `any`，因此相册、标签选择与引导页的数据模型都是具名 `interface`：`UPAlbumItem { src, url, thumb, path, image }`、`UPChooseItem { id, title, label, name, value }`、`UPGuideItem { image, title, desc, backgroundColor }`。`UPAlbum` 的 `keyName` 只能指向 `src`/`url`/`thumb`/`path`/`image`，`UPChoose` 的 `labelName` 只能指向 `title`/`label`/`name`、`valueName` 只能指向 `value`/`id`；传入模型之外的字段名时回落到第一个可用字段并记录一条诊断。上游“任意对象 + 任意字段名”的用法需要宿主先把数据映射成上述模型，`upAlbumItems()` 可以把纯 URL 字符串数组直接抬成 `UPAlbumItem` 数组。

`UPGuide` 同时提供上游的 `zIndex` 与本端别名 `stackLevel`（默认均为 10075），显式设置 `stackLevel` 时以它为准，内部统一由 `stackZIndex()` 落到 `.zIndex()`；私有方法不能叫 `zIndex`，否则与 ArkUI `CommonAttribute` 冲突。

以下上游能力保留为 no-op 兼容位或改由宿主承担，除改名项外都会在传入时通过 `UPCompatibilityDiagnostics.report()` 记录一条诊断：

- `UPTransition` 的 `mode` 与 `timingFunction`：白名单外取值分别回落 `fade` 与 `ease-out`。ArkUI 没有 CSS `transitionend`，进出场收口用 `duration` 时长的定时器近似，快速连续切换 `show` 时以最后一次为准，中途被打断的过渡不再补发 `afterEnter`/`afterLeave`。
- `UPAlbum` 的 `previewFullImage`：`uni.previewImage` 不可用，全屏预览一律 no-op，请在 `onPreview` 里跳转宿主自己的预览页；`singleSize` 不做 `uni.getImageInfo` 量算，单图恒为 `singleSize` 见方；`stop` 的事件冒泡控制在 ArkUI 上是 no-op。非本地地址（不以 `resource://`、`file://`、`/`、`$rawfile:` 开头）渲染「图片占位」而不发起网络请求。
- `UPCalendarStrip` 的 `monthFormat`：dayjs 格式化 token 不可用，月标题恒为 `YYYY年MM月`；`fullMonthNum` 与上游“预生成 N 个月”的窗口无对应，展开面板一次只渲染一个月，取值不等于 24 时记录诊断但不改变行为。
- `UPChoose` 的 `type`：上游模板只渲染单选标签行，`type` 取值不等于 `radio` 时记录诊断但仍按单选处理；上游未提供多选布局，需要多选请改用 `UPCheckboxGroup`。
- `UPGuide` 的 `once` 记忆：`uni.getStorageSync`/`setStorageSync` 不可用，`UPGuideStorage { get/set/remove }` 由宿主实现（如 Preferences 或应用内配置），未注入时记忆一律读为「未记住」并记录诊断。

五个组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。图片预览页、日期业务校验、标签数据来源与引导记忆的持久化仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 16 静态契约覆盖五个组件的默认值、核心 Props/事件、12 种过渡模式与 5 种时间曲线、切行/钳制/白名单辅助函数、公共导出、Components T 目录和五条 Demo 路由。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称过渡动画的进出场时序观感、相册 `+N` 罩层与圆形裁剪表现、日期条上下拉展开的跟手度、标签选择横滑惯性和引导页翻页动画的设备验证完成；这些表现需在真机复核。
