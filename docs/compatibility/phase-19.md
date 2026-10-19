# 阶段 19 兼容说明

阶段 19 增加 `UPParse`、`UPMarkdown`、`UPPickerColumn`、`UPCityLocate` 与 `UPPdfReader`，补齐富文本解析、Markdown 渲染、选择器列容器、城市定位与 PDF 阅读五类能力。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPParse` 复刻上游 `u-parse`（内核为 mp-html v2.5.1）：`internal/UPHtmlParser.ets` 是词法与节点树的 ArkTS 移植，`UPHtmlLexer` 保留上游 `text`/`tagName`/`attrName`/`attrVal`/`endTag` 五态状态机与 `checkClose()` 自闭合处理，`UPHtmlParser` 保留 `onOpenTag`/`onCloseTag`/`onText`/`popNode`/`parseStyle`/`applyStyle`/`expose`/`decorateTable`/`decorateCells`/`pushCellStyles`/`convertRuby`/`prepareImage` 全套回调，受信标签表、`BLOCK_TAGS`/`INLINE_TAGS`/`IGNORE_TAGS`/`VOID_TAGS`、21 条实体表、12 条默认标签样式与 `UP_HTML_MERGE_THRESHOLD = 50` 的节点合并阈值都保持上游取值，`upHtmlDecodeEntity()`/`upHtmlResolveUrl()`/`upHtmlSplitDeclarations()`/`upHtmlConvertRpx()`/`upHtmlAttributeSize()`/`upHtmlMergeNodes()`/`upHtmlNodesText()` 与上游同名函数一一对应。`internal/UPHtmlLayout.ets` 把节点树摊平成 `text`/`image`/`divider`/`media`/`table` 五种渲染块，`upHtmlLength()`/`upHtmlResolveFontSize()`/`upHtmlEdges()`/`upHtmlBorderParts()`/`upHtmlListMarker()`（`decimal`、`lower/upper-alpha`、`lower/upper-roman`、`disc`/`circle`/`square` 与按层级兜底）承担 CSS 子集解析，`UP_HTML_HEADING_SCALES`/`UP_HTML_HEADING_MARGINS` 保持浏览器默认标题比例，`UP_HTML_LIST_INDENT = 40`、`UP_HTML_LINK_COLOR = '#366092'`、`UP_HTML_BASE_FONT_SIZE = 16` 与上游一致。组件侧 `content`/`domain`/`tagStyle`/`baseColor`/`linkColor`/`baseFontSize`/`viewportWidth`/`containerStyle`/`selectable`/`scrollTable`/`useAnchor`/`copyLink` 均生效，`useAnchor` 同时接受布尔与数字偏移，表格用 `Flex` + `layoutWeight(colspan)` 排布并可横向滚动，`onLoad`/`onReady`/`onImgTap`/`onLinkTap`/`onPlay`/`onError` 对齐上游六个事件。
- `UPParseController` 把上游模板 `ref` 上的实例方法搬成显式控制器：`setContent(content, append)`、`pauseMedia()`、`setPlaybackRate(rate)`、`getText()`、`imageList()`、`documentTitle()` 与改名后的 `scrollToAnchor(id, offset)`（上游 `navigateTo`）。追加渲染会累加图片索引，未挂载解析器时命令被丢弃并记录诊断。
- `UPMarkdown` 复刻上游 `u-markdown`：`internal/UPMarkdownSource.ets` 内置 markdown 词法，覆盖 ATX 标题、Setext 下划线标题、段落与硬换行（行尾两空格或反斜杠）、`-`/`*`/`+` 与有序列表（含 `start` 与缩进嵌套）、引用块、围栏代码块（``` 与 ~~~ 及语言标记）、分隔线、GFM 表格（含 `:---`/`---:`/`:---:` 对齐）、粗体、斜体、删除线、行内代码、链接与图片，转换结果交给 `UPParse` 渲染。上游 scss 的默认样式经 `upMarkdownTagStyle()` 注入为 `tagStyle`：`UP_MARKDOWN_HEADING_SIZES = [32, 24, 18, 16, 13, 10]`、`UP_MARKDOWN_HEADING_MARGINS = [8, 8, 7, 7, 6, 5]`、段落与列表 `margin:16px 0`、列表 `padding-left:32px`、列表项 `margin:8px 0`、引用 `margin:8px 0` + `padding:0 10px` + 左侧 4px 竖线、代码块 14px + `#f6f8fa` 底 + `padding:16px` + `border-radius:6px`、表格单元格 `padding:6px 13px` + `1px solid #dfe2e5`、`th` `font-weight:600`、图片 `margin:16px 0`、分隔线 1px `#e1e4e8` 都按上游取值写入；根节点 `padding:16px`、`font-size:16px`、`line-height:1.6` 同样保留。`theme` 支持上游 `light`/`dark` 两套色（深色下正文 `#ccc`、底色 `#1e1e1e`、代码 `#2d2d2d`/`#dcdcdc`、链接 `#4da6ff`、引用 `#bbb`），`showLineNumber` 打开时按 `upMarkdownGutter()` 右对齐行号，六个事件与 `previewImg`/`copyLink`/`domain` 原样透传给 `UPParse`。
- `UPPickerColumn` 复刻上游 `u-picker-column`：上游模板只是 `picker-view-column` 包一个空 `view`，`props.js` 里没有任何字段与事件，因此本端同样是薄壳插槽容器，只提供 `itemHeight`（缺省 `UP_PICKER_COLUMN_ITEM_HEIGHT = 44`）、`align`（`upPickerColumnAlign()` 映射到 `FlexAlign.Start`/`Center`/`End`）与 `customStyle`，内容由 `contentBuilder` 提供。多列联动仍由 `UPPicker` 与 `UPPickerController` 承担。
- `UPCityLocate` 复刻上游 `u-city-locate`：索引列表直接复用 `UPIndexList`/`UPIndexItem`/`UPIndexAnchor`，分割线复用 `UPLine`。第一组按上游渲染成热门城市横排标签（`padding:6px 12px`、`margin:5px`、`1px solid #ededed`、底色 `#ffffff`），其余分组是 `padding:8px 1px` 的列表行加 `UPLine`。定位行沿用上游 30vp 高度与 `#909399` 标题、`#303133` 城市名，`locationCity` 初值为「定位中....」，失败文案为「定位失败，请点击重试。」，与上游 i18n 的 `up.cityLocate.locateCity`/`locating`/`fail` 三条一致。`indexList`、`cityList`、`currentCity`、`nameKey`、`locationType` 均生效，`upCityLocateHotCities()` 保留上游默认的北京、上海、广州、深圳、杭州五个热门城市与 `name`/`value` 字段，`onSelectCity` 对齐上游 `select-city`，`onLocationSuccess` 对齐 `location-success`。
- `UPPdfReader` 按边界组件复刻上游 `u-pdf-reader`：`upPdfReaderViewerUrl()` 复刻上游 `${baseUrl}/static/pdfjs/web/viewer.html?file=` 拼接，`upPdfReaderEncode()` 是 `encodeURIComponent` 的等价实现（保留 `-_.~!*'()`，其余按 UTF-8 展开成 `%XX`，含代理对处理），`UP_PDF_READER_BASE_URL` 保持上游默认的 pdf.js 资源域名，`height` 缺省 `500px`。计算结果通过 `onViewerUrl` 回传，渲染区交给 `viewerBuilder`，未接入时渲染 `file-text` 图标加中文占位文案。

