# ultra-ui-hos 阶段 2B 头像与独立输入实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在阶段 2A 基线上新增头像、头像组、输入、文本域、开关、评分和步进器，并提供示例入口。

**Architecture:** 组件继续采用 ArkTS/ArkUI 原生实现；Props 类保存 uview-plus/Android/iOS 兼容字段，组件内部将非法值安全回退。输入类组件桥接系统 `TextInput`/`TextArea`，选择类组件通过明确的值事件回传；所有公共 API 统一从 `ultra-ui/Index.ets` 导出。

**Tech Stack:** HarmonyOS NEXT Stage 模型、ArkTS、ArkUI、DevEco Studio 6.1.1、Hvigor 6.24.1、HarmonyOS SDK API 24、HAR、HAP、Python 静态契约测试。

## Global Constraints

- 最低兼容 API 为 24；产品兼容/目标 SDK 为 `5.0.0(12)`。
- 包名保持 `@lingyun/ultra-ui-hos` 和 `net.lingyun.ultraui.hos.sample`。
- 示例只从 `@lingyun/ultra-ui-hos` 公共入口导入，不导入库内部文件。
- 不实现 WebView、FastView、JSON 动态渲染、网络请求、业务路由或运行时代码生成。
- 远程图片、网络地址和不适用的跨端能力必须安全回退或 no-op。

---

### Task 1: 失败契约测试

**Files:**
- Create: `scripts/test_form_entry_contract.py`

- [x] **Step 1: Write the failing test**
- [x] **Step 2: Run the test and confirm it fails because 2B sources are absent**

### Task 2: Implement avatar components

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPAvatar.ets`
- Create: `ultra-ui/src/main/ets/components/UPAvatarGroup.ets`
- Modify: `ultra-ui/Index.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Create: `sample/entry/src/main/ets/demos/AvatarDemo.ets`
- Create: `sample/entry/src/main/ets/demos/AvatarGroupDemo.ets`

- [x] **Step 1: Implement Props and deterministic local fallback rendering**
- [x] **Step 2: Export components, add routes and demos**
- [x] **Step 3: Run `python3 scripts/test_form_entry_contract.py`**

### Task 3: Implement input and textarea

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPInput.ets`
- Create: `ultra-ui/src/main/ets/components/UPTextarea.ets`
- Modify: `ultra-ui/Index.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Create: `sample/entry/src/main/ets/demos/InputDemo.ets`
- Create: `sample/entry/src/main/ets/demos/TextareaDemo.ets`

- [x] **Step 1: Implement controlled-compatible text state and typed callbacks**
- [x] **Step 2: Add clear/password/count/readonly/disabled presentation**
- [x] **Step 3: Export components, add routes and demos**
- [x] **Step 4: Run the 2B contract test and the sample contract**

### Task 4: Implement switch, rate and number box

**Files:**
- Create: `ultra-ui/src/main/ets/components/UPSwitch.ets`
- Create: `ultra-ui/src/main/ets/components/UPRate.ets`
- Create: `ultra-ui/src/main/ets/components/UPNumberBox.ets`
- Modify: `ultra-ui/Index.ets`
- Modify: `sample/entry/src/main/ets/catalog/SampleCatalog.ets`
- Modify: `sample/entry/src/main/ets/pages/SamplePage.ets`
- Create: `sample/entry/src/main/ets/demos/SwitchDemo.ets`
- Create: `sample/entry/src/main/ets/demos/RateDemo.ets`
- Create: `sample/entry/src/main/ets/demos/NumberBoxDemo.ets`

- [x] **Step 1: Implement safe value mapping and typed change events**
- [x] **Step 2: Implement rating and numeric boundary behavior**
- [x] **Step 3: Export components, add routes and demos**
- [x] **Step 4: Run all component/sample contracts**

### Task 5: Documentation and verification

**Files:**
- Modify: `README.md`
- Create: `docs/compatibility/phase-2b.md`
- Modify: `scripts/test_documentation_contract.py` if required by the new component list

- [x] **Step 1: Document 2B fields, fallback and device limits**
- [x] **Step 2: Run all Python contracts, boundaries, toolchain and screenshot script**
- [x] **Step 3: Run `./scripts/build.sh` and `git diff --check`**
- [x] **Step 4: Inspect HAR/HAP outputs and report exact verification evidence**
