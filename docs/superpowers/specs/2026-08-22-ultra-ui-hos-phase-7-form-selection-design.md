# ultra-ui-hos Phase 7 设计：表单选择与滑块

**状态：已确认 `isRange` 降级方案（选项 A），组件范围与实施顺序为推荐决定，待规格审阅**
**范围：** `UPPicker`、`UPPickerController`、`UPSlider`、`UPSelect`

## 1. 目标与边界

阶段 7 在现有纯 ArkTS/ArkUI 的 `@lingyun/ultra-ui-hos` HAR 中新增三个选择类组件与一个命令式控制器，并为每个组件增加独立中文示例路由。字段名、默认值和事件载荷以固定 uview-plus 上游源码为唯一依据。

本阶段选择「原生 `TextPicker`/`Slider` 承载 + 命令式控制器表达联动」方案：滚轮与滑块交互交给 ArkUI 原生组件，多列联动通过 `UPPickerController` 由页面驱动，与上游命令式语义一致。

本阶段不实现 `hasInput` 触发输入框模式、双滑块 `isRange` 真实渲染、`useNative` 分支、`u-cascader` 声明式级联、`u-picker-data` 便捷包装器，以及 `toolbarRightSlot` 等插槽扩展。上述能力属于后续阶段。

### 1.1 上游依据与文档偏差

所有默认值以上游源码为准：`/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components/`（3.8.111，commit `b32377ce`）。已核实上游**文档表格与源码存在三处不一致**，本阶段一律采信源码：

| 字段 | 文档表格 | 源码实际 | 源码位置 |
| --- | --- | --- | --- |
| `slider.min` | `1` | `0` | `u-slider/slider.js:14` |
| `picker.confirmText` | 确认 | **确定** | `libs/i18n/locales/zh-Hans.js:3` |
| `picker.confirmColor` | `#3c9cff` | `''`（空值，由主题回退） | `u-picker/picker.js` |
| `select.keyName` | `ud`（拼写错误） | `id` | `u-select/u-select.vue` |

关联 Android 移植（`ultra-ui-android`）在这些字段上存在同源错误（`confirmText` 写作"确认"、`inputBorder` 默认 `true`），本阶段不沿用其取值。

## 2. 平台与工程约束

- HarmonyOS NEXT Stage 模型，最低兼容 API 为 24，产品兼容和目标 SDK 为 `5.0.0(12)`。
- 组件库包名保持 `@lingyun/ultra-ui-hos`；所有稳定 API 只从 `ultra-ui/Index.ets` 导出。
- 示例只能从 `@lingyun/ultra-ui-hos` 导入，不允许访问 `ultra-ui/src` 内部路径。
- 不使用 WebView、FastView、Vue/NVue、网络请求、远程资源、运行时代码生成或 JSON 组件映射。
- 使用现有 `UPRawValue`、`UPStyleInput`、`UPUnit`、`UPColor`、`UPStyle` 和兼容诊断机制；非法值安全回退，不抛异常。
- 弹层沿用既有约定：`Stack` + `zIndex` 页面内渲染，与 `UPActionSheet` 一致；**不使用 `CustomDialog`**。
- 页面持有受控状态；组件可持有原生滚轮/滑块的瞬时位置，但不得形成与页面 Props 冲突的第二份业务状态。
- 无连接设备时，设备交互和截图验证必须标记为 `skipped`，不能写成通过。

## 3. 总体架构

### 3.1 文件职责

- `UPSlider.ets`：原生 `Slider` 封装、步长量化与精度归一、纵向方向、值显示。
- `UPPicker.ets`：受控底部弹层、原生 `TextPicker` 多列滚轮、工具栏与事件载荷。
- `UPSelect.ets`：锚定式下拉面板、选项列表、受控 `current`。
- `UPPickerController.ets`（`ultra-ui/src/main/ets/controllers/`）：命令式列操作，承载联动能力。

`UPPickerColumn` **不纳入本阶段**。上游 `u-picker-column/props.js` 声明为 `props: {}`（空契约），组件本体为 6 行 stub 且 `u-picker` 并不使用它——不存在可移植的 API。README 与兼容文档将明确说明这一点，避免被误认为遗漏。

### 3.2 原生映射与能力边界