## 边界

ArkTS 禁止索引签名与 `any`，因此上游直接读写动态键的写法改为具名模型：`UPHtmlAttrs` 用具名字段承载 `id`/`src`/`href`/`style`/`class`/`colspan`/`rowspan` 等属性并保留 `extras` 兜底，`UPHtmlDeclaration { key, value }` 承载一条 CSS 声明（`tagStyle` 也用它传入），`UPHtmlTextRun`/`UPHtmlTextStyle`/`UPHtmlBlockStyle`/`UPHtmlBlock`/`UPHtmlTableCell`/`UPHtmlTableRow` 承载渲染块，`UPParseImageTapEvent`/`UPParseLinkTapEvent`/`UPParseReadyEvent`/`UPParseMediaEvent`/`UPParseErrorEvent` 承载五个事件载荷，`UPCityLocateItem { name, value, city, label }` 替代上游 `item[nameKey]`，`upCityLocateName()` 按白名单读取，`UPCityLocateRequest`/`UPCityLocateResult`/`UPCityLocateSuccessEvent`/`UPCityLocateSelectEvent`/`UPCityLocateFailureEvent` 承载定位交互。

`RichText` 与 `Web` 都依赖 web 内核，本阶段一律不使用；富文本改为解析后用 `Text` + `Span`、`Image`、`Divider` 与 `Flex` 表格逐块渲染。

以下上游能力保留为 no-op 兼容位或改由宿主承担，除改名项外都会在传入时通过 `UPCompatibilityDiagnostics.report()` 记录一条诊断：

