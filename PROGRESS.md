# ultra-ui-hos uview-plus 组件复刻进度

> 基线日期：2026-08-31。本表用于逐项跟踪 uview-plus 上游目录在 HarmonyOS NEXT 原生 ArkUI 组件库与示例工程中的复刻状态。
>
> “已有实现覆盖”表示已存在公开 ArkUI API，不等于逐字段、逐事件、逐动画、逐像素或真机行为完全一致。当前没有把未执行的真机/模拟器验证记为通过。

## 基线与统计

| 项目 | 当前值 | 说明 |
| --- | ---: | --- |
| 上游版本 | `3.8.113` | 本地上游提交 `cf27e4ef6`，目录 `/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus` |
| 上游目录总数 | 141 | 140 个 `u-*` 目录 + 1 个 `uview-plus` 根模块目录 |
| 上游 UI 目录 | 138 | 排除 `u-action-sheet-data`、`u-picker-data`、`uview-plus` |
| 已有 ArkUI 实现覆盖 | 138 / 138（100%） | 95 个阶段 1–11 映射 + 4 个阶段 12 映射 + 5 个阶段 13 映射 + 5 个阶段 14 映射 + 5 个阶段 15 映射 + 5 个阶段 16 映射 + 5 个阶段 17 映射 + 5 个阶段 18 映射 + 5 个阶段 19 映射 + 4 个阶段 20 映射；包含 `u-upload`、`u-copy`、`u-no-network`、`u-pdf-reader` 本地占位边界 |
| 待单独复刻 UI | 0 / 138 | 上游 UI 目录已全部具备同名公开 ArkUI API |
| 上游 props 字段覆盖 | 138 / 138 目录 | 由 `scripts/test_upstream_prop_coverage.py` 逐目录核对 props.js 与主 .vue 的 props 块 |
| 上游 emits 事件覆盖 | 138 / 138 目录 | 由 `scripts/test_upstream_event_coverage.py` 逐目录核对 emits 数组与 $emit 调用 |
| 上游 slot 插槽覆盖 | 138 / 138 目录 | 由 `scripts/test_upstream_slot_coverage.py` 逐目录核对主 .vue 的 `<slot>` 声明与 ArkTS Builder 入口 |
| 上游工具层覆盖 | 74 / 74 导出 | 由 `scripts/test_upstream_util_coverage.py` 核对 `libs/function` 与 `libs/config`；另有 31 个依赖 uni 运行时的导出登记为 caller-owned |
| 辅助目录并入 | 2 / 2 | 数据模型并入 ActionSheet 与 Picker API |
| 公开 ArkUI 组件 | 141 | 以 `ultra-ui/Index.ets` 导出和 `export struct` 为准 |
| 公开控制器 | 7 | `UPToastController`、`UPPickerController`、`UPRefreshVirtualListController`、`UPParseController`、`UPPosterController`、`UPNovelReaderController`、`UPFormController` |
| Demo 页面/路由 | 153 | 以 `SampleCatalog.ets` 与 `SamplePage.ets` 为准；144 组件路由 + 阶段 24/26/27 的 `utils`/`i18n`/`theme` + 阶段 28 的 9 个 `Templates` 业务模板页 |
| 共享工具模块 | 8 | `UPValidate`、`UPMath`、`UPFormat`、`UPGradient`、`UPLayers`（阶段 24）、`UPValidator`（阶段 25）、`UPI18n`（阶段 26）、`UPThemeManager`（阶段 27） |
| 内置语言包 | 10 种 × 84 条 | `UPLocaleCatalog`，由 `tools/generate_uplocale_catalog.py` 从固定上游快照生成 |
| 主题令牌 | 42 个 × 2 套 | `UPThemeTokens`，由 `tools/generate_uptheme_tokens.py` 从固定上游快照生成 |
| 上游 JS 离线比对 | 8 组 | `scripts/parity/run.sh` 把工具层与上游 `libs/function`/`libs/i18n`/`libs/theme`/`libs/util/async-validator` 逐值比对，node≥22 + 本地检出可跑，缺则跳过 |
| HarmonyOS 原生扩展 | 2 | `UPTimeline`、`UPProgressButton`，上游无同名目录 |

## 状态口径

| 维度 | 值 | 含义 |
| --- | --- | --- |
| 复刻进度 | 基本完成 | 核心 Props、事件和主要状态已落地，并有静态契约与 Demo；仍不代表全量上游或真机视觉完全一致 |
| 复刻进度 | 基础可用 | 主路径可运行，但复杂插槽、动画、平台能力或边缘 Props 仍采用 ArkUI 近似、回退或 no-op |
| 复刻进度 | 占位实现 | 仅提供稳定本地 UI/回调边界，关键外部能力由宿主接入 |
| 复刻进度 | 已并入 | 上游辅助目录已合并到另一个公开组件/控制器的数据模型 |
| 复刻进度 | 未单独复刻 | 有相关能力可复用，但没有上游同名独立公开 API |
| 复刻进度 | 未开始 | 尚无对应公开 API 和独立 Demo |
| 接口兼容性 | 中高（核心 API） | 组件名或映射关系、核心 Props、常用事件基本对齐；slot/生命周期按 Builder 与 ArkUI 模型适配 |
| 接口兼容性 | 中（原生近似/拆分） | 核心行为可用，但命名、组合方式、动画或平台语义存在明确差异 |
| 接口兼容性 | 低（占位/能力复用） | 只覆盖部分能力，不能替代上游同名组件的完整接口 |
| Demo 页面 | ✅ 已完成 | 有独立示例路由 |
| Demo 页面 | ↪ 合并覆盖 / 能力复用 | 不单列页面，由关联 Demo 展示 |
| Demo 页面 | ⬜ 未开始 | 尚无示例页面和路由 |

## 上游组件完整进度表

