# 阶段 17 兼容说明

阶段 17 增加 `UPLazyLoad`、`UPCanvas`、`UPSignature`、`UPColorPicker` 与 `UPGoodsSku`，补齐图片懒加载、画布绘制、手写签名、取色面板与商品规格五类能力。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPLazyLoad` 复刻上游懒加载图片：`onVisibleAreaChange([0.0, 0.01])` 取代上游 `IntersectionObserver`/`lazy-load` 组件，元素进入可视区即触发一次 `reveal()` 且不再回退。`loadStatus` 保持上游 `'' → lazyed → loaded` 状态机，`upLazyLoadNextStatus()` 只做单向推进，`onComplete` 推进到 `loaded` 时回传一次 `onLoad`，`onError` 回传 `onError`，容器点击回传 `onClick`，三个事件都带上游的 `index` 透传字段。`isEffect` 打开时按上游 `isShow` watch 的做法先把不透明度归零、延迟 `UP_LAZY_LOAD_EFFECT_DELAY = 30` 毫秒后再回到 1 形成淡入，时长取 `duration`，曲线经 `upLazyLoadEffectSupported()`/`upLazyLoadEffectCurve()` 从 `linear`、`ease`、`ease-in`、`ease-out`、`ease-in-out` 映射到 `Curve`，白名单外回落 `Curve.EaseInOut` 并记录一条诊断。`imgMode` 经 `upLazyLoadFit()` 把上游 `widthFix`/`heightFix`/`aspectFit` 映射为 `ImageFit.Contain`、`scaleToFill` 映射为 `ImageFit.Fill`、其余回落 `ImageFit.Cover`；`height` 支持字符串数字，`borderRadius` 配 `.clip(true)` 裁剪，`loadingImg` 落到 `Image.alt`，`errorImg` 在错误态整幅替换，缺图时渲染「加载失败」文案占位。
- `UPCanvas` 复刻上游画布：`UPCanvasSurface` 是命令式绘制门面，`onReady(surface)` 回传后即可调用 `beginPath/moveTo/lineTo/arc/arcTo/ellipse/bezierCurveTo/quadraticCurveTo/rect/fillRect/strokeRect/clearRect/fill/stroke/clip`、变换族 `save/restore/translate/rotate/scale/transform/setTransform/resetTransform`、样式族 `setFillStyle/setStrokeStyle/setFillGradient/setStrokeGradient/setLineWidth/setLineCap/setLineJoin/setMiterLimit/setLineDash/getLineDash/setGlobalAlpha/setGlobalCompositeOperation/setShadow/setLineStyle`、文本族 `setFont/setFontSize/setTextAlign/setTextBaseline/setDirection/fillText/strokeText/measureText` 与位图族 `drawImage/drawImageRegion/getImageData/putImageData`，字符串枚举全部经 `upCanvasLineCap()`/`upCanvasLineJoin()`/`upCanvasTextAlign()`/`upCanvasTextBaseline()`/`upCanvasDirection()`/`upCanvasFillRule()` 白名单映射。`width`/`height` 经 `upCanvasParseSize()` 按 `unit` 换算，`useRootHeightAndWidth` 打开时铺满父容器，`bgColor` 落到容器底色，`upCanvasId()` 复刻上游随机 canvasId 生成，`onTouchStart`/`onTouchMove`/`onTouchEnd` 回传画布内的相对坐标。`measureText()` 优先用 ArkUI `measureText`，宽度为 0 时回落 `upCanvasEstimateTextWidth()`（全角按一个字号、空白按 0.28、其余按 0.56 估算），避免中文量算偏短。
- `UPSignature` 复刻手写签名板：`PanGesture({ fingers: 1, direction: PanDirection.All, distance: 0 })` 取代上游 canvas `touchstart/touchmove/touchend`，落笔点经 `pointOf()` 归一化为 `UPSignaturePoint`（`UP_SIGNATURE_POINT_START`/`UP_SIGNATURE_POINT_MOVE`），笔画数组保留全部轨迹以支持 `undo()` 出栈后 `redraw()` 重绘。工具栏五个按钮 `undo`/`clear`/`confirm`/`brush`/`color` 与上游一一对应，可用态取 `UP_SIGNATURE_ICON_COLOR`、禁用态取 `UP_SIGNATURE_ICON_DISABLED_COLOR`；`brush` 展开「笔画粗细:」滑块、`color` 展开「笔画颜色:」色板（`UP_SIGNATURE_PRESET_COLORS`）。`thickness` 经 `upSignatureLineWidth()` 钳制到上游滑块区间 1–20，`color` 经 `upSignatureStrokeColor()` 归一化，`bgColor` 同时作为画布底色与 `clear()` 的回填色，`showToolbar` 关闭后只剩画布。
- `UPColorPicker` 复刻取色面板：`UPSubsection` 承载上游「纯色」/「渐变」双页，饱和度面板、色相条、透明度条与色标轨道全部改用 `PanGesture(distance: 0)` 并配 `onAreaChange` 量取实际尺寸，`upColorPickerHslToRgb()` 复刻上游 HSL→RGBA 转换。渐变页色标数量受 `UP_COLOR_PICKER_GRADIENT_MIN = 2` 与 `UP_COLOR_PICKER_GRADIENT_MAX = 5` 限制，`upColorPickerAddStop()`/`upColorPickerRemoveStop()` 负责增删并保持位置有序，轨道宽度取 `UP_COLOR_PICKER_TRACK_WIDTH = 280`；方向盘覆盖 `UP_COLOR_PICKER_DIRECTIONS` 的八个方向，`upColorPickerDirectionAngle()`/`upColorPickerDirectionFromAngle()` 在 CSS 方向串与角度间互转，`upColorPickerGradientCss()` 输出上游同形的 `linear-gradient(...)` 字符串，`upColorPickerArkAngle()` 再把它换算成 ArkUI `linearGradient` 的角度。「常用颜色」取 `commonColors`，纯色页与渐变页各自保存/恢复状态，`onModelValueChange` 随取色实时回传，「确定」再补一次 `onConfirm`，「取消」与关闭回传 `onClose` 与 `onClosed`。
- `UPGoodsSku` 复刻商品规格面板：`skuTree` 为具名维度树（`name` + `children`），`skuList` 为组合数组，`upGoodsSkuMatch()` 按已选维度匹配组合，`upGoodsSkuPrice()`/`upGoodsSkuStock()` 优先取组合字段、缺失时回落 `goodsInfo`。同一维度点击已选项取消选择，`selectionsWith()` 负责替换与清理，`isDisabled()` 用一次 `upGoodsSkuMatch()` 判定该取值是否还有库存可达，`upValueKey()` 归一化 id 比较使 `1` 与 `'1'` 等价。头部渲染 `UP_GOODS_SKU_IMAGE_SIZE = 90` 的商品图、价格行、`库存 N 件` 与 `已选: …`，价格行改用 `VerticalAlign.Bottom` 对齐（上游 `baseline`），维度区在 `UP_GOODS_SKU_CONTENT_MAX_HEIGHT = 300` 内滚动，「购买数量」行复用 `UPNumberBox` 并以 `maxBuy` 与实时库存取小值为上限，底部按钮文案取 `confirmText`（默认「确定」），库存不足或未选满时置灰并按 `UP_GOODS_SKU_ERROR_COLOR` 提示。`pageInline` 打开时内联渲染，关闭时由受控 `show` 驱动弹层，`onOpen`/`onConfirm`（回传 `sku`、`goodsInfo`、`num` 与 `selectedText`）/`onClose`/`onClosed` 与上游事件对齐。

## 边界

ArkTS 禁止索引签名与 `any`，因此上游 `sku[key]` 的扁平写法改为具名模型：`UPGoodsSkuCombination { id, values: Array<UPGoodsSkuSelection>, price, price_fee, stock, quantity }`，维度取值经 `upGoodsSkuValueOf()` 读取，保留字段由 `UP_GOODS_SKU_RESERVED_KEYS`（`price`、`price_fee`、`stock`、`quantity`）与 `upGoodsSkuKeySupported()` 声明；维度名与保留字段冲突时记录一条诊断。`UPCanvas` 的 `getImageData`/`putImageData` 同样用具名 `UPCanvasImageDataOptions`/`UPCanvasPutImageDataOptions` 代替上游的对象字面量参数。

以下上游能力保留为 no-op 兼容位或改由宿主承担，除改名项外都会在传入时通过 `UPCompatibilityDiagnostics.report()` 记录一条诊断：

- `UPLazyLoad` 的 `threshold`：`onVisibleAreaChange` 没有视口偏移量，预加载距离只由 `upLazyLoadThreshold()` 换算并记录诊断，不参与实际触发时机（取值为 0 时不记录）。非本地地址（不以 `resource://`、`file://`、`/`、`$rawfile:` 开头）渲染「图片占位」而不发起网络请求，也因此不会回传 `onError`；空地址直接进入错误态，同样不回传 `onError`。
- `UPCanvas` 的 `canvasId`：ArkUI 通过渲染上下文寻址画布，`canvasId` 只作信息透传；`disableScroll` 在 ArkUI 上是 no-op（画布自身不滚动）；`unit` 只支持 `px`/`rpx`/`upx`，其余取值回落 `px`；`draw()` 因 ArkUI 即时绘制只保留回调时序契约，`isLastDraw` 不再触发重绘；`exportImage()` 返回 base64 data URL 而不是上游的临时文件路径；`drawImage()` 只绘制本地地址，远端地址被跳过并记录诊断。
- `UPSignature` 的导出：`confirm` 回传 base64 data URL 而不是临时文件路径，空签名按上游语义跳过导出并记录诊断；取不到画布实例或导出失败时回传 `onError`（「无法获取画布实例」/「导出签名图片失败」）。`thickness` 越界被静默钳制到 1–20 并记录诊断。
- `UPColorPicker` 的 `trigger` 插槽：ArkUI 无插槽，触发器改由宿主自行渲染并通过受控 `show` 控制面板；饱和度按宽高两轴分别归一（上游用 `Math.min(width, height)` 归一，拖到边角时饱和度可超过 100%）；透明度条的棋盘格用浅底叠白色渐变近似；方向盘的 `conic-gradient` 用 `sweepGradient` 近似，0° 起点与浏览器实现略有差异。
- `UPGoodsSku` 的 `trigger`/`header` 插槽同样改由受控 `show` 与内置头部承担；上游把 `:border-radius="20"` 传给只有 `round` 属性的 `up-popup`，该属性在上游即为 no-op，本端默认圆角 0，需要圆角请用 `customStyle.borderRadius` 覆盖；上游 `close()` 内的 `this.false = true` 是无效赋值，本端不复刻；命令式 `reset()` 不对外暴露，重置请改动 `show` 或重建组件；维度区用 `Scroll` 代替上游 `scroll-view`；商品图只渲染本地地址，远端地址渲染「图片占位」。

五个组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。远端图片下载、签名与画布导出结果的落盘、取色结果的持久化以及库存与价格的业务校验仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 17 静态契约覆盖五个组件的默认值与常量、核心 Props/事件、画布字符串枚举白名单、懒加载状态机与图片模式映射、色标增删与方向换算、规格匹配与保留字段、公共导出、Components U 目录和五条 Demo 路由。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称懒加载淡入观感与可视区触发时机、画布触摸涂鸦跟手度与导出图质量、签名笔迹平滑度、取色面板拖拽精度和商品规格弹层滚动表现的设备验证完成；这些表现需在真机复核。
