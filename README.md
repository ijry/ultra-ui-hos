# ultra-ui-hos

uview-plus 的 HarmonyOS NEXT 原生实现。仓库同时提供一个可复用的 HAR 组件库和一个中文 HAP 示例工程，组件使用 ArkTS/ArkUI 编写，不依赖 Vue/NVue、WebView、网络请求或业务路由运行时。

## 当前交付范围

当前包含阶段 1、阶段 2A、阶段 2B、阶段 2C、阶段 3A、阶段 3B、阶段 4A、阶段 5、阶段 6、阶段 7、阶段 8、阶段 9、阶段 10、阶段 11、阶段 12、阶段 13、阶段 14、阶段 15、阶段 16、阶段 17、阶段 18、阶段 19、阶段 20、阶段 21、阶段 22、阶段 23、阶段 24、阶段 25、阶段 26、阶段 27 与阶段 28，共 148 个已实现组件/控制器（141 个组件 + 7 个控制器）与 8 个共享工具模块，均从 HAR 公共入口导出。上游 138 个 UI 目录已全部具备对应的公开 ArkUI API，`libs/function` 与 `libs/config` 工具层也已复刻。

阶段 8 完成时的历史交付基线为 80 个已实现组件/控制器（78 个组件 + 2 个控制器）和 78 条组件示例路由；阶段 9 完成时为 86 个已实现组件/控制器（84 个组件 + 2 个控制器）和 84 条组件示例路由；阶段 10 完成时为 92 个已实现组件/控制器（90 个组件 + 2 个控制器）和 90 条组件示例路由；阶段 11 完成时为 100 个已实现组件/控制器（98 个组件 + 2 个控制器）和 98 条组件示例路由；阶段 12 完成时为 104 个已实现组件/控制器（102 个组件 + 2 个控制器）和 102 条组件示例路由；阶段 13 完成时为 109 个已实现组件/控制器（107 个组件 + 2 个控制器）和 107 条组件示例路由；阶段 14 完成时为 115 个已实现组件/控制器（112 个组件 + 3 个控制器）和 112 条组件示例路由；阶段 15 完成时为 120 个已实现组件/控制器（117 个组件 + 3 个控制器）和 117 条组件示例路由；阶段 16 完成时为 125 个已实现组件/控制器（122 个组件 + 3 个控制器）和 122 条组件示例路由；阶段 17 完成时为 130 个已实现组件/控制器（127 个组件 + 3 个控制器）和 127 条组件示例路由；阶段 18 完成时为 135 个已实现组件/控制器（132 个组件 + 3 个控制器）和 132 条组件示例路由；阶段 19 完成时为 141 个已实现组件/控制器（137 个组件 + 4 个控制器）和 137 条组件示例路由；这些历史短语保留用于跨阶段文档契约。

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

### 阶段 5：导航核心组件

- `UPStatusBar`、`UPSafeBottom`：顶部/底部系统安全区域和内容 Builder
- `UPNavbar`、`UPNavbarMini`：标题导航、返回、首页重启和实例级导航适配器
- `UPTabs`、`UPTabsItem`：受控标签、禁用项、长按、滚动近似和内容 Builder
- `UPSubsection`：`button`/`subsection` 模式、受控索引和禁用项
- `UPSteps`、`UPStepsItem`：横向/纵向步骤、点状连接、状态计算和 Builder

导航组件的页面受控状态、事件顺序、安全区回退、固定定位近似、Tabs 滚动近似和 Steps 连接线近似见 [`docs/compatibility/phase-5.md`](docs/compatibility/phase-5.md)。

### 阶段 6：列表与索引组件

- `UPList`、`UPListItem`：原生纵向列表、阈值事件、锚点定位、刷新请求与独立安全回退
- `UPIndexList`、`UPIndexItem`、`UPIndexAnchor`：受控侧边索引、吸顶分组、显式双 Builder 与默认标题条
- `UPScrollList`：原生横向滚动、左右边界事件与比例指示器

列表组件的 no-op 字段、原生近似、无网络边界和设备验证状态见 [`docs/compatibility/phase-6.md`](docs/compatibility/phase-6.md)。

