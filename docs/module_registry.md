﻿﻿﻿﻿# 功能模块永久文档

> 目的: 记录每个功能模块的前端、后端、API、缓存和构建依赖，避免后续修改单个模块时误伤已完成的模块。
>
> 使用方式:
> - 新增或修改模块前，先查本文件对应小节。
> - 涉及接口、字段、缓存、配置项时，优先同步更新这里。
> - 本文件作为长期维护说明，尽量保持和当前代码一致。
>
> 编号说明:
> - 一级模块编号以功能为主，可能因历史插入导致物理位置不完全按数字顺序排列。
> - 以 `## N.` 作为模块边界，`### N.x` 作为该模块子项。
>
> 推荐阅读顺序:
> - 先看 `docs/project_context.md`，确认全局硬规则。
> - 再看本文件的「索引（按主题）」找到对应模块。
> - 最后进入具体 `## N.` 小节和代码实现。

## 快速入口

下面这些模块最常见，也最容易影响全局口径，建议优先关注：

- `0` 投资认购签约复用
- `1` 每日签到
- `2` 个人信息
- `3` 实名认证
- `5` 充值
- `6` 我的资产
- `7` 银行卡
- `8` 注册
- `10` 资讯中心 / 新闻
- `13` 投资产品与券体系（后台）
- `16` 投资展示与在线签约（APP）
- `21` 参数类型增强（后台与APP配置）
- `24` 产品投资模式升级（按金额/按份额）
- `48` 真实姓名字段打通
- `54` APP配置新增真实拼团开关
- `69` 首页改版与APP广告管理
- `77` 首页聚合接口与运营位联动
- `78` 新闻分类类型隔离（NEWS 与 首页运营位）

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 0. 投资认购签约复用（新增）

### 模块说明

- 认购流程新增“同用户同产品已签约复用”能力：若已存在有效签约记录，再次认购无需重复手写签名与勾选合同。

### 后端改动

- `AppInvestOrderController.previewContract` 返回 `signedBefore` 字段，供前端决定是否展示签约弹窗。
- `AppInvestOrderController.submit` 增加签约复用逻辑：
  - 若存在该用户该产品的有效签约记录，则允许本次提交不传签名；
  - 若本次未传 `signatureData`，自动复用历史签名；
  - 仍保留支付密码校验与订单幂等逻辑。
- `SysAppInvestOrderMapper` 新增 `selectLatestValidContractSign(userId, productId)` 查询。

### 前端改动

- `InvestOrderApi.previewContract` 解析 `signedBefore`。
- `InvestPurchasePage` 在 `signedBefore=true` 时跳过合同签约弹窗，直接走支付提交；未签约用户保持原先签约流程。


## 1. 每日签到

### 1.1 模块目标

每日签到支持两种奖励方式:

- 积分奖励
- 现金奖励

支持连续签到奖励规则，按天数命中对应档位发奖。

### 1.2 前端文件

APP 侧主要文件:

- [app/lib/pages/mine/sign_page.dart](../app/lib/pages/mine/sign_page.dart)
- [app/lib/request/sign_api.dart](../app/lib/request/sign_api.dart)
- [app/lib/tools/sign_cache_tool.dart](../app/lib/tools/sign_cache_tool.dart)
- [app/lib/tools/sign_config_cache_tool.dart](../app/lib/tools/sign_config_cache_tool.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `SignPage` 负责页面渲染、签到提交、签到状态展示、连续签到奖励展示。
- `SignApi` 负责签到接口请求和签到配置请求。
- `SignCacheTool` 负责按 `userId + day` 缓存当日签到状态。
- `SignConfigCacheTool` 负责缓存签到配置，避免每次进入页面都重新拉取。

### 1.3 后端文件

APP 签到接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppSignController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppSignController.java)

签到业务实现:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserSignServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserSignServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserSignService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserSignService.java)

签到流水相关:

- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserSignLogMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserSignLogMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserSignLogMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserSignLogMapper.xml)

后端职责:

- `AppSignController` 对外提供签到配置、签到状态、提交签到三个接口。
- `SysUserSignServiceImpl` 负责连续签到计算、奖励发放、签到流水落库、缓存读写。
- 奖励类型为现金时，写入钱包流水；奖励类型为积分时，写入积分账户。

### 1.4 API 说明

#### 1.4.1 获取签到配置

```http
GET /app/sign/config
```

返回字段:

- `rewardType`: `POINT` 或 `MONEY`
- `rewardAmount`: 首日基础奖励金额
- `continuousRewardRule`: 连续签到规则 JSON 字符串

#### 1.4.2 获取签到状态

```http
GET /app/sign/status
```

返回字段:

- `signedToday`: 今日是否已签到
- `consecutiveDays`: 连续签到天数
- `rewardType`: 奖励类型
- `rewardAmount`: 当前档位奖励
- `rewardLabel`: 奖励文案
- `records`: 最近签到记录

#### 1.4.3 提交签到

```http
POST /app/sign/submit
```

返回字段:

- `signedToday`
- `consecutiveDays`
- `rewardType`
- `rewardAmount`
- `rewardLabel`
- `records`

### 1.5 配置项

签到相关系统配置只读这三项:

- `app.sign.rewardType`
- `app.sign.rewardAmount`
- `app.sign.continuousRewardRule`

说明:

- 这三项已经从 APP 基础 bootstrap 中拆出。
- 签到页应单独请求 `/app/sign/config`，不要再塞回通用 APP 配置基础包。
- 连续签到规则建议保存为紧凑 JSON 数组，例如:

```json
[
  {"day": 1, "amount": 300},
  {"day": 2, "amount": 320}
]
```

### 1.6 缓存策略

APP 本地缓存:

- `sign.today.{userId}.{yyyyMMdd}`: 当日签到状态
- `sign.config.v1`: 签到配置

后端缓存:

- 签到状态和签到配置都应避免重复请求。
- 签到提交成功后，前端应更新本地状态，不要依赖再次完整刷新才显示结果。

### 1.7 业务规则

- 同一天只能签到一次。
- 连续签到天数按最近签到日期推算。
- 奖励类型为 `MONEY` 时，发放到可用余额。
- 奖励类型为 `POINT` 时，发放到积分账户。
- 连续签到规则命中逻辑按天数从小到大取最近档位。
- 日期和奖励金额都必须做统一格式化，避免前后端显示不一致。

### 1.8 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 端验证建议:

- 进入签到页确认配置拉取正常。
- 连续签到规则展示与后台参数一致。
- 签到后刷新状态、缓存和历史记录都能同步更新。

### 1.9 修改清单

修改签到模块时，至少检查下面几处是否同步:

1. `AppSignController`
2. `SysUserSignServiceImpl`
3. `sign_page.dart`
4. `sign_api.dart`
5. `sign_cache_tool.dart`
6. `sign_config_cache_tool.dart`
7. `zh-CN.json`
8. `en-US.json`
9. 数据库 `sys_config` 中的签到配置项

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 2. 个人信息

### 2.1 模块目标

个人信息模块用于展示和编辑当前登录用户的基础资料，核心包含：

- 头像上传与裁剪
- 昵称修改
- 用户名查看
- 用户ID复制
- 手机号修改
- 邮箱修改
- 生日选择
- 性别选择
- 邀请码查看与复制
- 实名状态、支付密码状态等派生信息展示

### 2.2 前端文件

APP 侧主要文件:

- [app/lib/pages/mine/profile_page.dart](../app/lib/pages/mine/profile_page.dart)
- [app/lib/pages/mine/avatar_crop_page.dart](../app/lib/pages/mine/avatar_crop_page.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/tools/auth_tool.dart](../app/lib/tools/auth_tool.dart)
- [app/lib/widgets/app_network_image.dart](../app/lib/widgets/app_network_image.dart)
- [app/lib/widgets/app_image_cache.dart](../app/lib/widgets/app_image_cache.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `ProfilePage` 负责个人信息展示、编辑、头像上传、生日选择、性别弹窗和本地缓存同步。
- `AvatarCropPage` 负责头像裁剪，当前为 Flutter 自绘裁剪页，不依赖原生 uCrop toolbar。
- `AuthApi.getInfo()` 负责拉取服务端个人信息并写入本地缓存。
- `AuthTool` 负责 token、用户信息、支付密码是否设置等本地缓存。

### 2.3 后端文件

个人资料接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java)

后端用户服务:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java)

用户缓存/登录态相关:

- [ruoyi-framework/src/main/java/com/ruoyi/framework/security/service/TokenService.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/security/service/TokenService.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)

### 2.4 API 说明

#### 2.4.1 获取当前登录用户信息

```http
GET /getInfo
```

返回字段重点包含:

- `user.userId`
- `user.userName`
- `user.nickName`
- `user.avatar`
- `user.email`
- `user.phonenumber`
- `user.sex`
- `user.birthday`
- `user.remark`
- `user.inviteCode`
- `user.payPasswordSet`
- `roles`
- `permissions`

说明:

- 前端个人信息页优先使用本地缓存。
- 当本地缓存缺失、过期或手动刷新时，再请求 `getInfo`。
- 如果昵称为空，前端显示默认文案“用户”。

#### 2.4.2 更新个人资料

```http
PUT /system/user/profile
```

支持字段:

- `nickName`
- `email`
- `phonenumber`
- `sex`
- `birthday`
- `avatar`
- `remark`

说明:

- 接口支持普通 JSON，也支持加密包裹体 `data`。
- 保存成功后后端会同步刷新登录缓存。
- 如果带了 `avatar`，会同步更新 `sys_user.avatar`。

#### 2.4.3 上传头像

```http
POST /system/user/profile/avatar
```

请求体:

- `avatarfile`：MultipartFile

返回字段:

- `imgUrl`
- `avatar`

说明:

- 头像上传后前端会先裁剪，再上传。
- 后端保存成功后会同步更新头像字段并刷新登录缓存。

### 2.5 缓存策略

APP 本地缓存:

- `auth.token`: 登录 token
- `auth.userProfile`: 当前用户资料
- `auth.userProfile.updatedAt`: 用户资料更新时间
- `auth.payPasswordSet`: 支付密码是否设置

缓存行为:

- APP 启动时如果已登录，会静默刷新一次 `getInfo` 并覆盖本地缓存。
- 进入个人信息页时，会优先显示本地缓存，再后台静默刷新。
- 修改昵称、头像、手机号、邮箱、生日、性别后，页面先本地回填，再异步刷新服务端数据。
- 多端同时登录时，下一次启动或进入资料页会同步最新个人资料。

### 2.6 业务规则

- 昵称为空时，前端默认显示“用户”。
- 用户名只读，不允许前端修改。
- 用户ID只读，支持复制。
- 生日使用日期选择器，不用手工文本输入。
- 头像支持裁剪后上传，裁剪结果由 Flutter 自绘裁剪页产出。
- 性别枚举目前按前端约定展示。
- `getInfo` 返回的派生字段，如 `payPasswordSet`，必须和后端用户状态同步。

### 2.7 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 端验证建议:

- 进入个人信息页，确认昵称、用户名、用户ID、手机号、邮箱、生日、性别都能正常显示。
- 修改昵称后，退出再进页面，确认本地缓存和服务端一致。
- 上传头像后，确认后端头像字段和 `getInfo` 返回值都已更新。
- 多台设备同时登录时，确认一台修改后，另一台下次进入页面可同步最新值。

### 2.8 修改清单

修改个人信息模块时，至少检查下面几处是否同步:

1. `SysProfileController`
2. `SysLoginController.getInfo`
3. `SysUserServiceImpl`
4. `AuthApi.getInfo`
5. `AuthApi.updateProfile`
6. `AuthTool.saveUserProfile`
7. `ProfilePage`
8. `AvatarCropPage`
9. `zh-CN.json`
10. `en-US.json`
11. `SysUserMapper.xml` 中对应字段映射

### 2.9 2026-05-02 性能优化记录（个人信息提交慢）

问题现象：

- APP 端在个人信息页修改昵称、手机号、邮箱、生日、性别、头像后，成功提示出现较慢。
- 一次提交链路中存在重复查询和重复请求，导致体感延迟偏高。

本次优化：

1. 后端 `PUT /system/user/profile` 成功后不再执行重型用户重查（`selectUserById`），改为直接使用当前更新后的 `LoginUser.user` 回写登录缓存。
2. 后端手机号/邮箱唯一性校验改为“仅当值发生变化时才查重”，避免无变化也访问数据库。
3. 头像上传成功后直接更新当前登录态中的 `avatar` 并刷新 token 缓存，不再额外触发全量资料重查。
4. 前端 `ProfilePage` 去掉保存成功后的立即 `getInfo(forceRefresh)`，改为本地 patch + 本地缓存更新，减少一次网络往返。

涉及文件：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java)
- [app/lib/pages/mine/profile_page.dart](../app/lib/pages/mine/profile_page.dart)

回归验证要点（必须）：

- 修改昵称/手机号/邮箱/生日/性别后，响应时间应明显下降，且值不回退。
- 上传头像后，接口返回成功时页面头像立即更新，重新进页仍是新头像。
- 后端日志中，`PUT /system/user/profile` 成功后不应再紧跟一次重型 `selectUserById` 用于刷新缓存。
- 多端登录场景下，另一端在下次进入资料页或下次启动时仍能同步最新资料。

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 3. 实名认证

### 3.1 模块目标

实名认证模块用于管理用户真实姓名、身份证信息、手持证件照片及审核状态。

核心流程:

- APP 端提交实名认证资料
- 后端落库实名认证申请
- 后台管理页审核通过或驳回
- 用户表 `sys_user.real_name_status` 跟随审核结果同步

### 3.2 前端文件

APP 端主要文件:

- [app/lib/pages/mine/real_name_auth_page.dart](../app/lib/pages/mine/real_name_auth_page.dart)
- [app/lib/pages/mine/real_name_auth_controller.dart](../app/lib/pages/mine/real_name_auth_controller.dart)
- [app/lib/pages/mine/security_center_page.dart](../app/lib/pages/mine/security_center_page.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/request/real_name_api.dart](../app/lib/request/real_name_api.dart)
- [app/lib/tools/auth_tool.dart](../app/lib/tools/auth_tool.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `RealNameAuthPage` 负责实名认证资料填写、图片选择、提交前校验与结果提示。
- `RealNameAuthController` 负责拉取实名状态、提交实名申请、提交成功后的本地状态同步。
- `RealNameApi` 负责实名认证状态/提交接口请求。
- `AuthTool` 负责缓存个人资料与登录态，实名提交后会把本地缓存状态立即置为“待审核”，进入实名页拉取到新状态后若与本地缓存不一致会立即同步更新。
- 实名页提交前必须校验:
  - 姓名不能为空
  - 身份证号不能为空
  - 身份证正反面图片不能为空
  - 若后台配置要求手持身份证，则必须补充手持照

### 3.3 后端文件

APP 实名接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppAuthController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppAuthController.java)

后台实名认证审核:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysAppRealNameAuthController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysAppRealNameAuthController.java)

实名认证业务实现:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysAppRealNameAuthServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysAppRealNameAuthServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysAppRealNameAuthService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysAppRealNameAuthService.java)

用户资料与实名状态相关:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)

实名认证申请表:

- [ruoyi-system/src/main/resources/mapper/system/SysAppRealNameAuthMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppRealNameAuthMapper.xml)

### 3.4 API 说明

#### 3.4.1 获取实名状态

```http
POST /app/auth/realName/status
```

返回字段:

- `handheldRequired`: 是否要求手持身份证
- `status`: 当前用户实名状态
- `latestAuth`: 最近一次实名申请记录

#### 3.4.2 提交实名申请

```http
POST /app/auth/realName/submit
```

请求字段:

- `realName`
- `idCardNumber`
- `idCardFront`
- `idCardBack`
- `handheldPhoto`

说明:

- 接口同时支持明文 JSON 和 `data` 加密包裹体。
- 提交成功后，实名认证申请表写入一条待审核记录。
- 同时会把用户表实名状态同步到“待审核”类状态。

#### 3.4.3 后台实名列表

```http
GET /system/realNameAuth/list
```

#### 3.4.4 后台实名审核

```http
PUT /system/realNameAuth
```

#### 3.4.5 后台实名详情

```http
GET /system/realNameAuth/{authId}
```

#### 3.4.6 后台实名删除

```http
DELETE /system/realNameAuth/{authIds}
```

### 3.5 状态同步规则

实名状态的写入只允许来自以下路径:

- `AppAuthController.submitRealName`
- `SysAppRealNameAuthServiceImpl.insertAuth`
- `SysAppRealNameAuthServiceImpl.updateAuth`
- `SysAppRealNameAuthServiceImpl.deleteAuthById`
- `SysAppRealNameAuthServiceImpl.deleteAuthByIds`
- `SysUserServiceImpl.updateUserRealNameStatus`

关键规则:

- 实名申请提交时，会新建申请单并同步用户实名状态。
- 后台审核通过或驳回时，会根据审核结果同步用户实名状态。
- 删除实名申请时，会把用户实名状态回退到初始值。
- 个人资料保存 `updateUserProfile` 只允许改昵称、邮箱、手机号、头像、生日、性别等基础资料，**不能**回写 `real_name_status`。

### 3.6 缓存与同步

- 实名申请本身不依赖独立 Redis 业务缓存。
- 用户表实名状态的变化会通过 `userApiService.evictUserCache(userId)` 清理用户缓存。
- APP 端提交实名认证成功后，必须先把本地缓存的 `realNameStatus` 立即更新为 `1`（待审核），避免等待后端审核状态回写前页面仍显示“未实名”。
- APP 端进入实名页时，必须拉取 `POST /app/auth/realName/status`；若拉取到的 `status` 与本地缓存 `realNameStatus` 不一致，立即以服务端返回为准覆盖本地缓存。
- 个人资料页保存成功后，必须重新拉 `getInfo`，避免本地缓存仍显示旧实名状态。