已核对 ArkUI SDK 声明（`/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets/component/`）：

| 上游能力 | ArkUI 原生支持 | 结论 |
| --- | --- | --- |
| 单列/多列滚轮 | `TextPicker` 的 `range: string[][]` | 原生承载，无需自绘 |
| `itemHeight` | `defaultPickerItemHeight()` | 原生支持 |
| `vertical` 纵向滑块 | `Slider` 的 `direction: Axis.Vertical` | 原生支持（Android 移植的已知缺口，本实现补齐） |
| `step` 步长 | `Slider` 的 `step` + `showSteps` | 原生支持，但精度归一需自行实现 |
| `immediateChange` 触发时机 | `TextPicker` 的 `onChange` 与 `onScrollStop` | 原生支持两种时机，见 5.2 |
| `isRange` 双滑块 | **无**（`slideRange` 仅限制可滑范围，非双值） | 降级为 no-op 兼容字段，见 6.1 |

### 3.3 联动方案：命令式控制器

上游 `columns` 恒为二维数组，**不存在 `cascade` 属性或 `children` 字段**。联动是应用级行为：页面监听 `change` 拿到 `columnIndex` 与 `index`，再调用 ref 方法替换后续列。

ArkTS 无 Vue `ref` 方法，因此必须显式提供控制器。这与纯 props 设计不兼容——**没有控制器就无法表达联动**，这正是 Android 移植缺失该能力的原因。

控制器形态沿用既有 `UPToastController` 先例（listener + mount/unmount 生命周期），不引入新机制。

## 4. 公共类型与事件

### 4.1 滑块事件

```ts
export type UPSliderChangeMode = 'start' | 'changing' | 'change';
export interface UPSliderChangeEvent {
  value: number;
  mode: UPSliderChangeMode;
}
```

上游 `emits: ["start","changing","change","update:modelValue"]`。单值模式载荷为 `number`。`isRange` 模式上游返回整个数组，但本阶段 `isRange` 为 no-op，故载荷恒为 `number`。

### 4.2 选择器事件

```ts
export interface UPPickerChangeEvent {
  value: Array<UPRawValue>;      // 各列选中的原始项
  index: number;                 // 变化列内的行索引
  indexs: Array<number>;         // 各列选中索引
  values: Array<Array<UPRawValue>>;  // 全部列数据
  columnIndex: number;           // 变化的列
}

export interface UPPickerConfirmEvent {
  indexs: Array<number>;
  value: Array<UPRawValue>;
  values: Array<Array<UPRawValue>>;
}
```

字段严格照上游 `changeHandler`/`confirm` 实现。注意 `values` 为**全部列**（上游代码 `const values = this.innerColumns`），上游文档注释称"当前变化列的数组内容"与代码不符，采信代码。

事件顺序：`onChange`（滚动时）→ `onConfirm` + `onModelValueChange`（确认时）→ `onShowChange(false)`。`onCancel` 触发时同时 `onShowChange(false)` 并重置为上次确认值。`onClose` **仅在** `closeOnClickOverlay` 为真且点击遮罩时触发，与上游一致（Android 移植在取消/确认时也发 `close`，为错误行为，不沿用）。

### 4.3 下拉框事件

```ts
export interface UPSelectSelectEvent {
  option: UPSelectOption;   // 整个选项对象
  current: UPRawValue;      // option[keyName]
}
```

## 5. 组件契约

### 5.1 `UPSlider`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `modelValue` / `value` | `0` | 双字段，`modelValue` 优先 |
| `min` | `0` | 源码值（文档表格写 `1`，不采信） |
| `max` | `100` | |
| `step` | `1` | `≤0` 时回退为 `1`（上游 `getSliderStep()`） |
| `disabled` | `false` | |
| `vertical` | `false` | → `direction: Axis.Vertical` |
| `length` | `'auto'` | 横向为宽、纵向为高 |
| `showValue` | `false` | 独立文本块，非滑块内嵌 |
| `blockSize` | `18` | 有效区间 12–28 |
| `blockColor` | `'#ffffff'` | |
| `blockStyle` | `undefined` | |
| `activeColor` | `'#2979ff'` | |
| `inactiveColor` | `'#c0c4cc'` | |
| `size` | `'2px'` | 轨道粗细 |
| `height` | `''` | 上游 3.7 起废弃，作为 `size` 别名 |
| `innerStyle` | `undefined` | |
| `useNative` | `false` | no-op 兼容字段 |
| `isRange` | `false` | **no-op 兼容字段**，见 6.1 |
| `rangeValue` | 每实例新建 `[0, 0]` | no-op；上游用共享数组是反模式，本实现每实例独立 |