- `UPParse` 的 `lazyLoad`：ArkUI 不暴露图片解码时机，图片一律立即渲染；`loadingImg` 与 `errorImg` 由 `UPImage` 的确定性占位替代；`previewImg` 不打开系统预览，点击只回传 `onImgTap`，预览界面由宿主呈现；`showImgMenu` 的长按菜单不提供；`pauseVideo` 因为媒体渲染为占位块而成为 no-op；`setTitle` 不写导航栏标题，`<title>` 文本改由 `UPParseController.documentTitle()` 取回。
- `UPParse` 的外链：`copyLink` 为真且宿主提供 `openLink(href)` 时才会打开，回调返回 `false` 会触发 `onError`（`openLink rejected the external link`）；站内链接与业务路由一律交给宿主，组件不调用任何路由 API，控制器方法因此从 `navigateTo` 改名为 `scrollToAnchor`。锚点滚动需要 `containerStyle` 给出高度，否则记录诊断并跳过。
- `UPParse` 相对上游解析器的有意简化共八条：① SVG 子树不复刻，遇到 `svg` 记录丢弃；② 表格的 `display:grid` 合并单元格布局不复刻，`colspan` 用 `layoutWeight` 近似、`rowspan` 只透传；③ 上游 plugins 与 hook 机制不复刻；④ `scrollTable` 不用 `div{overflow:auto}` 包裹，改为横向 `Scroll`；⑤ 重复图片地址的随机大小写变换不复刻；⑥ `previewImg` 的 `'all'` 取值简化为布尔；⑦ `node.f` 承载的 flex 外提样式不复刻；⑧ `<title>` 不写导航栏，只随解析结果回传。布局侧的 CSS 子集不支持 `box-sizing`、`overflow`、`border-collapse`、`border-spacing`、`max-width`、`float`、`direction`、`user-select`、`word-wrap` 与 flex 系列属性。
- `UPMarkdown` 的解析内核：上游随组件打包的 `marked.esm.mjs` 不移植，改用内置 ArkTS 词法，覆盖上文列出的语法子集；HTML 内联块、脚注、任务列表、定义列表、引用式链接与自动链接不在覆盖范围内。上游 `applyTheme()` 原样返回 html，本端同样是 no-op，`theme` 只切换注入 `UPParse` 的标签样式与链接色；取值不在 `light`/`dark` 内时回落浅色并记录诊断。
- `UPMarkdown` 的 `customStyle.height`：该高度下推给内嵌 `UPParse` 作为滚动视口高度，根节点的实际高度还会叠加上游 16px 的内边距；不传高度时内容整体铺开，由外层滚动容器负责滚动。
- `UPMarkdown` 的 `showLineNumber`：上游用一列 `flex` 容器加右侧竖线渲染行号，ArkUI 的文本块内无法并排两列，改为在每行前拼接右对齐行号；代码块的语法高亮上游也未实现，本端同样只做等宽渲染。表格的 `tr:nth-child(2n)` 斑马纹与 `border-collapse` 无等价能力，单元格改为逐格描边。
- `UPPickerColumn`：上游没有 props、事件与样式，滚动联动由父级 `picker-view` 负责，因此本端只承载插槽与尺寸，不提供选中态与滚动事件；`align` 越界时回落居中并记录诊断。
- `UPCityLocate` 的定位：`uni.getLocation` 不可用，系统定位改由宿主注入 `locate(request)` 同步回调，返回 `undefined` 或城市为空时显示失败文案并回传 `onLocationFail`；未注入回调时同样按失败分支呈现。`locationType` 只作信息透传交给宿主。定位入口固定在索引列表上方，因为 `UPIndexList` 的 header 插槽保留给锚点；上游 footer 插槽只放安全区占位，本端省略。`nameKey` 越界时按具名字段兜底并记录诊断。
- `UPPdfReader`：pdf.js 运行在浏览器内核内，组件不内嵌 `Web`，也不请求 `baseUrl` 指向的远端资源，只计算 `viewerUrl` 并通过 `onViewerUrl` 回传，渲染区由 `viewerBuilder` 提供，未接入时显示占位；上游 `webview-styles` 固定的 750rpx 宽度改为跟随容器宽度。上游 `watch baseUrl` 只把值赋回自身（`this.baseUrl = val`），实际生效的始终是 `mounted` 时读到的初值，这个上游缺陷不复刻，本端 `baseUrl` 变化会重算 `viewerUrl`。

五个组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。富文本与 Markdown 的图片预览、外链打开、媒体播放，城市定位的权限申请与坐标解析，以及 PDF 的解码与分页浏览仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 19 静态契约覆盖五个组件与解析内核的默认值和常量、核心 Props/事件、受信标签与实体表、块级摊平的五种渲染块、markdown 词法函数与注入样式、城市字段白名单、`viewerUrl` 拼接与百分号编码、公共导出、`Components W` 目录和五条 Demo 路由。
- `upPdfReaderEncode()` 与 `encodeURIComponent` 在 ASCII、中文、重音字符、代理对与保留字符五组样例上逐字符比对一致。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。当前未宣称富文本长文排版与锚点滚动、Markdown 明暗主题观感、城市索引侧边栏跟手度与 PDF 宿主视图接入的设备验证完成；这些表现需在真机复核。