### 3.7 业务规则

- 已审核通过的实名状态不能在个人资料编辑中被重置。
- 个人资料更新接口不得接收或写回 `realNameStatus`。
- 审核状态变更应只由实名认证审核流程驱动，不应由普通资料编辑驱动。
- 图片字段需要在前端提交前做完整性校验，缺少正反面或手持照时要明确提示。

### 3.8 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

建议验证点:

- 提交实名申请后，数据库申请表和用户表实名状态都同步变化。
- 后台审核通过后，用户表实名状态保持不被个人资料修改覆盖。
- 修改昵称、头像、手机号等资料时，实名状态不会回退。

### 3.9 修改清单

修改实名认证模块时，至少一起检查以下文件:

1. `AppAuthController`
2. `SysAppRealNameAuthController`
3. `SysAppRealNameAuthServiceImpl`
4. `SysUserServiceImpl`
5. `SysUserMapper.xml`
6. `real_name_auth_page.dart`
7. `auth_api.dart`
8. `auth_tool.dart`
9. `zh-CN.json`
10. `en-US.json`

## 4. 邀请好友

### 4.1 模块目标

邀请好友模块用于展示用户邀请码、生成邀请二维码、展示返佣规则，并提供 Android / iOS 下载入口。

核心流程:

- APP 端从当前登录用户信息中读取邀请码
- APP 端从升级配置接口读取邀请二维码内容和下载地址
- APP 端从基础配置读取返佣规则
- 用户可复制邀请码或扫码邀请好友

### 4.2 前端文件

APP 端主要文件:

- [app/lib/pages/mine/invite_friend_page.dart](../app/lib/pages/mine/invite_friend_page.dart)
- [app/lib/request/upgrade_api.dart](../app/lib/request/upgrade_api.dart)
- [app/lib/request/app_config_api.dart](../app/lib/request/app_config_api.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `InviteFriendPage` 负责邀请码展示、二维码展示、复制邀请码、下载按钮展示。
- `UpgradeApi` 负责单独请求升级配置，用于获取二维码内容与下载地址。
- `AuthApi.getInfo()` 负责获取当前登录用户的邀请码。
- `AppBootstrapTool.config.inviteRewardRules` 负责提供返佣规则配置。
- 二维码使用 `PrettyQrView.data` 在客户端直接渲染，不再依赖服务端生成图片。

### 4.3 后端文件

当前邀请好友模块涉及的后端文件:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppUpgradeController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppUpgradeController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInviteController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInviteController.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserApiServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserApiServiceImpl.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)

说明:

- `SysLoginController.getInfo()` 返回当前用户 `inviteCode`，邀请页直接取这个值。
- `AppUpgradeController` 提供独立升级配置接口，返回 `appUrl`、`androidApkUrl`、`iosInstallUrl` 等字段。
- `AppConfigController` 负责提供 `inviteCodeEnabled`、`inviteRewardRule` 等基础配置。
- `AppInviteController` 仍保留二维码生成接口，可作为兼容或其他场景复用，但当前邀请页主要使用客户端二维码渲染。
- `SysUserApiServiceImpl` 对邀请码建立缓存索引，避免邀请码查询重复打库。

### 4.4 API 说明

#### 4.4.1 获取当前用户信息

```http
GET /getInfo
```

重点返回字段:

- `user.inviteCode`
- `user.nickName`
- `user.avatar`
- `user.userId`

#### 4.4.2 获取升级配置

```http
GET /app/upgrade/config
```

返回字段重点:

- `appUrl`
- `androidApkUrl`
- `iosInstallUrl`
- `releaseNote`
- `forceUpgrade`

#### 4.4.3 获取 APP 基础配置

```http
GET /app/config/bootstrap
```

当前邀请模块会读取:

- `inviteCodeEnabled`
- `inviteRewardRule`

#### 4.4.4 二维码生成接口

```http
POST /app/invite/qr
```

说明:

- 当前 APP 邀请页以客户端二维码为主。
- 该接口保留用于兼容或其他端生成二维码的场景。

### 4.5 配置项

邀请好友相关配置主要有:

- `app.feature.inviteCodeEnabled`
- `app.invite.rewardRule`

说明:

- `inviteCodeEnabled` 控制注册页是否显示邀请码输入框。
- `inviteRewardRule` 采用 JSON 字符串存储，前端解析后展示为三级返佣规则。
- 二维码内容不再从基础配置中取，而是从升级配置 `appUrl` 推导。

### 4.6 缓存策略

APP 本地缓存:

- `auth.userProfile` 中保存用户邀请码和基础资料
- `app.bootstrap.config.v2` 中保存邀请返佣规则与基础 APP 配置

后端缓存:

- 用户邀请码查询走 `SysUserApiServiceImpl` 的缓存索引，减少重复查询。
- 升级配置与基础配置会走各自独立的配置缓存。

缓存行为:

- 进入邀请页时，先读取本地用户缓存，再必要时请求 `getInfo`。
- 邀请规则为空时，前端会回退到默认三级规则，保证页面不空白。
- 下载地址与二维码内容以升级接口返回为准，避免与基础配置耦合。

### 4.7 业务规则

- 邀请码只读，前端不允许修改。
- 邀请码为空时前端显示 `--`。
- 二维码内容优先使用 `appUrl`，如果为空再回退到 `androidApkUrl`，最后回退到 `iosInstallUrl`。
- 返佣规则展示顺序按层级排序，默认三层规则为 5%、3%、2%。
- 邀请页下载按钮应始终与升级配置保持一致。

### 4.8 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 端验证建议:

- 进入邀请页，确认邀请码、二维码、返佣规则、下载按钮都正常显示。
- 切换升级配置后，确认二维码内容与下载地址同步更新。
- 修改返佣规则后，确认邀请页能按最新 JSON 规则展示。
- 邀请码为空时，页面应显示占位符而不是报错。

### 4.9 修改清单

修改邀请好友模块时，至少一起检查以下文件:

1. `InviteFriendPage`
2. `UpgradeApi`
3. `AuthApi.getInfo`
4. `AppBootstrapTool`
5. `SysLoginController.getInfo`
6. `AppUpgradeController`
7. `AppConfigController`
8. `AppInviteController`
9. `SysUserApiServiceImpl`
10. `SysUserMapper.xml`
11. `zh-CN.json`
12. `en-US.json`

## 5. 充值

### 5.1 模块目标

充值模块用于提交用户充值申请，并在后台审核通过后把金额写入对应币种钱包。

核心流程:

- APP 端填写充值金额并选择充值币种 / 充值方式
- 后端生成充值申请单，状态默认为待审核
- 后台审核通过后，金额写入用户钱包可用余额和充值总额
- 后台审核驳回后，订单保留驳回原因，钱包不变

### 5.2 前端文件

APP 端主要文件:

- [app/lib/pages/mine/recharge_page.dart](../app/lib/pages/mine/recharge_page.dart)
- [app/lib/request/recharge_api.dart](../app/lib/request/recharge_api.dart)
- [app/lib/request/ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `RechargePage` 负责金额输入、预设金额选择、币种选择、充值方式选择和提交。
- `RechargeApi` 负责提交充值单和获取我的充值列表。
- `AppBootstrapTool.config.investCurrencyMode` 决定当前是单币种还是双币种充值模式。
- 金额输入支持预设金额和自定义金额两种方式。

### 5.3 后端文件

APP 充值接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppRechargeController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppRechargeController.java)

充值业务实现:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserRechargeServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserRechargeServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserRechargeService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserRechargeService.java)

后台充值审核:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserRechargeController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserRechargeController.java)

相关钱包处理:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletLogServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletLogServiceImpl.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserRechargeMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserRechargeMapper.xml)

### 5.4 API 说明

#### 5.4.1 提交充值申请

```http
POST /app/recharge/submit
```

请求字段:

- `amount`
- `currencyType`
- `rechargeMethod`
- `remark`

说明:

- 接口同时支持明文 JSON 和 `data` 加密包裹体。
- `amount` 必须大于 0。
- 双币种模式下，`currencyType` 和 `rechargeMethod` 需要与所选币种一致。
- 充值申请默认进入待审核状态。

#### 5.4.2 获取充值列表

```http
GET /app/recharge/list
```

返回字段重点包含:

- `orderNo`
- `currencyType`
- `rechargeMethod`
- `amount`
- `status`
- `rejectReason`
- `submitTime`

#### 5.4.3 后台充值列表

```http
GET /system/recharge/list
```

#### 5.4.4 后台充值审核

```http
PUT /system/recharge
```

#### 5.4.5 后台充值详情

```http
GET /system/recharge/{rechargeId}
```

#### 5.4.6 后台充值删除

```http
DELETE /system/recharge/{rechargeIds}
```

### 5.5 配置项

充值模块依赖的主要配置:

- `app.currency.investMode`
- `app.currency.supportRmbToUsd`
- `app.currency.usdRate`

说明:

- `investMode = 1` 时表示单币种，仅显示人民币充值。
- `investMode = 2` 时表示双币种，同时显示人民币和 USDT 充值入口。

### 5.6 缓存策略

APP 本地缓存:

- 充值页不单独维护复杂缓存，主要依赖当前登录态和 bootstrap 配置。
- 充值列表可以按需分页请求，不建议一次性拉全量。

后端缓存:

- 充值申请入库后，通过钱包服务和通知服务驱动状态变化。
- 审核通过后，钱包余额和充值总额需要同步更新。

### 5.7 业务规则

- 充值金额必须大于 0。
- 单币种模式下，充值币种和方式强制固定为人民币充值。
- 双币种模式下，充值币种和方式必须与选择一致。
- 充值申请创建后状态为待审核，审核通过后才入账。
- 审核通过时只影响钱包可用余额和充值总额，不应影响其他资产状态。

### 5.8 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 端验证建议:

- 预设金额点击后，输入框应同步显示对应金额。
- 自定义金额输入后，提交前应正确解析为正数。
- 双币种模式下，人民币 / USDT 两个入口都能正确提交。
- 充值列表能正常显示待审核、通过、驳回状态。

### 5.9 修改清单

修改充值模块时，至少一起检查以下文件:

1. `RechargePage`
2. `RechargeApi`
3. `AppRechargeController`
4. `SysUserRechargeServiceImpl`
5. `SysUserRechargeController`
6. `SysUserRechargeMapper.xml`
7. `SysUserWalletServiceImpl`
8. `SysUserWalletLogServiceImpl`
9. `AppBootstrapTool`
10. `zh-CN.json`
11. `en-US.json`

## 6. 我的资产

### 6.1 模块目标

我的资产模块用于展示用户当前钱包资产概览，包括可投资产、可用余额、冻结金额、收益、充值和提现累计等信息。

核心展示内容:

- 总资产
- 可投资产
- 可用余额
- 冻结金额
- 收益金额
- 充值累计
- 提现累计
- 双币种钱包切换

### 6.2 前端文件

APP 端主要文件:

- [app/lib/pages/mine/assets_page.dart](../app/lib/pages/mine/assets_page.dart)
- [app/lib/request/withdraw_api.dart](../app/lib/request/withdraw_api.dart)
- [app/lib/request/recharge_api.dart](../app/lib/request/recharge_api.dart)
- [app/lib/request/app_config_api.dart](../app/lib/request/app_config_api.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `AssetsPage` 负责资产首页展示、钱包切换、详情弹窗和空态处理。
- `WithdrawApi.getWallets()` 负责拉取钱包列表。
- `RechargeApi` 与提现页共享钱包口径，用于展示充值 / 提现对资产的影响。
- `AppBootstrapTool.config.investCurrencyMode` 决定是否展示双币种切换。

### 6.3 后端文件

资产首页相关接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppUserController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppUserController.java)

钱包相关业务:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserWalletService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserWalletService.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserWalletMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserWalletMapper.xml)

钱包流水相关:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletLogServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWalletLogServiceImpl.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserWalletLogMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserWalletLogMapper.xml)

充值 / 提现 / 余额宝对资产的影响:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserRechargeServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserRechargeServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWithdrawServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWithdrawServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysYebaoOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysYebaoOrderServiceImpl.java)

### 6.4 API 说明

#### 6.4.1 获取钱包列表

```http
GET /app/user/wallets
```

返回字段重点:

- `walletId`
- `currencyType`
- `totalInvest`
- `availableBalance`
- `usdExchangeQuota`
- `frozenAmount`
- `profitAmount`
- `pendingAmount`
- `totalRecharge`
- `totalWithdraw`

#### 6.4.2 充值相关

```http
POST /app/recharge/submit
GET /app/recharge/list
```

#### 6.4.3 提现相关

```http
POST /app/withdraw/submit
GET /app/withdraw/list
```

#### 6.4.4 余额宝相关

```http
GET /app/yebao/my
GET /app/yebao/orders
GET /app/yebao/incomes
POST /app/yebao/purchase
POST /app/yebao/redeem
```

### 6.5 配置项

资产模块依赖的主要配置:

- `app.currency.investMode`
- `app.currency.supportRmbToUsd`
- `app.currency.usdRate`

说明:

- `investMode = 1` 表示单币种，仅展示人民币资产。
- `investMode = 2` 表示双币种，资产页显示人民币和 USDT 钱包切换。

### 6.6 缓存策略

APP 本地缓存:

- 资产页主要依赖钱包接口实时数据，不建议缓存过久。
- 资产页应在进入或下拉刷新时重新拉取钱包列表。

后端缓存:

- 钱包查询可以使用已有钱包服务缓存索引，但资产金额变更后必须及时刷新。
- 充值、提现、余额宝购买和赎回都会驱动钱包余额变化，相关服务需要同步更新钱包缓存。

### 6.7 业务规则

- 总资产由可投资产、可用余额、冻结金额、收益金额、待结算金额等汇总展示。
- 充值会增加可用余额和充值累计。
- 提现会先冻结，再在审核结果中解冻或扣减。
- 余额宝购买会减少可用余额并增加持仓金额，不应算作冻结金额。
- 双币种模式下，资产页默认优先显示人民币钱包。

### 6.8 构建与验证

后端编译校验:

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 端验证建议:

- 进入我的资产页，确认总资产、可用余额、冻结金额、收益金额都能正常显示。
- 切换币种时，人民币 / USDT 数据都能正常切换。
- 充值、提现、余额宝操作后，资产页数值应跟随变化。
- 下拉刷新后，钱包列表应与服务端保持一致。

### 6.9 修改清单

修改我的资产模块时，至少一起检查以下文件:

1. `AssetsPage`
2. `WithdrawApi`
3. `RechargeApi`
4. `AppUserController`
5. `SysUserWalletServiceImpl`
6. `SysUserWalletLogServiceImpl`
7. `SysUserRechargeServiceImpl`
8. `SysUserWithdrawServiceImpl`
9. `SysYebaoOrderServiceImpl`
10. `AppBootstrapTool`
11. `zh-CN.json`
12. `en-US.json`

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 7. 银行卡

### 7.1 模块目标

银行卡模块用于管理用户的收款 / 提币银行卡或钱包地址，按币种区分：

- 人民币 `CNY`：银行卡卡号、开户行、账户名
- 美元 `USD`：链上钱包地址

核心约束：

- RMB 卡必须先通过实名认证，且实名状态必须为已通过
- 单币种模式下仅允许人民币银行卡
- 双币种模式下同时支持 RMB / USD，但仍受每币种最多绑定 2 张卡限制

### 7.2 前端文件

APP 侧主要文件：

- [app/lib/pages/mine/bank_card_page.dart](../app/lib/pages/mine/bank_card_page.dart)
- [app/lib/request/bank_card_api.dart](../app/lib/request/bank_card_api.dart)
- [app/lib/request/ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)
- [app/lib/widgets/currency_brand_badge.dart](../app/lib/widgets/currency_brand_badge.dart)

相关资源：

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责：

- `BankCardPage` 负责页面展示、币种切换、卡片列表加载、添加 / 删除弹窗。
- `BankCardApi` 负责银行卡列表、创建、删除接口请求。
- `AppBootstrapTool.config.investCurrencyMode` 决定是否显示双币种入口。
- RMB 表单字段：开户行、账号、账户名。
- USD 表单字段：钱包地址。

### 7.3 后端文件

银行卡接口：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppBankCardController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppBankCardController.java)

银行卡业务：

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserBankCardServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserBankCardServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserBankCardService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserBankCardService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserBankCardMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserBankCardMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserBankCardMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserBankCardMapper.xml)
- [ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserBankCard.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserBankCard.java)

关联用户状态：

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)

### 7.4 API 说明

#### 7.4.1 获取银行卡列表

```http
GET /app/bankCard/list
```

返回字段重点：

- `bankCardId`
- `userId`
- `userName`
- `currencyType`
- `bankName`
- `accountNo`
- `accountName`
- `walletAddress`
- `createTime`

#### 7.4.2 新增银行卡

```http
POST /app/bankCard
```

请求字段：

- `currencyType`
- `bankName`
- `accountNo`
- `accountName`
- `walletAddress`
- `remark`

字段规则：

- `currencyType = CNY` 时，必须填写 `bankName`、`accountNo`、`accountName`
- `currencyType = USD` 时，必须填写 `walletAddress`
- 后端支持明文 JSON 和 `data` 加密包裹体
- 后端兼容 `bankName / bank_name`、`accountNo / account_no`、`accountName / account_name`、`walletAddress / wallet_address`

#### 7.4.3 删除银行卡

```http
POST /app/bankCard/delete
```

请求字段：

- `bankCardId`

### 7.5 配置项

银行卡模块依赖的核心配置：

- `app.currency.investMode`

说明：

- `1` = 单币种，仅显示 RMB 入口
- `2` = 双币种，同时显示 RMB 和 USD 入口

