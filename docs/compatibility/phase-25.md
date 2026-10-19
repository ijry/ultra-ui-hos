# 阶段 25 兼容说明

阶段 25 复刻上游 `libs/util/async-validator.js`（1343 行）的规则引擎，并把它接进 `UPForm` / `UPFormItem`。阶段 24 结束时表单校验仍是缺口：`UPForm.validate()` 只做确定性的存在性检查，上游的 `rules` 语法完全没有对应实现。本阶段落地同步规则引擎 `UPValidator`、命令式控制器 `UPFormController` 与共享上下文 `UPFormContext`，`UPFormItem` 现在按 `prop` 自动显示表单级错误。所有改动仍面向 HarmonyOS NEXT API 24。

## 范围

### `UPValidator`（对应 `async-validator` 的 Schema）

- **规则字段**：`type`、`required`、`message`、`min`、`max`、`len`、`pattern`、`enumValues`、`whitespace`、`triggers`、`validator`、`transform`，与上游 rule 对象一一对应。
- **类型判定**：`string`、`boolean`、`integer`、`float`、`array`、`number`、`email`、`url`、`hex`、`date`、`regexp`，正则（`pattern.email` / `pattern.url` / `pattern.hex`）逐字镜像上游。
- **区间判定**：保留上游按值的运行时类型挑选文案分组（number / string / array）的行为，以及用 `[\uD800-\uDBFF][\uDC00-\uDFFF]` 修正补充平面字符长度的处理。
- **文案表**：`UPValidateMessages` 保留上游 19 条模板与 `%s` 占位符；`UPValidator.format()` 实现上游的位置替换。
- **执行顺序**：`required` → `type` → `range` → `enum` → `pattern` → `whitespace` → 自定义 `validator`，与上游 `rules` 表的调用顺序一致；同一字段的多条规则逐条收集，不提前退出。

### `UPFormController`（对应上游 `u-form` 的实例方法）

`setRules()`、`setValue()` / `setValues()`、`validate()`、`validateField(field, trigger)`、`clearValidate(fields?)`、`resetFields()`、`resetValues()`、`currentErrors()`、`errorOf(prop)`。控制器持有首次写入的值快照供 `resetFields()` 还原，并通过 `mount()` / `unmount()` 与 `UPForm` 建立生命周期绑定。

### `UPFormContext` 与组件接线

`UPForm` 用 `@Provide('UPFormContext')` 下发错误集合与 `errorType` / `borderBottom` / `labelPosition` / `labelWidth` / `labelAlign` / `disabled`；`UPFormItem` 用 `@Consume` 消费，按 `prop` 自动取错误，并按 `errorType` 决定呈现方式：

- `message`：在字段下方渲染红色错误文案（默认）。
- `border-bottom`：下划线转红色，不渲染文案。
- `toast`：不渲染文案，改由 `UPForm.onErrorToast` 把首条错误交给宿主。
- `none`：不呈现。

`UPFormItem` 同时补上了此前缺失的 `labelPosition: 'top'`（标签独占一行）与 `labelAlign` 对齐行为，未被 `UPForm` 包裹时全部回落自身 props。

## 边界