### 阶段 7：滑块与选择组件

- `UPSlider`：原生 Slider、步长量化、方向、禁用、数值显示和变更事件
- `UPPicker`：原生 TextPicker、单列/多列、工具栏、确认/取消和受控显示
- `UPPickerController`：多列索引、列值更新和级联联动
- `UPSelect`：受控下拉选项、遮罩、禁用项和当前值回调

阶段 7 的原生映射、`isRange`/`popupMode` 等兼容降级、`UPPickerColumn` 范围（独立列容器在阶段 19 补齐）和设备验证状态见 [`docs/compatibility/phase-7.md`](docs/compatibility/phase-7.md)。

### 阶段 8：导航与更多组件

- `UPPopover`、`UPTooltip`：页面内气泡/文字提示、触发回退、复制与按钮回调
- `UPSticky`：吸顶安全容器、偏移字段和宿主滚动诊断
- `UPSwipeAction`、`UPSwipeActionItem`：父子自动关闭、拖动阈值和选项选择
- `UPReadMore`：受控展开收起、折叠高度与自定义文案
- `UPPagination`：页数推导、页码钳制、前后翻页和单页隐藏

阶段 8 的页面内定位、Sticky 宿主滚动、滑动手势和无网络边界见 [`docs/compatibility/phase-8.md`](docs/compatibility/phase-8.md)。

### 阶段 9：时间、日期与输入交互

- `UPCountDown`、`UPCountTo`：本地倒计时、数字滚动、暂停/重置和完成事件
- `UPTimeline`：节点内容、颜色、禁用态和点击回传
- `UPCalendar`：月份切换、周起始、日期网格和选择事件
- `UPKeyboard`：数字/证件模式、删除、确认和长度限制
- `UPFloatingBubble`：位置、禁用态、图标/文字和点击回传

阶段 9 的本地计时、日期计算、虚拟键盘边界和设备验证状态见 [`docs/compatibility/phase-9.md`](docs/compatibility/phase-9.md)。

### 阶段 10：高级选择与媒体占位

- `UPTreeSelect`、`UPCascader`：树形选择、多级联动、禁用节点和确认回调
- `UPDatePicker`、`UPTimePicker`：本地年月日及时分秒选择、步长和边界回退
- `UPUpload`：本地文件列表占位、删除/重试回调，不执行网络上传
- `UPProgressButton`：普通、加载、成功、失败状态和进度显示

阶段 10 的选择器列联动、上传网络边界和设备验证状态见 [`docs/compatibility/phase-10.md`](docs/compatibility/phase-10.md)。

### 阶段 11：容器、轮播与底部导航

- `UPView`、`UPBox`：通用内容容器、尺寸/边距/边框样式、标题和内容 Builder
- `UPSection`：区块标题、辅助文案、左侧标识线、箭头和点击回传
- `UPToolbar`：受控面板工具栏、取消/确认按钮和本地操作事件
- `UPSwiper`、`UPSwiperIndicator`：原生轮播、本地条目、受控索引、自动播放和页码指示器
- `UPTabbar`、`UPTabbarItem`：受控底部导航、禁用项、颜色、安全区、占位和元数据回传

阶段 11 的原生映射、远程图片安全占位、受控状态和设备验证状态见 [`docs/compatibility/phase-11.md`](docs/compatibility/phase-11.md)。

### 阶段 12：协议、复制、网络与验证码工具

- `UPAgreement`：协议正文、用户协议/隐私政策链接回调、确认/取消事件和内容 Builder
- `UPCopy`：宿主剪贴板注入、复制请求和成功/失败回调；不直接调用系统剪贴板
- `UPNoNetwork`：受控连接状态、网络类型、无网络占位和重试事件；不执行系统网络监听
- `UPCode`：本地验证码倒计时、文本替换、重置、状态事件和可选 `UPCodeStorage`

阶段 12 的宿主能力边界、no-op 回退、剪贴板/网络监听约束和设备验证状态见 [`docs/compatibility/phase-12.md`](docs/compatibility/phase-12.md)。

### 阶段 13：表格体系