### 7.6 缓存策略

后端缓存：

- 银行卡列表缓存
- 银行卡详情缓存
- 每币种绑定数量缓存

缓存失效：

- 新增银行卡后清理银行卡相关缓存
- 删除银行卡后清理银行卡相关缓存

### 7.7 业务规则

- RMB 卡必须先通过实名认证
- USD 卡仅在双币种模式下可用
- 每币种最多绑定 2 张卡
- 后端最终校验必须以服务层为准，前端只做首层提示

### 7.8 构建与验证

后端编译校验：

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 验证建议：

- 单币种模式下只展示 RMB 入口
- 双币种模式下 RMB / USD 入口均可切换
- RMB 新增前必须先满足实名认证状态
- 删除银行卡后列表应立即刷新

### 7.9 修改清单

修改银行卡模块时，至少一起检查：

1. `AppBankCardController`
2. `SysUserBankCardServiceImpl`
3. `bank_card_page.dart`
4. `bank_card_api.dart`
5. `ruoyi_endpoints.dart`
6. `SysUserBankCardMapper.xml`
7. `SysUserBankCard`
8. `app.currency.investMode`

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 8. 注册

### 8.1 模块目标

注册模块用于创建并登录用户，主要流程包含账号输入、密码输入、验证码、邀请码、注册开关配置等。

核心约束：

- 当前系统是否开放注册由 `sys.account.registerUser` 控制
- 验证码开关由 `sys.account.captchaEnabled` 控制
- 邀请码显示由 `app.feature.inviteCodeEnabled` 控制
- 注册提交支持明文 JSON 与 `data` 加密包裹体

### 8.2 前端文件

APP 侧主要文件：

- [app/lib/pages/auth/register/register_page.dart](../app/lib/pages/auth/register/register_page.dart)
- [app/lib/pages/auth/register/register_controller.dart](../app/lib/pages/auth/register/register_controller.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/request/ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)
- [app/lib/pages/auth/login/login_page.dart](../app/lib/pages/auth/login/login_page.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)

相关资源：

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责：

- `RegisterPage` 负责注册表单展示、验证码展示、邀请码字段显示与提交反馈。
- `RegisterController` 负责注册请求、验证码刷新、邀请码显示状态同步。
- `AuthApi.registerWithParams()` 负责注册接口请求。
- `AuthApi.captcha()` 负责获取验证码。
- `LoginPage` 负责根据注册开关决定是否显示“去注册”入口。
- `AppBootstrapTool.config.inviteCodeEnabled` 决定注册页是否显示邀请码输入框。

### 8.3 后端文件

注册接口：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java)

注册服务：

- [ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysRegisterService.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysRegisterService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)

登录 / 配置联动：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java)

### 8.4 API 说明

#### 8.4.1 获取验证码

```http
GET /captchaImage
```

返回字段重点：

- `uuid`
- `img`
- `captchaEnabled`

#### 8.4.2 提交注册

```http
POST /register
```

请求字段：

- `username`
- `password`
- `nickName`
- `inviteCode`
- `code`
- `uuid`
- `phonenumber`
- `email`

说明：

- `nickName` 当前默认跟 `username` 保持一致
- `inviteCode` 是否显示由 `app.feature.inviteCodeEnabled` 控制
- 若后台未开启注册开关，接口直接返回失败
- 注册请求支持明文 JSON 与 `data` 加密包裹体

### 8.5 配置项

注册模块依赖的核心配置：

- `sys.account.registerUser`
- `sys.account.captchaEnabled`
- `app.feature.inviteCodeEnabled`

说明：

- `sys.account.registerUser = true` 时允许注册
- `sys.account.captchaEnabled = true` 时注册页显示验证码并要求填写
- `app.feature.inviteCodeEnabled = true` 时注册页显示邀请码输入框

### 8.6 缓存策略

APP 本地缓存：

- 验证码图片与 `uuid` 仅用于当前注册流程
- 邀请码显示状态来源于 bootstrap 配置缓存

后端缓存：

- `captchaImage` 的验证码值走 Redis 临时缓存
- 注册状态不额外落业务缓存

### 8.7 业务规则

- 用户名、密码、确认密码为空时直接拦截
- 两次密码必须一致
- 验证码开启时必须填写验证码
- 邀请码开启时必须填写邀请码
- 注册成功后返回登录页

### 8.8 构建与验证

后端编译校验：

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 验证建议：

- 注册开关关闭时，登录页“去注册”入口应隐藏或禁用
- 验证码开关开启时，注册页必须显示验证码图片和输入框
- 邀请码开关开启时，注册页必须显示邀请码输入框
- 注册成功后应返回登录页并刷新验证码状态

### 8.9 修改清单

修改注册模块时，至少一起检查：

1. `RegisterPage`
2. `RegisterController`
3. `AuthApi.registerWithParams`
4. `AuthApi.captcha`
5. `SysRegisterController`
6. `SysRegisterService`
7. `LoginPage`
8. `AppBootstrapTool`
9. `sys.account.registerUser`
10. `sys.account.captchaEnabled`
11. `app.feature.inviteCodeEnabled`
12. `zh-CN.json`
13. `en-US.json`

### 8.10 额外说明

- 注册成功后后端会直接签发 APP token，前端收到后自动写入登录态。
- 注册页不再要求用户回到登录页手动再登录一次。
- 若自动登录后个人信息刷新失败，前端会保留 token，并依赖后续 `getInfo` 静默补齐。
- 注册完成后，应用会直接切换到已登录状态对应的主界面。

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 9. 安全问题

### 9.1 模块目标

安全问题（密保问题）用于增强账户安全，覆盖三类核心场景：

- 登录后引导用户完成安全问题设置（至少 2 题）
- 已登录状态下，通过安全问题修改登录密码/支付密码
- 未登录状态下，通过安全问题找回登录密码（带验证码校验）

### 9.2 前端文件

APP 侧主要文件：

- [app/lib/pages/mine/security_center_page.dart](../app/lib/pages/mine/security_center_page.dart)
- [app/lib/pages/mine/security_question_set_page.dart](../app/lib/pages/mine/security_question_set_page.dart)
- [app/lib/pages/main/main_page.dart](../app/lib/pages/main/main_page.dart)
- [app/lib/pages/auth/forgot/forgot_page.dart](../app/lib/pages/auth/forgot/forgot_page.dart)
- [app/lib/pages/auth/forgot/forgot_controller.dart](../app/lib/pages/auth/forgot/forgot_controller.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/request/ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)
- [app/lib/tools/auth_tool.dart](../app/lib/tools/auth_tool.dart)
- [app/lib/routers/app_router.dart](../app/lib/routers/app_router.dart)

相关资源：

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责：

- `SecurityCenterPage` 作为“安全中心”入口页，提供设置密保、修改密码/支付密码等入口。
- `SecurityQuestionSetPage` 负责拉取题库、选择至少 2 题、填写答案并提交设置。
- `MainPage` 登录后检查 `userInfo.securityQuestionSet`，未设置时引导进入设置页。
- `ForgotPage/ForgotController` 负责找回密码链路：加载题库、收集答案与验证码、提交找回请求。
- `AuthApi` 负责相关接口请求；`AuthTool` 负责本地用户档案缓存（包含 `securityQuestionSet` 标记）。

### 9.3 后端文件

题库（后台维护 + APP 端读取）：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysSecurityQuestionController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysSecurityQuestionController.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysSecurityQuestionService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysSecurityQuestionService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysSecurityQuestionServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysSecurityQuestionServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysSecurityQuestionMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysSecurityQuestionMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysSecurityQuestionMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysSecurityQuestionMapper.xml)
- [ruoyi-system/src/main/java/com/ruoyi/system/domain/SysSecurityQuestion.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysSecurityQuestion.java)

用户答案（设置 / 查询 / 校验 / 通过密保改密码）：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserSecurityAnswerController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserSecurityAnswerController.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserSecurityAnswerService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserSecurityAnswerService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserSecurityAnswerServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserSecurityAnswerServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserSecurityAnswerMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserSecurityAnswerMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserSecurityAnswerMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserSecurityAnswerMapper.xml)
- [ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserSecurityAnswer.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserSecurityAnswer.java)

匿名找回密码 / 匿名查询入口（APP 认证安全聚合入口）：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppAuthController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppAuthController.java)

APP 用户侧补充接口（当前用户“我的答案”）：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppUserController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppUserController.java)

后端职责：

- 题库按 `lang` 返回（en-US 会做文案映射），并做缓存，避免频繁读库。
- 用户答案保存时对答案进行加密存储；校验时按题目逐一验证。
- 设置成功后写入 `sys_user.security_question_set = 1`，供 APP 引导逻辑使用。
- 相关请求体支持明文 JSON 与 `data` 加密包裹体（服务端会解密兼容）。

### 9.4 API 说明

#### 9.4.1 获取题库（匿名）

```http
POST /app/auth/security/questions
```

请求字段（可选）：

- `lang`: `zh-CN` / `en-US`

#### 9.4.2 判断用户是否已设置（匿名，用于找回流程辅助）

```http
POST /app/auth/security/hasSet
```

请求字段：

- `username`

#### 9.4.3 获取用户已设置的问题文本（匿名，不返回答案）

```http
POST /app/auth/security/myQuestions
```

请求字段：

- `username`

#### 9.4.4 找回登录密码（匿名 + 验证码）

```http
POST /app/auth/forgotPwdBySecurity
```

请求字段：

- `username`
- `newPassword`
- `answers`（至少 2 题）
- `code` / `uuid`（验证码开启时必填）

#### 9.4.5 设置安全问题答案（登录态）

```http
POST /app/user/security/answers
```

说明：

- 兼容两种请求体：直接数组 `[{...},{...}]` 或 `{ "answers": [{...},{...}] }`
- 也兼容 `data` 加密包裹体（服务端解密后再解析）

#### 9.4.6 获取当前用户答案列表（登录态）

```http
GET /app/user/security/answers
GET /app/user/security/my
```

#### 9.4.7 获取已设置题数（登录态）

```http
GET /app/user/security/count
```

#### 9.4.8 校验单题答案（登录态）

```http
POST /app/user/security/verify
```

#### 9.4.9 通过密保更新登录密码（登录态）

```http
POST /app/user/security/updatePwd
```

#### 9.4.10 通过密保更新支付密码（登录态）

```http
POST /app/user/security/updatePayPwd
```

#### 9.4.11 管理端题库维护（后台）

```http
GET /system/security/question/list
GET /system/security/question/{id}
POST /system/security/question
PUT /system/security/question/{id}
DELETE /system/security/question/{ids}
```

### 9.5 缓存策略

后端缓存：

- 题库 Redis key：`security:questions:{lang}`，过期 1 天

APP 本地缓存：

- `securityQuestionSet` 来自 `getInfo.user.securityQuestionSet`，并在设置成功后本地同步更新

### 9.6 数据库与字段

- `sys_security_question`：安全问题题库
- `sys_user_security_answer`：用户答案（user + question 唯一，避免重复配置同一题）
- `sys_user.security_question_set`：是否已设置（APP 引导逻辑使用）

### 9.7 业务规则

- 用户答案至少设置 2 题
- 找回密码/改密码前必须逐题校验答案
- 密码长度校验：登录密码 6-20 位；支付密码 6 位纯数字
- 安全问题答案禁止明文落库，后端统一加密存储

### 9.8 构建与验证

后端编译校验：

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

APP 验证建议：

- 首次登录后未设置时应自动引导到设置页
- 设置完成后“安全中心”显示为已设置，且不再重复强制引导
- 找回密码流程：题库加载、验证码校验、两题答案校验通过后可重置
- 修改登录密码/支付密码流程：两题答案校验失败时必须拦截并提示

### 9.9 修改清单

修改安全问题模块时，至少一起检查：

1. `SecurityCenterPage`
2. `SecurityQuestionSetPage`
3. `ForgotPage` / `ForgotController`
4. `AuthApi`（安全问题相关方法与模型）
5. `RuoYiEndpoints`（路径常量）
6. `SysSecurityQuestionController`
7. `SysSecurityQuestionServiceImpl`（含缓存与多语言）
8. `SysUserSecurityAnswerController`
9. `SysUserSecurityAnswerServiceImpl`（答案存储与校验）
10. `sys_user.security_question_set` 写入链路
11. `zh-CN.json`
12. `en-US.json`

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 10. 资讯中心 / 新闻

### 10.1 模块目标

资讯中心用于在 APP 内展示“新闻资讯 / 关于我们”等图文内容，支持分类切换、列表浏览与详情阅读。

### 10.2 前端文件

APP 端主要文件:

- [app/lib/pages/mine/news_page.dart](../app/lib/pages/mine/news_page.dart)
- [app/lib/pages/mine/news_detail_page.dart](../app/lib/pages/mine/news_detail_page.dart)
- [app/lib/request/news_api.dart](../app/lib/request/news_api.dart)
- [app/lib/request/ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)
- [app/lib/routers/app_router.dart](../app/lib/routers/app_router.dart)
- [app/lib/pages/main/main_page.dart](../app/lib/pages/main/main_page.dart)

相关资源:

- [app/assets/i18n/zh-CN.json](../app/assets/i18n/zh-CN.json)
- [app/assets/i18n/en-US.json](../app/assets/i18n/en-US.json)

前端职责:

- `NewsPage` 负责分类 Tab、文章列表、下拉刷新与空态展示；默认分类码为 `NEWS_INFO`。
- `NewsDetailPage` 负责文章详情展示，使用 `flutter_html` 渲染正文，图片地址通过 `ApiClient.resolveImageUrl` 解析。
- `NewsApi` 封装分类/文章列表请求，并使用 SharedPreferences 做 10 分钟 TTL 的轻量缓存（允许 stale 回退 + 后台刷新）。
- `AppRouter` 维护 `/mine/news` 与 `/mine/news/detail` 的路由映射；`MainPage`“我的-资讯中心”作为入口。

### 10.3 后端文件

APP 侧接口（给 Flutter 调用）:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppNewsController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppNewsController.java)

管理端维护接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysNewsCategoryController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysNewsCategoryController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysNewsArticleController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysNewsArticleController.java)

业务与缓存:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsCategoryServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsCategoryServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsArticleServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsArticleServiceImpl.java)

Domain / Mapper / XML:

- [ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNewsCategory.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNewsCategory.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNewsArticle.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNewsArticle.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNewsCategoryMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNewsCategoryMapper.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNewsArticleMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysNewsArticleMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysNewsCategoryMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysNewsCategoryMapper.xml)
- [ruoyi-system/src/main/resources/mapper/system/SysNewsArticleMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysNewsArticleMapper.xml)

### 10.4 API 说明

#### 10.4.1 分类列表

```http
GET /app/news/categories
```

#### 10.4.2 文章列表

```http
GET /app/news/list
```

常用 query:

- `categoryCode`（如 `NEWS_INFO` / `COMPANY_INFO`）
- `status`（默认 `0`）

#### 10.4.3 文章详情

```http
GET /app/news/{articleId}
```

管理端维护（后台）:

```http
GET /system/news/category/list
GET /system/news/category/listAll
GET /system/news/category/{categoryId}
POST /system/news/category
PUT /system/news/category
DELETE /system/news/category/{categoryIds}

GET /system/news/article/list
GET /system/news/article/{articleId}
POST /system/news/article
PUT /system/news/article
DELETE /system/news/article/{articleIds}
```

### 10.5 缓存策略

APP 本地缓存:

- 分类与文章列表使用 SharedPreferences 缓存，TTL 10 分钟；过期时可先返回旧数据并后台刷新。

后端缓存（Redis）:

- 分类：`news:category:all`
- 文章列表：`news:article:list:{categoryCode}:{status}:{articleTitle}`
- 文章详情：`news:article:detail:{articleId}`
- 分类/文章变更后统一清理 `news:*` 相关 key。

### 10.6 业务规则

- APP 列表页默认只展示 `status=0` 的内容（AppNewsController 会补默认值）。
- 文章排序以置顶 `topFlag` 优先，其次 `sortOrder`，再按 `articleId` 倒序。
- 列表接口会返回正文 `articleContent`（字段兼容 `article_content`），用于直接打开详情页渲染。

### 10.7 修改清单

修改资讯中心模块时，至少一起检查:

1. `NewsPage` / `NewsDetailPage`
2. `NewsApi`（缓存与数据解析）
3. `RuoYiEndpoints`（接口路径常量）
4. `AppNewsController`（APP 接口入参默认值）
5. `SysNewsArticleServiceImpl` / `SysNewsCategoryServiceImpl`（Redis 缓存与清理）
6. `SysNewsArticleMapper.xml` / `SysNewsCategoryMapper.xml`（排序、字段、联表）
7. `zh-CN.json`
8. `en-US.json`

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 11. 矿机 / 节点

### 11.1 后台管理（封面图上传）

目标: 后台新增/编辑矿机时可上传封面图，行为与“新闻资讯封面”一致，最终存储为后端可访问的图片路径/URL。

管理端页面:

- [ruoyi-ui/src/views/operation/miner/index.vue](../ruoyi-ui/src/views/operation/miner/index.vue)

实现约束:

- 表单字段 `coverImage` 使用 `image-upload` 组件（`limit=1`），调用若依通用上传接口（`POST /common/upload`）上传图片。
- 提交保存前需对 `coverImage` 做归一化（组件可能返回数组/对象），最终落库字段必须为字符串（图片路径或 URL）。
- 列表页封面预览使用 `el-image`；当 `coverImage` 为相对路径时，按 `VUE_APP_BASE_API + coverImage` 拼出可访问地址（与新闻封面处理逻辑一致）。

数据字段:

