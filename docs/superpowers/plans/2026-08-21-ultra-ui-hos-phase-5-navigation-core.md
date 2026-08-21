# ultra-ui-hos Phase 5 导航核心实现计划

> 目标：在不改变现有阶段实现的前提下，为 HarmonyOS NEXT 原生 HAR 增加导航核心九组件及对应示例。

## 任务 1：系统区域与导航栏

- [ ] 扩展静态契约，先确认 `UPStatusBar`、`UPSafeBottom`、`UPNavbar`、`UPNavbarMini` 的公共 API、默认值和导航事件顺序。
- [ ] 新增 `UPNavigationAdapter`，以实例级可选适配器承接返回和重启首页，不依赖示例路由。
- [ ] 实现四个组件、公共入口导出和四条中文示例路由。
- [ ] 运行 Phase 5 契约、边界检查和 `git diff --check`。

## 任务 2：标签导航

- [ ] 扩展契约，锁定 `UPTabs`、`UPTabsItem`、`UPSubsection` 的受控字段、Builder、禁用项和事件顺序。
- [ ] 新增 `UPTabsContext`，在组合期登记条目并协调受控索引、滚动居中和内容 Builder。
- [ ] 实现三个组件、三个示例路由及公共导出。
- [ ] 运行专项契约并检查示例仅通过 HAR 公共入口导入。

## 任务 3：步骤导航

- [ ] 扩展契约，锁定 `UPStepsContext`、状态计算、方向回退、连接线和 Builder API。
- [ ] 实现 `UPSteps`、`UPStepsItem`、两个示例路由及公共导出。
- [ ] 写入阶段兼容说明，记录安全区、固定定位、动态尺寸和设备验证降级。

## 任务 4：全量验证与交付

- [ ] 更新 README 的组件和示例路由统计到 63/61。
- [ ] 执行全部 Python 契约、边界检查、工具链检查、截图脚本、HAR/HAP 构建和空白检查。
- [ ] 复核工作区，仅保留本阶段必要变更；无设备时明确报告设备验证为 `skipped`。
