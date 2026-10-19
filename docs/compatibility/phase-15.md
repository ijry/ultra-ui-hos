# 阶段 15 兼容说明

阶段 15 增加 `UPCarKeyboard`、`UPMessageInput`、`UPCateTab`、`UPCoupon` 与 `UPTabsPro`，补齐车牌键盘、验证码输入、分类导航、优惠券展示与增强标签栏五类能力。五个组件均面向 HarmonyOS NEXT API 24 使用原生 ArkUI 实现，并从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

- `UPCarKeyboard` 复刻上游车牌键盘：内置 36 个省份中文简称与 36 个数字字母键，`upCarKeyboardRows()` 按上游 `slice(0,10)`/`(10,20)`/`(20,30)`/`(30,36)` 切成四行，第四行左右两端分别是「中/英」切换键与退格键。`random` 打开时用 `upCarKeyboardShuffle()` 洗牌一份副本，只在 `random` 变化时重排一次而不是每帧重排；`autoChange` 打开后按下省份键 200ms 自动切到英文键盘，对应上游 `carInputClick()` 里的 `sleep(200)`。按键经 `onChange` 回传 `{ value }`，退格键经 `onTouch` 实现「按下立即触发一次、随后每 250ms 连发」的 `onBackspace`，`aboutToDisappear` 内 `clearTimeout` 与 `clearInterval` 一并释放。上游 `mode="car"` 的键盘面板容器由宿主自行套 `UPPopup`，组件本身只渲染键盘面。
- `UPMessageInput` 复刻验证码输入：`maxlength` 决定格子数，`mode` 支持 `box` 边框、`bottomLine` 底部横线与 `middleLine` 中部横线三种，`dotFill` 打开后已输入位显示 `●`，`bold` 把线宽由 2 提到 4 并加粗字重，`width` 同时决定格子宽高。真实输入由一个 `TextInput({ type: InputType.Number })` 承担，它铺满整行、`.opacity(0.01)` 保持可点可聚焦但不可见，`disabledKeyboard` 通过 `.enabled(false)` 关闭系统键盘以便宿主接自定义键盘。事件顺序与上游一致：每次输入回传 `onChange`，满位再回传一次 `onFinish`，`finishedValue` 去重避免同一值重复 finish。
- `UPCateTab` 复刻分类导航：左侧菜单 + 右侧分组内容双 `Scroll` 结构，`mode` 为 `follow` 时右侧滚动联动左侧高亮，为 `tab` 时右侧只渲染当前分组。`tabList` 为具名 `UPCateTabItem` 数组，`children` 为 `UPCateTabChildItem` 数组，`current` 经 `@Watch('applyCurrent')` 双向同步并回传 `onCurrentChange`（对应上游 `update:current`）。四个插槽 `tabItemBuilder`、`rightTopBuilder`、`itemListBuilder`、`pageItemBuilder` 对应上游 `tabItem`、`rightTop`、`itemList`、`pageItem`。
- `UPCoupon` 复刻优惠券：`shape` 支持 `coupon` 半圆缺口、`envelope` 顶部斜纹红包与 `card` 纯卡片，`size` 支持 `small`/`medium`/`large` 三档高度（80/90/110vp），`unitPosition` 决定货币符号在金额左右，`amount`/`limit`/`title`/`desc`/`time`/`actionText` 与上游同名。`type` 命中 `primary`/`success`/`warning`/`error` 时由 `upCouponGradient()` 取出渐变端点并把文字与金额转白色，`bgColor`/`color` 优先级高于内置主题。`amountBuilder`、`infoBuilder`、`actionBuilder`、`contentBuilder` 覆盖上游金额区、信息区、操作区与默认插槽，操作区默认复用 `UPTag`。
- `UPTabsPro` 在 `UPTabs` 之上复刻增强标签栏：透传 `list`、`lineColor`、`lineWidth`、`lineHeight`、`activeStyle`、`inactiveStyle`、`itemStyle`、`iconStyle`、`scrollable`、`duration`、`shapeMode`，并新增 `showContent` 内容区。`current` 经 `upTabsProNormalizeCurrent()` 钳制到 `[0, list.length - 1]`，`onClick`、`onLongPress`、`onChange`、`onCurrentChange`（对应 `update:current`）四个事件与上游同序。`leftBuilder`、`rightBuilder`、`iconBuilder`、`tabBuilder` 经 `leftRegion`/`rightRegion`/`iconRegion`/`tabRegion` 包装后转发给 `UPTabs`，`contentBuilder` 拿到 `UPTabsProContentSlot`（`current`、`index`、`item`、`value`、`list`）渲染内容区。

## 边界

ArkTS 禁止索引签名与 `any`，因此分类导航与标签栏的数据模型都是具名 `interface`：`UPCateTabItem { name, label, value, icon, children }`、`UPCateTabChildItem { name, label, value, icon }`，标签栏复用 `UPTabsItemData`。`tabKeyName`/`itemKeyName` 只能指向 `name`/`label`/`value`/`icon`，`UPTabsPro` 的 `keyName` 只能指向 `name`；传入模型之外的字段名时回落到 `name` 并记录一条诊断。上游"任意对象 + 任意字段名"的用法需要宿主先把数据映射成上述模型。

以下上游能力保留为 no-op 兼容位或改由宿主承担，全部通过 `UPCompatibilityDiagnostics.report()` 在传入时记录一条诊断：

- `UPMessageInput` 的 `mode`：白名单外的取值回落 `box`。`breathe` 呼吸光标用 `setInterval(UP_MESSAGE_INPUT_BREATHE_DURATION = 1200)` 切换透明度并配 `.animation()` 近似上游 CSS keyframes，不是逐帧等价动画。
- `UPCateTab` 的 `mode`：非 `tab` 取值回落 `follow`。上游 `createSelectorQuery()` 量算分组位置改用 `.onAreaChange()` 收集偏移 + `Scroller.scrollTo()` 滚动，首帧偏移未收敛前联动高亮可能滞后一帧。
- `UPCoupon` 的 `shape` 与 `size`：白名单外取值分别回落 `coupon` 与 `medium`；`circle` 为 no-op，上游操作标签本身恒为圆角胶囊。`envelope` 斜纹用 `linearGradient({ repeating: true })` 近似，金额分隔线用 `BorderStyle.Dashed` 替代上游伪元素虚线。
- `UPTabsPro` 的 `contentMode` 只渲染 `static`，滑动切换内容为 no-op；`contentClass` 不适用 CSS 类名，请改用 `contentStyle`；`bindIndexRef` 模板 ref 不适用，请改用 `onCurrentChange`；`lineBgSize` 因下划线以实心条绘制而为 no-op。
- `UPCarKeyboard` 只渲染键盘面本身，不含上游 `u-keyboard` 的面板容器、遮罩与「完成」栏；按键触感反馈（`uni.vibrateShort`）没有对应实现，一律 no-op。

五个组件只使用 ArkUI、本地状态和宿主回调，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。车牌拼接、验证码校验、分类数据获取与券状态流转仍由宿主负责。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 阶段 15 静态契约覆盖五个组件的默认值、核心 Props/事件、插槽与洗牌/切行/钳制辅助函数、公共导出、Components S 目录和五条 Demo 路由。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，字体资源契约通过。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约通过不等于设备验证通过。
- 当前未宣称车牌键盘连发退格的节奏、验证码呼吸光标的观感、分类导航联动高亮的跟手度、优惠券缺口与斜纹的裁剪表现和增强标签栏下划线滑动的设备验证完成；这些表现需在真机复核。
