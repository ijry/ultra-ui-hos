# ultra-ui-hos 阶段 2B 兼容性与验证记录

## 1. 目标和基线

阶段 2B 在阶段 1、阶段 2A 的可构建 HAR/HAP 基线上补齐头像、独立输入和基础值控件：
`UPAvatar`、`UPAvatarGroup`、`UPInput`、`UPTextarea`、`UPSwitch`、`UPRate`、`UPNumberBox`。

本阶段继续遵守以下基线：

- HarmonyOS NEXT Stage 模型，最低兼容 API 24；
- 产品兼容/目标 SDK 为 `5.0.0(12)`；
- HAR 包名为 `@lingyun/ultra-ui-hos`，所有 public API 由 `ultra-ui/Index.ets` 导出；
- 示例包名为 `net.lingyun.ultraui.hos.sample`，示例只从 HAR 公共入口导入；
- 字段和默认语义参考固定 uview-plus 3.x 提交 `96f14b06f857aeda011ae5baf9654bb4634dba9a` 以及关联 iOS/Android 工程；
- 不引入 Vue/NVue、WebView、FastView、JSON 动态渲染、网络请求、业务路由运行时或运行时代码生成。

## 2. 已实现组件、Props 和事件

| 组件 | 主要 Props | 事件/回传 | HarmonyOS 交付语义 |
| --- | --- | --- | --- |
| `UPAvatar` | `src`、`text`、`name`、`shape`、`size`、`mode`、`icon`、`bgColor`、`color`、`fontSize`、`randomBgColor`、`defaultUrl`、`colorIndex`、`customStyle` | `onClick(UPAvatarClickEvent)`，回传 `name`、`src`、展示文本 | 只渲染本地资源；无可用本地图像时按文字、图标、背景色顺序回退 |
| `UPAvatarGroup` | `urls`、`maxCount`、`shape`、`mode`、`showMore`、`size`、`keyName`、`gap`、`extraValue`、`customStyle` | 当前无组级事件 | 支持字符串或对象源（`url`/`src`/`avatar`/`text`/`name`），超出数量显示 `+N` |
| `UPInput` | `value`、`modelValue`、`type`、`password`、`clearable`、`maxlength`、`placeholder`、`showWordLimit`、`prefixIcon`、`suffixIcon`、`border`、`shape`、`readonly`、`disabled`、`inputAlign`、`customStyle` | `onInput`、`onChange`、`onConfirm`、`onFocus`、`onBlur`、`onClear` | 基于原生 `TextInput`；输入长度截断到 `maxlength`，密码和数字类型映射到原生输入类型 |
| `UPTextarea` | `value`、`modelValue`、`placeholder`、`height`、`count`、`maxlength`、`border`、`disabled`、`autoHeight`、`customStyle` | `onInput`、`onChange`、`onConfirm`、`onFocus`、`onBlur` | 基于原生 `TextArea`；显示可选计数器，长度按 `maxlength` 截断 |
| `UPSwitch` | `value`、`modelValue`、`activeValue`、`inactiveValue`、`loading`、`disabled`、`size`、`activeColor`、`inactiveColor`、`dotActiveColor`、`dotInactiveColor`、`asyncChange` | `onChange(UPSwitchChangeEvent)`，回传值和 `checked` | 只维护本地勾选表现并回传事件；不执行异步业务确认 |
| `UPRate` | `value`、`modelValue`、`count`、`minCount`、`allowHalf`、`disabled`、`readonly`、`size`、`gutter`、`activeIcon`、`inactiveIcon`、`touchable`、`customStyle` | `onChange(UPRateChangeEvent)`，回传数值 | 使用本地 `UPIcon` 星形图标；当前点击按整星选择，`allowHalf` 保留兼容字段 |
| `UPNumberBox` | `value`、`modelValue`、`min`、`max`、`step`、`integer`、`decimalLength`、`disabled`、`disabledInput`、`showMinus`、`showPlus`、`disablePlus`、`disableMinus`、`customStyle` | `onChange`、`onPlus`、`onMinus`、`onBlur`，回传数值、`name` 和 `type` | 原生数字输入与本地加减按钮；值钳制到边界并按整数/小数位归一化 |

所有 Props 类和事件类型均可从 `@lingyun/ultra-ui-hos` 公共入口导入。未列出的兼容字段可以保留在 Props 中；不适用 HarmonyOS 的字段采用稳定 no-op 或安全回退，不会因此触发未实现的跨端能力。

## 3. `value` / `modelValue` 兼容策略

