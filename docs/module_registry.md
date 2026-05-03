# 功能模块永久文档

> 目的: 记录每个功能模块的前端、后端、API、缓存和构建依赖，避免后续修改单个模块时误伤已完成的模块。
>
> 使用方式:
> - 新增或修改模块前，先查本文件对应小节。
> - 涉及接口、字段、缓存、配置项时，优先同步更新这里。
> - 本文件作为长期维护说明，尽量保持和当前代码一致。

---

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

---

## 2. 待补充模块

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