| # | 分类 | 上游组件 | HarmonyOS API | 接口兼容性 | 复刻进度 | Demo 页面进度 | 路由 | 复刻进度备注 |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 原生交互 | `u-action-sheet` | `UPActionSheet` / `UPActionSheetProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `action-sheet` | 阶段 4A；ArkUI 原生实现，受控遮罩、选择和取消。 |
| 2 | 辅助模块 | `u-action-sheet-data` | `UPActionSheetAction` | 中（数据模型） | 已并入 | ↪ 合并覆盖 | `action-sheet` | 阶段 4A；上游数据辅助目录已并入操作面板公开 action 模型，不单独提供组件。 |
| 3 | 表单与协议 | `u-agreement` | `UPAgreement` / `UPAgreementProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `agreement` | 阶段 12；复用 UPModal 提供协议正文、链接回调和确认/取消事件，不自动导航。 |
| 4 | 媒体与内容 | `u-album` | `UPAlbum` / `UPAlbumProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `album` | 阶段 16；ArkUI 原生实现，单图见方、多图按 `rowCount` 分行、`maxCount` 截断 `+N` 罩层、圆形裁剪与 `albumWidth` 回传；`previewFullImage`、`stop` 为 no-op，非本地地址渲染占位。 |
| 5 | 原生交互 | `u-alert` | `UPAlert` / `UPAlertProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `alert` | 阶段 3B；ArkUI 原生实现，受控显示、类型和关闭回调。 |
| 6 | 媒体与内容 | `u-avatar` | `UPAvatar` / `UPAvatarProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `avatar` | 阶段 2B；ArkUI 原生实现，文字、图标和稳定背景色。 |
| 7 | 媒体与内容 | `u-avatar-group` | `UPAvatarGroup` / `UPAvatarGroupProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `avatar-group` | 阶段 2B；ArkUI 原生实现，列表、上限和更多数量。 |
| 8 | 原生交互 | `u-back-top` | `UPBackTop` / `UPBackTopProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `back-top` | 阶段 4A；ArkUI 原生实现，滚动阈值与本地回调。 |
| 9 | 基础展示 | `u-badge` | `UPBadge` / `UPBadgeProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `badge` | 阶段 2A；ArkUI 原生实现，数字、圆点、上限和反色。 |
| 10 | 原生能力 | `u-barcode` | `UPBarcode` / `UPBarcodeProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `barcode` | 阶段 18；ArkUI 原生实现，CODE128/CODE39/EAN/UPC 编码、文本位置与对齐、逐边留白与 canvas/image 两种回传；`font`、`fontOptions` 在上游即为 no-op，白名单内无 switch 分支的格式回落 CODE128，image 分支回传 base64 data URL 而非临时文件路径。 |
| 11 | 布局 | `u-box` | `UPBox` / `UPBoxProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `box` | 阶段 11；ArkUI 原生实现，背景、圆角、标题和内容 Builder。 |
| 12 | 基础展示 | `u-button` | `UPButton` / `UPButtonProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `button` | 阶段 1；ArkUI 原生实现，类型、加载、禁用与节流。 |
| 13 | 选择与日期 | `u-calendar` | `UPCalendar` / `UPCalendarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `calendar` | 阶段 9；ArkUI 原生实现，月份切换、周起始和日期选择。 |
| 14 | 选择与日期 | `u-calendar-strip` | `UPCalendarStrip` / `UPCalendarStripProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `calendar-strip` | 阶段 16；ArkUI 原生实现，自实现日期计算（无 dayjs）、周条选中与今日描边、上下拉展开月历复用 `UPCalendar`、8 种 `scene` 来源；`monthFormat`、`fullMonthNum` 为 no-op。 |
| 15 | 媒体与内容 | `u-canvas` | `UPCanvas` / `UPCanvasProps` / `UPCanvasSurface` | 中（原生近似） | 基础可用 | ✅ 已完成 | `canvas` | 阶段 17；ArkUI 原生实现，`UPCanvasSurface` 命令式门面覆盖图元、变换、样式、文本与位图族，字符串枚举走白名单映射，`measureText` 中文宽度有兜底估算；`canvasId`、`disableScroll` 为 no-op，`draw()` 只保留回调时序，`exportImage()` 返回 base64 data URL。 |
| 16 | 键盘与输入 | `u-car-keyboard` | `UPCarKeyboard` / `UPCarKeyboardProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `car-keyboard` | 阶段 15；ArkUI 原生实现，36 键省份/字母 10-10-10-6 分行、乱序洗牌、中英自动切换与退格连发；不含上游键盘面板容器与触感反馈。 |
| 17 | 基础展示 | `u-card` | `UPCard` / `UPCardProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `card` | 阶段 5；ArkUI 原生实现，本地缩略图、分区 Builder 与点击。 |
| 18 | 选择与日期 | `u-cascader` | `UPCascader` / `UPCascaderProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `cascader` | 阶段 10；ArkUI 原生实现，多级本地选项、联动和确认。 |
| 19 | 导航 | `u-cate-tab` | `UPCateTab` / `UPCateTabProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `cate-tab` | 阶段 15；ArkUI 原生实现，左菜单右分组双滚动联动、`follow`/`tab` 两模式与四个插槽；量算改用 `onAreaChange`，键名仅具名字段可寻址。 |
| 20 | 基础展示 | `u-cell` | `UPCell` / `UPCellProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `cell` | 阶段 1 建立，阶段 23 补齐 6 个插槽入口：`icon`/`title`/`label`/`value`/`right-icon`/`righticon`；上游后两者是不同插槽，本端按原名保留两个字段。 |
| 21 | 基础展示 | `u-cell-group` | `UPCellGroup` / `UPCellGroupProps` | 中高（核心 API） | 基本完成 | ↪ 合并覆盖 | `cell` | 阶段 1；ArkUI 原生实现，分组标题、容器边界和子项组合。 |
| 22 | 选择 | `u-checkbox` | `UPCheckbox` / `UPCheckboxProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `checkbox` | 阶段 2C；ArkUI 原生实现，独立勾选与禁用态。 |
| 23 | 选择 | `u-checkbox-group` | `UPCheckboxGroup` / `UPCheckboxGroupProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `checkbox-group` | 阶段 2C；ArkUI 原生实现，多选值、布局和上限回退。 |
| 24 | 选择 | `u-choose` | `UPChoose` / `UPChooseProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `choose` | 阶段 16 建立，阶段 23 把默认插槽改为作用域 `itemBuilder`（`UPChooseItemSlot`）；复用 `UPTag` 渲染单选标签行，支持换行与横滑两种布局，`modelValue` 为选中下标，`customClick` 可拦截选中；`type` 为 no-op。 |
| 25 | 布局与进度 | `u-circle-progress` | `UPCircleProgress` / `UPCircleProgressProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `circle-progress` | 阶段 3B；ArkUI 原生实现，原生环形进度与自定义颜色。 |
| 26 | 原生能力 | `u-city-locate` | `UPCityLocate` / `UPCityLocateProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `city-locate` | 阶段 19；复用 `UPIndexList`/`UPIndexItem`/`UPLine`，热门城市横排、索引分组列表与失败重试文案照上游；`uni.getLocation` 改为宿主注入 `locate(request)`，`nameKey` 按具名字段白名单读取。 |
| 27 | 键盘与输入 | `u-code` | `UPCode` / `UPCodeProps` / `UPCodeStorage` | 中（原生近似） | 基础可用 | ✅ 已完成 | `code` | 阶段 12；本地验证码倒计时、文本替换、重置和可选存储适配器；短信发送由宿主负责。 |
| 28 | 键盘与输入 | `u-code-input` | `UPCodeInput` / `UPCodeInputProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `code-input` | 阶段 3A；ArkUI 原生实现，格子、掩码、完成事件和禁用键盘。 |
| 29 | 布局 | `u-col` | `UPCol` / `UPColProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `col` | 阶段 5；ArkUI 原生实现，独立回退、跨度和内容对齐。 |
| 30 | 内容面板 | `u-collapse` | `UPCollapse` / `UPCollapseProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `collapse` | 阶段 5；ArkUI 原生实现，多开受控值与切换回调。 |
| 31 | 内容面板 | `u-collapse-item` | `UPCollapseItem` / `UPCollapseItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `collapse-item` | 阶段 5 建立，阶段 23 补齐 `icon`/`title`/`value`/`right-icon` 四个表头插槽并补上此前缺失的 `value` 文案；插槽直接落在自绘表头行，不经 `UPCell` 转发。 |
| 32 | 选择与日期 | `u-color-picker` | `UPColorPicker` / `UPColorPickerProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `color-picker` | 阶段 17；ArkUI 原生实现，纯色/渐变双页、`PanGesture` 拖拽取色、2–5 个色标增删与八方向渐变盘；`trigger` 插槽改为受控 `show`，饱和度按两轴分别归一，`conic-gradient` 用 `sweepGradient` 近似。 |
| 33 | 通知与状态 | `u-column-notice` | `UPColumnNotice` / `UPColumnNoticeProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `column-notice` | 阶段 18；`Swiper` 纵向轮播、数组文本归一、`Math.max(100, …)` 钳制切换时长与六种 `justifyContent` 映射；`speed`、`bgColor` 在上游即为 no-op。 |
| 34 | 工具 | `u-copy` | `UPCopy` / `UPCopyProps` | 低（占位/能力复用） | 占位实现 | ✅ 已完成 | `copy` | 阶段 12；通过宿主注入 `clipboard(content)`，提供成功/失败回调，不直接调用系统剪贴板。 |
| 35 | 数值与时间 | `u-count-down` | `UPCountDown` / `UPCountDownProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `count-down` | 阶段 9；ArkUI 原生实现，秒数递减、暂停重置和完成回调。 |
| 36 | 数值与时间 | `u-count-to` | `UPCountTo` / `UPCountToProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `count-to` | 阶段 9；ArkUI 原生实现，起止值、时长、小数和完成事件。 |
| 37 | 基础展示 | `u-coupon` | `UPCoupon` / `UPCouponProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `coupon` | 阶段 15 建立，阶段 23 补齐 `unit`/`limit`/`title`/`desc`/`time` 五个插槽（`unit` 按 `unitPosition` 挂左或挂右）；优惠券/红包/卡片三形状、三档尺寸、四种内置渐变；`circle` 为 no-op。 |
| 38 | 媒体与内容 | `u-cropper` | `UPCropper` / `UPCropperProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `cropper` | 阶段 20；裁剪几何逐函数移植（`stretch`/`lock` 各六分支、`inner` 贴边、控制点拖拽与双指缩放旋转），预览调色复刻 HSL 饱和度；三层 canvas 合并为一张，选图与落盘交给宿主，导出为 data URL。 |
| 39 | 选择与日期 | `u-datetime-picker` | `UPDatePicker` / `UPDatePickerProps`<br>`UPTimePicker` / `UPTimePickerProps` | 中（拆分映射） | 基础可用 | ✅ 已完成（2 页） | `date-picker`<br>`time-picker` | 阶段 10；将上游单一日期时间选择器拆成日期、时间两个 ArkUI 原生组件。 |
| 40 | 基础展示 | `u-divider` | `UPDivider` / `UPDividerProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `divider` | 阶段 2A；ArkUI 原生实现，文本、圆点和位置。 |
| 41 | 列表与拖拽 | `u-dragsort` | `UPDragSort` / `UPDragSortProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `dragsort` | 阶段 14；ArkUI 原生实现，纵向/横向/多列网格拖拽、条目级禁用与拖拽句柄；`vibrate` 触感为 no-op。 |
| 42 | 原生交互 | `u-dropdown` | `UPDropdown` / `UPDropdownProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `dropdown` | 阶段 5；ArkUI 原生实现，受控打开索引与遮罩关闭。 |
| 43 | 原生交互 | `u-dropdown-item` | `UPDropdownItem` / `UPDropdownItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `dropdown-item` | 阶段 5；ArkUI 原生实现，单选、多选与禁用选项。 |
| 44 | 基础展示 | `u-empty` | `UPEmpty` / `UPEmptyProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `empty` | 阶段 3A；ArkUI 原生实现，预设空状态图标和安全回退。 |
| 45 | 原生交互 | `u-float-button` | `UPFloatingBubble` / `UPFloatingBubbleProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `floating-bubble` | 阶段 9；以悬浮气泡 API 适配位置、禁用、图标/文字和点击回传。 |
| 46 | 表单与协议 | `u-form` | `UPForm` / `UPFormProps` / `UPFormController` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `form` | 阶段 2C 建立，阶段 25 接入 `UPValidator` 规则引擎：`rules` 支持上游全部规则字段，`errorType` 四种取值生效，布局口径经 `UPFormContext` 下发给子项；`values` 取代无索引签名的 model 对象，toast 分支由 `onErrorToast` 交宿主。 |
| 47 | 表单与协议 | `u-form-item` | `UPFormItem` / `UPFormItemProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `form-item` | 阶段 2C 建立，阶段 23 补齐 label/error 插槽，阶段 25 按 `prop` 自动显示表单级错误并补上 `labelPosition: 'top'` 与 `labelAlign`；未被 `UPForm` 包裹时全部回落自身 props。 |
| 48 | 基础展示 | `u-gap` | `UPGap` / `UPGapProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `gap` | 阶段 2A；ArkUI 原生实现，背景色、高度和上下边距。 |
| 49 | 选择 | `u-goods-sku` | `UPGoodsSku` / `UPGoodsSkuProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `goods-sku` | 阶段 17；ArkUI 原生实现，维度联动选择、库存置灰、价格与库存回落、`UPNumberBox` 购买数量和内联/弹层两种形态；`skuList` 用具名 `values` 替代索引签名，`trigger`/`header` 插槽与命令式 `reset()` 未提供，`borderRadius` 在上游即为 no-op。 |
| 50 | 布局 | `u-grid` | `UPGrid` / `UPGridProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `grid` | 阶段 5；ArkUI 原生实现，列数、间隙、边框与末行对齐。 |
| 51 | 布局 | `u-grid-item` | `UPGridItem` / `UPGridItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `grid-item` | 阶段 5；ArkUI 原生实现，名称、索引回退和点击事件。 |
| 52 | 原生交互 | `u-guide` | `UPGuide` / `UPGuideProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `guide` | 阶段 16；ArkUI 原生实现，`Swiper` 翻页 + 指示点 + 跳过/完成按钮，`once` 记忆交由 `UPGuideStorage` 宿主实现；上游 `zIndex` 改名 `stackLevel`。 |
| 53 | 基础能力 | `u-icon` | `UPIcon` / `UPIconProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `icon` | 阶段 1；ArkUI 原生实现，图标、标签和图片回退。 |
| 54 | 媒体与内容 | `u-image` | `UPImage` / `UPImageProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `image` | 阶段 3A；ArkUI 原生实现，本地资源、形状和确定性占位。 |
| 55 | 列表与索引 | `u-index-anchor` | `UPIndexAnchor` / `UPIndexAnchorProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `index-anchor` | 阶段 6；ArkUI 原生实现，默认标题条与自定义样式。 |
| 56 | 列表与索引 | `u-index-item` | `UPIndexItem` / `UPIndexItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `index-item` | 阶段 6；ArkUI 原生实现，显式标题与内容 Builder。 |
| 57 | 列表与索引 | `u-index-list` | `UPIndexList` / `UPIndexListProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `index-list` | 阶段 6；ArkUI 原生实现，受控索引、侧边栏与吸顶分组。 |
| 58 | 键盘与输入 | `u-input` | `UPInput` / `UPInputProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `input` | 阶段 2B；ArkUI 原生实现，清除、前后图标和字数限制。 |
| 59 | 键盘与输入 | `u-keyboard` | `UPKeyboard` / `UPKeyboardProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `keyboard` | 阶段 9；ArkUI 原生实现，数字/证件模式、删除和确认。 |
| 60 | 媒体与内容 | `u-lazy-load` | `UPLazyLoad` / `UPLazyLoadProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `lazy-load` | 阶段 17；ArkUI 原生实现，`onVisibleAreaChange` 触发、`'' → lazyed → loaded` 状态机、淡入时长与曲线映射、`loadingImg` 落 `Image.alt` 与错误态整幅替换；`threshold` 只换算不参与触发，非本地地址渲染占位且不回传 `onError`。 |
| 61 | 基础展示 | `u-line` | `UPLine` / `UPLineProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `line` | 阶段 2A；ArkUI 原生实现，横线、竖线、细线与虚线。 |
| 62 | 布局与进度 | `u-line-progress` | `UPLineProgress` / `UPLineProgressProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `line-progress` | 阶段 2A；ArkUI 原生实现，百分比、颜色和文字。 |
| 63 | 基础展示 | `u-link` | `UPLink` / `UPLinkProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `link` | 阶段 2A；ArkUI 原生实现，文本、下划线和点击回传。 |
| 64 | 列表与索引 | `u-list` | `UPList` / `UPListProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `list` | 阶段 6；ArkUI 原生实现，阈值、锚点、滚动与刷新请求。 |
| 65 | 列表与索引 | `u-list-item` | `UPListItem` / `UPListItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `list-item` | 阶段 6；ArkUI 原生实现，独立回退与原生 ListItem。 |
| 66 | 基础能力 | `u-loading-icon` | `UPLoadingIcon` / `UPLoadingIconProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `loading-icon` | 阶段 1；ArkUI 原生实现，spinner、semicircle 和 circle。 |
| 67 | 通知与状态 | `u-loading-page` | `UPLoadingPage` / `UPLoadingPageProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `loading-page` | 阶段 3A；ArkUI 原生实现，受控显示、加载图标和遮罩区域。 |
| 68 | 通知与状态 | `u-loadmore` | `UPLoadmore` / `UPLoadmoreProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `loadmore` | 阶段 2A；ArkUI 原生实现，加载、可加载和无更多。 |
| 69 | 内容与解析 | `u-markdown` | `UPMarkdown` / `UPMarkdownProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `markdown` | 阶段 19；内置 ArkTS markdown 词法替代上游打包的 marked，标题、列表、引用、围栏代码块、表格与行内语法转 html 后交给 `UPParse`；上游 scss 默认样式注入 `tagStyle`，`light`/`dark` 双主题，`applyTheme` 在上游即为 no-op。 |
| 70 | 键盘与输入 | `u-message-input` | `UPMessageInput` / `UPMessageInputProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `message-input` | 阶段 15；ArkUI 原生实现，`box`/`bottomLine`/`middleLine` 三形态、圆点填充、满位 finish 与隐藏原生键盘；呼吸效果用定时器近似 CSS keyframes。 |
| 71 | 原生交互 | `u-modal` | `UPModal` / `UPModalProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `modal` | 阶段 1；ArkUI 原生实现，确认、取消和异步关闭。 |
| 72 | 导航 | `u-navbar` | `UPNavbar` / `UPNavbarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `navbar` | 阶段 6；ArkUI 原生实现，标题、左右区域、自动返回与占位。 |
| 73 | 导航 | `u-navbar-mini` | `UPNavbarMini` / `UPNavbarMiniProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `navbar-mini` | 阶段 6；ArkUI 原生实现，返回、首页重启与透明背景。 |
| 74 | 通知与状态 | `u-no-network` | `UPNoNetwork` / `UPNoNetworkProps` | 低（占位/能力复用） | 占位实现 | ✅ 已完成 | `no-network` | 阶段 12；由宿主控制 `isConnected`/`networkType`，提供无网占位和重试事件，不执行系统网络监听。 |
| 75 | 通知与状态 | `u-notice-bar` | `UPNoticeBar` / `UPNoticeBarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `notice-bar` | 阶段 3B；ArkUI 原生实现，本地公告、链接和关闭。 |
| 76 | 原生交互 | `u-notify` | `UPNotify` / `UPNotifyProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `notify` | 阶段 3B；ArkUI 原生实现，受控顶部通知与关闭回调。 |
| 77 | 内容与解析 | `u-novel-reader` | `UPNovelReader` / `UPNovelReaderProps` / `UPNovelReaderController` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `novel-reader` | 阶段 20 建立，阶段 23 补齐 8 个插槽（`loading`/`error`/`empty`/`top`/`toolbar-extra`/`bottom`/`catalog`/`settings`）；合并上游五个内核模块，分页引擎与上游逐页比对一致，滚动/翻页双模式、五套主题、目录书签与章节预取齐备；持久化改宿主注入 `UPNovelStorage`，视口改 `onAreaChange` 量测。 |
| 78 | 数值与时间 | `u-number-box` | `UPNumberBox` / `UPNumberBoxProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `number-box` | 阶段 2B；ArkUI 原生实现，加减、边界和小数位。 |
| 79 | 键盘与输入 | `u-number-keyboard` | `UPNumberKeyboard` / `UPNumberKeyboardProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `number-keyboard` | 阶段 18；`number`/`card` 两套布局、`randomArray()` 洗牌、0 键占两格与 250ms 长按连续退格；`hover-class`、`hover-stay-time` 改由 `onTouch` 按下态近似，未知 `mode` 回落数字布局。 |
| 80 | 原生交互 | `u-overlay` | `UPOverlay` / `UPOverlayProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `overlay` | 阶段 1；ArkUI 原生实现，受控显示与遮罩点击。 |
| 81 | 选择与日期 | `u-pagination` | `UPPagination` / `UPPaginationProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `pagination` | 阶段 8；ArkUI 原生实现，页数推导、边界钳制和单页隐藏。 |
| 82 | 内容与解析 | `u-parse` | `UPParse` / `UPParseProps` / `UPParseController` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `parse` | 阶段 19；mp-html v2.5.1 词法与节点树移植，html 摊平为文本/图片/分隔线/媒体/表格五种原生块，不使用 `rich-text` 或浏览器内核；SVG、`display:grid` 合并单元格与 plugins 不复刻，图片预览、外链与媒体播放交给宿主。 |
| 83 | 内容与解析 | `u-pdf-reader` | `UPPdfReader` / `UPPdfReaderProps` | 低（占位/能力复用） | 占位实现 | ✅ 已完成 | `pdf-reader` | 阶段 19；`viewerUrl` 拼接与百分号编码照上游，但不内嵌浏览器内核也不请求远端资源，渲染区由宿主 `viewerBuilder` 提供，未接入时显示占位。 |
| 84 | 选择与日期 | `u-picker` | `UPPicker` / `UPPickerProps`<br>`UPPickerController` | 中（原生近似） | 基础可用 | ✅ 已完成（2 页） | `picker`<br>`picker-cascade` | 阶段 7；ArkUI 原生实现，原生文本选择、多列、工具栏与控制器级联。 |
| 85 | 选择与日期 | `u-picker-column` | `UPPickerColumn` / `UPPickerColumnProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `picker-column` | 阶段 19；上游模板只是 `picker-view-column` 包一个空 `view` 且无 props 与事件，本端同样是薄壳插槽容器，只提供行高、主轴对齐与 `customStyle`；多列联动仍由 `UPPicker` 与 `UPPickerController` 承担。 |
| 86 | 辅助模块 | `u-picker-data` | `UPPickerOption` / `UPPickerItem`<br>`UPPickerController` | 中（数据模型） | 已并入 | ↪ 合并覆盖 | `picker`<br>`picker-cascade` | 阶段 7；选项、条目与级联控制能力已并入 Picker API，不单独提供组件。 |
| 87 | 原生交互 | `u-popover` | `UPPopover` / `UPPopoverProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `popover` | 阶段 8；ArkUI 原生实现，受控显示、方位回退和切换回调。 |
| 88 | 原生交互 | `u-popup` | `UPPopup` / `UPPopupProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `popup` | 阶段 1；ArkUI 原生实现，方向、圆角和关闭按钮。 |
| 89 | 媒体与内容 | `u-poster` | `UPPoster` / `UPPosterProps` / `UPPosterController` | 中（原生近似） | 基础可用 | ✅ 已完成 | `poster` | 阶段 20；`view`/`text`/`image`/`qrcode` 四类元素、线性与径向渐变、圆角裁剪与行数受限折行照上游；二维码改用内置编码器直绘，导出为 data URL，20 秒超时竞速与 H5 Blob 不复刻。 |
| 90 | 列表与索引 | `u-pull-refresh` | `UPPullRefresh` / `UPPullRefreshProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `pull-refresh` | 阶段 14；ArkUI 原生实现，三态提示、阻尼阈值、三态插槽与触底加载；`enableBackToTop` 为 no-op。 |
| 91 | 原生能力 | `u-qrcode` | `UPQrcode` / `UPQrcodeProps` / `UPQrcodeEncoder` | 中（原生近似） | 基础可用 | ✅ 已完成 | `qrcode` | 阶段 18；完整 QR 编码器与上游 36 例逐格一致、四档容错级别、定位角 `pdground` 配色、留白与中心图标；`toTempFilePath`、`previewImage`、`saveImageToPhotosAlbum` 改回调 + base64 data URL，`show`、`usingComponents` 为 no-op。 |
| 92 | 选择 | `u-radio` | `UPRadio` / `UPRadioProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `radio` | 阶段 2C；ArkUI 原生实现，独立单选与禁用态。 |
| 93 | 选择 | `u-radio-group` | `UPRadioGroup` / `UPRadioGroupProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `radio-group` | 阶段 2C；ArkUI 原生实现，单选值、布局和变更回传。 |
| 94 | 选择 | `u-rate` | `UPRate` / `UPRateProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `rate` | 阶段 2B；ArkUI 原生实现，星级、最小值和禁用态。 |
| 95 | 内容面板 | `u-read-more` | `UPReadMore` / `UPReadMoreProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `read-more` | 阶段 8；ArkUI 原生实现，折叠高度、文案和开关回调。 |
| 96 | 列表与索引 | `u-refresh-virtual-list` | `UPRefreshVirtualList` / `UPRefreshVirtualListProps`<br>`UPRefreshVirtualListController` | 中（原生近似） | 基础可用 | ✅ 已完成 | `refresh-virtual-list` | 阶段 14；下拉刷新与虚拟窗口组合容器，上游实例方法改由控制器下发 `finishRefresh`/`scrollTo`/`scrollToTop`。 |
| 97 | 布局 | `u-row` | `UPRow` / `UPRowProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `row` | 阶段 5；ArkUI 原生实现，12 栅格、间距、偏移与换行。 |
| 98 | 通知与状态 | `u-row-notice` | `UPRowNotice` / `UPRowNoticeProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `row-notice` | 阶段 18；原生 `Marquee` 横向滚动、20 字符分片、速度到每帧步进换算与 `link`/`closable` 模式；`bgColor` 在上游即为 no-op，文本宽度改由估算替代 DOM 量测。 |
| 99 | 导航 | `u-safe-bottom` | `UPSafeBottom` / `UPSafeBottomProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `safe-bottom` | 阶段 6；ArkUI 原生实现，底部安全区回退与内容 Builder。 |
| 100 | 列表与索引 | `u-scroll-list` | `UPScrollList` / `UPScrollListProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `scroll-list` | 阶段 6；ArkUI 原生实现，横向滚动、边界事件与比例指示器。 |
| 101 | 键盘与输入 | `u-search` | `UPSearch` / `UPSearchProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `search` | 阶段 3A；ArkUI 原生实现，输入、清除、搜索和操作事件。 |
| 102 | 基础展示 | `u-section` | `UPSection` / `UPSectionProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `section` | 阶段 11；ArkUI 原生实现，标识线、标题、辅助文案和箭头。 |
| 103 | 选择 | `u-select` | `UPSelect` / `UPSelectProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `select` | 阶段 7 建立，阶段 23 补齐 `text`/`icon`/`options` 三个插槽与作用域 `optionItemBuilder`（`UPSelectOptionSlot`）；ArkUI 原生实现，受控选项、遮罩和禁用项。 |
| 104 | 媒体与内容 | `u-short-video` | `UPShortVideo` / `UPShortVideoProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `short-video` | 阶段 20；纵向 `Swiper` 加原生 `Video`，五个播放事件、倍速面板、互动计数与底部进度滑块齐备；多个 `videoContext` 改为单个 `VideoController`，`enable-progress-gesture` 无等价能力。 |
| 105 | 原生能力 | `u-signature` | `UPSignature` / `UPSignatureProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `signature` | 阶段 17；ArkUI 原生实现，`PanGesture(distance: 0)` 采集手写轨迹、撤销与清空重绘、粗细钳制 1–20 与预设色板；导出返回 base64 data URL 而非上游临时文件路径。 |
| 106 | 通知与状态 | `u-skeleton` | `UPSkeleton` / `UPSkeletonProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `skeleton` | 阶段 2A；ArkUI 原生实现，标题、头像和占位行。 |
| 107 | 选择 | `u-slider` | `UPSlider` / `UPSliderProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `slider` | 阶段 7；ArkUI 原生实现，步长、方向、禁用和变更回调。 |
| 108 | 导航 | `u-status-bar` | `UPStatusBar` / `UPStatusBarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `status-bar` | 阶段 6；ArkUI 原生实现，顶部安全区高度与背景。 |
| 109 | 导航 | `u-steps` | `UPSteps` / `UPStepsProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `steps` | 阶段 6；ArkUI 原生实现，横向、纵向、点状与错误状态。 |
| 110 | 导航 | `u-steps-item` | `UPStepsItem` / `UPStepsItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `steps-item` | 阶段 6；ArkUI 原生实现，独立步骤项与 Builder 回退。 |
| 111 | 原生交互 | `u-sticky` | `UPSticky` / `UPStickyProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `sticky` | 阶段 8；ArkUI 原生实现，偏移字段、禁用态和安全容器。 |
| 112 | 导航 | `u-subsection` | `UPSubsection` / `UPSubsectionProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `subsection` | 阶段 6；ArkUI 原生实现，button/subsection 模式与禁用项。 |
| 113 | 原生交互 | `u-swipe-action` | `UPSwipeAction` / `UPSwipeActionProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `swipe-action` | 阶段 8；ArkUI 原生实现，父子自动关闭与受控开合。 |
| 114 | 原生交互 | `u-swipe-action-item` | `UPSwipeActionItem` / `UPSwipeActionItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `swipe-action-item` | 阶段 8；ArkUI 原生实现，阈值拖动、禁用和选项事件。 |
| 115 | 媒体与内容 | `u-swiper` | `UPSwiper` / `UPSwiperProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `swiper` | 阶段 11；ArkUI 原生实现，本地轮播、循环、方向和切换事件。 |
| 116 | 媒体与内容 | `u-swiper-indicator` | `UPSwiperIndicator` / `UPSwiperIndicatorProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `swiper-indicator` | 阶段 11；ArkUI 原生实现，点状、线状、数字和点击索引。 |
| 117 | 选择 | `u-switch` | `UPSwitch` / `UPSwitchProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `switch` | 阶段 2B；ArkUI 原生实现，自定义值、禁用和加载。 |
| 118 | 导航 | `u-tabbar` | `UPTabbar` / `UPTabbarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tabbar` | 阶段 11；ArkUI 原生实现，受控值、禁用项、安全区和元数据。 |
| 119 | 导航 | `u-tabbar-item` | `UPTabbarItem` / `UPTabbarItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tabbar-item` | 阶段 11；ArkUI 原生实现，独立导航项、图标、徽标和点击。 |
| 120 | 表格 | `u-table` | `UPTable` / `UPTableProps` / `UPTableRow` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `table` | 阶段 13；ArkUI 原生实现，样式上下文下发、网格边框，支持插槽组合与 `headers`/`rows`/`widths` 数据驱动。 |
| 121 | 表格 | `u-table2` | `UPTable2` / `UPTable2Props` / `UPTable2Column` / `UPTable2Row` | 中（原生近似） | 基础可用 | ✅ 已完成 | `table2` | 阶段 13 建立，阶段 23 补齐作用域 `header`/`headerSort`/`cell` 与 `empty` 插槽；ArkUI 原生实现，斑马纹、固定表头、滚动、过滤、单/多列排序、勾选与展开列、树形缩进；`spanMethod`、类名、`cellStyle`、`lazy`/`load`、`showOverflowTooltip`、`column.fixed` 为 no-op 兼容位并记录诊断。 |
| 122 | 导航 | `u-tabs` | `UPTabs` / `UPTabsProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tabs` | 阶段 6；ArkUI 原生实现，受控索引、禁用项、长按与滚动。 |
| 123 | 导航 | `u-tabs-item` | `UPTabsItem` / `UPTabsItemProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tabs-item` | 阶段 6；ArkUI 原生实现，独立内容 Builder 与安全呈现。 |
| 124 | 导航 | `u-tabs-pro` | `UPTabsPro` / `UPTabsProProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tabs-pro` | 阶段 15；基于 `UPTabs` 扩展内容区、左右与图标插槽和下标钳制；`contentMode`、`contentClass`、`bindIndexRef`、`lineBgSize` 为 no-op。 |
| 125 | 基础展示 | `u-tag` | `UPTag` / `UPTagProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `tag` | 阶段 1；ArkUI 原生实现，类型、朴素样式和关闭。 |
| 126 | 表格 | `u-td` | `UPTd` / `UPTdProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `td` | 阶段 13；ArkUI 原生实现，宽度、对齐、字号、颜色和边框留空即继承表格上下文。 |
| 127 | 基础展示 | `u-text` | `UPText` / `UPTextProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `text` | 阶段 3A；ArkUI 原生实现，模式、格式化、图标和本地回调。 |
| 128 | 键盘与输入 | `u-textarea` | `UPTextarea` / `UPTextareaProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `textarea` | 阶段 2B；ArkUI 原生实现，多行输入、计数和边框。 |
| 129 | 表格 | `u-th` | `UPTh` / `UPThProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `th` | 阶段 13；ArkUI 原生实现，留空等分或原生固定宽度，`thStyle` 继承与本地 `customStyle` 覆盖。 |
| 130 | 基础展示 | `u-title` | `UPTitle` / `UPTitleProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `title` | 阶段 2A；ArkUI 原生实现，主标题、副标题和前缀色条。 |
| 131 | 原生交互 | `u-toast` | `UPToastHost`<br>`UPToastController` / `UPToastOptions` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `toast` | 阶段 1；采用单 Host + Controller 的命令式模型，覆盖位置、遮罩、替换和完成回调。 |
| 132 | 原生交互 | `u-toolbar` | `UPToolbar` / `UPToolbarProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `toolbar` | 阶段 11；ArkUI 原生实现，取消、标题、确认和动作回调。 |
| 133 | 原生交互 | `u-tooltip` | `UPTooltip` / `UPTooltipProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `tooltip` | 阶段 8；ArkUI 原生实现，长按、复制、按钮和遮罩关闭。 |
| 134 | 表格 | `u-tr` | `UPTr` / `UPTrProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `tr` | 阶段 13；ArkUI 原生实现，Flex 等高行、行底色和行序号登记。 |
| 135 | 原生交互 | `u-transition` | `UPTransition` / `UPTransitionProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `transition` | 阶段 16；ArkUI 原生实现，12 种 `mode`、5 种时间曲线映射 `Curve`、三态挂载与 20ms 进入延时、六个进出场事件；ArkUI 无 `transitionend`，收口用定时器近似。 |
| 136 | 内容面板 | `u-tree` | `UPTreeSelect` / `UPTreeSelectProps` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `tree-select` | 阶段 10 建立，阶段 23 把节点标签改为作用域 `nodeBuilder`，阶段 21 按上游补齐 18 个字段与 6 个事件：键名映射、三态勾选、`checkStrictly`、`accordion`、当前行高亮与展开/折叠图标；`children` 固定读具名字段。 |
| 137 | 媒体与内容 | `u-upload` | `UPUpload` / `UPUploadProps` | 低（本地占位） | 占位实现 | ✅ 已完成 | `upload` | 阶段 10 建立，阶段 23 补齐 `default`/`trigger`/`playIcon`/`success` 四个插槽（`trigger` 优先于 `default`）；仅提供本地文件列表、删除和重试回调，不执行文件选择或网络上传。 |
| 138 | 辅助模块 | `uview-plus` | — | 不适用 | 不适用 | — 不单列 | — | 上游根模块/注册辅助目录，不是独立 UI 组件，不计入 138 个 UI 目录分母。 |
| 139 | 布局 | `u-view` | `UPView` / `UPViewProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `view` | 阶段 11；ArkUI 原生实现，Flex、尺寸、边距、边框和点击回传。 |
| 140 | 列表与索引 | `u-virtual-list` | `UPVirtualList` / `UPVirtualListProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `virtual-list` | 阶段 14；ArkUI 原生实现，固定行高窗口、缓冲区、占位撑高与滚动位置双向同步；不支持动态行高。 |
| 141 | 列表与索引 | `u-waterfall` | `UPWaterfall` / `UPWaterfallProps` | 中（原生近似） | 基础可用 | ✅ 已完成 | `waterfall` | 阶段 14 建立，阶段 23 补齐 `left` 整列插槽与 `useLeftSlot` 开关（`column` 优先）；逐条入列、最短列落位、`columns='auto'` 自适应；不含图片懒加载。 |

