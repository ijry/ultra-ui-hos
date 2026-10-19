# 阶段 14 兼容说明

阶段 14 增加 `UPVirtualList`、`UPPullRefresh`、`UPRefreshVirtualList`、`UPWaterfall` 与 `UPDragSort`，并配套 `UPRefreshVirtualListController`，补齐长列表虚拟化、下拉刷新与拖拽排序能力。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPVirtualList` 复刻上游固定行高虚拟列表：`itemHeight` 决定行高，容器高度由 `.onAreaChange()` 实测后换算可视条数 `remain`，`buffer` 再向前后各补半个缓冲区，窗口外用上下占位 `Row` 撑出总高度，因此滚动条长度与真实数据量一致。`keyField` 指定稳定标识并参与 `ForEach` 键生成，`scrollTop` 由 `@Watch('applyScrollTop')` 触发 `Scroller.scrollTo()`，滚动时通过 `onScrollTopChange`（对应上游 `update:scrollTop`）与 `onScroll` 双通道回传 `scrollTop` 及当前窗口区间。行内容由 `itemBuilder` 插槽渲染，缺省渲染 `label`/`value`。
- `UPPullRefresh` 复刻三态下拉刷新：`pull`/`release`/`refreshing` 对应文案「下拉刷新」「释放刷新」「正在刷新...」，`threshold` 为触发阈值，`damping` 为阻尼系数，`maxDistance` 为最大下拉距离；`pullBuilder`、`releaseBuilder`、`refreshingBuilder` 分别覆盖三态提示，`contentBuilder` 承载列表内容。`refreshing` 受 `@Watch('syncRefreshing')` 监听，宿主置回 `false` 即完成上游 `finishRefresh()` 的回弹。`showLoadmore` 配合 `loadmoreProps` 复用 `UPLoadmore`，`lowerThreshold` 触底时经 `onScrollEdge` 派发 `onLoadmore`，`onStatusChange` 暴露状态机变化。
- `UPRefreshVirtualListController` 把上游通过模板 `ref` 调用的实例方法 `finishRefresh()`、`scrollTo(top)`、`scrollToTop()` 转成显式控制器：ArkTS 无法跨 struct 取实例句柄，宿主改为 `new UPRefreshVirtualListController()` 后传入 `controller`，组件在 `aboutToAppear` 内 `mount()` 监听、`aboutToDisappear` 内 `unmount()`。未挂载时下发命令会被丢弃并记录一条诊断。
- `UPRefreshVirtualList` 是 `UPPullRefresh` 与 `UPVirtualList` 的组合容器，共享 `listData`、`itemHeight`、`height`、`buffer`、`keyField` 一组 Props，内部维护 `refreshing`/`scrollTop`，并以 `onRefresh`、`onScroll`、`onRefreshingChange` 对外派发。
- `UPWaterfall` 复刻上游逐条入列的瀑布流：`addTime` 为入列间隔，`setTimeout` 串行执行 `step(generation)`，每步用 `.onAreaChange()` 实测各列高度后把新数据放进最短列，`onAfterAddOne`（对应 `after-add-one`）与 `onAfterAddAll`（`after-add-all`）分别回传单条落位与整批列高。`columns` 支持固定列数与 `'auto'`：`'auto'` 按容器实测宽度与 `minColumnWidth` 加 7px 间距换算列数，并不低于 `columnsMin`。`idKey` 指定去重与移除所依据的字段，`onUpdateModelValue` 对应上游 `update:modelValue`；`useColumnSlot` 打开后由 `columnBuilder` 接管整列渲染，否则逐条走 `itemBuilder`。
- `UPDragSort` 复刻拖拽排序：`direction` 支持 `vertical`/`horizontal`/`all`（`all` 按 `columns` 排成网格），`Stack` + `.position()` 定位替代上游 `movable-area`/`movable-view`，`PanGesture` 配合 `PanDirection` 收集位移，拖动中实时算出目标序号并重排，松手后回落网格并派发 `onDragEnd`（对应 `drag-end`）携带排序后的完整列表。`draggable` 支持组件级与条目级 `item.draggable` 双开关，`useHandler` 打开后仅 `handlerBuilder` 区域可发起拖拽。

## 边界

ArkTS 禁止索引签名与 `any`，因此四个数据组件的模型都是具名 `interface`：`UPVirtualListItem { id, key, label, value, description, disabled }`、`UPWaterfallItem { id, title, label, price, shop, image, description, value, height }`、`UPDragSortItem { id, label, value, description, disabled, draggable }`。`keyField` 与 `idKey` 只能指向这些具名字段，传入模型之外的字段名时取值为空并回落到序号键；上游"任意对象 + 任意字段名"的用法需要宿主先把数据映射成上述模型。

以下上游能力保留为 no-op 兼容位或改由宿主承担，全部通过 `UPCompatibilityDiagnostics.report()` 在传入时记录一条诊断：

- `UPDragSort` 的 `vibrate`：`uni.vibrateShort` 在无依赖的 ArkUI 组件层没有对应实现，触感反馈一律 no-op，默认值仍保留 `true` 以便上游代码原样迁移。
- `UPPullRefresh` 的 `enableBackToTop`：`Scroll` 的 `backToTop` 属性需要 API 15 以上，为守住 API 24 基线不接线，仅保留手动滚动。同理未使用 `Refresh` 组件的 `maxPullDownDistance`（API 20）与 `pullUpToCancelRefresh`（API 23），下拉刷新完全由本组件的触摸状态机与阻尼计算实现，不委托 SDK `Refresh`。
- `UPVirtualList` 只支持固定行高，不做动态行高测量与 `LazyForEach` 数据源；超长列表（十万级）的内存与回收表现仍需宿主评估。
- `UPWaterfall` 不含图片懒加载与网络图加载，`image` 字段只作为模型占位，示例使用纯文本卡片；上游实例方法 `clear()` 与 `remove(id)` 未暴露，请直接改写 `modelValue` 由组件重排。
- `UPDragSort` 不支持跨容器拖拽、自动滚动边缘吸附与长按延时阈值配置。

五个组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。排序、入列与窗口计算都在组件内对当前数据副本执行，分页与数据获取仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 14 静态契约覆盖五个组件与 `UPRefreshVirtualListController` 的默认值、核心 Props/事件、插槽与控制器命令、公共导出、Components R 目录和五条 Demo 路由。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称虚拟列表快速滚动的白屏表现、下拉刷新的手势跟手度、瀑布流列高测量的收敛速度与拖拽排序的回落动画的设备验证完成；这些表现需在真机复核。