- `sys_miner.cover_image`: 矿机封面图（存储上传后返回的相对路径或完整 URL）；不需要新增字段。

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 12. 成长值体系 / 后台成长值管理

### 12.1 模块目标

成长值体系用于替代“按投资金额升级”的旧逻辑，统一以用户成长值驱动会员升级。

核心要求（永久约束）:

- 成长值增减必须走统一服务类，不允许在业务代码里直接改 `sys_user.growth_value`。
- 每次成长值变动后，必须立即执行“是否满足升级条件”的检测。
- 若满足升级条件，必须同步更新用户等级信息（`sys_user.level`）。
- 后台提供独立“成长值管理页”，支持增减成长值与明细查询。

### 12.2 前端文件

后台管理页面与接口封装:

- [ruoyi-ui/src/views/system/growth/index.vue](../ruoyi-ui/src/views/system/growth/index.vue)
- [ruoyi-ui/src/api/system/growth.js](../ruoyi-ui/src/api/system/growth.js)
- [ruoyi-ui/src/views/system/user/index.vue](../ruoyi-ui/src/views/system/user/index.vue)
- [ruoyi-ui/src/router/index.js](../ruoyi-ui/src/router/index.js)

前端职责:

- `system/growth/index.vue` 为专门的成长值管理页，支持按用户筛选、增减成长值、查看明细。
- `system/user/index.vue` 的“成长值管理”入口改为跳转该专页，不再在当前页弹窗处理。
- 路由支持两种进入方式：
  - 带用户参数跳转（只看当前用户）
  - 无参数进入（管理全量用户成长值）

### 12.3 后端文件

统一成长值服务:

- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysGrowthValueService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysGrowthValueService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysGrowthValueServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysGrowthValueServiceImpl.java)

成长值管理接口:

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserGrowthController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserGrowthController.java)

成长值日志:

- [ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUserGrowthLog.java](../ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUserGrowthLog.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserGrowthLogMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserGrowthLogMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserGrowthLogMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserGrowthLogMapper.xml)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserGrowthLogService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserGrowthLogService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserGrowthLogServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserGrowthLogServiceImpl.java)

用户映射与升级落库:

- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)

### 12.4 API 说明

#### 12.4.1 成长值明细列表

```http
GET /system/growth/log/list
```

常用 query:

- `userId`
- `userName`
- `changeType`（`increase` / `decrease`）
- `sourceType`
- `beginTime` / `endTime`

#### 12.4.2 增加成长值

```http
POST /system/growth/increase
```

请求字段:

- `userId`
- `growthValue`
- `sourceType`（默认 `manual`）
- `sourceId`
- `sourceNo`
- `remark`

#### 12.4.3 扣除成长值

```http
POST /system/growth/decrease
```

请求字段同增加接口。

### 12.5 数据库脚本

成长值日志表初始化脚本:

- [sql/migration_user_growth_log.sql](../sql/migration_user_growth_log.sql)

说明:

- 必须先执行该脚本，后台成长值明细查询与日志落库才能正常使用。

### 12.6 业务规则（强约束）

- 成长值增减只允许通过 `ISysGrowthValueService`。
- `increaseGrowthValue` / `decreaseGrowthValue` 都会进入统一内部方法处理：
  - 校验用户与参数
  - 锁定并更新成长值
  - 执行升级检测
  - 记录成长值日志
- 升级检测逻辑使用会员等级配置（`required_growth_value`）计算可达最高等级。
- 检测到可升级后，必须写回用户等级（`sys_user.level`）。

### 12.7 最近变更记录（2026-05）

1. 成长值管理从 `system/user` 页面内弹窗迁移为独立页面 `system/growth/index`。
2. 新增成长值管理后端控制器与前端 API，支持“增/减 + 明细查询”。
3. 新增成长值日志链路（实体、Mapper、Service、建表 SQL）。
4. 成长值服务重构为统一变更方法，保证“每次成长值变化都检测升级并同步用户等级”。
5. 补齐 `SysUserMapper.xml` 的 `updateUserLevelValue` SQL，修复升级结果无法稳定落库风险。
6. `SysUserGrowthLog` 继承 `BaseEntity`，支持 `params.beginTime/endTime` 条件查询，修复列表查询报错。
7. 用户管理页成长值展示链路修复：
   - `selectUserList` 查询字段改为 `growth_value`
   - 前端列配置补齐 `growthValue` 可见性键
8. 余额宝配置“每份成长值”支持小数：
   - 类型调整为 `decimal(10,4)`
   - 后端实体改 `BigDecimal`
   - 后台输入改支持 `0.1`

### 12.8 修改清单

修改成长值模块时，至少一起检查：

1. `ISysGrowthValueService` / `SysGrowthValueServiceImpl`
2. `SysUserGrowthController`
3. `SysUserGrowthLog` + `SysUserGrowthLogMapper.xml`
4. `SysUserMapper.xml`（`growth_value` 查询与 `updateUserLevelValue`）
5. `system/growth/index.vue`
6. `api/system/growth.js`
7. `system/user/index.vue`（入口跳转）
8. `router/index.js`
9. `migration_user_growth_log.sql`

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 13. 投资产品与券体系（后台）

### 13.1 目标范围

本模块覆盖后台管理与核心业务规则，不包含 APP 前端页面改造。目标是将“投资产品”从单配置模式升级为可配置产品体系，并引入优惠券、等级体验券和可扩展的返息返本策略。

### 13.2 数据模型（新增）

新增脚本:

- [sql/investment_product_upgrade_20260503.sql](../sql/investment_product_upgrade_20260503.sql)

核心表:

1. `sys_invest_product`：投资产品主表
2. `sys_invest_tag`：产品标签
3. `sys_invest_product_tag_rel`：产品标签多对多关系
4. `sys_coupon_template`：优惠券模板（体验券/现金券/减满券/加息券）
5. `sys_coupon_user`：用户优惠券
6. `sys_level_trial_template`：等级体验券模板（独立于产品）
7. `sys_level_trial_user`：用户等级体验券
8. `sys_invest_order_plan`：订单收益执行计划（支持每日/分段/到期）

### 13.3 后端接口与文件

控制器:

- [SysInvestTagController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysInvestTagController.java)
- [SysInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysInvestProductController.java)
- [SysCouponTemplateController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysCouponTemplateController.java)
- [SysLevelTrialTemplateController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLevelTrialTemplateController.java)

服务与实现:

- [ISysInvestTagService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysInvestTagService.java)
- [ISysInvestProductService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysInvestProductService.java)
- [ISysCouponTemplateService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysCouponTemplateService.java)
- [ISysLevelTrialTemplateService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysLevelTrialTemplateService.java)
- [SysInvestTagServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestTagServiceImpl.java)
- [SysInvestProductServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestProductServiceImpl.java)
- [SysCouponTemplateServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysCouponTemplateServiceImpl.java)
- [SysLevelTrialTemplateServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysLevelTrialTemplateServiceImpl.java)

Mapper:

- [SysInvestTagMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestTagMapper.xml)
- [SysInvestProductMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestProductMapper.xml)
- [SysCouponTemplateMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysCouponTemplateMapper.xml)
- [SysLevelTrialTemplateMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysLevelTrialTemplateMapper.xml)

### 13.4 后台页面与 API

页面:

- [operation/investProduct/index.vue](../ruoyi-ui/src/views/operation/investProduct/index.vue)
- [operation/couponTemplate/index.vue](../ruoyi-ui/src/views/operation/couponTemplate/index.vue)
- [operation/levelTrial/index.vue](../ruoyi-ui/src/views/operation/levelTrial/index.vue)

前端 API:

- [investProduct.js](../ruoyi-ui/src/api/operation/investProduct.js)
- [couponTemplate.js](../ruoyi-ui/src/api/operation/couponTemplate.js)
- [levelTrial.js](../ruoyi-ui/src/api/operation/levelTrial.js)

路由入口:

- [router/index.js](../ruoyi-ui/src/router/index.js)

### 13.5 业务规则（当前实现）

1. 产品支持多标签（同一产品可关联多个标签）。
2. 产品支持币种、卡片主题、风险标签配置，用于前端差异化展示。
3. 产品支持单购利率与拼团利率双配置。
4. 产品支持返息方式（每日/分段/到期）与返本方式（分段/到期）字段化配置。
5. 支持起投金额、最高可投、总份数、限购等级、限投次数。
6. 支持每份积分、每份成长值、每份红包金额配置。
7. 支持产品是否可用优惠券、是否拼团、成团人数、自动拼团。
8. 优惠券支持通用/指定产品范围与四类券模板配置。
9. 等级体验券独立建模，支持按用户发放。
10. 优惠券发放支持按用户ID批量，或按最低等级批量发放。

### 13.6 设计优化建议（对理财业务更稳妥）

1. 分段返息/返本的比例建议拆成结构化子表，不建议长期只用 JSON 字段。
2. 限投次数建议按“历史完成订单次数”口径校验，避免赎回后重复套利。
3. 拼团建议增加 `sys_invest_group` 与 `sys_invest_group_member` 两张运行态表，区分“开团中/成团/失败”。
4. 券核销建议做单独“券核销流水表”，避免只靠用户券状态难以审计。
5. 等级体验券生效期建议与订单收益结算解耦，通过“结算时取当前有效体验券”计算加成。
6. 所有奖励（积分/成长值/红包）建议统一走账务流水服务，避免多入口直接写余额。

### 13.7 后续迭代清单

1. 下单前校验服务：等级、限投次数、库存份数、券可用性、拼团可用性。
2. 收益计划生成器：按返息返本模式拆分为执行计划写入 `sys_invest_order_plan`。
3. 结算任务执行器：按计划逐条结算并写收益/钱包/成长值/积分/红包流水。
4. 活动页领取接口：支持优惠券与体验券活动发放。
5. 菜单 SQL：将三个新后台页面挂入 `sys_menu` 并补按钮权限。

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 14. 团队奖励体系

### 14.1 模块目标

建立团队长等级体系，后台可配置等级条件；用户达到条件后可自动升级团队长级别。并在 APP 会员中心将“团队说明”升级为“团队奖励”页面。

### 14.2 数据变更

脚本:

- [sql/team_reward_upgrade_20260503.sql](../sql/team_reward_upgrade_20260503.sql)

变更点:

1. `sys_user` 增加字段 `team_leader_level`（默认 `0`）。
2. 新增 `sys_team_level` 团队等级配置表，支持：
   - 团队长等级
   - 自身等级要求
   - 直推有效用户数
   - 团队有效用户数
   - 团队总投资门槛
   - 团队长加成比例（‰，例如 `5` 表示千分之五）
   - 奖励金额

### 14.3 后端接口

后台管理:

- [SysTeamLevelController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysTeamLevelController.java)

APP 查询:

- [AppTeamRewardController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppTeamRewardController.java)

服务与映射:

- [ISysTeamLevelService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysTeamLevelService.java)
- [SysTeamLevelServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamLevelServiceImpl.java)
- [SysTeamLevelMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamLevelMapper.java)
- [SysTeamLevelMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamLevelMapper.xml)

## 42. 投资订单后台详情与强制结算

### 42.1 页面能力补充

- 后台 `system/yebao/order` 新增“详情”操作：可查看订单基础信息、计划明细、未结算本金/收益与已结算收益汇总。
- 同页新增“结算”操作：与赎回一致采用二次确认 + Google 验证后执行。

### 42.2 强制结算逻辑

- 新增后台接口 `/system/invest/order/settle`，确认文案固定为“确认结算”，仅允许持有中订单执行。
- 结算时直接处理该订单全部未结算计划（未到期也执行）：未结算本金一次返还、未结算收益一次入账。
- 执行后统一将订单状态置为已完成，并把计划状态更新为已执行（写执行时间与备注）。
- 在原有积分/成长值发放基础上，补充产品红包发放（按产品配置 `redPacketPerUnit` 与奖励单位折算）。
- 新增等级加成发放：按用户等级 `invest_bonus` 计算 `订单本金 * 等级加成%`，入账到用户同币种钱包（可用余额+收益）。
- 新增上级团队加成发放：按直属上级团队长等级 `team_bonus_rate` 计算 `订单本金 * 团队加成%`，入账到上级同币种钱包（可用余额+收益）。
- 全链路补齐钱包账变记录（本金返还、收益入账、产品红包、等级加成、团队加成）并写服务日志摘要。

### 42.3 关键文件

- [SysInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysInvestOrderController.java)
- [ISysInvestOrderService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysInvestOrderService.java)
- [SysInvestOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestOrderServiceImpl.java)
- [SysAppInvestOrderMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysAppInvestOrderMapper.java)
- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)
- [order.js](../ruoyi-ui/src/api/system/yebao/order.js)
- [index.vue](../ruoyi-ui/src/views/system/yebao/order/index.vue)

## 43. APP 我的投资/收益明细文案与卡片排版微调

### 43.1 我的投资页

- 将卡片字段文案“年化利率”统一调整为“投资利率”。

### 43.2 收益明细页

- 收益卡片顶部布局调整为“标题居左、状态标签（未收取/待收取/已收取）居右”。
- 币种图片从收益金额左侧移动至卡片右下角固定展示，避免干扰金额阅读。

涉及文件：

- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)
- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)

## 44. 账变记录新增“所有账变”分页页签

### 44.1 需求落地

- 在“账变记录”菜单中新增“所有账变”，并放在“充值记录”上方第一项。
- 新页面展示用户全部账变类型，不再只看充值/提现/投资子项。
- 列表按每页 10 条加载，滚动触底自动继续加载，直到全部加载完成。

### 44.2 后端接口

- 新增 APP 接口：`GET /app/user/wallet/log/list?pageNum=&pageSize=`
- 返回结构：`rows + total + pageNum + pageSize`，用于前端分页滚动加载。

涉及文件：

- [AppUserController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppUserController.java)

### 44.3 前端改造

- 新增页面 `AccountAllRecordsPage`，展示所有账变明细并支持下拉刷新/触底加载。
- 路由新增 `/mine/account/records/all` 并接入路由表。
- 账变菜单页新增“所有账变”入口并置顶。
- 请求层新增 `appUserWalletLogList` endpoint 与分页请求方法 `fetchWalletLogs(...)`。

涉及文件：

- [account_all_records_page.dart](../app/lib/pages/mine/account_all_records_page.dart)
- [account_change_records_page.dart](../app/lib/pages/mine/account_change_records_page.dart)
- [app_router.dart](../app/lib/routers/app_router.dart)
- [invest_order_api.dart](../app/lib/request/invest_order_api.dart)
- [ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)

## 45. 银行卡添加弹窗崩溃修复

### 45.1 问题现象

- 在“添加银行卡”提交后，出现 Flutter 断言：`InheritedElement debugDeactivated _dependents.isEmpty`。

### 45.2 根因与修复

- 根因：弹窗内部 `StatefulBuilder` 的局部 `context` 在弹窗 `pop` 后仍被用于 `AppLocalizations.of(context)` 等依赖访问，触发已销毁上下文依赖断言。
- 修复：
  - 在进入弹窗前从页面级 `context` 预取 `i18n`，弹窗内部文案统一使用该实例；
  - 提交后改为使用预先获取的 `NavigatorState` 关闭弹窗，避免跨 async gap 再访问已失效的弹窗 `context`；
  - 删除银行卡成功/失败提示前补充 `mounted` 判断，避免页面销毁后继续操作 UI 上下文。

涉及文件：

- [bank_card_page.dart](../app/lib/pages/mine/bank_card_page.dart)

## 46. 银行卡图标与删除接口参数兼容修复

### 46.1 人民币银行卡图标

- 银行卡页面中人民币卡片/新增入口图标统一改为银联图标 `unionpay.webp`。
- 通过 `CurrencyBrandBadge(useUnionPayForCny: true)` 生效，USD 保持原图标逻辑。

### 46.2 删除银行卡报“Bank card ID cannot be empty”修复

- 后端 `POST /app/bankCard/delete` 由直接绑定 `SysUserBankCard` 改为接收 `Map` 并复用 `resolveBankCardBody(...)`。
- 兼容加密请求体（`data` 解密）与明文字段（`bankCardId/bank_card_id`），避免因参数解析失败导致 `bankCardId` 为空。

涉及文件：

- [AppBankCardController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppBankCardController.java)
- [bank_card_page.dart](../app/lib/pages/mine/bank_card_page.dart)

### 46.3 钱包地址脱敏规则调整

- 银行卡页中的“钱包地址（USD）”显示改为固定脱敏：仅展示前4位+后4位，中间固定 `*********`（9个*）。
- 不再按原始地址真实长度计算星号数量，避免泄露地址长度特征。
- 该规则仅用于钱包地址；人民币银行卡号仍使用原有尾号脱敏逻辑。

### 46.4 银行卡页卡死（InheritedElement 断言）兜底修复

- 针对银行卡页在异步回调期间触发 `_dependents.isEmpty` 断言，调整为在方法入口预取文案，避免 `await` 后再次直接读取 `AppLocalizations.of(context)`。
- `SnackBar` 统一改为 `ScaffoldMessenger.maybeOf(context)` + `mounted` 判定，避免页面/弹窗销毁瞬间继续访问失效 `context`。
- 覆盖加载失败、删除成功/失败、实名校验/数量上限等提示路径。

### 46.5 银行卡弹窗焦点链路卡死修复（InkResponse）

- 针对 `Looking up a deactivated widget's ancestor is unsafe` 且堆栈落在 `InkResponse` 焦点高亮回调的问题，移除银行卡页弹窗中的 `TextButton/ElevatedButton`。
- 改为 `GestureDetector + Container` 自定义动作按钮，规避 `InkResponse` 在销毁瞬间触发的祖先查找。
- 删除确认弹窗同时改为预取 `i18n` 文案，不在弹窗 builder 内反复取 `AppLocalizations.of(context)`。