`height` 与 `size` 的优先级照抄上游 `mounted()`：`height` 非空则用 `height`，否则用 `size`。

**精度归一必须实现。** 上游 `formatByStep` 流程：钳制到 `[min, max]` → `steps = Math.round((bounded - min) / step)` → `value = min + steps * step` → 按 `digitLength` 计算精度并 `toFixed` 归一。Android 移植用 `Float` 且未做归一，`step: 0.1` 会漂成 `0.30000000000000004`。本实现按上游处理。

上游 `blockWidth` 与"height 单位 rpx 默认 6"是过期注释，`props.js` 无此字段，不移植。

### 5.2 `UPPicker`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `show` | `false` | 受控显示 |
| `columns` | `[]` | **恒为二维数组**；单列为 `[[...]]` |
| `modelValue` | `[]` | 各列选中值（经 `valueName` 映射） |
| `keyName` | `'text'` | 对象项的显示字段；字符串项原样显示 |
| `valueName` | `'value'` | 回传值字段 |
| `defaultIndex` | `[]` | 各列默认索引 |
| `visibleItemCount` | `5` | |
| `itemHeight` | `44` | → `defaultPickerItemHeight()` |
| `loading` | `false` | 异步联动加载态 |
| `showToolbar` | `true` | |
| `title` | `''` | |
| `cancelText` | `'取消'` | |
| `confirmText` | `'确定'` | 源码 i18n 值，非"确认" |
| `cancelColor` | `'#909193'` | |
| `confirmColor` | `''` | 空值时回退主题主色 |
| `closeOnClickOverlay` | `false` | 为假时点击遮罩无响应 |
| `immediateChange` | `true` | 影响 `change` **时机**，不影响是否触发（Android 移植误作开关，不沿用） || `popupMode` | `'bottom'` | 本阶段仅实现 `bottom`，其余值降级并诊断上报 |
| `round` | `0` | |
| `zIndex` | `10076` | |
| `overlayOpacity` | `0.5` | |
| `controller` | `undefined` | `UPPickerController` 实例，联动必需 |

`keyName` 按**单项**判定而非整列：项为对象时取 `item[keyName]`，为字符串时原样显示（上游 `getItemText`）。`modelValue` 反向映射值→索引时使用宽松比较（上游 `==`，故 `'1'` 匹配 `1`）。

`immediateChange` 映射到原生两个事件：为真时绑定 `TextPicker.onChange`（滚动中即触发），为假时绑定 `onScrollStop`（滚动停止后触发）。二者互斥绑定，避免同一次滚动重复触发 `onChange` 回调。上游该字段仅影响**时机**，任何取值下 `change` 都会触发。

### 5.3 `UPPickerController`

```ts
setColumnValues(columnIndex: number, values: Array<UPRawValue>): void
setIndexs(indexs: Array<number>): void
getIndexs(): Array<number>
getValues(): Array<UPRawValue>
getColumnValues(columnIndex: number): Array<UPRawValue>
```

`setColumnValues` 是联动 primitive：替换指定列数据后，将其**后续所有列的索引归零**（上游行为，使联动手感正确）。`setIndexs` 必须整数组赋值（上游注释明确"一次性赋值，不能单个修改，否则无效"）。

越界 `columnIndex` 安全忽略并经 `diagnostics` 上报，不抛异常。