## HarmonyOS 原生扩展组件

| 组件 | 接口兼容性 | 复刻进度 | Demo 页面进度 | 路由 | 备注 |
| --- | --- | --- | --- | --- | --- |
| `UPTimeline` / `UPTimelineProps` | 不适用（原生扩展） | 基础可用 | ✅ 已完成 | `timeline` | 阶段 9；时间线节点布局、颜色、禁用态和点击回传。上游 141 个目录中无同名组件。 |
| `UPProgressButton` / `UPProgressButtonProps` | 不适用（原生扩展） | 基础可用 | ✅ 已完成 | `progress-button` | 阶段 10；普通、加载、成功、失败状态和进度展示。上游 141 个目录中无同名组件。 |

## 共享工具进度

| ArkTS 模块 | 上游来源 | 接口兼容性 | 复刻进度 | Demo 页面进度 | 路由 | 复刻进度备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `UPValidate`（26 个函数） | `libs/function/test.js` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `utils` | 阶段 24；正则与上游逐字一致，`upIsLetter`/`upIsEnOrNum` 保留空串为真的上游行为；另加严格日历判定 `upIsCalendarDate`，`array`/`object`/`promise` 等类型探测函数为 caller-owned。 |
| `UPMath` | `libs/function/digit.js`、`calc.js` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `utils` | 阶段 24；放大成整数再运算，四则、舍入与折叠形态齐备；越界改为返回布尔并记录 `lastOverflow()`，不打印日志；`calc.js` 与 `digit.js` 重复能力只保留一套。 |
| `UPFormat` | `libs/function/index.js` 格式化族 | 中（原生近似） | 基本完成 | ✅ 已完成 | `utils` | 阶段 24；日期换算用 days-from-civil 算法且按 UTC，不读平台时钟（`timeFrom` 的 `now` 由调用方传入）；`priceFormat` 逐字保留上游清洗字符类；`queryParams` 因 ArkTS 无索引签名改为显式条目数组。 |
| `UPGradient` | `libs/function/colorGradient.js`、`genLightColor()` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `utils` | 阶段 24；hex/rgb/rgba/HSL 互转与 N 段渐变，首尾锁定起止色；解析失败返回空串而非抛错。 |
| `UPZIndex` / `UPLegacyColor` | `libs/config/zIndex.js`、`color.js` | 中高（常量镜像） | 基本完成 | ✅ 已完成 | `utils` | 阶段 24；层级与调色板逐值镜像，另导出 `UP_THEME_TYPES` 与 `UP_UPSTREAM_CONFIG_VERSION`；兼容主色 `#3c9cff` 与组件主题主色 `#2979ff` 按原样并存。 |
| `UPValidator` | `libs/util/async-validator.js` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `form` | 阶段 25；12 个规则字段、11 种类型判定与 19 条文案模板逐字对齐，执行顺序同上游；同步返回取代 Promise，`source` 改显式条目数组（不支持 `a.b.c` 深层路径），`rule.enum` 改名 `enumValues`，`pattern` 传源码字符串；`asyncValidator`、`fields` 嵌套、`defaultField`、`options.first` 未复刻。 |
| `UPThemeManager` / `UPThemeTokens` | `libs/theme/theme.js` | 中（原生近似） | 基本完成 | ✅ 已完成 | `theme` | 阶段 27；42 个令牌 × 明暗两套取值逐值镜像上游，生成器 + 固定快照维护；模式与偏好收敛规则同上游。不探测平台主题（`uni.getAppBaseInfo`/`onThemeChange` 无 ArkTS 等价）也不持久化偏好；ArkTS 无 CSS 变量层，令牌改为组件内显式查表，切换后已挂载组件需经 `addListener()` + `@State` 才重绘；四个中性色名与组件专属色经 `UPColor.neutral()`/`adaptive()` 取令牌，固定「浅色照旧、暗色查令牌」以零回归，品牌色按上游保持模式无关。`libs/theme/runtime.js` 的导航栏/tabBar 同步属宿主职责，未复刻。 |
| `UPI18n` / `UPLocaleCatalog` | `libs/i18n` | 中高（核心 API） | 基本完成 | ✅ 已完成 | `i18n` | 阶段 26；10 种语言 × 84 条文案逐字节镜像上游，生成器 + 固定快照维护；`t()`/`registerLocale()`/`translate()` 与占位符回落链同上游。不读平台语言（`uni.getLocale`/`onLocaleChange` 无 ArkTS 等价），默认 `zh-Hans` 由宿主 `setLocale()` 设置；`registerLocale` 改按键合并而非整表替换；组件默认值在实例化时求值，已挂载组件不随切换刷新。 |