- `UPTable`：表格容器、样式上下文下发、网格边框，支持插槽组合与 `headers`/`rows`/`widths` 数据驱动两种用法
- `UPTr`：等高行、行底色和行序号登记
- `UPTh`：表头单元格、留空等分或原生固定宽度、`thStyle` 继承与本地覆盖
- `UPTd`：数据单元格、对齐/字号/颜色/边框留空即继承表格上下文
- `UPTable2`：斑马纹、固定表头、滚动高度、当前行高亮、列过滤、单列与多列排序、勾选列、展开列和树形表格

阶段 13 的具名行模型、no-op 兼容字段（`spanMethod`、类名、`cellStyle`、`lazy`/`load`、`showOverflowTooltip`、`column.fixed`、`treeProps`）和设备验证状态见 [`docs/compatibility/phase-13.md`](docs/compatibility/phase-13.md)。

### 阶段 14：列表虚拟化与拖拽

- `UPVirtualList`：固定行高虚拟窗口、缓冲区、占位撑高、`keyField` 稳定标识和滚动位置双向同步
- `UPPullRefresh`：下拉/释放/刷新三态提示、阻尼与阈值、三态插槽覆盖、触底加载更多和状态事件
- `UPRefreshVirtualList`、`UPRefreshVirtualListController`：下拉刷新与虚拟窗口的组合容器，控制器提供 `finishRefresh`/`scrollTo`/`scrollToTop`
- `UPWaterfall`：逐条入列、最短列落位、固定列数与 `columns='auto'` 自适应、列插槽和入列事件
- `UPDragSort`：纵向/横向/多列网格拖拽排序、条目级禁用、拖拽句柄和排序结果事件

阶段 14 的具名列表模型、no-op 兼容位（`vibrate` 触感、`enableBackToTop`）、固定行高与图片加载边界和设备验证状态见 [`docs/compatibility/phase-14.md`](docs/compatibility/phase-14.md)。

### 阶段 15：键盘、验证码与内容展示

- `UPCarKeyboard`：36 个省份简称与数字字母键、10/10/10/6 分行、乱序洗牌、中英自动切换和退格连发
- `UPMessageInput`：`box`/`bottomLine`/`middleLine` 三种形态、圆点填充、呼吸激活格、满位 finish 和隐藏原生键盘
- `UPCateTab`：左菜单右分组双滚动联动、`follow`/`tab` 两种模式、四个插槽和受控 `current`
- `UPCoupon`：优惠券/红包/卡片三种形状、三档尺寸、四种内置渐变主题、金额与操作区插槽和禁用态
- `UPTabsPro`：在 `UPTabs` 之上扩展内容区、左右与图标插槽、下标钳制和 `click`/`longPress`/`change` 事件

阶段 15 的具名分类模型、no-op 兼容位（`circle`、`contentMode`、`contentClass`、`bindIndexRef`、`lineBgSize`）、呼吸动画与量算回退边界和设备验证状态见 [`docs/compatibility/phase-15.md`](docs/compatibility/phase-15.md)。

### 阶段 16：过渡动画、相册与引导

- `UPTransition`：12 种过渡模式、5 种时间曲线、`show` 受控进出场和 `beforeEnter`/`enter`/`afterEnter` 六个事件
- `UPAlbum`：单图见方、多图按 `rowCount` 分行、`maxCount` 截断与 `+N` 罩层、圆形裁剪和 `albumWidth` 回传
- `UPCalendarStrip`：横向日期条、上下拉展开月历、`minDate`/`maxDate` 钳制、回到今天和跨月 `monthChange`
- `UPChoose`：标签行单选、换行与横滑两种布局、白名单字段名和 `customClick` 拦截
- `UPGuide`：`Swiper` 翻页引导、指示点与跳过/完成按钮、`once` 一次性记忆和宿主注入的存储实现

阶段 16 的具名数据模型、no-op 兼容位（`previewFullImage`、`stop`、`monthFormat`、`fullMonthNum`、`type`）、`zIndex` 到 `stackLevel` 的改名和设备验证状态见 [`docs/compatibility/phase-16.md`](docs/compatibility/phase-16.md)。

### 阶段 17：懒加载、画布与商品规格