### 14.4 自动升级规则

系统在团队奖励查询时会执行一次“检查并升级”：

1. 读取用户当前等级、团队长等级。
2. 统计直推有效用户数（直属下级，状态正常）。
3. 统计团队有效用户数（团队树内用户，状态正常）。
4. 统计团队总投资（基于 `sys_yebao_order` 的 `principal_amount`）。
5. 从启用的团队等级规则中选择可达最高等级并升级 `sys_user.team_leader_level`。

### 14.5 APP 页面改造

会员中心:

- [member_center_page.dart](../app/lib/pages/mine/member_center_page.dart)
  - 菜单文案由“团队说明”改为“团队奖励”
  - 点击进入团队奖励页

新页面与接口:

- [team_reward_page.dart](../app/lib/pages/mine/team_reward_page.dart)
- [team_reward_api.dart](../app/lib/request/team_reward_api.dart)
- [app_router.dart](../app/lib/routers/app_router.dart)
- [ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)

用户字段映射补齐:

- [SysUser.java](../ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUser.java)
- [SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)
- [auth_api.dart](../app/lib/request/auth_api.dart)
- [SysLoginService.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java)

<!-- REGISTRY_INDEX_START -->
## 目录（按编号）

- 0. 投资认购签约复用（新增）
- 1. 每日签到
- 2. 个人信息
- 3. 实名认证
- 4. 邀请好友
- 5. 充值
- 6. 我的资产
- 7. 银行卡
- 8. 注册
- 9. 安全问题
- 10. 资讯中心 / 新闻
- 11. 矿机 / 节点
- 12. 成长值体系 / 后台成长值管理
- 13. 投资产品与券体系（后台）
- 14. 团队奖励体系
- 15. 我的团队（夜间统计）
- 16. 投资展示与在线签约（APP）
- 17. 余额宝幂等增强
- 18. 产品展示筛选与缓存
- 19. 投资币种约束（后台）
- 20. 产品进度入库与排序
- 21. 参数类型增强（后台与APP配置）
- 22. 投资合同公章改为后台图片参数
- 23. 产品交易规则内容配置
- 24. 产品投资模式升级（按金额/按份额）
- 25. 后台产品复制功能
- 26. APP 签名组件工具化
- 27. 产品认购支付密码前置校验
- 28. 余额宝购买支付密码验证闭环
- 29. 产品积分/成长值计算口径预留（按金额模式）
- 30. 后台 Google 二次验证（敏感操作）
- 31. APP 投资收益明细（仅利息口径）
- 32. APP 投资扣款与本金口径
- 33. APP 我的投资页面重构
- 34. APP 投资链路口径修正（资产与账变）
- 35. 充值/提现人民币图标统一（银联）
- 36. 产品认购页去除汇率展示
- 37. 收益明细卡片状态/币种图标布局优化
- 38. 资产详情文案调整（可投资金 -> 已投资金）
- 39. APP 提现提交金额解析兜底
- 40. 后台提现审核通过不写系统通知
- 41. 投资成功写入团队统计并纳入夜间升级口径
- 42. 投资订单后台详情与强制结算
- 43. APP 我的投资/收益明细文案与卡片排版微调
- 44. 账变记录新增“所有账变”分页页签
- 45. 银行卡添加弹窗崩溃修复
- 46. 银行卡图标与删除接口参数兼容修复
- 47. 钱包地址长度限制（前后端双重校验）
- 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）
- 49. 实名重审入口与审核通过通知收口
- 50. 实名审核 Google 验证范围调整
- 51. 矿机兑换账变显示修正
- 52. 产品详情有效期按开始/结束分行展示
- 53. 提现冻结账变类型与负号显示修正
- 54. APP配置新增真实拼团开关
- 55. 真实拼团流程落地（开团/参团/超时失败退款）
- 56. APP配置页面开关控件交互优化
- 57. APP配置保存 selectOne 异常修复
- 58. 产品详情页拼团利率展示口径统一
- 59. 拼团下单 insertInvestGroup 主键回填异常修复
- 60. 我的拼团入口与页面完善
- 61. 拼团下单时间类型兼容修复
- 62. 产品与投资页面提醒样式统一
- 63. 提醒颜色按成功态区分
- 64. 我的拼团倒计时组件化
- 65. 我的投资页拼团状态与倒计时优化
- 66. 待拼团收益不展示与结算拦截
- 67. 产品详情页标签间距压缩
- 68. 拼团自动匹配与自拼团限制
- 69. 首页改版与APP广告管理
- 70. APP图标替换（Android/iOS）
- 71. 首页视觉统一优化
- 72. 我的节点页面UI同风格优化
- 73. 产品页UI同风格优化
- 74. 产品详情页UI同风格优化
- 75. 产品列表页透明度同步
- 76. APP广告新增分类ID兜底修复
- 77. 首页聚合接口与运营位联动
- 78. 新闻分类类型隔离（NEWS 与 首页运营位）
- 79. 产品系列与我的核心页面多语言补齐
- 80. 产品详情下单前等级校验
- 81. Web 图标替换为 ico 目录素材

## 索引（按主题）

- 账户与基础能力：0-9
- 资讯/首页运营位：10、69、76-78
- 矿机/节点与成长值：11-12、51、72
- 投资产品与订单主链路：13、16、18、20、24、31-34、42、52、55、58-59、61、65-68、73-75、80
- 团队/拼团与奖励：14-15、41、54-56、60、64、66、68
- 支付/充值/提现与风控：5-7、27-30、35、39-40、45-46、49-50、53、57
- 参数配置与系统治理：19、21-23、25-26、36-38、43-44、47-48、70-71、79
- 端侧资源与品牌素材：81

<!-- REGISTRY_INDEX_END -->

---
## 15. 我的团队（夜间统计）

### 15.1 模块目标

“我的团队”统计采用夜间批处理，不在白天实时递归计算，避免层级扩大后在线性能抖动。

白天查询口径：

- 查询夜间生成的快照表
- 支持后台按用户、等级、日期筛选
- 提供事件流水用于追溯“注册/充值/投资”来源

### 15.2 数据模型（MVP 四表）

新增脚本：

- [sql/team_stats_mvp_20260503.sql](../sql/team_stats_mvp_20260503.sql)

四张核心表：

1. `sys_team_relation`：团队关系闭包表（祖先-后代 + depth）
2. `sys_team_stat_event`：团队事件流水（REGISTER/RECHARGE/INVEST）
3. `sys_team_stat_user`：用户最新团队汇总快照
4. `sys_team_stat_daily`：按日留档快照

参数配置：

- `team.stats.calc.depth`：统计层级（默认 3）
- `team.stats.calc.cron`：夜间统计 cron（默认 `0 30 2 * * ?`）
- `team.stats.last.calc.date`：最近成功统计日期

### 15.3 后端文件

统计服务与任务：

- [ISysTeamStatService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysTeamStatService.java)
- [SysTeamStatServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamStatServiceImpl.java)
- [SysTeamStatMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamStatMapper.java)
- [SysTeamStatMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamStatMapper.xml)
- [TeamStatTask.java](../ruoyi-quartz/src/main/java/com/ruoyi/quartz/task/TeamStatTask.java)

后台接口：

- [SysTeamStatController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysTeamStatController.java)

核心职责：

- 每日按目标日期重建关系表（幂等）
- 生成当日事件流水（注册/充值/投资）
- 计算并落库每日快照
- 刷新最新用户汇总快照
- 更新最近统计日期参数

### 15.4 后台页面与 API

后台页面：

- [operation/teamStats/index.vue](../ruoyi-ui/src/views/operation/teamStats/index.vue)

前端 API：

- [operation/teamStats.js](../ruoyi-ui/src/api/operation/teamStats.js)

路由：

- [router/index.js](../ruoyi-ui/src/router/index.js)

功能点：

- 汇总查询：用户ID/用户名/团队等级/统计日期
- 事件查询：上级ID/下级ID/事件类型/统计日
- 查看当前统计层级与最近统计日
- 手动触发指定日期重算（权限控制）

### 15.5 API 说明

```http
GET /system/teamStats/list
GET /system/teamStats/event/list
GET /system/teamStats/config
POST /system/teamStats/rebuild?statDate=yyyy-MM-dd
```

权限建议：

- `system:teamStats:list`：查询汇总与事件
- `system:teamStats:rebuild`：手动重算

### 15.6 计算口径（当前实现）

- 团队人数：`sys_team_relation` 中 depth 范围内的后代人数
- 有效人数：后代用户 `total_recharge_amount > 0` 或 `total_invest_amount > 0`
- 团队总资产：后代用户充值审核通过金额累计
- 团队总投资：后代用户余额宝投资本金累计
- 直推口径：`depth = 1`

### 15.7 风险与注意

- 当前关系表为夜间全量重建，适合 MVP，后续可升级为增量维护
- 金额口径当前基于现有充值/余额宝订单，若接入新投资产品需并入口径
- 重算接口应限制在后台授权角色使用，避免频繁触发

### 15.8 APP 我的团队页（按设计图）

APP 页面与路由：

- [my_team_page.dart](../app/lib/pages/mine/my_team_page.dart)
- [member_center_page.dart](../app/lib/pages/mine/member_center_page.dart)
- [app_router.dart](../app/lib/routers/app_router.dart)

APP 请求与缓存：

- [my_team_api.dart](../app/lib/request/my_team_api.dart)
- [ruoyi_endpoints.dart](../app/lib/request/ruoyi_endpoints.dart)

APP 接口：

```http
GET /app/team/stats/me
```

后端入口：

- [AppTeamStatsController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppTeamStatsController.java)

返回字段（当前）：

- 邀请码、用户等级、团队长等级
- 总资产、总收益
- 直推总人数、直推有效人数、直推有效率
- 团队总人数、团队有效人数、团队有效率
- 最近统计日期

缓存策略（已实现）：

- 本地缓存 key：`my.team.stats.cache.v1`
- 本地时间戳 key：`my.team.stats.cache.updatedAt.v1`
- TTL：10 分钟
- 读取策略：优先返回缓存；缓存过期时先返回旧缓存并后台静默刷新
- 强制刷新：下拉刷新或显式 `forceRefresh=true` 走远端并覆盖缓存

## 16. 投资展示与在线签约（APP）

本模块已接入 APP 端产品展示、产品详情、认购页与在线签约流程，并完成认购提交幂等改造。

### 16.1 APP 页面与路由

页面：

- [invest_product_list_page.dart](../app/lib/pages/product/invest_product_list_page.dart)
- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

路由：

- [app_router.dart](../app/lib/routers/app_router.dart)

能力：

- 产品列表/详情展示（购买逻辑分步接入）
- 普通认购与拼团认购页面
- 购买前合同弹窗
- 必须“勾选同意 + 手写签名”后才能继续支付提交

### 16.2 APP 接口与后端入口

APP 接口：

```http
GET  /app/invest/product/list
GET  /app/invest/product/{productId}
POST /app/invest/order/contract/preview
POST /app/invest/order/submit
```

后端入口：

- [AppInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestProductController.java)
- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)

### 16.3 在线签约规则

- 点击购买后先展示合同条款，不直接扣款
- 用户必须勾选同意并手写签名
- 合同页展示投资章图片（资源由 APP assets 管理）
- 提交时后端校验：同意状态、签名数据、支付密码、金额与产品约束

### 16.4 认购落库链路（当前实现）

- 扣减用户钱包可用余额并记录钱包流水
- 写入投资订单（`sys_invest_order`）
- 写入合同签署记录（`sys_invest_contract_sign`）
- 生成收益/返本计划（`sys_invest_order_plan`）
- 更新产品已售份数

核心 Mapper：

- [SysAppInvestOrderMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysAppInvestOrderMapper.java)
- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)

### 16.5 认购提交幂等

已实现“双层幂等”：

- 接口层：`userId + clientReqNo` Redis 原子锁，提交处理中拒绝重复请求
- 结果层：同请求号缓存成功结果，重复请求直接返回原结果
- 数据库层：`sys_invest_order` 唯一键 `(user_id, client_req_no)` 兜底

对应脚本：

- [invest_order_online_sign_20260504.sql](../sql/invest_order_online_sign_20260504.sql)
- [invest_order_idempotent_20260504.sql](../sql/invest_order_idempotent_20260504.sql)

## 17. 余额宝幂等增强

余额宝已补齐购买请求幂等与结算并发防重，降低重复扣款和重复结算风险。

### 17.1 购买幂等

入口：

- [AppYebaoController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppYebaoController.java)
- [SysYebaoOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysYebaoOrderServiceImpl.java)

规则：

- 购买请求必须带 `clientReqNo`
- 接口层按 `userId + clientReqNo` 加 Redis 锁防并发重复提交
- 服务层按 `userId + clientReqNo` 查重，命中则不重复扣款不重复下单
- 前端购买请求已自动携带 `clientReqNo`

### 17.2 结算防重

- 结算处理前对订单执行 `select ... for update`
- 锁定后再次校验状态与 `next_settle_time`，避免并发重复结算
- 建议配合 DB 唯一键进一步兜底

### 17.3 数据库幂等键

脚本：

- [yebao_idempotent_20260504.sql](../sql/yebao_idempotent_20260504.sql)

内容：

- `sys_yebao_order` 增加 `client_req_no`
- 唯一键：`uk_yebao_user_req (user_id, client_req_no)`
- `sys_yebao_income_log` 唯一键：`uk_yebao_order_period (order_id, period_end_time)`

## 18. 产品展示筛选与缓存

APP 产品列表筛选已改为“动态标签组 + 全部”，并优先使用本地缓存。

实现：

- [invest_product_api.dart](../app/lib/request/invest_product_api.dart)
- [invest_product_list_page.dart](../app/lib/pages/product/invest_product_list_page.dart)

策略：

- 标签组固定包含首项“全部”
- 点击“全部”不做标签筛选
- 标签组由产品数据动态生成并缓存（本地优先）
- 缓存过期时先返回旧缓存并后台静默刷新

## 19. 投资币种约束（后台）

投资产品币种已统一为仅支持 `CNY` 与 `USD`。

改动：

- 后台产品页去掉 `USDT` 选项，仅保留“人民币(CNY)”与“USD”
- 后端服务层增加强校验，拦截非 `CNY/USD` 提交

文件：

- [index.vue](../ruoyi-ui/src/views/operation/investProduct/index.vue)
- [SysInvestProductServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestProductServiceImpl.java)

## 20. 产品进度入库与排序

产品进度改为落库字段 `progress_percent`，由 `sold_shares / total_shares * 100` 计算（保留 4 位小数，范围 0~100）。

规则：

- 进度用于判断产品是否仍可继续投资（100% 视为已满）
- 列表排序改为“未满额优先 + 进度倒序”
- 达到 `100%` 的产品默认排到列表最下面

实现：

- 产品插入、更新时自动重算 `progress_percent`
- 已投资份数变更（`increaseSoldShares`）时同步刷新 `progress_percent`
- 用户投资成功后按“投资金额/单份金额”折算写入 `sold_shares`，并校验剩余份额是否充足
- APP 返回优先读取落库进度，空值时兼容走运行时计算

脚本与文件：

- [invest_product_progress_20260504.sql](../sql/invest_product_progress_20260504.sql)
- [SysInvestProduct.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysInvestProduct.java)
- [SysInvestProductMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestProductMapper.xml)
- [AppInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestProductController.java)

## 21. 参数类型增强（后台与APP配置）

参数管理与 APP 配置管理已支持参数类型驱动渲染：

- `TEXT` 文本
- `IMAGE` 图片（上传与预览）
- `FILE` 文件（上传与下载）
- `DATE` 日期时间
- `SWITCH` 开关（true/false）
- `SELECT` 下拉选择（选项来源于参数备注）

实现：

- `sys_config` 新增 `config_value_type` 字段，默认 `TEXT`
- 后端 `SysConfig`/Mapper/Service 与 APP 配置保存链路支持该字段
- 后台参数管理页新增“参数类型”查询与编辑，参数值输入控件按类型自动切换
- `SELECT` 类型约定用 `remark` 存选项，支持逗号/分号/换行分隔，支持 `值:文案` 或 `值=文案`
- APP 配置管理页同步复用参数类型渲染与保存，避免仅按值猜测类型
- 参数值 `config_value` 容量扩展为 `varchar(2000)`，用于存储较长合同文本

脚本与文件：

- [config_value_type_20260504.sql](../sql/config_value_type_20260504.sql)
- [config_value_len_2000_20260504.sql](../sql/config_value_len_2000_20260504.sql)
- [SysConfig.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysConfig.java)
- [SysConfigMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysConfigMapper.xml)
- [SysConfigServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysConfigServiceImpl.java)
- [AppConfigController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java)
- [index.vue](../ruoyi-ui/src/views/system/config/index.vue)
- [index.vue](../ruoyi-ui/src/views/system/appConfig/index.vue)

## 22. 投资合同公章改为后台图片参数

新增 APP 配置参数用于合同公章：

- `app.htimg1`
- `app.htimg2`

APP 端认购合同弹窗公章展示规则：

- 优先读取 `app.htimg1/app.htimg2` 并渲染（支持相对路径自动补全）
- 两张图都为空时，兜底使用本地默认公章图

涉及文件：