## 控制器进度

| 控制器 | 关联上游组件 | 接口兼容性 | 进度 | Demo 页面进度 | 路由 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `UPToastController` | `u-toast` | 中高（命令式 API） | 基本完成 | ↪ 由组件页覆盖 | `toast` | 管理显示、替换、关闭、时长和完成原因；页面只挂载一个 `UPToastHost`。 |
| `UPPickerController` | `u-picker` / `u-picker-data` | 中（原生控制器） | 基础可用 | ✅ 已完成 | `picker-cascade` | 管理多列选项、选中索引和级联更新；列容器由独立的 `UPPickerColumn` 承担。 |
| `UPRefreshVirtualListController` | `u-refresh-virtual-list` | 中（原生控制器） | 基础可用 | ↪ 由组件页覆盖 | `refresh-virtual-list` | 把上游模板 `ref` 实例方法 `finishRefresh()`、`scrollTo(top)`、`scrollToTop()` 转成显式控制器；未挂载时命令被丢弃并记录诊断。 |
| `UPParseController` | `u-parse` | 中（原生控制器） | 基础可用 | ↪ 由组件页覆盖 | `parse` | 把上游模板 `ref` 实例方法 `setContent()`、`getText()`、`pauseMedia()`、`setPlaybackRate()` 与改名后的 `scrollToAnchor()` 转成显式控制器，并回传纯文本、图片列表与 `<title>` 快照；未挂载时命令被丢弃并记录诊断。 |
| `UPPosterController` | `u-poster` | 中（原生控制器） | 基础可用 | ↪ 由组件页覆盖 | `poster` | 把上游 `exportImage()` 转成显式控制器，并提供 `redraw()` 与 `lastImage()` 快照；未挂载时命令被丢弃并记录诊断。 |
| `UPNovelReaderController` | `u-novel-reader` | 中（原生控制器） | 基础可用 | ↪ 由组件页覆盖 | `novel-reader` | 把翻页、跳章、切模式、改设置、开合工具条、书签与重试转成显式命令，并回传进度、书签与阅读时长快照；`setMode()` 因 `mode` 受控只回传 `onModeChange`。 |
| `UPFormController` | `u-form` | 中高（命令式 API） | 基本完成 | ✅ 已完成 | `form` | 阶段 25；把上游 `validate()`、`validateField(prop, trigger)`、`clearValidate()`、`resetFields()`、`setRules()` 转成显式控制器，并持有首次值快照；`resetFields()` 只还原控制器内的值，宿主用 `resetValues()` 回灌自己的 `@State`。 |