- **同步取代 Promise**：上游 `validate()` 返回 Promise 并用 `asyncParallelArray` / `asyncSerialArray` 串联。ArkTS 侧禁用 `async`/`await`/`Promise`，且所有内置规则都是纯计算，因此本端全部同步返回 `UPValidateResult`。异步校验（如远端查重）需宿主自行编排后用 `setValue()` + `validateField()` 回灌结果。
- **`source` 对象变成显式条目数组**：上游靠 `source.hasOwnProperty(field)` 区分「字段缺失」与「字段为空」，并支持 `'a.b.c'` 形式的深层路径（`getProperty` / `setProperty`）。ArkTS 没有索引签名与运行时反射，改为 `Array<UPValidateFieldValue>`：条目不存在即等价于 `hasOwnProperty` 为假。深层路径不支持，嵌套模型需调用方自己摊平成扁平字段名。
- **`pattern` 传源码字符串而非 `RegExp` 实例**：上游允许 `rule.pattern` 是 `RegExp`（并会重置 `lastIndex`）。ArkTS 的 props 不便携带 `RegExp` 实例，改为传正则源码字符串，内部每次 `new RegExp(source)`，因此不存在 `lastIndex` 残留问题。
- **`enum` 是 ArkTS 保留字**：上游 `rule.enum` 改名为 `rule.enumValues`，语义与文案（`%s must be one of %s`）不变。
- **`type: 'regexp'` 的判定放宽**：上游用 `try { new RegExp(value) } catch` 探测。本端不依赖异常捕获，改为保守的括号配平检查，因此少数非法正则（如 `[a-`）会被判为合法。
- **`type: 'date'` 的口径**：上游要求值是 `Date` 实例（检查 `getTime`/`getMonth`/`getYear`）。ArkTS 侧的模型值是标量，改为复用 `upDateParts()` 解析 `yyyy-mm-dd[ hh:mm[:ss]]` 字符串，因此 `Date` 对象本身不参与判定。
- **`resetFields()` 不改写调用方的模型**：上游直接用 `setProperty` 写回 `model` 对象。本端只还原控制器内的值，宿主需用 `resetValues()` 把快照同步回自己的 `@State`；`FormDemo` 演示了这个回灌步骤。
- **`errorType: 'toast'` 是 no-op 兼容位**：上游调用 `uni.showToast`。ArkUI 没有全局 toast，本端只把首条错误通过 `onErrorToast` 转发给宿主，实际提示由宿主用 `UPToastController` 或自有组件承担；不接这个回调时该分支不产生任何可见反馈。
- **`trigger` 的过滤方向**：上游 `validateField(prop, callback, event)` 在传入 `event` 且规则未声明该 trigger 时跳过该规则。本端 `validateField(field, trigger)` 保持同一判定：`trigger` 为空串表示不过滤（等价于上游 `event = null`），非空时只跑声明了该 trigger 的规则。
- **未复刻的上游能力**：`asyncValidator`（规则级异步函数）、`fields` 嵌套描述符、`defaultField`（数组元素统一规则）、`options.first` / `options.firstFields` 短路选项、`messages.clone()`。这些都依赖 Promise 编排或深层对象遍历，属于本阶段范围外。
- 本阶段改动只使用 ArkTS 语言能力与本地计算，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 示例工程

重写 `FormDemo`（路由 `form` 不变，示例路由总数仍为 142）：

- 五个字段覆盖不同规则族：姓名（`required` + `min`/`max`）、邮箱（`required` + `type: 'email'`）、年龄（`required` + `type: 'number'` + 区间）、性别（`type: 'enum'` + `enumValues`）、兴趣（`type: 'array'` + `min`）。
- 输入框的 `onInput` / `onBlur` 分别以 `change` / `blur` 触发 `validateField()`，演示 `triggers` 过滤。
- 三个按钮对应 `validate()`、`clearValidate()`、`resetFields()`，其中重置按钮演示了用 `resetValues()` 把快照回灌到 `@State` 的步骤。
- 底部标注 `errorType` 四种取值与 toast 分支的宿主承接方式。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_phase_25_form_validation_contract.py`：锁定 12 个规则字段、11 种类型判定、19 条上游文案模板的逐字保留，上游正则与补充平面修正的镜像，10 个控制器方法与 mount/unmount 生命周期、快照机制，`@Provide`/`@Consume` 接线与 `errorType` 分支，以及 Demo 的规则演示与公共导出。
- 离线差分验证：用 `node --experimental-strip-types` 把 `UPValidator` 与上游 `async-validator` 并排跑 30 组规则、约 90 个样本（required / 11 种 type / string 与 number 与 array 的 len·min·max·range / pattern / whitespace / enum / 自定义 message），逐条比对首条错误文案，输出 `UPValidator parity: OK`。差异项已在「边界」里逐条记录，不计入失败。
- 既有 41 个契约脚本全部通过。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约与离线差分通过不等于设备验证通过。当前未宣称 `blur` 触发时机、`@Provide`/`@Consume` 的错误刷新时序与 `border-bottom` 呈现在真机上的表现的设备验证完成；这些表现需在真机复核。
