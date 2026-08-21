# 阶段 6 列表与索引兼容说明

阶段 6 面向 HarmonyOS NEXT API 24、产品兼容和目标 SDK `5.0.0(12)`，新增 `UPList`、`UPListItem`、`UPIndexList`、`UPIndexItem`、`UPIndexAnchor` 和 `UPScrollList`。全部组件通过 `@lingyun/ultra-ui-hos` 公共 HAR 入口使用，不依赖 WebView、Vue/NVue、网络或远程资源。

## 原生实现

- `UPList` 使用 ArkUI 原生 `List`/`Scroller`，支持滚动、上下边界、阈值去重、受控 `scrollTop` 与锚点定位。
- `UPListItem` 在父列表内使用原生 `ListItem`，脱离父列表时以普通 `Column` 安全呈现。
- `UPIndexList` 使用原生 `List`、`ListItemGroup` 和父级 `StickyStyle.Header`，侧边索引选择按 `onSelect`、条件 `onChange`、`onCurrentChange`、滚动的顺序执行。
- `UPIndexAnchor` 是可独立使用的本地标题条；`UPScrollList` 使用原生横向 `Scroll` 和 `Scroller`。

## 原生近似与 no-op

- `UPList` 的 `pagingEnabled`、`enableBackToTop`、`preLoadScreen` 是 no-op 兼容字段；刷新视觉由 ArkUI 能力近似，组件只发出刷新请求，不改写页面状态。
- `UPIndexList` 支持点击侧边索引，不实现连续拖拽气泡、触觉反馈或自动可见分组追踪；`safeBottomFix` 使用固定安全间距近似。
- `UPScrollList` 依据可获得的内容尺寸和偏移计算比例指示器；尺寸不可获得时回退为零，不伪造滚动进度。
- 所有降级路径均可通过可选兼容诊断接收器观察；未注入时静默，不抛异常。

## 边界

示例仅使用固定本地文本与色块，保持无网络运行，不提供虚拟列表、瀑布流、表格或运行时 JSON 组件映射。页面持有 `current` 和刷新状态，组件只持有滚动偏移等瞬时原生状态。

## 设备验证

当前环境未连接 HarmonyOS NEXT 设备，设备验证与截图状态为 `skipped`。静态契约和 Hvigor 构建不能替代真实设备上的触摸滚动、吸顶、边界事件和指示器视觉验证。
