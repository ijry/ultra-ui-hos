export class SampleItem {
  readonly route: string;
  readonly title: string;
  readonly description: string;

  constructor(route: string, title: string, description: string) {
    this.route = route;
    this.title = title;
    this.description = description;
  }
}

export class SampleGroup {
  readonly title: string;
  readonly items: Array<SampleItem>;

  constructor(title: string, items: Array<SampleItem>) {
    this.title = title;
    this.items = items;
  }
}

export const SAMPLE_GROUPS: Array<SampleGroup> = [
  new SampleGroup('Components A', [
    new SampleItem('button', '按钮 Button', '类型、加载、禁用与节流'),
    new SampleItem('cell', '单元格 Cell', '标题、说明、值与点击回传'),
    new SampleItem('icon', '图标 Icon', '图标、标签和图片回退'),
    new SampleItem('loading-icon', '加载图标 LoadingIcon', 'spinner、semicircle 和 circle'),
    new SampleItem('overlay', '遮罩层 Overlay', '受控显示与遮罩点击'),
    new SampleItem('popup', '弹出层 Popup', '方向、圆角和关闭按钮'),
    new SampleItem('line', '线条 Line', '横线、竖线、细线与虚线'),
    new SampleItem('gap', '间隔槽 Gap', '背景色、高度和上下边距'),
    new SampleItem('link', '超链接 Link', '文本、下划线和点击回传'),
    new SampleItem('title', '标题 Title', '主标题、副标题和前缀色条'),
    new SampleItem('badge', '徽标 Badge', '数字、圆点、上限和反色'),
    new SampleItem('divider', '分割线 Divider', '文本、圆点和位置'),
    new SampleItem('skeleton', '骨架屏 Skeleton', '标题、头像和占位行'),
    new SampleItem('line-progress', '线形进度条 LineProgress', '百分比、颜色和文字'),
    new SampleItem('loadmore', '加载更多 Loadmore', '加载、可加载和无更多'),
    new SampleItem('avatar', '头像 Avatar', '文字、图标和稳定背景色'),
    new SampleItem('avatar-group', '头像组 AvatarGroup', '列表、上限和更多数量'),
    new SampleItem('input', '输入框 Input', '清除、前后图标和字数限制'),
    new SampleItem('textarea', '文本域 Textarea', '多行输入、计数和边框'),
    new SampleItem('switch', '开关 Switch', '自定义值、禁用和加载'),
    new SampleItem('rate', '评分 Rate', '星级、最小值和禁用态'),
    new SampleItem('number-box', '步进器 NumberBox', '加减、边界和小数位'),
    new SampleItem('checkbox', '复选框 Checkbox', '独立勾选与禁用态'),
    new SampleItem('checkbox-group', '复选框组 CheckboxGroup', '多选值、布局和上限回退'),
    new SampleItem('radio', '单选框 Radio', '独立单选与禁用态'),
    new SampleItem('radio-group', '单选框组 RadioGroup', '单选值、布局和变更回传'),
    new SampleItem('form', '表单 Form', '模型、规则占位与校验回调'),
    new SampleItem('form-item', '表单项 FormItem', '标签、必填、错误和插槽')
  ]),
  new SampleGroup('Components B', [
    new SampleItem('tag', '标签 Tag', '类型、朴素样式和关闭'),
    new SampleItem('toast', '提示消息 Toast', '位置、遮罩和替换'),
  ]),
  new SampleGroup('Components C', [
    new SampleItem('modal', '模态框 Modal', '确认、取消和异步关闭')
  ]),
  new SampleGroup('Components D', [
    new SampleItem('text', '文本 Text', '模式、格式化、图标和本地回调'),
    new SampleItem('image', '图片 Image', '本地资源、形状和确定性占位'),
    new SampleItem('empty', '空状态 Empty', '预设空状态图标和安全回退'),
    new SampleItem('loading-page', '加载页 LoadingPage', '受控显示、加载图标和遮罩区域'),
    new SampleItem('search', '搜索框 Search', '输入、清除、搜索和操作事件'),
    new SampleItem('code-input', '验证码输入 CodeInput', '格子、掩码、完成事件和禁用键盘')
  ]),
  new SampleGroup('Components F', [
    new SampleItem('circle-progress', '环形进度 CircleProgress', '原生环形进度与自定义颜色'),
    new SampleItem('alert', '提示条 Alert', '受控显示、类型和关闭回调'),
    new SampleItem('notify', '通知 Notify', '受控顶部通知与关闭回调'),
    new SampleItem('notice-bar', '公告栏 NoticeBar', '本地公告、链接和关闭'),
  ]),
  new SampleGroup('Components G', [
    new SampleItem('action-sheet', '操作面板 ActionSheet', '受控遮罩、选择和取消'),
    new SampleItem('back-top', '返回顶部 BackTop', '滚动阈值与本地回调'),
  ]),
  new SampleGroup('Components H', [
    new SampleItem('collapse', '折叠面板 Collapse', '多开受控值与切换回调'),
    new SampleItem('collapse-item', '折叠项 CollapseItem', '独立展开值与内容 Builder'),
    new SampleItem('dropdown', '下拉菜单 Dropdown', '受控打开索引与遮罩关闭'),
    new SampleItem('dropdown-item', '下拉项 DropdownItem', '单选、多选与禁用选项'),
  ]),
  new SampleGroup('Components E', [
    new SampleItem('row', '行布局 Row', '12 栅格、间距、偏移与换行'),
    new SampleItem('col', '列布局 Col', '独立回退、跨度和内容对齐'),
    new SampleItem('grid', '宫格 Grid', '列数、间隙、边框与末行对齐'),
    new SampleItem('grid-item', '宫格项 GridItem', '名称、索引回退和点击事件'),
    new SampleItem('card', '卡片 Card', '本地缩略图、分区 Builder 与点击')
  ]),
  new SampleGroup('Components I', [
    new SampleItem('navbar', '导航栏 Navbar', '标题、左右区域、自动返回与占位'),
    new SampleItem('navbar-mini', '迷你导航栏 NavbarMini', '返回、首页重启与透明背景'),
    new SampleItem('status-bar', '状态栏 StatusBar', '顶部安全区高度与背景'),
    new SampleItem('safe-bottom', '安全底部 SafeBottom', '底部安全区回退与内容 Builder'),
    new SampleItem('tabs', '标签 Tabs', '受控索引、禁用项、长按与滚动'),
    new SampleItem('tabs-item', '标签项 TabsItem', '独立内容 Builder 与安全呈现'),
    new SampleItem('subsection', '分段器 Subsection', 'button/subsection 模式与禁用项'),
    new SampleItem('steps', '步骤条 Steps', '横向、纵向、点状与错误状态'),
    new SampleItem('steps-item', '步骤项 StepsItem', '独立步骤项与 Builder 回退')
  ]),
  new SampleGroup('Components J', [
    new SampleItem('list', '列表 List', '阈值、锚点、滚动与刷新请求'),
    new SampleItem('list-item', '列表项 ListItem', '独立回退与原生 ListItem'),
    new SampleItem('index-list', '索引列表 IndexList', '受控索引、侧边栏与吸顶分组'),
    new SampleItem('index-item', '索引项 IndexItem', '显式标题与内容 Builder'),
    new SampleItem('index-anchor', '索引锚点 IndexAnchor', '默认标题条与自定义样式'),
    new SampleItem('scroll-list', '横向列表 ScrollList', '横向滚动、边界事件与比例指示器')
  ]),
  new SampleGroup('Components K', [
    new SampleItem('slider', '滑块 Slider', '步长、方向、禁用和变更回调'),
    new SampleItem('picker', '选择器 Picker', '原生文本选择、多列和工具栏'),
    new SampleItem('picker-cascade', '级联选择器 Picker', '控制器联动列和选中索引'),
    new SampleItem('select', '下拉选择 Select', '受控选项、遮罩和禁用项')
  ]),
  new SampleGroup('Components L', [
    new SampleItem('popover', '气泡 Popover', '受控显示、方位回退和切换回调'),
    new SampleItem('tooltip', '文字提示 Tooltip', '长按、复制、按钮和遮罩关闭'),
    new SampleItem('sticky', '吸顶 Sticky', '偏移字段、禁用态和安全容器'),
    new SampleItem('swipe-action', '滑动操作 SwipeAction', '父子自动关闭与受控开合'),
    new SampleItem('swipe-action-item', '滑动操作项 SwipeActionItem', '阈值拖动、禁用和选项事件'),
    new SampleItem('read-more', '展开阅读 ReadMore', '折叠高度、文案和开关回调'),
    new SampleItem('pagination', '分页器 Pagination', '页数推导、边界钳制和单页隐藏')
  ]),
  new SampleGroup('Components M', [
    new SampleItem('count-down', '倒计时 CountDown', '秒数递减、暂停重置和完成回调'),
    new SampleItem('count-to', '数字滚动 CountTo', '起止值、时长、小数和完成事件'),
    new SampleItem('timeline', '时间线 Timeline', '节点内容、颜色、禁用和点击'),
    new SampleItem('calendar', '日历 Calendar', '月份切换、周起始和日期选择'),
    new SampleItem('keyboard', '虚拟键盘 Keyboard', '数字/证件模式、删除和确认'),
    new SampleItem('floating-bubble', '悬浮按钮 FloatingBubble', '位置、禁用和点击回传')
  ]),
  new SampleGroup('Components N', [
    new SampleItem('tree-select', '树形选择 TreeSelect', '树节点、多选、禁用和父子展开'),
    new SampleItem('cascader', '级联选择 Cascader', '多级本地选项、联动和确认'),
    new SampleItem('date-picker', '日期选择 DatePicker', '年月日列选择和边界回退'),
    new SampleItem('time-picker', '时间选择 TimePicker', '时分秒列选择和步长'),
    new SampleItem('upload', '上传占位 Upload', '本地文件占位、删除和重试回调'),
    new SampleItem('progress-button', '进度按钮 ProgressButton', '加载、成功、失败和进度')
  ]),
  new SampleGroup('Components O', [
    new SampleItem('view', '通用容器 View', 'Flex、尺寸、边距、边框和点击回传'),
    new SampleItem('box', '信息面板 Box', '背景、圆角、标题和内容 Builder'),
    new SampleItem('section', '区块标题 Section', '标识线、标题、辅助文案和箭头'),
    new SampleItem('toolbar', '工具栏 Toolbar', '取消、标题、确认和动作回调'),
    new SampleItem('swiper', '轮播 Swiper', '本地轮播、循环、方向和切换事件'),
    new SampleItem('swiper-indicator', '轮播指示器 SwiperIndicator', '点状、线状、数字和点击索引'),
    new SampleItem('tabbar', '底部导航 Tabbar', '受控值、禁用项、安全区和元数据'),
    new SampleItem('tabbar-item', '底部导航项 TabbarItem', '独立导航项、图标、徽标和点击')
  ]),
  new SampleGroup('Components P', [
    new SampleItem('agreement', '协议弹窗 Agreement', '协议文本、链接回调和确认状态'),
    new SampleItem('copy', '复制工具 Copy', '宿主剪贴板注入和成功/失败回调'),
    new SampleItem('no-network', '无网络 NoNetwork', '受控网络状态、占位和重试事件'),
    new SampleItem('code', '验证码倒计时 Code', '本地倒计时、可选存储和状态事件')
  ]),
  new SampleGroup('Components Q', [
    new SampleItem('table', '表格 Table', '边框、对齐、内边距与数据驱动行'),
    new SampleItem('tr', '表格行 Tr', '行容器、背景与子单元格拉伸'),
    new SampleItem('th', '表头单元格 Th', '固定宽度、表头样式与对齐'),
    new SampleItem('td', '表格单元格 Td', '宽度、字号、颜色与本地覆盖'),
    new SampleItem('table2', '数据表格 Table2', '排序、勾选、树形展开与空态')
  ]),
  new SampleGroup('Components R', [
    new SampleItem('virtual-list', '虚拟列表 VirtualList', '固定行高、缓冲区与可视窗口渲染'),
    new SampleItem('pull-refresh', '下拉刷新 PullRefresh', '三态提示、阻尼阈值与触底加载'),
    new SampleItem('refresh-virtual-list', '刷新虚拟列表 RefreshVirtualList', '下拉刷新与虚拟窗口的组合容器'),
    new SampleItem('waterfall', '瀑布流 Waterfall', '最短列入列、自动列数与列插槽'),
    new SampleItem('dragsort', '拖拽排序 DragSort', '纵向、横向、多列与自定义句柄')
  ]),
  new SampleGroup('Components S', [
    new SampleItem('car-keyboard', '车牌键盘 CarKeyboard', '省份/号码切换、乱序按键与连续删除'),
    new SampleItem('message-input', '验证码输入 MessageInput', '盒子、下划线、圆点填充与呼吸光标'),
    new SampleItem('cate-tab', '分类导航 CateTab', '左右联动、tab 单显与分组插槽'),
    new SampleItem('coupon', '优惠券 Coupon', '券形缺口、主题渐变与自定义插槽'),
    new SampleItem('tabs-pro', '增强标签栏 TabsPro', '内容区联动、索引钳制与左右插槽')
  ]),
  new SampleGroup('Components T', [
    new SampleItem('transition', '过渡动画 Transition', '12 种模式、时长曲线与进出场事件'),
    new SampleItem('album', '相册 Album', '单图九宫格、+N 罩层与宽度回传'),
    new SampleItem('calendar-strip', '日期条 CalendarStrip', '横向日期条、上下拉展开与范围钳制'),
    new SampleItem('choose', '标签选择 Choose', '换行、横滑与 customClick 拦截'),
    new SampleItem('guide', '引导页 Guide', '翻页指示、跳过完成与一次性记忆')
  ]),
  new SampleGroup('Components U', [
    new SampleItem('lazy-load', '懒加载 LazyLoad', '可视区触发、淡入动画与占位错误态'),
    new SampleItem('canvas', '画布 Canvas', '基础图元、渐变、触摸涂鸦与导出'),
    new SampleItem('signature', '签名板 Signature', '手写轨迹、撤销清空与粗细颜色面板'),
    new SampleItem('color-picker', '颜色选择器 ColorPicker', '纯色渐变双页、色标轨道与方向盘'),
    new SampleItem('goods-sku', '商品规格 GoodsSku', '维度联动、库存置灰与购买数量')
  ]),
  new SampleGroup('Components V', [
    new SampleItem('qrcode', '二维码 Qrcode', '容错级别、定位角配色与白边'),
    new SampleItem('barcode', '条形码 Barcode', '多码制校验、文本位置与错误态'),
    new SampleItem('row-notice', '横向公告 RowNotice', '跑马灯滚动、速度换算与关闭'),
    new SampleItem('column-notice', '纵向公告 ColumnNotice', '轮播节奏、步进模式与主轴对齐'),
    new SampleItem('number-keyboard', '数字键盘 NumberKeyboard', '身份证模式、乱序按键与连续删除')
  ]),
  new SampleGroup('Components W', [
    new SampleItem('parse', '富文本 Parse', 'html 摊平成原生块、锚点滚动与媒体占位'),
    new SampleItem('markdown', 'Markdown 渲染', '内置词法转 html、明暗主题与代码行号'),
    new SampleItem('picker-column', '选择器列 PickerColumn', '空壳插槽容器、行高与主轴对齐'),
    new SampleItem('city-locate', '城市定位 CityLocate', '宿主定位注入、热门横排与索引分组'),
    new SampleItem('pdf-reader', 'PDF 阅读器 PdfReader', 'viewerUrl 计算、宿主视图与占位边界')
  ]),
  new SampleGroup('Components X', [
    new SampleItem('cropper', '图片裁剪 Cropper', '裁剪框拖拽、双指缩放旋转与预览调色'),
    new SampleItem('poster', '海报合成 Poster', 'json 配置绘制、渐变圆角与二维码嵌入'),
    new SampleItem('short-video', '短视频 ShortVideo', '纵向滑动、倍速面板与互动计数'),
    new SampleItem('novel-reader', '小说阅读 NovelReader', '滚动翻页双模式、五套主题与书签目录')
  ]),
  new SampleGroup('Components Y', [
    new SampleItem('utils', '工具集 Utils', '高精度运算、格式化、校验器与颜色渐变'),
    new SampleItem('i18n', '多语言 I18n', '十种语言包、占位符替换与注册覆盖'),
    new SampleItem('theme', '主题 Theme', '明暗令牌、跟随系统与令牌覆盖')
  ]),
  new SampleGroup('Templates', [
    new SampleItem('tpl-login', '登录页 Login', '手机号校验、验证码入口与第三方登录'),
    new SampleItem('tpl-pay', '红包支付 Pay', '数字键盘驱动六位密码输入与支付流程'),
    new SampleItem('tpl-submit-bar', '商品操作栏 SubmitBar', '客服/店铺/购物车徽标与双按钮'),
    new SampleItem('tpl-comment', '评论列表 Comment', '头像、点赞切换与嵌套回复'),
    new SampleItem('tpl-order', '订单列表 Order', '状态分类标签、按店铺分组与合计'),
    new SampleItem('tpl-coupon', '优惠券 Coupon', '组件券与店铺券混排'),
    new SampleItem('tpl-mine', '个人中心 Mine', '头像资料头与分组功能入口'),
    new SampleItem('tpl-mall', '商城分类 Mall', '左侧分类栏与右侧商品联动'),
    new SampleItem('tpl-address', '地址管理 Address', '地址列表与新增表单')
  ])
];
