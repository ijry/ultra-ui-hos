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
  ])
];
