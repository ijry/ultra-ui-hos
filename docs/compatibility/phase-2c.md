# ultra-ui-hos 阶段 2C 兼容性与验证记录

## 1. 范围和基线

阶段 2C 在阶段 2B 基线上补齐表单与选择组件：`UPForm`、`UPFormItem`、`UPCheckbox`、`UPCheckboxGroup`、`UPRadio`、`UPRadioGroup`。

继续遵守：

- HarmonyOS NEXT Stage 模型，最低兼容 API 24；产品兼容/目标 SDK 为 `5.0.0(12)`；
- HAR 包名为 `@lingyun/ultra-ui-hos`，所有公共 API 由 `ultra-ui/Index.ets` 导出；
- 示例包名为 `net.lingyun.ultraui.hos.sample`，示例只从 HAR 公共入口导入；
- Props 字段参考固定 uview-plus 3.x 提交 `96f14b06f857aeda011ae5baf9654bb4634dba9a` 与关联 Android/iOS 工程；
- 不引入 Vue/NVue、WebView、FastView、JSON 动态渲染、网络请求、业务路由运行时或运行时代码生成。

## 2. 组件契约

| 组件 | 主要 Props | 事件 | 原生回退语义 |
| --- | --- | --- | --- |
| `UPForm` | `model`、`rules`、`errorType`、`labelPosition`、`labelWidth`、`labelAlign`、`borderBottom`、`disabled`、`customStyle` | `onValidate(UPFormValidateEvent)`、`onSubmit(UPFormValidateEvent)` | 保留模型/规则字段；鸿蒙侧只执行确定性的本地校验回调桥接，不解析异步规则或执行网络提交 |
| `UPFormItem` | `label`、`prop`、`required`、`borderBottom`、`labelPosition`、`labelWidth`、`labelAlign`、`error`、`rightIcon`、`customStyle` | `onClick()` | 标签、必填星号、内容插槽和错误文本由 ArkUI 原生布局呈现；调用方负责真实字段校验 |
| `UPCheckbox` | `name`、`shape`、`size`、`checked`、`disabled`、`activeColor`、`inactiveColor`、`iconSize`、`iconColor`、`label`、`labelSize`、`labelColor`、`labelDisabled`、`usedAlone` | `onChange(UPCheckboxChangeEvent)` | 采用本地受控近似；非法形状回退为方形，颜色/尺寸回退为安全默认值 |
| `UPCheckboxGroup` | `name`、`modelValue`、`value`、`shape`、`disabled`、`activeColor`、`inactiveColor`、`size`、`placement`、`labelSize`、`labelColor`、`labelDisabled`、`iconColor`、`iconSize`、`borderBottom`、`iconPlacement`、`gap`、`options` | `onInput`、`onChange(UPCheckboxGroupChangeEvent)` | `modelValue` 优先于 `value`；数组以字符串等价比较，非法值回退为空数组；`placement` 只接受 `row`/`column` |
| `UPRadio` | `name`、`shape`、`checked`、`disabled`、`activeColor`、`inactiveColor`、`iconSize`、`iconColor`、`label`、`labelSize`、`labelColor`、`labelDisabled` | `onChange(UPRadioChangeEvent)` | 单项只允许从未选中变为选中；禁用和 labelDisabled 阻止点击 |
| `UPRadioGroup` | `name`、`modelValue`、`value`、`shape`、`disabled`、`activeColor`、`inactiveColor`、`size`、`placement`、`labelSize`、`labelColor`、`labelDisabled`、`iconColor`、`iconSize`、`borderBottom`、`iconPlacement`、`gap`、`options` | `onInput`、`onChange(UPRadioGroupChangeEvent)` | `modelValue` 优先于 `value`；同组只保留一个值；非法布局回退为横向 |

`options` 是 HarmonyOS 示例和无 slot 场景的显式辅助字段，每项形如 `{ name, label?, disabled? }`。使用 trailing builder 时，`UPCheckboxGroup`/`UPRadioGroup` 保留内容插槽；复杂联动状态仍由页面持有。

## 3. 表单和跨端字段限制

- `UPForm.model` 使用显式 ArkTS `UPFormModel` 结构保存常见字段；未知业务字段不由组件库动态解析，跨端专有能力保持安全 no-op。
- `rules`、`errorType`、`prop` 等字段保留兼容性，但不会在运行时生成验证器、执行任意函数或发起网络请求。
- `onValidate` 回调提供 `{ valid, errors }` 的确定性结果；真实异步校验应由业务层完成后再更新 `UPFormItem.error`。
- `modelValue` 为空/未定义时才回退到 `value`；空数组和空字符串是有效的受控值，不再继续回退。
- 所有尺寸按 `UPUnit` 安全解析，颜色仅接受主题名或合法十六进制值；非法输入不会抛异常。
- `shape`、`placement`、`iconPlacement` 等字符串枚举未知时采用安全视觉回退，不自动报告或执行跨端路由能力。
- 组件不提供 HTML 表单提交、JSON schema 解析、动态组件渲染和自动焦点跳转。

## 4. 示例和验证

示例新增六条路由：`checkbox`、`checkbox-group`、`radio`、`radio-group`、`form`、`form-item`。所有示例只从 `@lingyun/ultra-ui-hos` 导入，并使用本地确定性数据。

本阶段静态契约：

```bash
python3 scripts/test_phase_2c_form_selection_contract.py
```

完整验证：

```bash
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/capture-screenshots.sh
./scripts/build.sh
 git diff --check
```

无连接真机或模拟器时，设备安装、点击和截图输出为 `skipped`；这不是设备验证通过。HAR/HAP 构建成功只证明源码、资源和静态打包链路通过，不替代真实设备交互检查。