- [app_config_api.dart](../app/lib/request/app_config_api.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

## 23. 产品交易规则内容配置

产品后台新增“交易规则内容”字段，支持在新增/编辑时按多行维护规则文案；APP 产品详情“交易规则”区按行渲染该内容到规则卡片中。

- 后台未配置时，APP 继续使用原有收益公式文案作为兜底
- 后台配置后，APP 优先显示配置内容（每行一条）

涉及文件：

- [SysInvestProduct.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysInvestProduct.java)
- [SysInvestProductMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestProductMapper.xml)
- [AppInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestProductController.java)
- [index.vue](../ruoyi-ui/src/views/operation/investProduct/index.vue)
- [invest_product_api.dart](../app/lib/request/invest_product_api.dart)
- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [invest_product_trade_rule_20260504.sql](../sql/invest_product_trade_rule_20260504.sql)

## 24. 产品投资模式升级（按金额/按份额）

产品新增双模式：

- `SHARE`：按份额配置，后台维护总份数
- `AMOUNT`：按金额配置，后台维护总金额

数据模型补充：

- `invest_mode`（投资模式）
- `total_amount`（总金额）
- `sold_amount`（已售金额）

核心规则：

- 进度统一按金额优先计算：`sold_amount / total_amount * 100`（金额为空时兼容份额）
- 按份额模式下，后台校验“最高可投”必须是“起投金额”的整数倍
- 按份额模式下，`total_amount/sold_amount` 按 `份数 * 起投金额` 自动换算
- 认购成功后同时更新 `sold_shares` 与 `sold_amount`

APP 联动：

- 产品详情按模式展示：
- 按金额：剩余金额=`总金额-已投金额`，详情不显示总份数，仅显示金额项
- 按份额：保持原份额展示（总份数/已投份数/剩余份数）
- 认购页按份额模式增加“购买份数 +/-”，金额自动计算并禁止手工输入

涉及文件与脚本：

- [SysInvestProduct.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysInvestProduct.java)
- [SysInvestProductMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestProductMapper.xml)
- [SysInvestProductServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestProductServiceImpl.java)
- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)
- [AppInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestProductController.java)
- [index.vue](../ruoyi-ui/src/views/operation/investProduct/index.vue)
- [invest_product_api.dart](../app/lib/request/invest_product_api.dart)
- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [invest_order_api.dart](../app/lib/request/invest_order_api.dart)
- [invest_product_mode_amount_20260504.sql](../sql/invest_product_mode_amount_20260504.sql)

## 25. 后台产品复制功能

后台产品管理新增“复制”操作：按当前产品复制一条新产品数据，同时重置销售进度相关字段。

- 复制后 `sold_shares` 强制为 `0`
- 复制后 `progress_percent` 强制为 `0`（入库按 `sold_shares/total_shares` 自动计算）
- 复制保留原标签关系、产品介绍、交易规则内容等配置
- 复制新产品自动生成新的 `product_code`，避免唯一键冲突

涉及文件：

- [ISysInvestProductService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysInvestProductService.java)
- [SysInvestProductServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestProductServiceImpl.java)
- [SysInvestProductController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysInvestProductController.java)
- [investProduct.js](../ruoyi-ui/src/api/operation/investProduct.js)
- [index.vue](../ruoyi-ui/src/views/operation/investProduct/index.vue)

## 26. APP 签名组件工具化

为避免签名逻辑在各页面重复实现，已将签名能力封装为统一工具组件。

- 新增 `SignatureTool.show(context)`，统一打开签名页并返回 `base64` 签名图
- 签名板支持鼠标/触摸/手写笔指针事件（按下、移动、抬起）
- 投资认购合同页已改为调用工具类，不再内嵌签名画板代码

涉及文件：

- [signature_tool.dart](../app/lib/tools/signature_tool.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

## 27. 产品认购支付密码前置校验

产品认购页在输入支付密码和提交前，新增“支付密码是否已设置”前置校验流程。

- 点击支付密码输入框前先检查 `payPasswordSet`
- 未设置时跳转支付密码设置页，设置完成后自动返回认购页继续流程
- 提交前再次兜底校验，避免绕过输入步骤直接提交

涉及文件：

- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [auth_api.dart](../app/lib/request/auth_api.dart)
- [app_router.dart](../app/lib/routers/app_router.dart)

## 28. 余额宝购买支付密码验证闭环

余额宝购买流程已升级为“确认购买 -> 支付密码输入 -> 后台校验通过后购买”。

- 前端购买前弹确认框，随后检查是否已设置支付密码
- 未设置时跳转支付密码设置页，设置成功后返回继续购买
- 使用统一数字键盘输入支付密码，并随购买请求提交 `payPwd`
- 后端 `/app/yebao/purchase` 增加支付密码校验：未设置或密码错误直接拦截

涉及文件：

- [yebao_page.dart](../app/lib/pages/mine/yebao_page.dart)
- [yebao_api.dart](../app/lib/request/yebao_api.dart)
- [AppYebaoController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppYebaoController.java)

## 29. 产品积分/成长值计算口径预留（按金额模式）

为兼容产品“按份额/按金额”双模式，预留如下统一计算口径（本节先做规则沉淀，后续再按此实现代码）：

- 产品配置项保留“每份积分”“每份成长值”。
- `SHARE` 模式：按用户认购份数直接计算积分和成长值。
- `AMOUNT` 模式：
  - 先用 `最高可投 / 最低起投` 计算倍数；
  - 再用 `总金额 / 倍数` 计算单份投资金额；
  - 再用 `用户投资金额 / 单份投资金额` 换算投资份数；
  - 最后按换算份数 × 每份积分 / 每份成长值，得到本次应发积分和成长值。

补充约束（实现时必须遵守）：

- 计算过程需统一金额精度与舍入规则，避免前后端口径不一致。
- 倍数、单份金额、换算份数在边界值（0、空值、除数为0）时必须有兜底保护。
- 最终积分和成长值必须通过统一奖励/成长值服务入账，不允许在业务代码中分散直接写库。

## 30. 后台 Google 二次验证（敏感操作）

### 30.1 模块目标

为后台敏感操作增加 Google Authenticator 动态码校验能力，避免仅依赖登录态导致高风险操作被误执行。

### 30.2 绑定流程（个人中心）

- 管理员在“个人中心 -> Google验证”发起绑定
- 后端生成临时 `secret` 与 `otpauth`，并返回二维码 `qrImageBase64`
- 管理员扫码后输入 6 位动态码确认绑定
- 绑定信息写入 `sys_user_google_auth`

接口：

```http
GET  /system/user/profile/google2fa/status
POST /system/user/profile/google2fa/init
POST /system/user/profile/google2fa/bind
POST /system/user/profile/google2fa/unbind
```

### 30.3 敏感操作统一校验（注解+AOP）

新增注解 `@GoogleVerifyRequired` 与切面 `GoogleVerifyAspect`，统一提取请求中的 `googleCode` 并执行校验。

当前已接入：

- 提现审核：`PUT /system/withdraw`
- 实名审核：`PUT /system/realNameAuth`
- 投资赎回：`POST /system/invest/order/redeem`

前端在提交上述操作前必须弹窗输入 6 位 Google 动态码，并随请求体携带 `googleCode`。

### 30.4 关键文件

- [GoogleVerifyRequired.java](../ruoyi-common/src/main/java/com/ruoyi/common/annotation/GoogleVerifyRequired.java)
- [GoogleVerifyAspect.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/GoogleVerifyAspect.java)
- [GoogleTotpUtils.java](../ruoyi-common/src/main/java/com/ruoyi/common/utils/security/GoogleTotpUtils.java)
- [SysGoogleAuthServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysGoogleAuthServiceImpl.java)
- [SysProfileController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java)
- [googleAuth.vue](../ruoyi-ui/src/views/system/user/profile/googleAuth.vue)
- [upgrade_google_auth_202606.sql](../sql/upgrade_google_auth_202606.sql)

## 31. APP 投资收益明细（仅利息口径）

### 31.1 展示口径

- 收益明细页仅展示 `INTEREST`（利息）计划，不展示 `PRINCIPAL`（本金）计划。
- 顶部汇总改为“已收利息 / 待收利息”（按币种分开），不再展示“本息合计”。

### 31.2 明细卡片字段

- 每条记录显示：
  - 产品名称
  - 订单号
  - 状态（已收取 / 未收取 / 待收取 / 已取消）
  - 收取时间（已收取显示实际收取时间，未收取显示预计收取时间）
  - 利息金额 + 币种

### 31.3 状态判定

- `status = 1`：已收取
- `status = 0` 且 `plan_time > now`：未收取（未到期）
- `status = 0` 且 `plan_time <= now`：待收取（已到期待结算）
- `status = 2`：已取消（如赎回后取消计划）

### 31.4 关键文件

- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)
- [invest_order_api.dart](../app/lib/request/invest_order_api.dart)
- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)

## 32. APP 投资扣款与本金口径

### 32.1 下单扣款规则

- APP 投资下单前，前端需先按产品币种匹配用户钱包并做余额预校验，余额不足直接拦截。
- 后端下单时再次按币种钱包加锁校验余额并扣减，防止绕过前端校验。
- 钱包币种映射统一：`USDT -> USD`，其余按 `CNY/USD` 处理。

### 32.2 订单本金口径

- 投资订单中的 `invest_amount` 作为“实际扣款本金”口径。
- 订单收益计划（利息与返本）、产品已售金额统计、钱包投资金额累计，统一使用该本金口径。
- 用户累计投资字段写入同样按该实际扣款金额折算 CNY 后更新。

### 32.3 赎回回退累计投资

- 后台执行赎回时，除返还钱包本金外，必须同步回退用户累计投资字段（按币种折算 CNY）。
- 赎回回退不影响已结算收益；仅对本金维度进行回退。

### 32.4 关键文件

- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)
- [SysInvestOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestOrderServiceImpl.java)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

## 33. APP 我的投资页面重构

### 33.1 视觉风格统一

- “我的投资”页按 APP 整体暗色科技风重构，背景采用深色渐变 + 光晕层，AppBar 透明沉浸。
- 顶部新增订单概览面板（总订单/进行中/已结束），统一边框、圆角、阴影层级。
- Tab 区域改为独立深色胶囊容器，激活态保留发光下划线。

### 33.2 订单卡片重排

- 卡片信息层级重排：标题 + 状态、核心指标（单购利率/预期收益/期限/利率）、底部订单号与时间。
- 状态标签改为半透明底+描边，颜色跟随状态（进行中/已结束/已赎回）。
- 保留币种品牌图并在底部补充币种文本，增强币种识别一致性。

### 33.3 关键文件

- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)

### 33.4 统一卡片主题补充

- “我的投资”列表底部订单卡片已取消按币种分底色，统一为全局深色卡片主题（背景、边框、阴影一致）。
- 币种差异仅通过币种图标与文本体现，避免卡片主视觉割裂。
- “收益明细”列表卡片同样取消按币种分底色，统一为全局深色卡片主题，风格与“我的投资”保持一致。
- “收益明细”页面新增全局背景层（深色渐变 + 光晕），并启用透明 AppBar，整体风格与“我的投资/我的页面”统一。

## 34. APP 投资链路口径修正（资产与账变）

### 34.1 资产页总资产口径

- 资产页“总资产”改为钱包资产口径：`available + frozen + pending + profit`。
- 不再把 `totalInvest` 直接累加到总资产，避免投资时“可用减少、在投增加”导致总资产看起来不变化。

### 34.2 投资账变正负号

- 投资记录页金额符号按业务类型判定，而非按 `amount >= 0` 判定。
- `invest` 显示负号（扣款），`redeem/profit` 显示正号（入账）。

### 34.3 关键文件

- [assets_page.dart](../app/lib/pages/mine/assets_page.dart)
- [account_invest_records_page.dart](../app/lib/pages/mine/account_invest_records_page.dart)

## 35. 充值/提现人民币图标统一（银联）

### 35.1 规则

- APP 充值、提现页面中，人民币（CNY）相关入口与账户卡片统一使用 `unionpay.webp` 图标。
- USD/USDT 保持原币种图标不变。

### 35.2 实现方式

- `CurrencyBrandBadge` 新增 `useUnionPayForCny` 开关；开启后，非 USD 币种图标强制使用银联图。
- 在 `recharge_page.dart` 与 `withdraw_page.dart` 的人民币展示点统一开启该开关。

### 35.3 关键文件

- [currency_brand_badge.dart](../app/lib/widgets/currency_brand_badge.dart)
- [recharge_page.dart](../app/lib/pages/mine/recharge_page.dart)
- [withdraw_page.dart](../app/lib/pages/mine/withdraw_page.dart)

## 36. 产品认购页去除汇率展示

### 36.1 调整说明

- 产品认购页提示文案已移除固定“汇率”显示，避免在认购流程中出现与实时配置不一致的静态汇率信息。
- 保留“单笔最低 / 单笔最高 / 可投次数”等核心交易限制提示。

### 36.2 关键文件

- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

## 37. 收益明细卡片状态/币种图标布局优化

### 37.1 调整说明

- 收益明细卡片顶部状态保持与产品名同一行展示，并增加状态图标（已收取/已取消/待收取）提升识别度。
- 订单号改为“标签一行 + 值一行”，减少被右侧金额区域挤压导致的截断。
- 右侧金额区域固定显示币种图标与金额，保持币种识别一致。

### 37.2 关键文件

- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)

### 37.3 细节补充（卡片可读性）

- 状态标签已调整为与产品名同一行显示，避免视觉跳跃。
- “订单号”改为独立标题 + 下一行值，降低被右侧金额区域挤压导致的截断风险。
- 订单号新增复制按钮，点击后写入剪贴板并提示“订单号已复制”。

## 38. 资产详情文案调整（可投资金 -> 已投资金）

### 38.1 调整说明

- 资产中心“资产详情”中的字段文案 `assetsInvestable` 已统一改为“已投资金”，更贴合 `wallet.totalInvest` 的已投入语义。
- 英文文案同步从 `Investable` 调整为 `Invested`，中英文口径一致。

### 38.2 关键文件

- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)

## 39. APP 提现提交金额解析兜底

### 39.1 问题现象

- APP 提现提交出现后端提示“提现金额必须大于0”，但客户端已进入提交流程。

### 39.2 修复内容

- 后端 `AppWithdrawController.submit` 改为与充值接口一致的兼容解析模式：
- 支持 `data` 加密包解密后反序列化为 `SysUserWithdraw`。
- 支持明文字段兼容解析（`amount/withdrawAmount/money`、`currencyType`、`withdrawMethod`、`bankCardId`、`requestNo` 等）。
- 金额字符串解析时去除逗号，避免格式差异导致金额解析为 `null/0`。
- 前端提现提交前增加金额标准化：输入先去逗号，再按两位小数提交，避免异常格式导致金额失真。

### 39.3 关键文件

- [AppWithdrawController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppWithdrawController.java)
- [withdraw_page.dart](../app/lib/pages/mine/withdraw_page.dart)

## 40. 后台提现审核通过不写系统通知

### 40.1 调整说明

- 后台提现审核流程中，`审核通过` 分支不再写入 `sys_notice`（业务通知）。
- 资金处理逻辑保持不变：仍执行冻结金额扣除、钱包流水与状态更新。
- `审核拒绝` 分支维持原逻辑，仍可写拒绝通知。

### 40.2 关键文件

- [SysUserWithdrawServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWithdrawServiceImpl.java)

## 41. 投资成功写入团队统计并纳入夜间升级口径

### 41.1 调整目标

- 用户投资产品认购成功后，立即写入团队统计事件，保证团队计算链路有实时事件来源。
- 夜间团队重算与团队升级口径统一纳入 `sys_invest_order`，避免仅统计余额宝订单导致团队投资额偏小。

### 41.2 后端逻辑完善

- 在 `AppInvestOrderController.submit` 下单成功并拿到 `orderId` 后，调用 `teamStatService.recordInvestOrderEvent(...)` 写入团队投资事件。
- 团队统计服务新增 `recordInvestOrderEvent`，按当前统计层级将成员投资事件展开写入上级链路，且按 `biz_key` 做幂等防重。
- 夜间重算 `insertInvestEvents` 增加 `sys_invest_order` 来源（`event_type=INVEST`，`biz_key=IPO:{orderId}`）。
- 团队日快照 `team_total_invest` 改为“余额宝订单 + 投资产品订单”合并口径。
- 团队等级升级计算 `sumTeamInvestAmount` 同步改为“余额宝订单 + 投资产品订单”合并口径。

### 41.3 关键文件

- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)
- [ISysTeamStatService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysTeamStatService.java)
- [SysTeamStatServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamStatServiceImpl.java)
- [SysTeamStatMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamStatMapper.java)
- [SysTeamStatMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamStatMapper.xml)
- [SysTeamLevelMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamLevelMapper.xml)

### 41.4 赎回撤销补充

- 后台执行投资订单赎回时，新增撤销团队统计事件逻辑：按 `biz_key=IPO:{orderId}` 删除该订单对应 `INVEST` 团队事件，避免赎回后仍参与团队投资统计。
- 撤销动作与赎回资金处理处于同一事务链路，确保状态一致（订单改赎回、计划取消、团队事件撤销）。

补充涉及文件：

- [SysInvestOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestOrderServiceImpl.java)
- [ISysTeamStatService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysTeamStatService.java)
- [SysTeamStatServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamStatServiceImpl.java)
- [SysTeamStatMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamStatMapper.java)
- [SysTeamStatMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamStatMapper.xml)

### 41.5 余额宝团队逻辑开关补充

- 余额宝相关“团队升级/团队统计投资额”逻辑改为仅在 `app.yebao.levelBonusEnabled=true` 时生效。
- 当开关为 `false`（或缺省）时：
  - 夜间团队事件重算不写入余额宝投资事件；
  - 团队日快照 `team_total_invest` 不计入余额宝投资；
  - 团队升级判定投资额不计入余额宝投资。
- 投资产品订单（`sys_invest_order`）统计不受该开关影响，继续参与团队口径。

补充涉及文件：

- [SysTeamStatServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamStatServiceImpl.java)
- [SysTeamStatMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamStatMapper.java)
- [SysTeamStatMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamStatMapper.xml)
- [SysTeamLevelServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysTeamLevelServiceImpl.java)
- [SysTeamLevelMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysTeamLevelMapper.java)
- [SysTeamLevelMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysTeamLevelMapper.xml)