- `UPLazyLoad`：可视区触发、`'' → lazyed → loaded` 状态机、淡入时长与曲线、占位图与错误态
- `UPCanvas`：`UPCanvasSurface` 命令式绘制门面、图元与渐变、文本量算兜底、触摸坐标回传和 data URL 导出
- `UPSignature`：`PanGesture` 手写轨迹、撤销与清空、粗细 1–20 钳制、预设色板和工具栏开关
- `UPColorPicker`：纯色/渐变双页、饱和度与色相透明度轨道、2–5 个色标增删和八方向渐变盘
- `UPGoodsSku`：维度联动选择、库存置灰、价格与库存回落、`UPNumberBox` 购买数量和内联/弹层两种形态

阶段 17 的具名数据模型、no-op 兼容位（`canvasId`、`disableScroll`、`threshold`、`borderRadius`、`reset`）、data URL 导出差异和设备验证状态见 [`docs/compatibility/phase-17.md`](docs/compatibility/phase-17.md)。

### 阶段 18：二维码、条码与公告键盘

- `UPQrcode`：完整 QR 编码器、四档容错级别、定位角配色、留白与中心图标和 data URL 回传
- `UPBarcode`：CODE128/CODE39/EAN/UPC 编码、文本位置与对齐、逐边留白和 canvas/image 两种回传形态
- `UPRowNotice`：原生 `Marquee` 横向滚动、20 字符分片、速度到步进换算和 `link`/`closable` 两种模式
- `UPColumnNotice`：`Swiper` 纵向轮播、数组文本归一、切换时长钳制和六种对齐方式
- `UPNumberKeyboard`：`number`/`card` 两套布局、乱序洗牌、0 键占两格和长按连续退格

阶段 18 的具名数据模型、no-op 兼容位（`show`、`usingComponents`、`font`、`bgColor`、`speed`、`hover-class`）、data URL 导出差异和设备验证状态见 [`docs/compatibility/phase-18.md`](docs/compatibility/phase-18.md)。

### 阶段 19：富文本、Markdown 与内容边界

- `UPParse`、`UPParseController`：mp-html 词法与节点树移植、html 摊平成原生文本/图片/分隔线/媒体/表格块、锚点滚动与命令式 `setContent`
- `UPMarkdown`：内置 ArkTS markdown 词法、上游默认样式注入 `tagStyle`、`light`/`dark` 双主题与代码块行号
- `UPPickerColumn`：对齐上游空壳插槽容器，提供行高、主轴对齐与插槽承载
- `UPCityLocate`：复用索引列表与分割线、热门城市横排、宿主注入定位回调与失败重试文案
- `UPPdfReader`：`viewerUrl` 拼接与百分号编码、宿主 `viewerBuilder` 接入和内置占位边界

阶段 19 的解析器简化清单、no-op 兼容位（`lazyLoad`、`loadingImg`、`errorImg`、`showImgMenu`、`pauseVideo`、`setTitle`、`applyTheme`）、宿主注入边界和设备验证状态见 [`docs/compatibility/phase-19.md`](docs/compatibility/phase-19.md)。

### 阶段 20：裁剪、海报、短视频与小说阅读

- `UPCropper`：裁剪框控制点拖拽、双指缩放旋转、`stretch`/`lock` 各六个分支、`inner` 模式贴边与预览调色
- `UPPoster`、`UPPosterController`：json 配置绘制 `view`/`text`/`image`/`qrcode`、渐变与圆角、行数受限折行和内置二维码编码
- `UPShortVideo`：纵向 `Swiper` 加原生 `Video`、倍速面板、互动计数与底部进度滑块
- `UPNovelReader`、`UPNovelReaderController`：滚动与翻页双模式、五套主题、目录书签抽屉、章节预取和阅读时长统计

阶段 20 的具名几何模型、no-op 兼容位（`noTab`、`quality`、`enable-progress-gesture`、`autoBack`、`fontFamily`）、宿主注入边界（`chooseImage`、`UPNovelStorage`）和设备验证状态见 [`docs/compatibility/phase-20.md`](docs/compatibility/phase-20.md)。

### 阶段 21：上游字段级对齐

