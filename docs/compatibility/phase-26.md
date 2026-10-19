# 阶段 26 兼容说明

阶段 26 复刻上游 `libs/i18n`：10 种语言包、`t()` 运行时与 `registerLocale()` 注册机制，并把组件里硬编码的中文文案改为查表。阶段 25 结束时多语言是最后一块上游缺口——组件默认文案在本端是写死的简体中文，切换语言无从下手。本阶段落地生成式语言包 `UPLocaleCatalog`、运行时 `UPI18n`，并把 17 个组件与 3 个内部模块的 41 处默认文案接进语言包。所有改动仍面向 HarmonyOS NEXT API 24。

## 范围

### `UPLocaleCatalog`（对应 `libs/i18n/locales`）

10 种语言（`zh-Hans`、`zh-Hant`、`en`、`es`、`fr`、`de`、`ko`、`ja`、`ru`、`th`）× 84 条文案，键名与文案逐字节镜像上游。语言包不手写：`tools/upstream/uview-plus-locales/*.js` 固定上游快照（提交 `cf27e4ef6`），`tools/generate_uplocale_catalog.py` 生成 ArkTS 文件，与既有的 `UPIconGlyphs` 走同一套「快照 + 生成器」模式。生成器会校验各语言的键集合与顺序完全一致，任何偏移直接失败。

### `UPI18n`（对应 `libs/i18n/index.js`）

`locale()`（上游 `getLocale`）、`setLocale()`、`hasLocale()`、`locales()`、`keys()`、`registerLocale()`、`clearLocale()`、`t()`、`translate(locale, key, params)`。占位符语法沿用上游的 `{name}`，缺失语言回落 `zh-Hans`、缺失键回落键名本身，与上游一致。另提供 `upText()` 短别名与 `upWeekText()`（上游 `weekText` 默认值由 `up.week.one` 到 `up.week.seven` 组成）。

### 组件默认文案接入

17 个组件的 35 处默认值与 3 个内部模块的 8 处常量改为查表，键与上游 `props.js` / `.vue` 的 `t()` 调用点一一对应：

- `UPActionSheet`、`UPModal`（含 `asyncCloseTip` 的 `+ '...'` 拼接）、`UPPicker`、`UPKeyboard`、`UPToolbar`、`UPCascader`、`UPGoodsSku`：确认/取消/请选择族。
- `UPSearch`、`UPReadMore`、`UPLoadmore`（含 `loadingText` 的 `+ '...'`）、`UPSection`、`UPLoadingPage`、`UPCode`、`UPNoNetwork`：各自的业务文案。
- `UPCalendar`（`forbidDaysToast` 与 `weekText`）、`UPCalendarStrip`（`weekText`）、`UPCityLocate`（三个定位常量）、`UPPagination`（上一页/下一页回落）。
- `internal/UPCropperGeometry.ets`（重选/关闭/旋转/预览/确定/裁剪框未设置）、`internal/UPNovelLayout.ets`（重试）、`internal/UPTriggerInput.ets`（请选择）。

接入时同时修正了 6 处与上游不一致的文案：`确认` → `确定`（`up.common.confirm`）、`请输入关键词` → `请输入关键字`、`x秒重新获取` → `X秒重新获取`、`展开` → `展开阅读全文`、`正在处理` → `操作中...`、`正在加载...` 现由 `up.common.loading2` 加后缀拼出。

### 校验文案的多语言（本端扩展）

上游 `async-validator` 的文案表只有英文，且不经 `libs/i18n`。本端新增 `upZhHansValidateMessages()` 与 `upValidateMessagesFor(locale)`，`UPFormController` 默认按 `UPI18n.locale()` 挑选：中文语言用中文表，其余走上游英文表；宿主也可用 `setMessages()` 覆盖。这是本端扩展，不是上游行为。

## 边界