## 47. 钱包地址长度限制（前后端双重校验）

### 47.1 调整说明

- 添加 USD 钱包地址时，输入长度统一限制为最多 34 个字符，超过即拦截。
- 前端在输入框层面增加长度限制，并在提交时做二次校验提示。
- 后端服务层增加强校验，防止绕过前端直接提交超长钱包地址。
- 银行卡新增流程改为“弹窗只收集表单并返回结果，页面层再发起网络请求”，避免在弹窗销毁动画阶段仍引用输入控制器，修复 `TextEditingController was used after being disposed` 与相关 `_dependents.isEmpty` 崩溃链路。

### 47.2 关键文件

- [bank_card_page.dart](../app/lib/pages/mine/bank_card_page.dart)
- [SysUserBankCardServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserBankCardServiceImpl.java)
- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)

## 48. 真实姓名字段打通（实名审核/个人信息/银行卡/投资合同）

### 48.1 调整说明

- 用户表新增 `real_name` 字段，作为实名认证通过后的权威姓名来源。
- 后台审核实名认证通过时，自动将实名记录中的 `real_name` 回写到 `sys_user.real_name`，并同步实名状态。
- `getInfo` / APP 登录返回的用户对象补充 `realName`，前端用户模型同步接收并缓存。
- 个人信息页“基本信息”新增“真实姓名”只读展示。
- 添加人民币银行卡时，持卡人姓名改为自动使用 `realName` 且前端只读不可改；后端也强制覆盖为 `sys_user.real_name` 防篡改。
- 投资产品合同预览与签约文本中的投资方姓名统一优先使用 `realName`（为空时才回退旧值）。

### 48.2 关键文件

- [user_real_name_20260504.sql](../sql/user_real_name_20260504.sql)
- [SysUser.java](../ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUser.java)
- [SysUserMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java)
- [SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)
- [ISysUserService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java)
- [SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [SysAppRealNameAuthServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysAppRealNameAuthServiceImpl.java)
- [SysLoginService.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java)
- [auth_api.dart](../app/lib/request/auth_api.dart)
- [profile_page.dart](../app/lib/pages/mine/profile_page.dart)
- [bank_card_page.dart](../app/lib/pages/mine/bank_card_page.dart)
- [SysUserBankCardServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserBankCardServiceImpl.java)
- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)
- [invest_order_api.dart](../app/lib/request/invest_order_api.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)

## 49. 实名重审入口与审核通过通知收口

### 49.1 调整说明

- 后台实名认证页面 `system/realNameAuth/index` 新增“重新审核”按钮（仅对非待审核状态显示）。
- 点击“重新审核”后，要求输入 Google 验证码，并将当前记录状态重置为 `待审核(status=0)`，用于历史已实名用户的重新审核流程。
- 保持提现审核通过不写 `sys_notice`（此前已处理）。
- 进一步收口“审核通过”通知：充值审核通过不再写入 `sys_notice`，仅保留审核拒绝提醒。

### 49.2 关键文件

- [index.vue](../ruoyi-ui/src/views/system/realNameAuth/index.vue)
- [SysUserRechargeServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserRechargeServiceImpl.java)

## 50. 实名审核 Google 验证范围调整

### 50.1 调整说明

- 实名认证“通过/拒绝”审核流程不再要求 Google 验证码。
- 仅“重新审核（重置为待审核，status=0）”时要求 Google 验证码。
- 后端接口按状态做强校验：`status=0` 且 `googleCode` 为空时直接返回错误，避免前端绕过。
- 后台页面同步交互：通过/拒绝操作去掉 Google 验证弹窗；重新审核保留验证码弹窗。

### 50.2 关键文件

- [SysAppRealNameAuthController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysAppRealNameAuthController.java)
- [index.vue](../ruoyi-ui/src/views/system/realNameAuth/index.vue)

## 51. 矿机兑换账变显示修正

### 51.1 调整说明

- 矿机 WAG 兑换入账写钱包账变时，类型由 `other` 调整为 `exchange_in`，确保 APP 账变记录按“进账(+)”展示。
- 账变备注统一为 `WAG兑换`。

### 51.2 关键文件

- [SysMinerAppServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysMinerAppServiceImpl.java)

## 52. 产品详情有效期按开始/结束分行展示

### 52.1 调整说明

- APP 产品详情页中，“产品有效期”改为仅在配置了开始/结束时间时显示。
- 展示形式改为换行：
- 第一行：`产品开放时间  {startTime}`
- 第二行：`产品结束时间  {endTime}`
- 当开始时间和结束时间都为空时，整块不显示。

### 52.2 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)

## 53. 提现冻结账变类型与负号显示修正

### 53.1 调整说明

- 提现提交冻结金额时，钱包账变类型由 `frozen` 调整为 `提现冻结`。
- APP“所有账变”金额展示改为对账变金额取绝对值后再拼接 `+/-`，避免后端负数金额叠加前端负号导致 `--` 显示。

### 53.2 关键文件

- [SysUserWithdrawServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserWithdrawServiceImpl.java)
- [account_all_records_page.dart](../app/lib/pages/mine/account_all_records_page.dart)

## 54. APP配置新增真实拼团开关

### 54.1 调整说明

- 新增 APP 参数 `app.invest.realGroupEnabled`（开关，默认 `false`），用于控制是否启用真实拼团下单链路。
- Flutter 端 App 启动配置模型新增该字段并写入缓存，前端可通过 `AppBootstrapTool.config` 直接读取。
- 产品详情页下单路由增加双条件：仅当“产品支持拼团 + 真实拼团开关开启”时进入拼团下单，否则进入普通下单。
- 补充 SQL 脚本用于在线库增量写入该参数（含幂等更新）。

### 54.2 关键文件

- [app_config_api.dart](../app/lib/request/app_config_api.dart)
- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [app_config_manage_page.dart](../app/lib/pages/settings/app_config_manage_page.dart)
- [app_real_group_enabled_20260504.sql](../sql/app_real_group_enabled_20260504.sql)
- [ry_20260417.sql](../sql/ry_20260417.sql)

## 55. 真实拼团流程落地（开团/参团/超时失败退款）

### 55.1 调整说明

- 当 `app.invest.realGroupEnabled=false` 时，继续沿用原有认购流程（兼容历史逻辑）。
- 当开关为 `true` 且产品启用拼团时，下单进入真实拼团分支：
- 支持“发起拼团（未传团号）/参团（传 groupNo）”。
- 下单写入 `group_id/group_no/group_status/group_deadline_time`，并回传给 APP。
- 拼团达标后自动把同团订单状态从“拼团中”更新为“已成团”。
- 定时任务执行前先处理超时拼团：未达标自动失败，批量取消未执行计划并退回本金，回滚产品销量与用户累计投资，写入钱包账变 `invest_group_refund`。
- APP订单列表新增拼团字段返回：`groupMode/groupId/groupNo/groupStatus/groupDeadlineTime/groupCountdownSeconds`，前端已接收并展示“拼团状态/团号”。

### 55.2 关键文件

- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)
- [SysAppInvestOrderMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysAppInvestOrderMapper.java)
- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)
- [SysInvestOrderServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysInvestOrderServiceImpl.java)
- [ISysInvestOrderService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysInvestOrderService.java)
- [InvestOrderTask.java](../ruoyi-quartz/src/main/java/com/ruoyi/quartz/task/InvestOrderTask.java)
- [SysInvestProductMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysInvestProductMapper.java)
- [SysInvestProductMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysInvestProductMapper.xml)
- [invest_order_api.dart](../app/lib/request/invest_order_api.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)
- [invest_real_group_20260504.sql](../sql/invest_real_group_20260504.sql)

## 56. APP配置页面开关控件交互优化

### 56.1 调整说明

- 后台 `system/appConfig` 页面中，开关类配置项不再使用下拉选择。
- 开关类编辑控件改为左右切换开关（`el-switch`），直接展示“开启/关闭”状态并支持一键切换。

### 56.2 关键文件

- [index.vue](../ruoyi-ui/src/views/system/appConfig/index.vue)

## 57. APP配置保存 selectOne 异常修复

### 57.1 问题现象

- 后台 `system/appConfig` 保存时报错：`Expected one result (or null) to be returned by selectOne(), but found: 2`。
- 根因是 `sys_config` 存在重复 `config_key`，而保存链路按单条查询读取配置，触发 MyBatis `selectOne` 异常。

### 57.2 修复内容

- `SysConfigMapper.selectConfig` 查询改为 `order by config_id desc limit 1`，重复 key 场景下优先取最新记录，避免保存接口直接报错。
- 新增 SQL 修复脚本，先按 `config_id` 清理重复 `config_key`，再补 `uk_sys_config_key(config_key)` 唯一索引防止复发。

### 57.3 关键文件

- [SysConfigMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysConfigMapper.xml)
- [sys_config_deduplicate_key_20260505.sql](../sql/sys_config_deduplicate_key_20260505.sql)

## 58. 产品详情页拼团利率展示口径统一

### 58.1 调整说明

- APP 产品详情页在拼团产品（`groupEnabled=true`）场景下，利率展示由“单购利率”切换为“拼团利率”，并显示 `groupRate`。
- 该口径同时应用在顶部大数字区域与“产品详情”TAB中的利率字段，避免同页出现两套利率。
- 收益计算 TAB 的默认公式也改为沿用同一展示利率口径（拼团产品用拼团利率，普通产品用单购利率）。
- 拼团产品场景补充保留“单购利率”展示：顶部利率区增加次级文案，详情 TAB 追加“单购利率”字段，确保两种利率同时可见。

### 58.2 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)

## 59. 拼团下单 insertInvestGroup 主键回填异常修复

### 59.1 问题现象

- APP 拼团下单调用 `/app/invest/order/submit` 报错：`Could not determine which parameter to assign generated keys to`。
- 原因是 `SysAppInvestOrderMapper.xml` 的 `insertInvestGroup` 配置了 `useGeneratedKeys/keyProperty=groupId`，但该 Mapper 方法是多参数 `@Param` 形式，且实际流程并不依赖该回填值，导致 MyBatis 参数映射冲突。

### 59.2 修复内容

- 移除 `insertInvestGroup` 的 `useGeneratedKeys/keyProperty` 配置。
- 保持现有逻辑：插入成功后通过 `groupNo` 查询 `groupId`（`selectInvestGroupIdByNo`）继续后续流程。

### 59.3 关键文件

- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)

## 60. 我的拼团入口与页面完善

### 60.1 调整说明

- 投资认购提交逻辑进一步显式化：输入团号时按参团提交；未输入团号时按系统自动开团提交。
- 我的页面快捷入口文案调整：
- `优惠券` 改为 `我的拼团`，并接入实际页面路由；
- `等级体验券` 改为 `优惠体验`（当前仍保留原占位能力）。
- 新增“我的拼团”页面，用于聚合展示当前用户全部拼团记录（从投资订单中筛选拼团单）。
- 页面支持展示团号、拼团状态、剩余成团时间，并提供“复制团号/复制分享文案”以便对外分享。

### 60.2 关键文件

- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [my_group_page.dart](../app/lib/pages/mine/my_group_page.dart)
- [app_router.dart](../app/lib/routers/app_router.dart)
- [main_page.dart](../app/lib/pages/main/main_page.dart)
- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)

## 61. 拼团下单时间类型兼容修复

### 61.1 问题现象

- 拼团下单 `/app/invest/order/submit` 在成团流程报错：`class java.time.LocalDateTime cannot be cast to class java.util.Date`。
- 触发点为读取拼团表 `deadline_time` 时直接强转 `Date`。

### 61.2 修复内容

- `AppInvestOrderController` 增加 `toDate(Object)` 兼容转换，支持 `Date / LocalDateTime / LocalDate`。
- 参团与开团后读取截止时间统一改为 `toDate(...)`，避免 JDBC 驱动返回 `LocalDateTime` 时的类型转换异常。

### 61.3 关键文件

- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)

## 62. 产品与投资页面提醒样式统一

### 62.1 调整说明

- 按“我的页面”口径统一提醒样式：产品页与投资相关页 `SnackBar` 背景统一改为黄色 `#FFA500`。

### 62.2 覆盖范围

- 产品详情页下单拦截提醒。
- 投资认购页的校验提示与签约弹窗签名提示。
- 我的投资收益页复制订单号提示。
- 我的拼团页复制团号与分享文案提示。

### 62.3 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)
- [my_group_page.dart](../app/lib/pages/mine/my_group_page.dart)

## 63. 提醒颜色按成功态区分

### 63.1 规则调整

- 产品与投资相关页面提醒继续保持“默认黄色”。
- 成功态提醒统一为绿色（`#38FFB3`），非成功态保持黄色（`#FFA500`）。

### 63.2 已应用点位

- 投资认购页：`签约并提交成功` 改为绿色，其余校验/失败提醒保持黄色。
- 我的拼团页：`复制团号/复制分享文案` 成功提示改为绿色。
- 我的投资收益页：`订单号已复制` 成功提示改为绿色。

### 63.3 关键文件

- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [my_group_page.dart](../app/lib/pages/mine/my_group_page.dart)
- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)

## 64. 我的拼团倒计时组件化

### 64.1 调整说明

- 新增通用倒计时控件 `CountdownText`，支持传入初始秒数并按 1 秒粒度自动递减。
- 控件支持前缀文案、结束文案、样式与结束回调，便于后续页面复用。
- 我的拼团页面对“拼团中”记录改为进入页面即开始倒计时显示，不再只展示静态剩余秒数字符串。

### 64.2 关键文件

- [countdown_text.dart](../app/lib/widgets/countdown_text.dart)
- [my_group_page.dart](../app/lib/pages/mine/my_group_page.dart)

## 65. 我的投资页拼团状态与倒计时优化

### 65.1 调整说明

- 我的投资列表中，订单为拼团且团状态为进行中时，右上角订单状态由“进行中”改为“拼团中”。
- 列表详情中“拼团状态”“拼团团号”值字体各下调 1 号，减少换行风险。
- 拼团进行中新增“剩余成团时间”行，改为复用 `CountdownText` 组件实时倒计时显示。

### 65.2 关键文件

- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)

## 66. 待拼团收益不展示与结算拦截

### 66.1 业务规则

- 拼团未成团（`group_mode=1` 且 `group_status!=1`）时，收益计划可先写入库，但不应在 APP 收益明细展示为“待收”。
- 定时收益结算也不应处理未成团拼团订单，避免成团前提前结算。
- 拼团失败仍沿用现有处理：取消未执行计划（`status=2`）并自动退款。

### 66.2 本次改动

- 收益明细日志查询：过滤掉“未成团拼团单”的待执行收益记录。
- 收益汇总查询（总览与按币种）：待收统计仅计入“非拼团或已成团拼团单”。
- 定时到期计划查询：仅选择“非拼团或已成团拼团单”进入结算。
- 我的投资页“拼团团号”字体再下调为比原值小 2 号，降低换行概率。

### 66.3 关键文件

- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)
- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)

### 66.4 启动解析异常修复

- 修复 MyBatis XML 解析错误：在 mapper SQL 条件中补齐 `<>` 的 XML 转义（`&lt;&gt;`），避免 `SqlSessionFactory` 启动时报 SAX 解析异常。

### 66.5 我的投资文案微调

- 我的投资页拼团倒计时标题文案由“剩余成团时间”调整为“待成团时间”。

## 67. 产品详情页标签间距压缩

### 67.1 调整说明

- 产品详情页“产品详情 / 收益计算”两个标签之间的横向间距进一步压缩至最小可用值，减少左右留白。

### 67.2 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)

## 68. 拼团自动匹配与自拼团限制

### 68.1 业务规则

- 当用户提交拼团订单且未填写团号时：系统优先自动匹配“同产品、进行中、未满员、未超时、且非本人发起”的可参团记录。
- 若无可匹配团：系统再自动创建新团并返回新团号。
- 当用户填写团号参团时：新增“不能参与自己发起的拼团”校验，防止自拼团。

### 68.2 技术实现

- Mapper 新增 `selectAutoJoinableGroupForUpdate`，按成团优先策略排序（成员数多优先，其次截止时间早优先）并加行级锁。
- 控制器 `submit` 的无团号分支改为“先匹配后开团”。
- 控制器 `submit` 的有团号分支增加发起人校验，命中本人发起团时直接拒绝。

### 68.3 关键文件

- [SysAppInvestOrderMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysAppInvestOrderMapper.java)
- [SysAppInvestOrderMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysAppInvestOrderMapper.xml)
- [AppInvestOrderController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppInvestOrderController.java)

## 69. 首页改版与APP广告管理

### 69.1 APP首页样式与内容

- 新增首页独立页面 `HomeTabPage`，替换原首页占位页，采用深色金融风格布局：
  - 顶部品牌区（`mlogo.webp`）；
  - 快捷入口（充值/提现/领矿/推广/邀请）；
  - 核心视觉区（`mylogo1.webp` + 标语）；
  - 二级功能宫格、公告栏、产品推荐卡、最新资讯区。
- 首页 Banner 默认优先使用本地两张占位图：
  - `assets/images/home-banner.webp`
  - `assets/images/home-banner2.webp`
- 同时支持后台配置远程 Banner 覆盖；未配置时自动回落本地默认图。

### 69.2 APP广告管理（后台）

- 新增后台页面 `system/appAd/index`，命名“APP广告管理”，用于上传和维护 APP 首页 Banner/广告：
  - 广告类型：`APP_HOME_BANNER`、`APP_HOME_AD`
  - 支持图片上传、标题、排序、状态、跳转链接（摘要字段）与内容编辑。