- `UPTriggerInput`（内部模块）：picker 家族共享的 `hasInput` 触发行，复刻上游 `inputPropsInner` 的展开顺序与 `surround`/`bottom`/`none` 三种边框
- `UPPicker`、`UPDatePicker`、`UPTimePicker`：新增 `hasInput`、`inputBorder`、`inputProps`、`placeholder`、`disabled`、`disabledColor` 与 `format`
- `UPTreeSelect`：按上游 `u-tree` 补齐 18 个字段与 6 个事件，三态勾选、`checkStrictly`、`accordion` 与当前行高亮齐备
- `UPCalendar`、`UPCalendarStrip`：新增 `forbidDays`、`forbidDaysToast`、`monthFormat` 与 `fullCalendarProps`
- `UPTable2`、`UPUpload`、`UPView`、`UPGuide`、`UPFormItem`、`UPFloatingBubble`、`UPSelect`、`UPCropper`、`UPNovelReader`：补齐 `sortBy`/`sortMethod`/`context`、`extension`、`flex1`、`zIndex`、`leftIconStyle`、`list`、`overlayStyle`、`lockWidth`/`lockHeight` 与 `autoBack`

阶段 21 的字段清单、别名规则、no-op 兼容位和设备验证状态见 [`docs/compatibility/phase-21.md`](docs/compatibility/phase-21.md)。

### 阶段 22：上游事件级对齐

- 反馈与容器：`UPModal` 的 `confirm`/`cancel`/`cancelOnAsync`、`UPCollapse` 的 `open`/`close`、`UPPopover` 与 `UPTooltip` 的 `click`/`open`/`close`、`UPPopup` 的 `closed`、`UPOverlay` 与 `UPGrid` 的 `click`
- 数据与表单：`UPTable2` 的 `select`/`select-all`/`filter-change`/`row-dblclick`、`UPPagination` 的 `current-change`/`size-change`、`UPList` 的三个下拉阶段事件、`UPUpload` 的读取流水线、`UPButton` 的 open-type 五个回调
- 输入与选择：`UPInput` 与 `UPTextarea` 的 `keyboardheightchange`/`nicknamereview`/`linechange`、`UPNumberBox` 的 `focus`/`overlimit`、`UPKeyboard` 的 `change`/`backspace`/`cancel`、日期与时间选择器的 `change`/`input`/`update:modelValue`/`close`

阶段 22 的事件清单、近似判定说明、no-op 兼容位和设备验证状态见 [`docs/compatibility/phase-22.md`](docs/compatibility/phase-22.md)。

### 阶段 23：上游插槽级对齐

- 承载方式：无作用域的具名插槽声明为 `xxxBuilder?: UPBuilder` 并交给内部 `UPSlotRegion` / `UPSlotBlock` 渲染，共 55 个组件、109 个入口；上游把数据传进插槽的场景保留 `@BuilderParam` 并配套单参数作用域接口
- 多插槽补齐：`UPCell` 的六个入口（含 `right-icon` 与 `righticon` 两个同源异名插槽）、`UPNovelReader` 的 8 个插槽、`UPCoupon` 的金额/信息区五个插槽、`UPCollapseItem`、`UPPicker` 与日期时间选择器的 `trigger`/`toolbar-right`/`toolbar-bottom`、`UPUpload` 的 `trigger`/`playIcon`/`success`
- 作用域插槽：`UPTable2` 的 `header`/`headerSort`/`cell`、`UPSelect.optionItem`、`UPChoose` 的默认项、`UPTreeSelect` 的节点标签、`UPWaterfall` 的 `left`（配套 `useLeftSlot` 开关）
- 示例工程：路由数不变，在 `CellDemo`、`TitleDemo`、`NumberBoxDemo`、`SelectDemo`、`Table2Demo` 里追加插槽演示段

阶段 23 的插槽清单、替换与追加语义、no-op 兼容位和设备验证状态见 [`docs/compatibility/phase-23.md`](docs/compatibility/phase-23.md)。

### 阶段 24：上游工具层复刻