- `UPInput`、`UPTextarea`、`UPSwitch`、`UPRate` 和 `UPNumberBox` 同时保留 `value` 与 `modelValue`；当 `modelValue` 不是 `null`/`undefined` 时优先使用它，否则使用 `value`。
- 组件在出现时把选定的初始值复制到本地状态。用户交互通过 typed callback 回传新值，页面负责更新自己的 `@State` 并重新创建/传入 Props；组件不偷偷发起双向绑定或业务提交。
- 文本组件的 `onInput` 与 `onChange` 回传 `{ value: string }`；提交回传 `{ value, key }`。清除操作先回传空字符串，再触发 `onClear`。
- `UPSwitch` 回传 `{ value, checked }`；`UPRate` 回传归一化后的数字；`UPNumberBox` 回传 `{ value, name, type }`，其中 `type` 为 `plus`、`minus` 或 `blur`。

## 4. 输入、清除、提交和边界行为

- `UPInput` 的 `clearable` 只在有内容、非禁用/只读且满足焦点条件时显示；`onlyClearableOnFocused` 可限制为聚焦时显示。`password`、`type`、前后图标、对齐和 `showWordLimit` 只影响本地原生呈现。
- `UPInput` 的 `readonly` 不接受组件内部的值更新，`disabled` 同时禁用原生输入；`border = 'none'` 去除边框，其余未知边框值安全回退为有边框表现。
- `UPTextarea` 的 `count` 控制计数器，`border = 'none'` 去除边框；`height` 和 `customStyle` 控制静态尺寸。`autoHeight`、光标、键盘和平台专属字段仅保留兼容输入，当前 API 24 版本不承诺动态高度或键盘编排行为。
- `maxlength` 为非负数字时执行长度截断；负值采用宽松上限，非法值回退到默认长度。禁用状态不接受用户输入。
- `onConfirm` 仅回传原生提交键值，不在组件库内触发导航、请求或表单提交。

## 5. 头像、本地资源和确定性回退

- `UPAvatar`/`UPAvatarGroup` 仅接受本地可解析资源前缀（如 `resource://`、`file://`、绝对本地路径和 `$rawfile:`）进行 `Image` 渲染。
- `http://`、`https://` 等远程地址不会发起请求，也不会被当作可加载图片；组件安全回退到文字、图标和背景色。`defaultUrl` 只有在本地资源条件满足时才会作为图像回退源。
- `randomBgColor` 名称沿用跨端 API，但实现使用固定调色板和 `colorIndex`/文本首字符计算颜色，不调用随机数，因此截图和重渲染结果稳定。
- `UPAvatarGroup` 对象源支持 `url`、`src`、`avatar`、`text`、`name`，`keyName` 只影响对象源的字段选择；超出 `maxCount` 的项目不会渲染，`showMore` 开启时显示隐藏数量。

## 6. 示例工程验收面

阶段 2B 在示例 `Components A` 中新增七条路由：

- `avatar`：头像 Avatar；
- `avatar-group`：头像组 AvatarGroup；
- `input`：输入框 Input；
- `textarea`：文本域 Textarea；
- `switch`：开关 Switch；
- `rate`：评分 Rate；
- `number-box`：步进器 NumberBox。

示例页面只使用本地文本和本地状态，不包含远程图片、网络数据、WebView、FastView 或业务路由。应用导航由示例自己的原生 `Navigation`/`NavPathStack` 管理，组件库只负责渲染和事件回传。

## 7. 构建、契约和边界验证

推荐在仓库根目录执行：

```bash
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/capture-screenshots.sh
./scripts/build.sh
git diff --check
```

阶段 2B 重点契约包括：

```bash
python3 scripts/test_form_entry_contract.py
python3 scripts/test_arkts_component_contract.py
```

`./scripts/build.sh` 先构建 `ultra_ui.har`，再通过本地 HAR 依赖构建示例 HAP，并检查 `upicon.ttf` 同时存在于 HAR 和 HAP。最新一次本机验证应以命令实际输出为准，文档中的 `skipped` 不替代构建或编译结果。

## 8. 设备验证状态

没有连接 HarmonyOS 模拟器或真机时，`scripts/verify-toolchain.sh` 和 `scripts/capture-screenshots.sh` 会输出类似：

```text
device: skipped (no connected target)
screenshots: skipped (no connected HarmonyOS device)
```

`skipped` 只表示设备级安装、点击、返回、输入法、动画和截图对比未执行，不代表设备验证通过。当前无设备时可确认的范围是源码契约、公共导出、禁止网络/运行时边界以及本机 HAR/HAP 构建。

## 9. 后续扩展

阶段 2C 可继续补齐 `UPForm`、`UPFormItem`、`UPCheckbox`/`UPCheckboxGroup`、`UPRadio`/`UPRadioGroup` 等表单组合能力；未实现能力不会加入公共导出或“已实现组件”列表。
