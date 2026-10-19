# 阶段 28 兼容说明

阶段 28 复刻上游示例工程 `pages/template/*` 的业务样板页。此前示例 App 的组件示例部分已 100% 覆盖(144 条组件路由),但上游还有一组"用组件拼装业务场景"的模板页未搬。本阶段落地 9 个场景页,归入示例目录新分组 `Templates`,示例路由数从 144 增至 153。所有页面只用 `@lingyun/ultra-ui-hos` 公共入口,不引入业务路由与网络请求,仍面向 HarmonyOS NEXT API 24。

## 范围

| 路由 | 场景 | 上游来源 | 主要组件 |
| --- | --- | --- | --- |
| `tpl-login` | 登录页 | `template/login/index.vue` | `UPInput`、`UPButton`、`UPIcon`、`upIsMobile` |
| `tpl-pay` | 红包支付 | `template/keyboardPay/index.vue` | `UPKeyboard`、`UPMessageInput` |
| `tpl-submit-bar` | 商品操作栏 | `template/submitBar/index.vue` | `UPBadge`、`UPIcon` |
| `tpl-comment` | 评论列表 | `template/comment/index.vue` | `UPAvatar`、`UPIcon` |
| `tpl-order` | 订单列表 | `template/order/index.vue` | `UPTabs`、`UPLoadmore`、`UPIcon` |
| `tpl-coupon` | 优惠券 | `template/coupon/index.vue` | `UPCoupon`、`UPIcon` |
| `tpl-mine` | 个人中心 | `template/wxCenter/index.vue` | `UPAvatar`、`UPCellGroup`、`UPCell`、`UPIcon` |
| `tpl-mall` | 商城分类 | `template/mallMenu/index1.vue` | `UPIcon`（左右联动分类） |
| `tpl-address` | 地址管理 | `template/address/index.vue` + `addSite.vue` | `UPInput`、`UPTag`、`UPSwitch`、`UPButton`、`UPIcon` |

## 边界

- **业务路由改本地状态**:上游多处用 `uni.navigateTo`/`this.$u.route` 跳转子页（登录 → 验证码页、评论 → 全部回复页）。本端不引入业务路由,改为同页文案提示或内联展开(如地址新增改为内联表单而非独立页)。
- **远程图改占位**:上游模板用远程 CDN 图(头像、商品图、优惠券店铺图)。组件库不加载远程图,统一用文字头像(`UPAvatar` text)或图标/色块占位。
- **订单页的分页容器**:上游用 `swiper` + `scroll-view` 做状态分页与触底加载。本端用受控 `UPTabs` 切换本地数据集,底部 `UPLoadmore` 固定 `nomore`;不模拟真实分页请求。
- **图标字形对齐**:商城分类页上游用的 `grape`/`coffee` 图标不在本端固定字形表内,替换为存在的 `gift`/`shopping-cart`,避免渲染空白。
- **`UPSwitch` 回调**:用 `event.checked`(布尔)读取开关态,而非 `event.value`。
- **未复刻项**:`example/ad.vue`(广告页,含硬编码远程广告接口,禁网络边界外);`login/code.vue`(验证码输入子页,核心的 `UPCode` 倒计时能力已在组件 Demo 覆盖);`citySelect`(城市选择,与 `UPCityLocate` 组件 Demo 1:1 重复,不重复搬)。

## 验证

- 最低兼容 API：24；产品兼容/目标 SDK：`5.0.0(12)`。
- `scripts/test_sample_contract.py` 扩展:新增 `TEMPLATE_ROUTES` 表,校验 9 个模板路由在目录页登记、在分发页 `SamplePage` 有 case 分支、Demo 只用公共入口、不出现 `=> this.` 箭头体、无 `fetch(`/`http(s)://`/`navigateTo`。`Templates` 分组必须存在。
- 既有契约脚本全部通过；示例路由总数 153(144 组件 + 9 模板)。
- HAR 与示例 HAP 已通过 `./scripts/build.sh` 完成 ArkTS 编译与打包,无新增编译告警。
- 未连接 HarmonyOS 模拟器或真机时,设备验证结果记录为 `skipped`;这些模板页的真机布局、滚动与交互表现需在真机复核。
