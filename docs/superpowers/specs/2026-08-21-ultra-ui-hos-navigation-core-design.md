# ultra-ui-hos 导航核心组件设计

**状态：已确认设计，待实现计划**
**范围：** `UPNavbar`、`UPNavbarMini`、`UPStatusBar`、`UPSafeBottom`、`UPTabs`、`UPTabsItem`、`UPSubsection`、`UPSteps`、`UPStepsItem`

## 1. 目标与边界

本阶段为 HarmonyOS NEXT 原生 HAR 补齐 uview-plus 导航核心组件。公开字段、默认值、插槽意图和事件顺序优先对齐 uview-plus 3.x，同时保留 Android/iOS 生成端需要的同名 API。渲染使用 ArkUI 原生组件和本库已有的主题、单位、颜色、样式及 Builder 能力。

本阶段不引入 Vue/NVue、WebView、FastView、网络请求、远程资源、运行时代码生成或业务路由依赖。组件库不持有页面级导航状态；返回、重启首页和页面栈变更由调用方提供的适配器负责。

组件采用当前仓库的 `Options -> Props -> @Component` 结构。受控字段由页面状态持有，组件只根据 Props 渲染并通过回调提出变更请求。组件可以保存动画位置、组合期索引等短暂视觉状态，但不能以内部状态永久替代外部受控值。

## 2. 组件分批与实现顺序

实现分为三个可独立编译、测试和审查的子批次：

1. **系统区域与导航栏：** `UPStatusBar`、`UPSafeBottom`、`UPNavbar`、`UPNavbarMini`；
2. **标签导航：** `UPTabs`、`UPTabsItem`、`UPSubsection`；
3. **步骤导航：** `UPSteps`、`UPStepsItem`。

每个子批次先扩展静态契约使缺失 API 的测试失败，再增加上下文/组件实现、HAR 公共导出、中文示例路由和兼容文档。全部子批次完成后统一构建 HAR/HAP 并更新 README 统计。

## 3. 公共类型与架构

### 3.1 导航适配器

新增公共 `UPNavigationAdapter`：

```ts
export interface UPNavigationAdapter {
  navigateBack?: () => void;
  relaunch?: (url: string) => void;
}
```

`UPNavbarProps` 和 `UPNavbarMiniProps` 接收可选 `navigationAdapter`。适配器按组件实例传入，不写入全局可变配置，也不直接引用示例工程的 `NavPathStack`。

导航事件顺序固定如下：

- `UPNavbar` 左侧点击：先调用 `onLeftClick`，再在 `autoBack=true` 时调用 `navigationAdapter.navigateBack`；右侧点击只调用 `onRightClick`。
- `UPNavbarMini` 左侧点击：先调用 `onLeftClick`，再在 `autoBack=true` 时调用 `navigateBack`。
- `UPNavbarMini` 首页点击：先调用 `onHomeClick`，再在 `homeUrl` 非空时调用 `navigationAdapter.relaunch(homeUrl)`。
- 缺少适配器或对应方法时，点击回调仍正常触发，自动导航安全 no-op。

首页事件采用实用兼容语义：当前 uview-plus 版本声明了 `homeClick`，但实际实现只在 `homeUrl` 非空时调用 `uni.reLaunch`，没有 emit 该事件。鸿蒙版保留该导航行为并补发显式回调，兼容文档记录此修正。

### 3.2 Builder 映射

上游具名插槽映射为可选 Builder：

- Navbar：`leftBuilder`、`centerBuilder`、`rightBuilder`；
- NavbarMini：`leftBuilder`、`centerBuilder`；
- Tabs：`leftBuilder`、`rightBuilder`、`iconBuilder`、`contentBuilder`；
- Steps：`contentBuilder`；
- StepsItem：`iconBuilder`、`titleBuilder`、`descBuilder`、`contentBuilder`。

Builder 不存在时使用确定性的默认 ArkUI 内容。Builder 的参数使用强类型索引和条目数据，不暴露 Vue 原始 DOM 事件或内部上下文对象。

## 4. 系统区域与导航栏

### 4.1 `UPNavbar`

保留上游字段及默认值：