- `UPValidate`：26 个纯函数校验器，正则与上游 `libs/function/test.js` 逐字一致，另加严格日历判定 `upIsCalendarDate`
- `UPMath`：高精度四则运算与舍入，沿用上游「放大成整数再运算」策略，`0.1 + 0.2` 得到 `0.3`
- `UPFormat`：`timeFormat`/`timeFrom`/`priceFormat`/`durationText`/`trim`/`queryParams`/`typeIcon`，日期换算不依赖平台 `Date` 解析
- `UPGradient`：hex/rgb/rgba/HSL 互转、N 段渐变与 `lightColor`
- `UPZIndex` 与 `UPLegacyColor`：上游层级表与兼容调色板的逐值镜像
- 示例工程新增 `Components Y` 分组与 `utils` 路由，示例路由数增至 142

阶段 24 的函数清单、口径差异、caller-owned 白名单和设备验证状态见 [`docs/compatibility/phase-24.md`](docs/compatibility/phase-24.md)。

### 阶段 25：表单规则校验

- `UPValidator`：复刻上游 `async-validator` 的规则引擎，12 个规则字段、11 种类型判定与 19 条文案模板逐字对齐，同步返回结果
- `UPFormController`：把上游 `u-form` 的 `validate()`/`validateField()`/`clearValidate()`/`resetFields()`/`setRules()` 转成显式控制器，并持有首次值快照
- `UPFormContext`：`UPForm` 下发错误与 `errorType`/`labelPosition`/`labelWidth`/`labelAlign`，`UPFormItem` 按 `prop` 自动显示错误
- `errorType` 四种取值：`message` 渲染文案、`border-bottom` 下划线转红、`toast` 经 `onErrorToast` 交宿主、`none` 不呈现
- `FormDemo` 重写：五个字段覆盖 required/email/number 区间/enum/array 规则，按 `blur`/`change` 触发逐字段校验

阶段 25 的规则字段、执行顺序、口径差异和设备验证状态见 [`docs/compatibility/phase-25.md`](docs/compatibility/phase-25.md)。

### 阶段 26：多语言

- `UPLocaleCatalog`：10 种语言 × 84 条文案的生成式快照，键名与文案逐字节镜像上游，由 `tools/generate_uplocale_catalog.py` 从固定快照生成
- `UPI18n`：`setLocale`/`hasLocale`/`registerLocale`/`clearLocale`/`t`/`translate`，`{name}` 占位符与缺失回落链与上游一致
- 组件接入：17 个组件的 35 处默认文案与 3 个内部模块的 8 处常量改为查表，顺带修正 6 处与上游不一致的译文
- 校验文案：新增 `upValidateMessagesFor()`，`UPFormController` 按当前语言挑选中/英文表（本端扩展，上游校验器只有英文）
- 示例工程新增 `i18n` 路由，示例路由数增至 143

阶段 26 的语言清单、接入点、口径差异和设备验证状态见 [`docs/compatibility/phase-26.md`](docs/compatibility/phase-26.md)。

### 阶段 27：明暗主题

- `UPThemeTokens`：42 个主题令牌 × 明暗两套取值的生成式快照，来源是上游 `theme.js` 的颜色映射表，由 `tools/generate_uptheme_tokens.py` 生成
- `UPThemeManager`：`setMode`/`setPreference`/`systemModeChanged`/`token`/`tokenFor`/`setOverrides`/`addListener`，模式与偏好收敛规则同上游
- `UPColor`：解析顺序扩展为「主题色名 → 主题令牌 → 字面色值 → fallback」，另加 `UPColor.token()`、`UPColor.neutral()` 与 `UPColor.adaptive()`
- 明暗自适应：`neutral()`/`adaptive()` 固定「浅色返回既有字面值、暗色查令牌」，浅色零回归；品牌色保持模式无关（与上游一致）
- 组件接入：49 个文件的 108 处硬编码颜色 + 21 处主题字段直读改为按令牌取值，浅色不变、暗色可用
- 示例工程新增 `theme` 路由，示例路由数增至 144

阶段 27 的令牌清单、接入映射、口径差异和设备验证状态见 [`docs/compatibility/phase-27.md`](docs/compatibility/phase-27.md)。

### 阶段 28：业务模板页