- **不读平台语言**：上游 `settings.lang` 初始值来自 `uni.getLocale()`，并用 `uni.onLocaleChange()` 跟随系统切换。本 HAR 不引入 `@ohos.i18n` / LocalizationKit，默认语言固定为上游的 `zh-Hans`，由宿主调用 `UPI18n.setLocale()` 显式设置；跟随系统语言需宿主自己监听后转发。这属于 no-op 兼容位：入口存在，但不主动探测平台。
- **默认值在实例化时求值**：ArkTS 的 `Props` 类字段默认值在构造时计算，因此 `UPI18n.setLocale()` 之后已挂载的组件不会自动刷新文案，需要重建组件或显式传入文案。上游 Vue 的 `props.js` 同样在模块加载时求值一次，行为方向一致但刷新时机不同——上游可借 Vue 的响应式重渲染，本端不能。
- **`registerLocale` 的入参形态**：上游接受 `registerLocale(locale, messagesObject)` 或一个 `{ locale: messages }` 映射。ArkTS 没有索引签名，改为 `registerLocale(locale, Array<UPI18nParam>)`，一次只注册一种语言；覆盖按键合并，未覆盖的键继续走内置表，与上游整表替换不同（上游整表替换后缺失的键会回落到 `zh-Hans`）。
- **`setLocale()` 不写平台状态**：上游会尝试调用 `uni.setLocale()` 同步平台。本端只改内部状态并返回当前值。
- **`t()` 的空值行为**：上游 `t(value)` 在 `value` 为假值时原样返回。本端 `t(key)` 对空串同样原样返回；参数为空数组时跳过替换。
- **未复刻的上游导出**：`i18n` 默认导出的 `settings` 对象（暴露内部可变状态）不对外提供，改用 `locale()` / `locales()` 只读访问。
- **校验文案的中文表是本端译文**，不是上游资产；上游若未来给校验器加多语言，两边措辞可能不一致。
- 本阶段改动只使用 ArkTS 语言能力与本地查表，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 示例工程

新增 `i18n` 路由（`I18nDemo`，归入 `Components Y`），示例路由数从 142 增至 143：

- 语言切换段列出 10 个内置标签，点击即 `setLocale()`。
- 文案对照表并排展示 8 个键在「当前语言 / zh-Hans / en」下的取值，用 `translate()` 直接指定语言。
- 组件默认文案段挂 `UPToolbar` / `UPSection` / `UPLoadmore`，并标注「已挂载组件不随语言切换刷新」这一边界。
- 占位符段演示 `up.calendar.daysExceed` 的 `{days}` 替换；按钮演示 `registerLocale()` 覆盖 en 的两个键与 `clearLocale()` 撤销。
- 校验段用 `upValidateMessagesFor()` 跑一次必填校验，展示中英文文案切换。
- 星期段渲染 `upWeekText()` 的七项。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_phase_26_i18n_contract.py`：校验 10 个上游快照文件与生成器在位、生成文件带「Do not edit manually」标记、各语言键集合一致、`zh-Hans` 全部 84 条文案在生成文件中逐字出现、`UPI18n` 的 9 个运行时方法与默认语言、不出现任何平台语言 API 探测、41 处组件默认值确实读对应键、校验文案表与控制器接线、Demo 与路由接线、公共导出。当前输出 `PASS (10 locales, 84 keys, 41 wired defaults)`。
- 离线差分验证：用 `node --experimental-strip-types` 把 `UPI18n` 与上游 `locale-packs.js` 并排比对 10 种语言 × 84 条共 840 条文案，逐条要求字节一致；另比对占位符替换、缺失键回落、未知语言回落与 `registerLocale` / `clearLocale` 行为，输出 `UPI18n parity: OK (10 locales, 840 entries)`。
- 既有 42 个契约脚本全部通过；其中 11 个脚本的默认值断言从字面量文案改为 i18n 键，锁定「默认文案必须来自语言包」而非重复硬编码译文。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约与离线差分通过不等于设备验证通过。当前未宣称语言切换后组件重建时机、非中文语种的文本折行与截断在真机上的表现的设备验证完成；这些表现需在真机复核。