- `safeAreaInsetTop=true`、`placeholder=false`、`fixed=true`、`border=false`；
- `leftIcon='arrow-left'`、`leftText=''`、`rightText=''`、`rightIcon=''`；
- `title=''`、`titleColor=''`、`bgColor=''`、`statusBarBgColor=''`；
- `titleWidth='400rpx'`、`height='44px'`、`leftIconSize=20`、`leftIconColor=''`；
- `autoBack=false`、`titleStyle`、`customStyle`。

标题、左右区域和状态栏区域按上游的占位意图布局。`fixed=true` 只在组件当前布局边界内实现固定呈现；`placeholder=true` 同时保留包含状态栏区域的等高占位。`statusBarBgColor` 非空时用于状态栏区域，否则继承 `bgColor`。

### 4.2 `UPNavbarMini`

保留上游字段及默认值：`safeAreaInsetTop=true`、`fixed=true`、`leftIcon='arrow-leftward'`、`bgColor='rgba(0,0,0,.15)'`、`height='32px'`、`iconSize='20px'`、`iconColor='#fff'`、`autoBack=true`、`homeUrl=''`、`customStyle`。

默认呈现为左侧返回区域、分隔线和首页区域。`homeUrl` 为空时仍可由 Builder 呈现中心区域，但默认首页图标不触发自动重启。

### 4.3 `UPStatusBar`

`UPStatusBar` 保留 `bgColor='transparent'`、`height=0` 和 `customStyle`。`height=0` 表示使用系统顶部安全区，正数表示显式覆盖；最终高度通过 `onHeightChange` 回调报告。系统信息不可用时使用原生安全区能力或安全回退 `0`，不伪造设备尺寸。

### 4.4 `UPSafeBottom`

`UPSafeBottom` 保留 `safeAreaInsetBottom=true` 和 `customStyle`。启用时优先使用 ArkUI 原生底部安全区，关闭时不增加底部避让。该组件不自行改变窗口或滚动容器的行为。

## 5. Tabs 与 Subsection

### 5.1 `UPTabs`

定义显式 `UPTabsItemData`，至少支持 `name`、`disabled`、`icon`、`badge`，并允许通过 `keyName` 读取条目名称。保留字段：

`duration`、`list`、`lineColor`、`activeStyle`、`inactiveStyle`、`lineWidth`、`lineHeight`、`lineBgSize`、`itemStyle`、`scrollable`、`current`、`keyName`、`iconStyle`、`shapeMode`、`customStyle`。

`current` 完全受控。`scrollable=true` 使用横向 `Scroll`，选中项尽量滚动到可视区域中央；无法测量或没有滚动控制器时保持稳定可见渲染。`duration` 默认 `300ms`，非法值回退；`shapeMode` 支持默认、`capsule`、`card`、`pill-arrow`、`tag`，非法值回退默认形态。

点击事件严格保持上游顺序：

1. 所有标签先触发 `onClick({ item, index })`；
2. `item.disabled=true` 时立即结束；
3. 点击当前项时立即结束；
4. 调用 `onCurrentChange(index)`；
5. 调用 `onChange({ item, index })`。

长按触发 `onLongPress({ item, index })`，不改变选中值。鸿蒙版事件不携带 Vue 原始 DOM 事件。

### 5.2 `UPTabsItem`

上游 `u-tabs-item` 当前为无 Props 的内容容器，不参与 `u-tabs` 的索引登记。鸿蒙版保留 `customStyle` 和唯一内容 Builder，提供独立安全呈现；不会虚构父子选中协议，也不改变 `UPTabs` 的 list 驱动模型。

### 5.3 `UPSubsection`

定义 `UPSubsectionItem`，支持文本以及每项独立的激活色和非激活色。保留 `list`、`current`、`activeColor`、`inactiveColor`、`mode`、`fontSize`、`bold`、`bgColor`、`keyName`、`activeColorKeyName`、`inactiveColorKeyName`、`disabled`、`customStyle`。

`mode` 支持 `button`、`subsection`，非法值回退 `button`。激活滑块由受控 `current` 定位；颜色优先级为“条目颜色字段 > 组件颜色 > 主题默认值”。

点击顺序为：

1. `disabled=true` 时不触发任何事件；
2. 调用 `onCurrentChange(index)`；
3. 调用 `onChange(index)`。

与上游一致，点击当前项仍触发两个事件。空列表、越界索引和缺失文本使用安全确定性渲染，不偷偷向调用方写回修正值。

