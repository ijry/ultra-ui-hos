# 阶段 24 兼容说明

阶段 24 不新增 UI 组件，而是把上游 `libs/function` 与 `libs/config` 这一层共享工具复刻为 ArkTS 内核 API。此前 22 个阶段只覆盖组件目录，工具层是最后一块公共 API 缺口：上游 74 个非平台相关导出现在都有对应的 ArkTS 入口，`scripts/test_upstream_util_coverage.py` 已归零。所有改动仍面向 HarmonyOS NEXT API 24，新增类型与函数均从 `@lingyun/ultra-ui-hos` 公共入口导出。

## 范围

### `UPValidate`（对应 `libs/function/test.js`）

26 个纯函数校验器：`upIsEmail`、`upIsMobile`、`upIsUrl`、`upIsDate`、`upIsDateISO`、`upIsNumeric`、`upIsDigits`、`upIsIdCard`、`upIsCarNo`、`upIsAmount`、`upIsChinese`、`upIsLetter`、`upIsEnOrNum`、`upIsLandline`、`upIsCode`、`upIsImage`、`upIsVideo`、`upIsEmpty`、`upContains`、`upInRange`、`upInRangeLength`，另加日历辅助 `upIsLeapYear`、`upDaysInMonth`、`upDateParts` 与列表判空 `upIsEmptyList`。正则与上游逐字一致，包括 `upIsLetter` / `upIsEnOrNum` 对空串返回 `true` 这类上游既有行为。

### `UPMath`（对应 `libs/function/digit.js` 与 `calc.js`）

高精度四则运算：`strip`、`digitLength`、`float2Fixed`、`checkBoundary`、`enableBoundaryChecking`、`times`、`plus`、`minus`、`divide`、`round`，以及折叠形态 `plusAll` / `minusAll` / `timesAll` / `divideAll` 和区间夹取 `clamp`（对应上游 `range()`）。实现沿用上游「先按小数位放大成整数再运算」的策略，因此 `0.1 + 0.2` 得到 `0.3` 而不是 `0.30000000000000004`。上游 `calc.js` 的 `add`/`sub`/`mul`/`div` 与 `digit.js` 同名能力重复（且 `div` 引用了不存在的 `xyutil`，在上游即为坏实现），本端只保留 `digit.js` 一套。

### `UPFormat`（对应 `libs/function/index.js` 的格式化族）

`padZero`、`timeFormat`、`timeFrom`、`priceFormat`、`durationText` / `durationValue`（对应 `getDuration(value, true|false)`）、`trim`、`queryParams`、`typeIcon`（对应 `type2icon`），另加日历互转 `partsOf`、`timestampOf`、`toMilliseconds`。日期换算使用 Howard Hinnant 的 days-from-civil 算法，不依赖平台 `Date` 解析，跨设备与跨时区结果一致。

### `UPGradient`（对应 `libs/function/colorGradient.js` 与 `genLightColor()`）

`toRgb` / `toRgbText`（对应 `hexToRgb` 的两种返回形态）、`toHex`（`rgbToHex`）、`toRgba`（`colorToRgba`）、`gradient`（`colorGradient`）、`expandHex`，以及 HSL 族 `toHsl` / `fromHsl` / `lightColor`（`genLightColor`）。`gradient()` 保留上游「首尾两项锁定为起止色」的行为。

### `UPZIndex` 与 `UPLegacyColor`（对应 `libs/config/zIndex.js` 与 `color.js`）

层级常量按上游取值逐项镜像：`TOAST = 10090`、`NO_NETWORK = 10080`、`POPUP = 10075`（上游把 popup / actionSheet / keyboard / picker 归到同一层）、`MASK = 10070`、`NAVBAR = 980`、`TOP_TIPS = 975`、`STICKY = 970`、`INDEX_LIST_STICKY = 965`，并提供 `of(name)` 按上游键名取值。`UPLegacyColor` 镜像上游为向后兼容保留的调色板，另导出 `UP_THEME_TYPES` 与 `UP_UPSTREAM_CONFIG_VERSION`。

## 边界