- 复用现有 `sys_news_article` 存储与 `system/news/article` 接口能力，避免新增表与重复接口维护。
- 新增 SQL 初始化脚本：
  - 初始化广告分类：`APP_HOME_BANNER`、`APP_HOME_AD`
  - 新增后台菜单：内容管理 -> APP广告管理

### 69.3 关键文件

- [home_tab_page.dart](../app/lib/pages/main/home_tab_page.dart)
- [main_page.dart](../app/lib/pages/main/main_page.dart)
- [app_images.dart](../app/lib/config/app_images.dart)
- [appAd.js](../ruoyi-ui/src/api/system/appAd.js)
- [index.vue](../ruoyi-ui/src/views/system/appAd/index.vue)
- [app_ad_manage_20260505.sql](../sql/app_ad_manage_20260505.sql)

## 70. APP图标替换（Android/iOS）

### 70.1 替换说明

- 按 `app/ico` 目录中的新图标资源，完成 Android 与 iOS 的应用图标替换。
- Android 使用各密度图替换 `mipmap-*` 下 `ic_launcher.png`；其中 `mdpi` 缺少 48x48 原图，使用 60x60 高质量缩放生成 48x48 后写入。
- iOS 按 `AppIcon.appiconset` 既有命名规则，逐一替换所有 `Icon-App-*` 图标文件。

### 70.2 关键目录

- `app/ico`
- `app/android/app/src/main/res/mipmap-*/ic_launcher.png`
- `app/ios/Runner/Assets.xcassets/AppIcon.appiconset`

### 70.3 首页跳转详情参数修正

- 修复首页产品卡跳转产品详情页时参数不匹配问题：由错误的 `item` 对象传参改为 `productId` 传参，适配 `InvestProductDetailPage({required int productId})` 构造函数。
- 修复后可正常打开产品详情，不再触发 `missing_required_argument`。

## 71. 首页视觉统一优化

### 71.1 优化目标

- 在不改变首页布局结构与模块顺序的前提下，按 APP 现有深蓝科技风统一首页视觉样式。

### 71.2 优化内容

- 统一区块样式为“深蓝渐变玻璃卡片”（圆角、描边、阴影）并抽离通用装饰方法 `_panelDecoration`。
- 顶部品牌区、快捷入口、主视觉区、功能宫格、Banner 区、公告区、产品卡、资讯区全部套用一致风格。
- 调整首页核心字号与对比度，避免过大字体导致的信息拥挤，提升整体可读性与一致性。
- 保持原有交互与数据逻辑不变，仅做 UI 与样式层优化。

### 71.3 关键文件

- [home_tab_page.dart](../app/lib/pages/main/home_tab_page.dart)

### 71.4 首页色调对齐“我的页面”

- 将首页整体背景渐变改为与“我的页面”一致的深色青蓝系（`0xFF0A1220 -> 0xFF0D1B2A -> 0xFF14233A`）。
- 各模块卡片统一采用“我的页面”同系卡片底色与边框高光（`0xCC101C30`、`0x334CE3FF`）及阴影强度。
- 快捷入口、功能图标、公告条、产品卡、资讯卡颜色同步收敛，去除偏紫高饱和蓝，统一为青蓝科技风。

### 71.5 首页背景氛围层同步

- 首页在保持原布局不变的前提下，新增与“我的页面”同系发光背景层（顶部/底部/中部光晕球），强化整体氛围一致性。
- 背景层仅做视觉增强，不影响列表滚动与交互逻辑。

### 71.6 同功能图标与色彩统一

- 首页中与“我的页面”重复的功能入口，统一采用同一图标与色彩映射（同功能=同图标=同主色）。
- 统一范围包括：充值、提现、每日签到、我的资产、我的团队、实名认证、余额宝、邀请好友等。
- 首页快捷入口与宫格入口均改为读取同一按钮配置（图标 + 主色）渲染，避免后续样式漂移。

### 71.7 按钮视觉效果统一

- 首页快捷入口按钮与功能宫格按钮统一为同款“圆形发光图标”效果（同透明度渐变、同阴影、同图标尺寸）。
- 按钮文案样式统一为与“我的页面”一致的小字号与色值，确保按钮感受一致。
- 抽离 `_buildGlowCircleIcon` 作为统一图标效果渲染入口，避免不同区域按钮效果分叉。

## 72. 我的节点页面UI同风格优化

### 72.1 视觉统一

- “我的节点”页面按首页/我的页面统一为深色青蓝科技风：背景渐变、发光氛围层、卡片玻璃化样式。
- 页面卡片统一使用同系描边与阴影参数，弱化原先偏黑背景与蓝紫色差异。

### 72.2 组件统一

- 顶部统计卡、节点详情卡、快捷入口卡统一使用 `_panelDecoration`。
- 快捷入口按钮改为与首页一致的“圆形发光图标 + 同级文字样式”。
- 底部主操作按钮统一为青/绿渐变并补充同系阴影。

### 72.3 交互提示统一

- 节点未领取与不可兑换提示改为黄色背景提醒，保持与项目其他页面一致的“非成功提示色”规范。

### 72.4 关键文件

- [miner_page.dart](../app/lib/pages/mine/miner_page.dart)

## 73. 产品页UI同风格优化

### 73.1 页面风格统一

- 产品列表页整体视觉切换到与首页/我的页面一致的青蓝科技风（背景渐变 + 发光氛围层）。
- 统一列表区域内搜索框、分类标签、产品卡片、投资按钮的卡片化风格与描边阴影规则。

### 73.2 卡片与控件优化

- 搜索框与产品卡采用同系玻璃卡片底色（`0xCC101C30`、`0xCC0E1A2D`）与高光边框（`0x334CE3FF`）。
- 分类标签选中态与未选中态统一到同一套青蓝交互规范，字号与可读性同步优化。
- 产品卡内部标签、币种徽标、利率文案与“投资”按钮配色收敛，减少高饱和杂色，增强一致性。

### 73.3 技术实现

- 新增 `_panelDecoration` 与 `_blurBall` 样式方法，作为产品页统一视觉基类。
- 保持原有业务逻辑、数据过滤、下单跳转与接口调用不变，仅调整 UI 样式层。

### 73.4 关键文件

- [invest_product_list_page.dart](../app/lib/pages/product/invest_product_list_page.dart)

## 74. 产品详情页UI同风格优化

### 74.1 页面风格统一

- 产品详情页背景统一为与首页/我的页面一致的青蓝深色渐变，并增加发光氛围层。
- 顶部产品信息卡、详情TAB、收益TAB全部切换为同系玻璃卡片样式（统一描边与阴影）。

### 74.2 组件风格优化

- 标签（风险/起投）改为同系半透明标签样式，替换高饱和红色块。
- TAB 选中态统一为青蓝描边高亮，未选中态保留弱描边，视觉与产品列表页一致。
- 底部“下单”主按钮改为同系青色按钮风格，保持项目主行动按钮一致性。

### 74.3 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)

### 74.4 下单按钮与图层透明度微调

- 产品详情页底部“下单”按钮改为亮青色大圆角实心样式（左右渐变 + 轻发光阴影 + 深色粗体文案），提升主行动按钮识别度。
- 页面卡片层透明度进一步降低（更接近实色，仅保留少量透明）：主卡片底色由 `0xCC` 提升到 `0xF2`，内部信息块透明层同步收敛。

## 75. 产品列表页透明度同步

### 75.1 调整说明

- 产品列表页图层透明度同步到与产品详情页一致：卡片层更接近实色，仅保留少量透明感。
- 列表页统一卡片基底透明度由 `0xCC` 提升到 `0xF2`，同时标签底色透明度同步收敛。

### 75.2 关键文件

- [invest_product_list_page.dart](../app/lib/pages/product/invest_product_list_page.dart)

### 75.3 可读性增强微调

- 产品列表页卡片透明度继续收敛为近不透明（主卡片层改为 `0xFF`），提升正文与指标可读性。
- 顶部分类导航标签未选中态文字改为白色，提高暗背景下识别度。
- 风险标签红色增强（改为更高饱和红），避免提示色偏灰导致辨识不足。

### 75.4 详情页风险提示同步

- 产品详情页风险标签同步使用与产品列表一致的高饱和红色样式，确保风险提示在列表与详情之间视觉一致。

### 75.5 列表页完全不透明化

- 产品列表页卡片与分类标签图层改为不透明实色渲染，移除半透明底色对正文可读性的影响。
- 投资按钮底色改为实色填充，并统一白色文案提升暗背景下对比度。
- 卡片边框由半透明描边改为不透明描边，保证深色底图下轮廓稳定可见。

## 76. APP广告新增分类ID兜底修复

- 修复后台 `content/appAd` 新增广告时报错 `category_id doesn't have a default value`。
- 在新闻文章服务保存链路增加分类ID兜底：当仅传 `categoryCode` 且 `categoryId` 为空时，后端自动按分类编码查询并回填 `categoryId`。
- 新增分类 Mapper 按 `categoryCode` 查询能力，避免前端漏传 `categoryId` 时插入失败。

## 77. 首页聚合接口与运营位联动

### 77.1 首页聚合接口

- 新增 APP 首页聚合接口：`GET /app/news/home`，一次返回 `banners + ads + notices`。
- `banners` 读取分类 `APP_HOME_BANNER`，`ads` 读取分类 `APP_HOME_AD`，状态均为启用（`status='0'`）。
- `notices` 仅返回 `sys_notice.notice_type <= 2` 且启用状态的数据，供首页跑马灯展示。

### 77.2 缓存策略与失效

- 首页聚合结果使用 Redis 缓存键 `news:home:mix:v1`，默认缓存 10 分钟，减少首页重复读库压力。
- 后台新增/编辑/删除新闻文章（含 `content/appAd` Banner/广告管理）后，统一通过 `SysNewsArticleServiceImpl.clearCache()` 立即清理：
- 清理首页聚合缓存键 `news:home:mix:v1`。
- 清理文章缓存前缀 `news:article:*`，保证首页 Banner/广告与新闻内容同步生效。

### 77.3 APP首页展示行为

- 首页顶部图片位改为 Banner 数据驱动（支持自动轮播与点击跳转）。
- 首页广告位改为广告数据驱动（左右滑动展示）。
- 首页通知位改为纵向跑马灯切换，仅展示公告类型 `<=2` 的系统通知。

### 77.4 关键文件

- [AppNewsController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppNewsController.java)
- [SysNoticeMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysNoticeMapper.xml)
- [SysNewsArticleServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsArticleServiceImpl.java)
- [news_api.dart](../app/lib/request/news_api.dart)
- [home_tab_page.dart](../app/lib/pages/main/home_tab_page.dart)

## 78. 新闻分类类型隔离（NEWS 与 首页运营位）

### 78.1 变更目标

- 解决 `APP_HOME_BANNER/APP_HOME_AD` 分类混入新闻分类列表导致 APP 新闻页分类异常。
- `sys_news_category` 增加 `category_type` 字段，隔离新闻分类与运营位分类。
- APP 新闻分类接口仅返回 `category_type=NEWS`。

### 78.2 关键改动

- 后端实体与 Mapper 增加 `category_type` 字段读写与筛选能力。
- `/app/news/categories` 改为按 `status=0` 且 `category_type=NEWS` 返回分类。
- 后台新闻分类管理页新增“分类类型”筛选与编辑项（NEWS/BANNER/AD）。
- 新增数据库升级脚本并回填历史分类类型。

### 78.3 关键文件

- [SysNewsCategory.java](../ruoyi-system/src/main/java/com/ruoyi/system/domain/SysNewsCategory.java)
- [SysNewsCategoryMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysNewsCategoryMapper.xml)
- [SysNewsCategoryServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysNewsCategoryServiceImpl.java)
- [AppNewsController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/app/AppNewsController.java)
- [index.vue](../ruoyi-ui/src/views/system/news/category/index.vue)
- [news_category_type_20260505.sql](../sql/news_category_type_20260505.sql)

## 79. 产品系列与我的核心页面多语言补齐

### 79.1 变更目标

- 将产品系列页（列表/详情/认购）与“我的”核心页面统一改为多语言文案读取，避免英文环境出现中文硬编码。
- 与忘记密码页保持一致，统一使用 `AppLocalizations` + `i18n.t(...)`。

### 79.2 覆盖页面

- 产品系列：`invest_product_list_page.dart`、`invest_product_detail_page.dart`、`invest_purchase_page.dart`
- 我的核心页：`my_team_page.dart`、`my_invest_orders_page.dart`、`my_invest_income_page.dart`、`my_group_page.dart`
- 账变页：`account_all_records_page.dart`、`account_invest_records_page.dart`

### 79.3 关键改动

- 页面标题、按钮、空态、字段标签、状态文案、提示文案全部改为多语言键。
- 拼团文案（团号/状态/倒计时/复制分享）统一接入多语言键。
- 钱包账变类型映射文本改为多语言输出。
- `zh-CN.json` 与 `en-US.json` 新增并补齐相关键值。

### 79.4 关键文件

- [invest_product_list_page.dart](../app/lib/pages/product/invest_product_list_page.dart)
- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [invest_purchase_page.dart](../app/lib/pages/product/invest_purchase_page.dart)
- [my_team_page.dart](../app/lib/pages/mine/my_team_page.dart)
- [my_invest_orders_page.dart](../app/lib/pages/mine/my_invest_orders_page.dart)
- [my_invest_income_page.dart](../app/lib/pages/mine/my_invest_income_page.dart)
- [my_group_page.dart](../app/lib/pages/mine/my_group_page.dart)
- [account_all_records_page.dart](../app/lib/pages/mine/account_all_records_page.dart)
- [account_invest_records_page.dart](../app/lib/pages/mine/account_invest_records_page.dart)
- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)

## 80. 产品详情下单前等级校验

### 80.1 变更目标

- 产品详情页点击下单前，增加用户等级 vs 产品限购等级（limitLevel）校验。
- 当用户等级不足时拦截跳转，不进入认购页。

### 80.2 校验规则

- `limitLevel <= 0` 视为不限制等级。
- `limitLevel > 0` 时读取当前用户等级（优先 `userLevel`，为空/0 时回退 `level`）。
- 当前等级小于 `limitLevel` 时提示并阻断下单。
- 读取用户信息失败时提示暂时无法校验等级，请稍后重试。

### 80.3 关键文件

- [invest_product_detail_page.dart](../app/lib/pages/product/invest_product_detail_page.dart)
- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)


## 81. Web 图标替换为 ico 目录素材

### 81.1 变更目标

- 将 Flutter Web 端图标统一替换为 `app/ico` 目录下的素材。
- 保持 `manifest.json` 现有图标引用路径不变，仅替换文件内容。

### 81.2 替换明细

- `web/favicon.png` 使用 `ico/40x40.png`。
- `web/icons/Icon-192.png` 与 `web/icons/Icon-maskable-192.png` 使用 `ico/192x192.png`。
- `web/icons/Icon-512.png` 与 `web/icons/Icon-maskable-512.png` 由 `ico/1024x1024.png` 缩放生成 `512x512`。

### 81.3 关键文件

- [favicon.png](../app/web/favicon.png)
- [Icon-192.png](../app/web/icons/Icon-192.png)
- [Icon-maskable-192.png](../app/web/icons/Icon-maskable-192.png)
- [Icon-512.png](../app/web/icons/Icon-512.png)
- [Icon-maskable-512.png](../app/web/icons/Icon-maskable-512.png)
- [manifest.json](../app/web/manifest.json)


## 82. 线路选择页隐藏地址信息

### 82.1 变更目标

- 线路选择页面不再展示 `HTTP` 地址、域名或 IP 信息，降低被探测与攻击风险。

### 82.2 关键调整

- 线路卡片标题统一展示为线路 N，不展示配置中的原始主机名。
- 原 `HTTP: xxx` 展示位改为地址信息已隐藏。
- 保留测速与切换能力，不影响线路切换逻辑。

### 82.3 关键文件

- [line_page.dart](../app/lib/pages/line/line_page.dart)
- [zh-CN.json](../app/assets/i18n/zh-CN.json)
- [en-US.json](../app/assets/i18n/en-US.json)

## 83. 我的节点概览本地缓存策略

### 83.1 变更目标

- 我的节点页进入时先展示本地缓存，提升首屏响应速度。
- 后台再请求最新概览数据，成功后回写缓存并刷新页面。

### 83.2 缓存策略

- 新增 `miner.overview.cache.v1` 本地缓存键保存概览 JSON。
- 页面加载顺序：先读缓存渲染 -> 再拉接口刷新。
- 自动跳转领取节点仅基于最新接口结果判断，避免使用旧缓存误跳转。

### 83.3 关键文件

- [miner_api.dart](../app/lib/request/miner_api.dart)
- [miner_page.dart](../app/lib/pages/mine/miner_page.dart)

## 84. 首页推荐产品拼团利率展示

### 84.1 变更目标

- 首页推荐产品卡片中，若产品开启拼团则展示拼团利率；否则展示单购利率。

### 84.2 展示规则

- `groupEnabled=true`：显示 `groupRate`，标签使用拼团利率。
- `groupEnabled=false`：显示 `singleRate`，标签使用单购利率。

### 84.3 关键文件

- [home_tab_page.dart](../app/lib/pages/main/home_tab_page.dart)

## 85. Web端首页固定手机画幅显示

### 85.1 变更目标

- Web 端不再全屏拉伸显示，改为手机 APP 画幅居中展示。

### 85.2 展示规则

- 在 `index.html` 中创建固定 `390x844` 的 `#app-container` 手机容器。
- 使用 `flutter.js + _flutter.loader` 在初始化阶段通过 `hostElement` 直接挂载到容器，避免全屏拉伸与偏移。
- 页面整体居中显示，容器保持圆角与阴影外观。

### 85.3 关键文件

- [index.html](../app/web/index.html)