- 复刻上游示例工程 `pages/template/*` 的 9 个业务场景页,归入示例目录新分组 `Templates`
- 登录 `tpl-login`、红包支付 `tpl-pay`、商品操作栏 `tpl-submit-bar`、评论 `tpl-comment`、订单 `tpl-order`、优惠券 `tpl-coupon`、个人中心 `tpl-mine`、商城分类 `tpl-mall`、地址管理 `tpl-address`
- 全部只用公共入口组件拼装,业务路由改本地状态、远程图改占位、无网络请求;示例路由数增至 153(144 组件 + 9 模板)

阶段 28 的场景清单、拼装边界和设备验证状态见 [`docs/compatibility/phase-28.md`](docs/compatibility/phase-28.md)。

上游 138 个 UI 目录已全部具备对应的公开 ArkUI API，且每个上游 prop、emit 与 slot 都有对应入口（由 `scripts/test_upstream_prop_coverage.py`、`scripts/test_upstream_event_coverage.py` 与 `scripts/test_upstream_slot_coverage.py` 逐目录校验）；工具层由 `scripts/test_upstream_util_coverage.py` 逐导出校验。后续维护聚焦真机验证与视觉细节。

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

示例应用只从 `@lingyun/ultra-ui-hos` 导入组件，不访问 HAR 内部文件。首页使用 ArkUI 原生 `Navigation`/`NavPathStack`，按 `Components A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y` 分组展示已完成路由，其中 `Components J` 收录阶段 6 列表与索引示例，`Components K` 收录阶段 7 滑块与选择示例，`Components L` 收录阶段 8 导航与更多示例，`Components M` 收录阶段 9 时间、日期与输入示例，`Components N` 收录阶段 10 高级选择与媒体占位示例，`Components O` 收录阶段 11 容器、轮播与底部导航示例，`Components P` 收录阶段 12 协议、复制、网络与验证码工具示例，`Components Q` 收录阶段 13 表格体系示例，`Components R` 收录阶段 14 虚拟列表、下拉刷新、瀑布流与拖拽排序示例，`Components S` 收录阶段 15 车牌键盘、验证码输入、分类导航、优惠券与增强标签栏示例，`Components T` 收录阶段 16 过渡动画、相册、日期条、标签选择与引导页示例，`Components U` 收录阶段 17 懒加载、画布、签名板、颜色选择器与商品规格示例，`Components V` 收录阶段 18 二维码、条形码、横向公告、纵向公告与数字键盘示例，`Components W` 收录阶段 19 富文本、Markdown、选择器列、城市定位与 PDF 阅读器示例，`Components X` 收录阶段 20 图片裁剪、海报合成、短视频与小说阅读示例，`Components Y` 收录阶段 24 工具集、阶段 26 多语言与阶段 27 主题示例，当前包含 144 条组件示例路由。

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
python3 scripts/test_phase_5_navigation_contract.py
python3 scripts/test_phase_6_list_index_contract.py
python3 scripts/test_phase_7_form_selection_contract.py
python3 scripts/test_phase_8_navigation_more_contract.py
python3 scripts/test_phase_9_time_interaction_contract.py
python3 scripts/test_phase_10_advanced_selection_media_contract.py
python3 scripts/test_phase_11_container_swiper_tabbar_contract.py
python3 scripts/test_phase_12_foundation_tools_contract.py
python3 scripts/test_phase_13_table_contract.py
python3 scripts/test_phase_14_list_virtualization_contract.py
python3 scripts/test_phase_15_keyboard_content_contract.py
python3 scripts/test_phase_16_transition_album_contract.py
python3 scripts/test_phase_17_lazyload_canvas_contract.py
python3 scripts/test_phase_18_code_notice_contract.py
python3 scripts/test_phase_19_parse_markdown_contract.py
python3 scripts/test_phase_20_media_reader_contract.py
python3 scripts/test_phase_21_prop_parity_contract.py
python3 scripts/test_upstream_prop_coverage.py
python3 scripts/test_phase_22_event_parity_contract.py
python3 scripts/test_upstream_event_coverage.py
python3 scripts/test_phase_23_slot_parity_contract.py
python3 scripts/test_upstream_slot_coverage.py
python3 scripts/test_phase_24_utility_contract.py
python3 scripts/test_upstream_util_coverage.py
python3 scripts/test_phase_25_form_validation_contract.py
python3 scripts/test_phase_26_i18n_contract.py
python3 scripts/test_phase_27_theme_contract.py
python3 scripts/test_parity_harness_contract.py
python3 scripts/test_documentation_contract.py
python3 scripts/test_device_script_contract.py
./scripts/verify-boundaries.sh
git diff --check
```

工具层与上游 JS 的字节级离线比对（需要 node ≥ 22 与本地 uview-plus 检出，缺任一时自动跳过）：

```bash
./scripts/parity/run.sh
```

该脚本把 `UPMath`、`UPValidate`、`UPFormat`、`UPGradient`、`UPI18n`、`UPThemeTokens`、`UPValidator`、`UPThemeManager` 与上游 `libs/function`、`libs/i18n`、`libs/theme`、`libs/util/async-validator` 的对应实现逐值比对，覆盖高精度运算、15 类校验器、时间/价格格式化、颜色互转与渐变、840 条多语言文案、84 个主题令牌取值、表单规则文案与明暗模式取色。`UPFormat` 的日期换算按 UTC 进行（见 `docs/compatibility/phase-24.md`），脚本已固定 `TZ=UTC`。

设备截图（无连接设备时会输出 `screenshots: skipped`）：

```bash
./scripts/capture-screenshots.sh
```

更具体的组件范围、兼容回退、no-op 字段、设备验证限制和后续扩展路线见 [`docs/compatibility/phase-1.md`](docs/compatibility/phase-1.md)、[`docs/compatibility/phase-2a.md`](docs/compatibility/phase-2a.md)、[`docs/compatibility/phase-2b.md`](docs/compatibility/phase-2b.md)、[`docs/compatibility/phase-2c.md`](docs/compatibility/phase-2c.md)、[`docs/compatibility/phase-3a.md`](docs/compatibility/phase-3a.md)、[`docs/compatibility/phase-3b.md`](docs/compatibility/phase-3b.md)、[`docs/compatibility/phase-4a.md`](docs/compatibility/phase-4a.md)、[`docs/compatibility/phase-5.md`](docs/compatibility/phase-5.md)、[`docs/compatibility/phase-6.md`](docs/compatibility/phase-6.md)、[`docs/compatibility/phase-7.md`](docs/compatibility/phase-7.md)、[`docs/compatibility/phase-8.md`](docs/compatibility/phase-8.md)、[`docs/compatibility/phase-9.md`](docs/compatibility/phase-9.md)、[`docs/compatibility/phase-10.md`](docs/compatibility/phase-10.md)、[`docs/compatibility/phase-11.md`](docs/compatibility/phase-11.md)、[`docs/compatibility/phase-12.md`](docs/compatibility/phase-12.md)、[`docs/compatibility/phase-13.md`](docs/compatibility/phase-13.md)、[`docs/compatibility/phase-14.md`](docs/compatibility/phase-14.md)、[`docs/compatibility/phase-15.md`](docs/compatibility/phase-15.md)、[`docs/compatibility/phase-16.md`](docs/compatibility/phase-16.md)、[`docs/compatibility/phase-17.md`](docs/compatibility/phase-17.md) 、[`docs/compatibility/phase-18.md`](docs/compatibility/phase-18.md)、[`docs/compatibility/phase-19.md`](docs/compatibility/phase-19.md)、[`docs/compatibility/phase-20.md`](docs/compatibility/phase-20.md)、[`docs/compatibility/phase-21.md`](docs/compatibility/phase-21.md)、[`docs/compatibility/phase-22.md`](docs/compatibility/phase-22.md)、[`docs/compatibility/phase-23.md`](docs/compatibility/phase-23.md)、[`docs/compatibility/phase-24.md`](docs/compatibility/phase-24.md)、[`docs/compatibility/phase-25.md`](docs/compatibility/phase-25.md)、[`docs/compatibility/phase-26.md`](docs/compatibility/phase-26.md)、[`docs/compatibility/phase-27.md`](docs/compatibility/phase-27.md) 和 [`docs/compatibility/phase-28.md`](docs/compatibility/phase-28.md)。