## 更新规则

1. 新增上游映射时，同步更新公共导出、组件源码、静态契约、Demo 文件、目录路由和本表。
2. 只有存在可导入的公开 ArkUI API 时，才计入“已有 ArkUI 实现覆盖”；内部工具类或相似能力不计入。
3. 只有 `SampleCatalog.ets` 和 `SamplePage.ets` 均接入后，Demo 才标记为“✅ 已完成”。
4. `基本完成` 仍需保留上游差异说明；完成真机/模拟器交互与截图对照前，不写“完整兼容”或“视觉一致”。
5. 新增或修改字段后跑 `scripts/test_upstream_prop_coverage.py`：它逐目录核对上游 props 与 ArkTS `Props`/`Options`，任何缺口都会失败。
6. 新增或修改事件后跑 `scripts/test_upstream_event_coverage.py`：它逐目录核对上游 emits 与 ArkTS `on*` 回调，任何缺口都会失败。
7. 新增或修改插槽后跑 `scripts/test_upstream_slot_coverage.py`：它逐目录核对上游 `<slot>` 与 ArkTS Builder 入口；无作用域插槽用 `xxxBuilder?: UPBuilder` + `UPSlotRegion`，带数据的作用域插槽保留 `@BuilderParam` 并补单参数作用域接口。
8. 新增或修改共享工具后跑 `scripts/test_upstream_util_coverage.py`：它核对上游 `libs/function` 与 `libs/config` 的导出；依赖 uni 运行时无法复刻的导出要显式登记到 `PLATFORM_OWNED` 白名单并在阶段文档里说明。
9. 新增组件默认文案时先在 `UPLocaleCatalog` 找对应的 `up.*` 键并用 `UPI18n.t()` 取值，不要写死中文；语言包只能通过 `tools/generate_uplocale_catalog.py` 从 `tools/upstream/uview-plus-locales` 重新生成，不手改生成文件。
10. 新增颜色时先在 `UPThemeTokens` 找对应令牌并用 `UPColor.token(令牌, 浅色字面值)` 取值，避免只在浅色下正确；令牌表只能通过 `tools/generate_uptheme_tokens.py` 从 `tools/upstream/uview-plus-theme.js` 重新生成。
11. 每次更新后核对 141 个上游目录无缺失、无重复，并重新统计公开组件、控制器和 Demo 路由数量。