- **纯函数取代运行时读取**：上游 `timeFormat(null)`、`timeFrom(null)` 会读 `Date.now()` 当作「现在」。本端保持纯函数，`0` 就是 1970 起点，`timeFrom()` 的 `now` 由调用方传入；这是有意的口径差异，便于测试与跨设备一致。
- **`priceFormat` 的清洗字符类**：上游正则 `[^0-9+-Ee.]` 里 `+-E` 构成一个字符区间，会连带保留逗号等符号。本端逐字保留该字符类，因此像 `'1,234.56'` 这种已带千分位的输入在上游与本端都会落到 `0`；要格式化这类字符串需先去掉分隔符。
- **两种日期口径**：`upIsDate()` 沿用上游依赖 `Date` 溢出进位的宽松判定，`2024-02-30` 会通过；需要严格日历判定时用本端新增的 `upIsCalendarDate()`。
- **时区**：`UPFormat.partsOf()` / `timestampOf()` 按 UTC 计算。上游用本地时区的 `Date` 方法，因此同一时间戳在非 UTC 设备上的显示可能相差数小时；需要本地时区展示时由调用方先做偏移。
- **`UPMath` 的越界提示**：上游 `checkBoundary()` 用 `console.warn` 打印。本端改为返回布尔值并记录到 `UPMath.lastOverflow()`，不产生日志输出。
- **`UPFormat.queryParams()` 的入参形态**：ArkTS 不支持索引签名，无法接收任意键的对象，改为显式的 `Array<UPQueryEntry>`；数组项通过 `values` 字段传入，四种 `arrayFormat`（`indices` / `brackets` / `repeat` / `comma`）行为与上游一致。
- **`UPGradient.lightColor()` 的失败路径**：上游 `parseColorWithoutDOM()` 解析失败时抛异常，本端返回空串，由调用方决定回退色。
- **caller-owned 的 31 个上游导出**：`upGetRect`、`upCreateIntersectionObserver`、`sleep`、`os`、`sys`、`getWindowInfo`、`getDeviceInfo`、`random`、`guid`、`$parent`、`deepClone`、`deepMerge`、`shallowMerge`、`error`、`randomArray`、`toast`、`formValidate`、`getProperty`、`setProperty`、`page`、`pages`、`getValueByPath` 以及 `jsonString`、`array`、`object`、`func`、`promise`、`regExp` 等类型探测函数。它们依赖 uni-app 运行时（节点查询、全局事件、路由栈）或需要运行时反射与索引签名，在 ArkTS 里没有等价形态，属于 no-op 兼容位：不提供 ArkTS 入口，由宿主用平台 API 承担；`scripts/test_upstream_util_coverage.py` 把它们登记在 `PLATFORM_OWNED` 白名单里。
- **`libs/util/async-validator.js`（1343 行）与 `libs/i18n`**：表单校验器与国际化包不在本阶段范围。`UPForm` 目前只做确定性的存在性检查，复杂规则仍由调用方承担。
- 本阶段改动只使用 ArkTS 语言能力与本地计算，不使用 WebView、网络请求、运行时 JSON、Vue/NVue 或业务路由。

## 示例工程

新增 `Components Y` 分组与 `utils` 路由（`UtilsDemo`），示例路由数从 141 增至 142：

- 高精度运算段用两个输入框对照原生浮点加法与 `UPMath.plus`，并列出 `minus` / `times` / `divide` / `round` 的结果。
- 格式化段展示 `timeFormat` 的两种模板、`partsOf`、`priceFormat`、`durationText` / `durationValue`、`trim(all)`、`typeIcon` 与 `queryParams`。
- 校验段用单个输入框同时跑 7 个校验器，并标注 `upIsDate` 与 `upIsCalendarDate` 的口径差异。
- 颜色段用滑块调节 `gradient()` 的段数并实时渲染色带，另展示 `toHex` / `toRgbText` / `toRgba` / `lightColor`。
- 层级段列出 `UPZIndex` 常量与 `UPLegacyColor` 兼容主色，并说明它与组件默认主题主色的差异。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- 新增 `scripts/test_upstream_util_coverage.py`：解析上游 `libs/function/{test,digit,calc,index,colorGradient}.js` 的 `export function` 与 `libs/config/{zIndex,color}.js` 的常量表，逐项核对 ArkTS 对应符号，未映射或缺失即失败；`PLATFORM_OWNED` 白名单显式登记 caller-owned 导出。当前输出 `PASS (74 exports, 31 caller-owned)`。
- 新增 `scripts/test_phase_24_utility_contract.py`：锁定 5 个内核模块的导出符号、37 个静态成员、上游常量的逐字镜像、`UPMath` 的整数放大策略与越界检查、`UPFormat` 不读平台时钟、`UPValidate` 的两种日期口径，以及 Demo 与路由接线。
- 离线差分验证：用 `node --experimental-strip-types` 把四个内核模块与上游 JS 并排跑同一批样本比对，`UPMath`、`UPValidate`、`UPFormat`、`UPGradient`、`UPLayers` 五组全部输出 `parity: OK`（覆盖四则运算与舍入、15 类校验器、时间/价格/时长/查询串格式化、颜色互转与渐变、层级与调色板常量）。差异项已在「边界」里逐条记录，不计入失败。
- 既有 39 个契约脚本全部通过。
- HAR（`ultra_ui.har`）与示例 HAP（`entry-default-unsigned.hap`）已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包，无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时，设备验证结果记录为 `skipped`；静态契约与离线差分通过不等于设备验证通过。当前未宣称工具函数在真机上的数值精度、时区表现与 `UtilsDemo` 交互的设备验证完成；这些表现需在真机复核。