### 5.4 `UPSelect`

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `options` | `[]` | |
| `current` | `''` | 受控值 |
| `keyName` | `'id'` | 注意与 picker 的 `'text'` 不同 |
| `labelName` | `'name'` | |
| `label` | `'选项'` | |
| `showOptionsLabel` | `false` | |
| `disabled` | `false` | |
| `border` | `false` | |
| `optionsWidth` | `''` | 数值转 `px` |
| `maxHeight` | `'90vh'` | `vh` 无原生对应，按屏高百分比换算 |
| `overlay` | `true` | |
| `overlayOpacity` | `0.01` | |
| `duration` | `300` | |
| `zIndex` | `11000` | 面板用 `zIndex + 1` |
| `itemColor` | `''` | 空值回退 `#303133` |
| `iconColor` | `''` | 空值回退 `#606266` |
| `iconSize` | `'13px'` | |

`u-select` 为上游 3.4.10 引入并持续迭代的**独立组件，未废弃**，与 `u-picker` 交互模型不同（锚定下拉面板 vs 底部滚轮），二者并存。旧 uview-ui 1.x/2.x 中被 `u-picker` 取代的 `u-select` 是同名的无关组件——兼容文档需写明，避免后续误删。

## 6. 错误处理与兼容降级

### 6.1 `isRange` 双滑块降级（已确认方案 A）

ArkUI `Slider` 无双滑块能力：`slideRange` 仅限制可滑范围，不提供双值。本阶段将 `isRange` 与 `rangeValue` 作为 **no-op 兼容字段**：接受入参、仅渲染单滑块、经 `diagnostics.report()` 上报，并在兼容文档中明确记录。与既有 `UPList.pagingEnabled` 的处理方式一致——不假装支持。

若后续阶段实现双滑块，须按上游语义（每滑块绑定各自触摸目标、强制至少一个 `step` 间隔、禁止交叉），不采用 Android 移植的"就近抢滑块 + 允许两值相等或交换"实现。

### 6.2 其他降级

- `popupMode` 非 `bottom` 值：降级为 `bottom` 并上报。
- `useNative`：no-op 兼容字段并上报。
- `maxHeight` 的 `vh` 单位：按屏高百分比换算；非法值回退 `'90vh'` 等效值。
- `step ≤ 0`：回退 `1` 并上报。
- `columns` 非二维数组：按单列包装（`[columns]`）并上报。
- 越界 `defaultIndex`/`columnIndex`：钳制或忽略并上报。
- 所有非法值安全回退，不抛异常。

## 7. 示例工程

新增四个示例路由，注册于 `SampleCatalog.ets` 的新分组 `Components K`，并在 `SamplePage.ets` 增加派发分支：

| 路由 | 标题 | 演示内容 |
| --- | --- | --- |
| `slider` | 滑块 Slider | 单值、步长、纵向、禁用、值显示、小数步长精度 |
| `picker` | 选择器 Picker | 单列、多列、默认索引、工具栏、遮罩关闭 |
| `picker-cascade` | 选择器联动 Picker | 通过 `UPPickerController` 实现二级联动 |
| `select` | 下拉框 Select | 选项、受控 `current`、禁用、边框 |

联动示例是本阶段的关键演示——它证明控制器机制可用，且是 Android 移植缺失的能力。

## 8. 测试与验收

### 8.1 静态契约

新增 `scripts/test_phase_7_form_selection_contract.py`，断言：组件 struct 与 Props class 存在、`Index.ets` 导出、关键默认值（含 `confirmText = '确定'`、`min = 0`、`confirmColor = ''`、`keyName = 'id'`）、事件载荷字段名、控制器方法签名、示例路由注册与派发、禁止 token 不出现。

同步扩展 `test_documentation_contract.py` 与 `test_sample_contract.py`，保留既有断言。

### 8.2 构建验证

```bash
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/build.sh
```

预期：全部契约通过，HAR 与 HAP 编译成功，仅保留已记录的未签名警告。

### 8.3 设备验证

无连接设备时，滚轮惯性滚动、步长量化视觉、纵向滑块手势、遮罩关闭、下拉面板定位与边缘碰撞重定位一律记录为 `skipped`。静态契约与 Hvigor 构建**不能**替代真实设备验证。

## 9. 非目标

`hasInput` 触发输入框模式及其 `inputProps`/`placeholder`/`inputBorder` 字段、双滑块真实渲染、`useNative` 原生分支、`u-cascader` 声明式级联、`u-picker-data` 便捷包装器、`u-picker-column`（上游空契约）、`toolbarRightSlot` 等插槽扩展、主题 `upThemeVar` 完整明暗回退体系。