## 6. Steps 父子协调

### 6.1 `UPStepsContext`

新增内部 `UPStepsContext`，通过本地 ArkUI 上下文协调当前组合：

- 父级提供 `current`、`direction`、颜色、图标和 `dot`；
- 子项在组合期间登记索引；
- 父级 Props 变化时子项重新计算状态；
- 子项脱离父级时使用独立安全状态，不抛异常。

`UPSteps` 保留 `direction='row'`、`current=0`、`activeColor='#3c9cff'`、`inactiveColor='#969799'`、`activeIcon=''`、`inactiveIcon=''`、`dot=false` 和 `customStyle`。方向只支持 `row`、`column`，非法值回退 `row`。`current` 解析为非负索引，但越界不会自动回调修改页面状态。

### 6.2 `UPStepsItem`

保留 `title=''`、`desc=''`、`iconSize=17`、`error=false`、`itemStyle`、`customStyle`。子项点击只调用 `onClick(index)`，不自动推进 `current`。

状态计算如下：

- `finish`：`current > index` 且自身不出错；
- `process`：`current == index` 且自身不出错；
- `error`：自身 `error=true`，优先级高于完成和进行中；
- `wait`：其他情况。

呈现规则：

- `dot=true` 时使用状态色圆点；
- 配置任一父级图标时，按 `index <= current` 选择激活或非激活图标；
- 未配置图标时，`process`/`wait` 显示序号，`finish` 显示完成图标，`error` 显示错误图标；
- 非最后一个子项显示连接线；后继子项出错时使用错误色，当前项之前使用激活色，其他情况使用非激活色。

横向布局使用稳定的等比分配，纵向布局让连接线随内容区域延展；无法取得动态尺寸时采用稳定最小尺寸，避免布局跳动。

## 7. 兼容降级与非目标

- `position: fixed`、安全区高度、滚动居中和动态连接线尺寸受 HarmonyOS API 24 能力限制时，使用确定性原生近似并在兼容文档逐项记录。
- `lineBgSize` 及字符串样式只在已有 `UPStyle` 支持范围内生效，不解析任意 CSS。
- 动画只影响视觉位置，不改变事件顺序和受控值；无法执行时退化为无动画静态位置。
- Navbar 自动返回和 Mini 首页重启不绑定具体应用路由；没有适配器时安全 no-op。
- 本阶段不新增通用滚动控制器、全局窗口服务、页面路由抽象或动态 CSS 解释器。

## 8. 示例工程

新增九条中文示例路由：`navbar`、`navbar-mini`、`status-bar`、`safe-bottom`、`tabs`、`tabs-item`、`subsection`、`steps`、`steps-item`。

示例从 HAR 公共入口导入组件，不访问内部上下文。Navbar 示例注入基于页面 `NavPathStack` 的适配器，分别展示点击回调和自动导航；Tabs 展示受控切换、禁用项 click、长按、滚动和非滚动模式；Subsection 展示两种模式、条目级颜色和禁用状态；Steps 展示横向、纵向、dot、自定义图标、错误状态和 Builder 内容。独立 item 示例展示脱离父组件时的安全呈现。

README 统计在本阶段完成后从 54 个组件/控制器、52 条示例路由更新为 **63 个组件/控制器、61 条示例路由**。

## 9. 测试与验收

新增 `scripts/test_phase_5_navigation_contract.py`，静态检查：

- 九个组件、Props/Options、事件类型和 HAR 公共导出；
- `UPNavigationAdapter` 与 `UPStepsContext`；
- Navbar、Tabs、Subsection 的事件调用顺序；
- Tabs/Steps Builders、默认值和安全回退；
- 九条示例路由、兼容文档和 README 计数；
- 禁止 WebView、Vue/NVue、网络、远程资源、运行时代码生成和示例内部导入。

最终验证执行：

```bash
for f in scripts/test_*.py; do python3 "$f" || exit 1; done
./scripts/verify-boundaries.sh
./scripts/verify-toolchain.sh
./scripts/capture-screenshots.sh
./scripts/build.sh
git diff --check
```

无连接 HarmonyOS 真机或模拟器时，设备安装、渲染、点击、长按、滚动、动画、安全区和真实导航验证必须明确报告为 `skipped`；HAR/HAP 构建成功和静态契约通过不能替代设备验收。
